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

  Future<void> loadCategoryServices(int categoryId) async {
    emit(
      state.copyWith(
        isCategoryServicesLoading: true,
        resetCategoryServicesError: true,
      ),
    );
    final result = await _repository.getCategoryServices(categoryId);
    if (isClosed) return;
    result.when(
      success: (categoryServices) {
        emit(
          state.copyWith(
            categoryServices: categoryServices,
            isCategoryServicesLoading: false,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            categoryServicesError: error,
            isCategoryServicesLoading: false,
          ),
        );
      },
    );
  }

  Future<void> addToCart({
    required int serviceId,
    required int categoryId,
  }) async {
    // Add to pending
    emit(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
      ),
    );

    final result = await _repository.addToCart(
      serviceId: serviceId,
      categoryId: categoryId,
      providerId: providerId,
    );
    // Remove from pending regardless of result
    final newPendingIds = Set<int>.from(state.pendingServiceIds)
      ..remove(serviceId);
    if (isClosed) return;

    result.when(
      success: (_) {
        // Reload category services to get updated isSelected
        loadCategoryServices(categoryId);
        _cartSyncService.serviceSelectionChanged(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: true,
        );
        emit(state.copyWith(pendingServiceIds: newPendingIds));
        // Pull the server truth so this instance's cart list updates too.
        unawaited(refreshCart());
      },
      failure: (error) {
        emit(state.copyWith(pendingServiceIds: newPendingIds));
      },
    );
  }

  Future<void> removeFromCart({
    required int serviceId,
    required int categoryId,
  }) async {
    // Add to pending
    emit(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
      ),
    );

    final result = await _repository.removeFromCart(serviceId);
    if (isClosed) return;
    // Remove from pending regardless of result
    final newPendingIds = Set<int>.from(state.pendingServiceIds)
      ..remove(serviceId);

    result.when(
      success: (_) {
        final nextCart = state.cart?.removeService(serviceId);
        _confirmedProviderAssignments.removeWhere(
          (_, item) => item.serviceId == serviceId,
        );
        emit(
          state.copyWith(
            cart: nextCart,
            pendingServiceIds: newPendingIds,
            resetCartError: true,
          ),
        );
        _cartSyncService.serviceSelectionChanged(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: false,
        );
        // Confirm against the server truth on top of the optimistic update.
        unawaited(refreshCart());
        loadCategoryServices(categoryId);
      },
      failure: (error) {
        emit(state.copyWith(pendingServiceIds: newPendingIds));
      },
    );
  }

  Future<void> updateMedicineQuantity({
    required int serviceId,
    required int quantity,
  }) async {
    if (isClosed || quantity < 1) return;
    final result = await _repository.updateMedicineQuantity(
      serviceId: serviceId,
      quantity: quantity,
    );
    if (isClosed) return;
    result.when(
      success: (_) => loadCart(),
      failure: (error) => emit(state.copyWith(cartError: error)),
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

  Future<void> clearCart() async {
    if (isClosed) return;
    emit(state.copyWith(isCartLoading: true, resetCartError: true));
    final result = await _repository.clearCart();
    if (isClosed) return;
    if (kDebugMode) {
      result.when(
        success: (_) => debugPrint('[CartCubit] clearCart succeeded'),
        failure: (err) => debugPrint('[CartCubit] clearCart failed: $err'),
      );
    }
    result.when(
      success: (_) {
        _confirmedProviderAssignments.clear();
        _cartMutationGeneration++;
        emit(
          state.copyWith(
            cart: const Cart.empty(),
            isCartLoading: false,
            resetCartError: true,
          ),
        );
        _cartSyncService.cartCleared();
      },
      failure: (error) {
        emit(state.copyWith(cartError: error, isCartLoading: false));
      },
    );
  }

  Future<bool> createCartInvoice() async {
    if (isClosed || _invoiceSubmissionInFlight) return false;
    // An invoice already exists for this checkout session (fresh success
    // or reconciled timeout): never POST twice for it. A new checkout
    // session (loadCheckout) resets this.
    if (state.createdInvoiceId != null) return false;
    if (state.isInvoiceOutcomeUnknown) {
      emit(
        state.copyWith(createInvoiceError: 'cart.invoice_outcome_unknown'.tr()),
      );
      return false;
    }
    final provider = state.checkoutProvider;
    final branch = state.selectedBranch;
    if (provider == null) {
      emit(state.copyWith(createInvoiceError: 'Please choose a provider.'));
      return false;
    }
    if (branch == null) {
      emit(state.copyWith(createInvoiceError: 'Please choose a branch.'));
      return false;
    }
    final branchIsCurrent = state.checkoutBranches.any(
      (candidate) => candidate.branchId == branch.branchId,
    );
    if (!branchIsCurrent) {
      emit(
        state.copyWith(
          createInvoiceError: 'cart.selected_branch_unavailable'.tr(),
          resetSelectedBranch: true,
        ),
      );
      return false;
    }

    _invoiceSubmissionInFlight = true;
    try {
      emit(
        state.copyWith(
          isCreatingInvoice: true,
          resetCreateInvoiceError: true,
          resetCreatedInvoiceId: true,
          resetCreatedInvoicePaymentLink: true,
        ),
      );
      final result = await _invoiceRepository.createFromCart(
        providerId: provider.providerId,
        providerBranchId: branch.branchId,
        isCash: state.paymentMethod == CartPaymentMethod.cash,
        familyId: state.selectedFamilyMember?.id,
      );
      if (isClosed) return false;
      return result.when<bool>(
        success: (invoice) {
          _cartMutationGeneration++;
          final remainingCart =
              state.cart?.removeProvider(provider.providerId) ??
              const Cart.empty();
          _confirmedProviderAssignments.removeWhere(
            (_, item) => item.providerId == provider.providerId,
          );
          emit(
            state.copyWith(
              cart: remainingCart,
              isCreatingInvoice: false,
              createdInvoiceId: invoice.invoiceId,
              createdInvoicePaymentLink: invoice.paymentLink,
            ),
          );
          _broadcastCartSnapshot(remainingCart, refreshCart: true);
          return true;
        },
        failure: (error) {
          final outcomeUnknown = error == invoiceOutcomeUnknownFailure;
          if (outcomeUnknown) {
            _unknownOutcomeItemIds = {
              for (final item in state.cart?.items ?? const <CartItem>[])
                if (item.providerId == provider.providerId) item.cartItemId,
            };
            _unknownOutcomeProviderName = provider.providerName;
            _unknownOutcomeSubmittedAt = DateTime.now().toUtc();
          }
          emit(
            state.copyWith(
              isCreatingInvoice: false,
              isInvoiceOutcomeUnknown: outcomeUnknown,
              createInvoiceError: outcomeUnknown
                  ? 'cart.invoice_outcome_unknown'.tr()
                  : error,
            ),
          );
          return false;
        },
      );
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isCreatingInvoice: false,
            createInvoiceError: parseApiError(error),
          ),
        );
      }
      return false;
    } finally {
      _invoiceSubmissionInFlight = false;
    }
  }

  /// Reconciles an ambiguous invoice outcome. Never posts anything, so it
  /// cannot duplicate an invoice by itself.
  ///
  /// Cart membership alone is NOT conclusive (consumption could lag the
  /// timed-out POST), so a matching invoice in `my-invoices` corroborates:
  /// - [UnknownInvoiceResolution.created]: an invoice for this provider
  ///   dated at/after submission exists. Latch cleared; go to activity.
  /// - [UnknownInvoiceResolution.notCreated]: snapshot items are all still
  ///   present AND no matching invoice exists. Latch cleared; retry is safe
  ///   (modulo the residual race documented on [InvoiceRepository]).
  /// - [UnknownInvoiceResolution.stillUnknown]: anything else (failed
  ///   reads, partial consumption without corroboration, items gone with
  ///   no matching invoice, package flow). Latch stays; do not retry.
  Future<UnknownInvoiceResolution> reconcileUnknownInvoiceOutcome() async {
    if (isClosed || !state.isInvoiceOutcomeUnknown) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    if (_unknownOutcomeItemIds.isEmpty || _unknownOutcomeSubmittedAt == null) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    final requestGeneration = ++_cartRequestGeneration;
    final invoicesResult = await _invoiceRepository.getMyInvoices(
      pageNumber: 1,
      pageSize: 10,
    );
    if (isClosed || requestGeneration != _cartRequestGeneration) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    final cartResult = await _repository.getCart();
    if (isClosed || requestGeneration != _cartRequestGeneration) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    final invoices = invoicesResult.when(
      success: (page) => page.items,
      failure: (_) => null,
    );
    final cart = cartResult.when(success: (c) => c, failure: (_) => null);
    if (invoices == null || cart == null) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    if (isClosed) return UnknownInvoiceResolution.stillUnknown;

    final earliest = _unknownOutcomeSubmittedAt!.subtract(
      const Duration(minutes: 5),
    );
    final wantedProvider = _unknownOutcomeProviderName.trim();
    InvoiceItem? matchingInvoice;
    for (final invoice in invoices) {
      if (invoice.providerName.trim() == wantedProvider &&
          !invoice.date.isBefore(earliest)) {
        matchingInvoice = invoice;
        break;
      }
    }
    final remainingIds = {for (final item in cart.items) item.cartItemId};
    final anyConsumed = _unknownOutcomeItemIds.any(
      (id) => !remainingIds.contains(id),
    );

    // Always converge the display to the fresh cart; the latch below
    // decides whether retry is allowed.
    emit(
      state.copyWith(cart: cart, isCartLoading: false, resetCartError: true),
    );
    _broadcastCartSnapshot(cart);

    if (matchingInvoice != null) {
      _clearUnknownOutcome();
      emit(
        state.copyWith(
          isInvoiceOutcomeUnknown: false,
          createdInvoiceId: '${matchingInvoice.invoiceId}',
        ),
      );
      return UnknownInvoiceResolution.created;
    }
    if (!anyConsumed) {
      _clearUnknownOutcome();
      emit(
        state.copyWith(
          isInvoiceOutcomeUnknown: false,
          resetCreateInvoiceError: true,
        ),
      );
      return UnknownInvoiceResolution.notCreated;
    }
    return UnknownInvoiceResolution.stillUnknown;
  }

  void _clearUnknownOutcome() {
    _unknownOutcomeItemIds = {};
    _unknownOutcomeProviderName = '';
    _unknownOutcomeSubmittedAt = null;
  }

  Future<bool> createPackageInvoice() async {
    if (isClosed || _invoiceSubmissionInFlight) return false;
    if (state.createdInvoiceId != null) return false;
    if (state.isInvoiceOutcomeUnknown) {
      emit(
        state.copyWith(createInvoiceError: 'cart.invoice_outcome_unknown'.tr()),
      );
      return false;
    }
    final packageId = state.checkoutPackageId;
    final branch = state.selectedBranch;
    if (packageId == null) {
      emit(state.copyWith(createInvoiceError: 'Package data is missing.'));
      return false;
    }
    if (branch == null) {
      emit(state.copyWith(createInvoiceError: 'Please choose a branch.'));
      return false;
    }
    final branchIsCurrent = state.checkoutBranches.any(
      (candidate) => candidate.branchId == branch.branchId,
    );
    if (!branchIsCurrent) {
      emit(
        state.copyWith(
          createInvoiceError: 'cart.selected_branch_unavailable'.tr(),
          resetSelectedBranch: true,
        ),
      );
      return false;
    }

    _invoiceSubmissionInFlight = true;
    try {
      emit(
        state.copyWith(
          isCreatingInvoice: true,
          resetCreateInvoiceError: true,
          resetCreatedInvoiceId: true,
          resetCreatedInvoicePaymentLink: true,
        ),
      );
      final result = await _invoiceRepository.createFromPackage(
        packageId: packageId,
        providerBranchId: branch.branchId,
        isCash: state.paymentMethod == CartPaymentMethod.cash,
      );
      if (isClosed) return false;
      return result.when<bool>(
        success: (invoice) {
          emit(
            state.copyWith(
              isCreatingInvoice: false,
              createdInvoiceId: invoice.invoiceId,
              createdInvoicePaymentLink: invoice.paymentLink,
            ),
          );
          return true;
        },
        failure: (error) {
          final outcomeUnknown = error == invoiceOutcomeUnknownFailure;
          emit(
            state.copyWith(
              isCreatingInvoice: false,
              isInvoiceOutcomeUnknown: outcomeUnknown,
              createInvoiceError: outcomeUnknown
                  ? 'cart.invoice_outcome_unknown'.tr()
                  : error,
            ),
          );
          return false;
        },
      );
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isCreatingInvoice: false,
            createInvoiceError: parseApiError(error),
          ),
        );
      }
      return false;
    } finally {
      _invoiceSubmissionInFlight = false;
    }
  }
}
