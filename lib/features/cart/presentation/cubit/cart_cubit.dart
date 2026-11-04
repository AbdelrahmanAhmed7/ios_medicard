import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_result.dart';
import '../../../../core/utils/api_error_parser.dart';
import '../../../../features/activity/domain/models/invoice_item.dart';
import '../../../../features/activity/domain/repositories/invoice_repository.dart';
import '../../../../features/family_members/data/models/family_member_model.dart';
import '../../../../features/family_members/domain/repository/family_members_repository.dart';
import '../../../../medicard_network/repository/medicard_network_repository.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/cart.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/provider_covered_service.dart';
import '../../domain/models/provider_option.dart';
import '../../domain/repository/cart_repository.dart';
import '../../domain/services/cart_sync_service.dart';
import 'cart_state.dart';

part 'cart_cubit_provider_assignment.dart';
part 'cart_cubit_sync.dart';
part 'cart_cubit_checkout.dart';
part 'cart_cubit_operations.dart';
part 'cart_cubit_invoices.dart';

/// Outcome of [CartCubit.reconcileUnknownInvoiceOutcome].
enum UnknownInvoiceResolution {
  /// Snapshot items are gone from the server cart: the invoice exists.
  created,

  /// Snapshot items are all still present: nothing was charged, retry safe.
  notCreated,

  /// Could not determine (read failed or nothing comparable): latch stays.
  stillUnknown,
}

class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;
  final InvoiceRepository _invoiceRepository;
  final FamilyMembersRepository _familyMembersRepository;
  final MedicardNetworkRepository _networkRepository;
  final CartSyncService _cartSyncService;
  final int? providerId;
  StreamSubscription<CartSyncEvent>? _cartSyncSubscription;
  Future<void>? _cartRefresh;
  var _cartRequestGeneration = 0;
  var _cartMutationGeneration = 0;
  var _branchRequestGeneration = 0;
  var _invoiceSubmissionInFlight = false;
  var _providerAssignmentInFlight = false;
  final _confirmedProviderAssignments = <int, CartItem>{};

  /// A successful assignment can precede the cart read model. Keep that
  /// confirmed choice while the same item is still returned without a provider.
  /// Removed items and explicit assignments to another provider stay authoritative.
  Cart _preserveConfirmedProviders(Cart cart) {
    final presentIds = cart.items.map((item) => item.cartItemId).toSet();
    _confirmedProviderAssignments.removeWhere(
      (id, _) => !presentIds.contains(id),
    );
    return Cart(
      items: cart.items.map((item) {
        final confirmed = _confirmedProviderAssignments[item.cartItemId];
        if (confirmed == null) return item;
        if (item.providerId != null &&
            item.providerId != confirmed.providerId) {
          _confirmedProviderAssignments.remove(item.cartItemId);
          return item;
        }
        final isUnassigned = item.providerId == null;
        return item.copyWith(
          providerId: confirmed.providerId,
          providerName:
              isUnassigned || (item.providerName?.trim().isEmpty ?? true)
              ? confirmed.providerName
              : item.providerName,
          priceBefore: isUnassigned
              ? confirmed.priceBefore
              : item.priceBefore ?? confirmed.priceBefore,
          priceAfter: isUnassigned
              ? confirmed.priceAfter
              : item.priceAfter ?? confirmed.priceAfter,
          discountPercentage: isUnassigned
              ? confirmed.discountPercentage
              : item.discountPercentage ?? confirmed.discountPercentage,
        );
      }).toList(),
      totalCount: cart.totalCount,
      categoryCounters: cart.categoryCounters,
    );
  }

  /// Snapshot taken when an invoice POST outcome turns ambiguous, used by
  /// [reconcileUnknownInvoiceOutcome] to decide whether the server consumed
  /// the items. Empty for package checkouts (packages are not cart items,
  /// so they cannot be reconciled this way and stay latched).
  Set<int> _unknownOutcomeItemIds = {};
  String _unknownOutcomeProviderName = '';
  DateTime? _unknownOutcomeSubmittedAt;

  CartCubit(
    this._repository,
    this._invoiceRepository,
    this._familyMembersRepository,
    this._networkRepository, {
    required CartSyncService cartSyncService,
    this.providerId,
  }) : _cartSyncService = cartSyncService,
       super(const CartState()) {
    _cartSyncSubscription = _cartSyncService.stream.listen((event) {
      if (!event.refreshCart) return;
      if (event.selectedServiceIds != null) {
        unawaited(_refreshAfterCurrent());
      } else {
        unawaited(refreshCart());
      }
    });
  }

  void _emitCartState(CartState nextState) => emit(nextState);

  @override
  Future<void> close() {
    _cartSyncSubscription?.cancel();
    return super.close();
  }

  void _broadcastCartSnapshot(Cart cart, {bool refreshCart = false}) {
    _cartSyncService.selectionSnapshotChanged(
      selectedServiceIds: cart.items.map((item) => item.serviceId),
      categorySelectedCounts: {
        for (final counter in cart.categoryCounters)
          counter.categoryId: counter.count,
      },
      refreshCart: refreshCart,
    );
  }

  Future<void> loadCartAndProviders() async {
    emit(
      state.copyWith(
        isCartLoading: true,
        isProvidersLoading: true,
        providers: const [],
        resetCartError: true,
        resetProvidersError: true,
        resetSelectedProvider: true,
      ),
    );

    final requestGeneration = ++_cartRequestGeneration;
    final mutationGeneration = _cartMutationGeneration;
    final cartResult = await _repository.getCart();
    if (isClosed) return;
    final cartRequestIsCurrent =
        requestGeneration == _cartRequestGeneration &&
        mutationGeneration == _cartMutationGeneration;
    if (cartRequestIsCurrent) {
      cartResult.when(
        success: (serverCart) {
          final cart = _preserveConfirmedProviders(serverCart);
          emit(state.copyWith(cart: cart, isCartLoading: false));
          _broadcastCartSnapshot(cart);
        },
        failure: (error) {
          emit(state.copyWith(cartError: error, isCartLoading: false));
        },
      );
    }

    final providersResult = await _getAvailableProviders();
    if (isClosed) return;
    providersResult.when(
      success: (providers) {
        emit(
          state.copyWith(
            providers: providers,
            isProvidersLoading: false,
            resetProvidersError: true,
            resetSelectedProvider: true,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(providersError: error, isProvidersLoading: false));
      },
    );
  }
}
