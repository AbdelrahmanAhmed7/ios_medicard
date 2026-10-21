import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/features/activity/domain/models/created_invoice.dart';
import 'package:medicard/features/activity/domain/models/invoice_item.dart';
import 'package:medicard/features/activity/domain/models/invoices_page.dart';
import 'package:medicard/features/activity/domain/repositories/invoice_repository.dart';
import 'package:medicard/features/cart/domain/models/cart.dart';
import 'package:medicard/features/cart/domain/models/cart_item.dart';
import 'package:medicard/features/cart/domain/models/category_counter.dart';
import 'package:medicard/features/cart/domain/models/category_services.dart';
import 'package:medicard/features/cart/domain/models/provider_covered_service.dart';
import 'package:medicard/features/cart/domain/models/provider_option.dart';
import 'package:medicard/features/cart/domain/repository/cart_repository.dart';
import 'package:medicard/features/cart/domain/services/cart_sync_service.dart';
import 'package:medicard/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:medicard/features/cart/presentation/cubit/cart_state.dart';
import 'package:medicard/features/cart/presentation/widgets/provider_selection_summary.dart';
import 'package:medicard/features/family_members/data/models/family_member_model.dart';
import 'package:medicard/features/family_members/domain/repository/family_members_repository.dart';
import 'package:medicard/medicard_network/repository/medicard_network_repository.dart';
import 'package:medicard/medicard_network/service/medicard_network_api_service.dart';
import 'package:medicard/network/data/provider_page_response_model.dart';
import 'package:medicard/features/search/presentation/screens/choose_provider_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('Cart order preparation', () {
    test('availability and totals only include the requested services', () {
      final provider = _providerA(
        allItems: true,
      ).forItems(_unassignedCart().items.skip(1));
      expect(provider.coveredServices.single.cartItemId, 2);
      expect(provider.totalCount, 1);
      expect(provider.coveredCount, 1);
      expect(provider.uncoveredCount, 0);
      expect(provider.totalPriceAfter, 80);

      final partial = _providerA(
        allItems: false,
      ).forItems(_unassignedCart().items);
      expect(partial.coveredCount, 1);
      expect(partial.uncoveredServices.single.serviceName, 'B');
      expect(partial.coversAll, isFalse);
    });

    test('checkout excludes services belonging to other orders', () async {
      final fixture = _Fixture(cart: _twoProviderCart());
      addTearDown(fixture.close);
      await fixture.prepareCheckout();
      final provider = fixture.cubit.state.checkoutProvider!;
      expect(provider.coveredServices.map((service) => service.cartItemId), [
        1,
      ]);
      expect(provider.totalPriceAfter, 80);
      expect(provider.totalPriceBefore, 100);
    });

    test('multiple branches require a deliberate selection', () async {
      final fixture = _Fixture(branches: [_branch(70), _branch(71)]);
      addTearDown(fixture.close);
      await fixture.prepareCheckout();
      expect(fixture.cubit.state.selectedBranch, isNull);
      expect(await fixture.cubit.createCartInvoice(), isFalse);
      expect(fixture.invoice.createCartCalls, 0);
      fixture.cubit.selectCheckoutBranch(_branch(71));
      expect(await fixture.cubit.createCartInvoice(), isTrue);
      expect(fixture.invoice.lastBranchId, 71);
    });

    test(
      'missing service prices cannot become a zero-priced checkout',
      () async {
        final fixture = _Fixture();
        addTearDown(fixture.close);
        fixture.cart.chooseProviders = const [
          ProviderOption(
            providerId: 7,
            providerName: 'Provider A',
            coveredCount: 1,
            uncoveredCount: 0,
            totalCount: 1,
            totalPriceBefore: 0,
            totalPriceAfter: 0,
            coveredServices: [
              ProviderCoveredService(
                cartItemId: 1,
                serviceId: 10,
                serviceName: 'A',
              ),
            ],
            uncoveredServices: [],
          ),
        ];
        await fixture.prepareCheckout();
        expect(fixture.cubit.state.checkoutProvider, isNull);
        expect(fixture.cubit.state.checkoutError, isNotNull);
        expect(await fixture.cubit.createCartInvoice(), isFalse);
        expect(fixture.invoice.createCartCalls, 0);
      },
    );

    for (final locale in [const Locale('en'), const Locale('ar')]) {
      testWidgets(
        'partial choice keeps both next steps and filters the rest (${locale.languageCode})',
        (tester) async {
          final fixture = _Fixture(cart: _unassignedCart());
          fixture.cart.chooseProviders = [
            _providerA(allItems: false),
            _providerB(),
          ];
          final router = await _pumpProviderFlow(
            tester,
            fixture,
            locale: locale,
          );
          await tester.tap(find.text('Provider A'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('cart.confirm_provider'.tr()));
          await tester.pumpAndSettle();
          expect(find.text('cart.place_saved'.tr()), findsOneWidget);
          expect(
            find.byKey(const ValueKey('continue-selected-order')).hitTestable(),
            findsOneWidget,
          );
          final chooseRest = find.text('cart.choose_remaining_places'.tr());
          await tester.ensureVisible(chooseRest);
          await tester.tap(chooseRest);
          await tester.pumpAndSettle();
          expect(find.text('Provider A'), findsNothing);
          expect(find.text('Provider B'), findsOneWidget);
          expect(
            find.text('cart.covers_all_services'.tr(args: ['1'])),
            findsOneWidget,
          );
          expect(fixture.cubit.state.cart!.items.first.providerId, 7);
          await tester.tap(find.text('Provider B'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('cart.confirm_provider'.tr()));
          await tester.pumpAndSettle();
          expect(find.text('cart.all_places_selected'.tr()), findsOneWidget);
          expect(find.text('cart.choose_remaining_places'.tr()), findsNothing);
          expect(fixture.cart.updateCalls, {1: 1, 2: 1});
          expect(
            fixture.cubit.state.cart!.items.map((item) => item.providerId),
            [7, 8],
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          router.dispose();
          await fixture.cubit.close();
          fixture.sync.dispose();
        },
      );
    }

    testWidgets(
      'partial choice can continue checkout and preserves unassigned services',
      (tester) async {
        final fixture = _Fixture(cart: _unassignedCart());
        fixture.cart.chooseProviders = [
          _providerA(allItems: false),
          _providerB(),
        ];
        final router = await _pumpProviderFlow(tester, fixture);
        await tester.tap(find.text('Provider A'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('cart.confirm_provider'.tr()));
        await tester.pumpAndSettle();
        final continueOrder = find.byKey(
          const ValueKey('continue-selected-order'),
        );
        await tester.tap(continueOrder);
        await tester.pumpAndSettle();
        expect(find.text('Checkout for 7'), findsOneWidget);
        expect(fixture.cubit.state.cart!.items.last.providerId, isNull);
        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(ProviderSelectionSummary), findsOneWidget);
        expect(fixture.cubit.isClosed, isFalse);
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        await fixture.cubit.close();
        fixture.sync.dispose();
      },
    );

    testWidgets('one location for all services goes straight to checkout', (
      tester,
    ) async {
      final fixture = _Fixture(cart: _unassignedCart());
      final router = await _pumpProviderFlow(tester, fixture);
      await tester.tap(find.text('Provider A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('cart.confirm_provider'.tr()));
      await tester.pumpAndSettle();
      expect(find.text('Checkout for 7'), findsOneWidget);
      expect(
        fixture.cubit.state.cart!.items.every((item) => item.providerId == 7),
        isTrue,
      );
      expect(fixture.cubit.isClosed, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await fixture.cubit.close();
      fixture.sync.dispose();
    });

    for (final locale in [const Locale('en'), const Locale('ar')]) {
      testWidgets(
        'selected service and checkout remain visible with three services left (${locale.languageCode})',
        (tester) async {
          final originalCart = Cart(
            items: [
              ..._unassignedCart().items,
              const CartItem(
                cartItemId: 3,
                serviceId: 30,
                serviceName: 'Service C with a long name',
                categoryId: 2,
              ),
              const CartItem(
                cartItemId: 4,
                serviceId: 40,
                serviceName: 'Service D with a long name',
                categoryId: 2,
              ),
            ],
            totalCount: 4,
            categoryCounters: const [],
          );
          final fixture = _Fixture(cart: originalCart);
          fixture.cart.chooseProviders = [_providerA(allItems: false)];
          final router = await _pumpProviderFlow(
            tester,
            fixture,
            locale: locale,
          );
          tester.view.physicalSize = const Size(360, 640);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Provider A'));
          await tester.pumpAndSettle();
          // The write succeeds, but the immediate GET still lacks provider IDs.
          fixture.cart.getCartResults.add(ApiResult.success(originalCart));
          await tester.tap(find.text('cart.confirm_provider'.tr()));
          await tester.pumpAndSettle();

          final order = find.byKey(const ValueKey('selected-provider-order'));
          expect(
            find.descendant(of: order, matching: find.text('A')),
            findsOneWidget,
          );
          expect(
            find.descendant(of: order, matching: find.text('Provider A')),
            findsOneWidget,
          );
          final pay = find.byKey(const ValueKey('continue-selected-order'));
          final chooseRest = find.byKey(
            const ValueKey('choose-remaining-places'),
          );
          expect(pay.hitTestable(), findsOneWidget);
          expect(chooseRest.hitTestable(), findsOneWidget);
          expect(
            fixture.cubit.state.cart!.items
                .where((item) => item.providerId == null)
                .length,
            3,
          );
          await tester.drag(
            find.byKey(const PageStorageKey('provider-selection-summary')),
            const Offset(0, -400),
          );
          await tester.pumpAndSettle();
          expect(pay.hitTestable(), findsOneWidget);
          expect(chooseRest.hitTestable(), findsOneWidget);
          await tester.tap(pay);
          await tester.pumpAndSettle();
          expect(find.text('Checkout for 7'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          router.dispose();
          await fixture.cubit.close();
          fixture.sync.dispose();
        },
      );
    }
  });

  group('CartCubit checkout reliability', () {
    test('simultaneous invoice calls issue one POST', () async {
      final pending = Completer<ApiResult<CreatedInvoice>>();
      final fixture = _Fixture();
      fixture.invoice.createCartResults.add(pending.future);
      await fixture.prepareCheckout();

      final first = fixture.cubit.createCartInvoice();
      final second = fixture.cubit.createCartInvoice();
      await Future<void>.delayed(Duration.zero);

      expect(fixture.invoice.createCartCalls, 1);
      expect(await second, isFalse);
      pending.complete(_created());
      expect(await first, isTrue);
      await fixture.close();
    });

    test(
      'a successful invoice blocks a second POST for the same session',
      () async {
        final fixture = _Fixture();
        await fixture.prepareCheckout();

        expect(await fixture.cubit.createCartInvoice(), isTrue);
        expect(await fixture.cubit.createCartInvoice(), isFalse);
        expect(fixture.invoice.createCartCalls, 1);
        await fixture.close();
      },
    );

    test('ordinary failure and exception release invoice guard', () async {
      final fixture = _Fixture();
      fixture.invoice.createCartResults
        ..add(Future.value(const ApiResult.failure('rejected')))
        ..add(Future.value(_created()));
      fixture.invoice.throwOnCalls.add(2);
      await fixture.prepareCheckout();

      expect(await fixture.cubit.createCartInvoice(), isFalse);
      expect(await fixture.cubit.createCartInvoice(), isFalse);
      expect(await fixture.cubit.createCartInvoice(), isTrue);
      expect(fixture.invoice.createCartCalls, 3);
      await fixture.close();
    });

    test(
      'ambiguous outcome blocks unsafe retry and is never auto-retried',
      () async {
        final fixture = _Fixture();
        fixture.invoice.createCartResults.add(
          Future.value(const ApiResult.failure(invoiceOutcomeUnknownFailure)),
        );
        await fixture.prepareCheckout();

        expect(await fixture.cubit.createCartInvoice(), isFalse);
        expect(fixture.cubit.state.isInvoiceOutcomeUnknown, isTrue);
        expect(await fixture.cubit.createCartInvoice(), isFalse);
        expect(fixture.invoice.createCartCalls, 1);
        await fixture.close();
      },
    );

    test(
      'reconcile reports created when a matching invoice corroborates',
      () async {
        final fixture = _Fixture();
        fixture.invoice.createCartResults.add(
          Future.value(const ApiResult.failure(invoiceOutcomeUnknownFailure)),
        );
        await fixture.prepareCheckout();
        expect(await fixture.cubit.createCartInvoice(), isFalse);
        expect(fixture.cubit.state.isInvoiceOutcomeUnknown, isTrue);

        // Server consumed the items AND lists a matching invoice.
        fixture.cart.cart = const Cart.empty();
        fixture.invoice.myInvoicesResult = ApiResult.success(
          InvoicesPage(
            items: [
              InvoiceItem(
                invoiceId: 314,
                providerName: 'Provider A',
                branchName: 'B',
                status: 'paid',
                date: DateTime.now().toUtc(),
              ),
            ],
            pageNumber: 1,
            pageSize: 10,
            totalCount: 1,
            totalPages: 1,
          ),
        );

        final resolution = await fixture.cubit.reconcileUnknownInvoiceOutcome();
        expect(resolution, UnknownInvoiceResolution.created);
        expect(fixture.cubit.state.isInvoiceOutcomeUnknown, isFalse);
        expect(fixture.invoice.createCartCalls, 1);
        await fixture.close();
      },
    );

    test(
      'reconcile stays unknown when items are gone with no matching invoice',
      () async {
        final fixture = _Fixture();
        fixture.invoice.createCartResults.add(
          Future.value(const ApiResult.failure(invoiceOutcomeUnknownFailure)),
        );
        await fixture.prepareCheckout();
        expect(await fixture.cubit.createCartInvoice(), isFalse);

        // Items gone but no corroborating invoice: do not assume creation.
        fixture.cart.cart = const Cart.empty();

        final resolution = await fixture.cubit.reconcileUnknownInvoiceOutcome();
        expect(resolution, UnknownInvoiceResolution.stillUnknown);
        expect(fixture.cubit.state.isInvoiceOutcomeUnknown, isTrue);
        expect(await fixture.cubit.createCartInvoice(), isFalse);
        expect(fixture.invoice.createCartCalls, 1);
        await fixture.close();
      },
    );

    test('reconcile catches async consumption via matching invoice', () async {
      final fixture = _Fixture();
      fixture.invoice.createCartResults.add(
        Future.value(const ApiResult.failure(invoiceOutcomeUnknownFailure)),
      );
      await fixture.prepareCheckout();
      expect(await fixture.cubit.createCartInvoice(), isFalse);

      // Items still present, but an invoice for this provider appeared:
      // the POST landed after all. Must not allow a retry.
      fixture.invoice.myInvoicesResult = ApiResult.success(
        InvoicesPage(
          items: [
            InvoiceItem(
              invoiceId: 315,
              providerName: 'Provider A',
              branchName: 'B',
              status: 'pending',
              date: DateTime.now().toUtc(),
            ),
          ],
          pageNumber: 1,
          pageSize: 10,
          totalCount: 1,
          totalPages: 1,
        ),
      );

      final resolution = await fixture.cubit.reconcileUnknownInvoiceOutcome();
      expect(resolution, UnknownInvoiceResolution.created);
      expect(fixture.cubit.state.isInvoiceOutcomeUnknown, isFalse);
      // The reconciled invoice ID guards the session: no second POST.
      expect(fixture.cubit.state.createdInvoiceId, '315');
      expect(await fixture.cubit.createCartInvoice(), isFalse);
      expect(fixture.invoice.createCartCalls, 1);
      await fixture.close();
    });

    test(
      'reconcile reports not created and unblocks retry when items remain',
      () async {
        final fixture = _Fixture();
        fixture.invoice.createCartResults
          ..add(
            Future.value(const ApiResult.failure(invoiceOutcomeUnknownFailure)),
          )
          ..add(Future.value(_created()));
        await fixture.prepareCheckout();
        expect(await fixture.cubit.createCartInvoice(), isFalse);

        // Server cart still holds every snapshot item: nothing was charged.
        final resolution = await fixture.cubit.reconcileUnknownInvoiceOutcome();
        expect(resolution, UnknownInvoiceResolution.notCreated);
        expect(fixture.cubit.state.isInvoiceOutcomeUnknown, isFalse);

        expect(await fixture.cubit.createCartInvoice(), isTrue);
        expect(fixture.invoice.createCartCalls, 2);
        await fixture.close();
      },
    );

    test(
      'reconcile keeps the latch when the authoritative read fails',
      () async {
        final fixture = _Fixture();
        fixture.invoice.createCartResults.add(
          Future.value(const ApiResult.failure(invoiceOutcomeUnknownFailure)),
        );
        await fixture.prepareCheckout();
        expect(await fixture.cubit.createCartInvoice(), isFalse);

        fixture.cart.getCartResults.add(const ApiResult.failure('offline'));

        final resolution = await fixture.cubit.reconcileUnknownInvoiceOutcome();
        expect(resolution, UnknownInvoiceResolution.stillUnknown);
        expect(fixture.cubit.state.isInvoiceOutcomeUnknown, isTrue);
        expect(await fixture.cubit.createCartInvoice(), isFalse);
        expect(fixture.invoice.createCartCalls, 1);
        await fixture.close();
      },
    );

    test(
      'successful provider checkout preserves other groups when refresh fails',
      () async {
        final fixture = _Fixture(cart: _twoProviderCart());
        await fixture.prepareCheckout();
        fixture.cart.getCartResults.add(const ApiResult.failure('sync failed'));

        expect(await fixture.cubit.createCartInvoice(), isTrue);
        await fixture.waitForAsyncWork();

        expect(fixture.cubit.state.cart!.items, hasLength(1));
        expect(fixture.cubit.state.cart!.items.single.providerId, 8);
        expect(fixture.cubit.state.cartError, 'sync failed');
        await fixture.close();
      },
    );

    test(
      'successful post-checkout refresh applies authoritative remaining cart',
      () async {
        final pending = Completer<ApiResult<CreatedInvoice>>();
        final fixture = _Fixture(cart: _twoProviderCart());
        fixture.invoice.createCartResults.add(pending.future);
        await fixture.prepareCheckout();

        final create = fixture.cubit.createCartInvoice();
        fixture.cart.cart = _providerBCart();
        pending.complete(_created());
        expect(await create, isTrue);
        await fixture.waitForAsyncWork();

        expect(fixture.cubit.state.cart!.items.single.providerId, 8);
        expect(fixture.cubit.state.cartError, isNull);
        await fixture.close();
      },
    );

    test('cash/Visa and family member values reach repository', () async {
      final fixture = _Fixture();
      await fixture.prepareCheckout();
      fixture.cubit
        ..selectPaymentMethod(CartPaymentMethod.visa)
        ..selectFamilyMember(const FamilyMemberModel(id: 44));

      expect(await fixture.cubit.createCartInvoice(), isTrue);
      expect(fixture.invoice.lastIsCash, isFalse);
      expect(fixture.invoice.lastFamilyId, 44);
      expect(fixture.invoice.lastProviderId, 7);
      expect(fixture.invoice.lastBranchId, 70);
      await fixture.close();
    });

    test(
      'package checkout uses its provider directly without cart providers',
      () async {
        final fixture = _Fixture();
        fixture.cart.chooseProviders = const [];

        await fixture.cubit.loadCheckout(
          initialProviderId: 7,
          initialProviderName: 'Package Provider',
          initialBranch: _branch(70),
          packageId: 42,
          packageName: 'Health Package',
          packageServiceNames: const ['CBC', 'Lipid panel'],
          packagePriceAfter: 250,
        );

        expect(fixture.cart.chooseProvidersCalls, 0);
        expect(fixture.cubit.state.checkoutProvider?.providerId, 7);
        expect(
          fixture.cubit.state.checkoutProvider?.providerName,
          'Package Provider',
        );
        expect(fixture.cubit.state.selectedBranch?.branchId, 70);
        expect(fixture.cubit.state.checkoutPackageServiceNames, [
          'CBC',
          'Lipid panel',
        ]);
        expect(fixture.cubit.state.checkoutError, isNull);
        await fixture.close();
      },
    );
  });

  group('CartCubit provider assignment reliability', () {
    test(
      'confirmed provider survives lagging cart reads without resurrecting removed items',
      () async {
        final fixture = _Fixture(cart: _unassignedCart());
        addTearDown(fixture.close);
        await fixture.cubit.loadCart();
        fixture.cart.getCartResults.add(ApiResult.success(_unassignedCart()));
        expect(
          await fixture.cubit.assignProvider(_providerA(allItems: false)),
          isTrue,
        );
        expect(fixture.cubit.state.cart!.items.first.providerId, 7);
        expect(fixture.cubit.state.cart!.items.first.priceAfter, 80);
        expect(fixture.cubit.state.cart!.items.last.providerId, isNull);

        fixture.cart.cart = _unassignedCart();
        await fixture.cubit.loadCartAndProviders();
        await fixture.cubit.refreshCart();
        expect(fixture.cubit.state.cart!.items.first.providerId, 7);
        await fixture.cubit.loadCheckout(initialProviderId: 7);
        expect(
          fixture
              .cubit
              .state
              .checkoutProvider!
              .coveredServices
              .single
              .cartItemId,
          1,
        );

        fixture.cart.cart = const Cart.empty();
        await fixture.cubit.refreshCart();
        expect(fixture.cubit.state.cart!.items, isEmpty);
        fixture.cart.cart = _unassignedCart();
        await fixture.cubit.refreshCart();
        expect(fixture.cubit.state.cart!.items.first.providerId, isNull);
      },
    );
    test(
      'already-assigned covered items proceed without redundant updates',
      () async {
        // `_mixedProviderCart` was never defined; `_twoProviderCart`
        // has the exact shape this test needs: every covered item already
        // carries a provider, so no redundant updates fire.
        final fixture = _Fixture(cart: _twoProviderCart());
        await fixture.cubit.loadCart();

        expect(
          await fixture.cubit.assignProvider(_providerA(allItems: true)),
          isTrue,
        );
        expect(fixture.cart.updateCalls, isEmpty);
        expect(fixture.cubit.state.checkoutProvider?.providerId, 7);
        expect(fixture.cubit.state.assignProviderError, isNull);
        await fixture.close();
      },
    );

    test('all assignments succeed and refresh authoritative state', () async {
      final fixture = _Fixture(cart: _unassignedCart());
      await fixture.cubit.loadCart();

      expect(
        await fixture.cubit.assignProvider(_providerA(allItems: true)),
        isTrue,
      );
      expect(fixture.cart.updateCalls, {1: 1, 2: 1});
      expect(
        fixture.cubit.state.cart!.items.map((item) => item.providerId),
        everyElement(7),
      );
      await fixture.close();
    });

    test('later failure reconciles an earlier successful update', () async {
      final fixture = _Fixture(cart: _unassignedCart());
      fixture.cart.updateResults[2] = const ApiResult.failure('second failed');
      await fixture.cubit.loadCart();

      expect(
        await fixture.cubit.assignProvider(_providerA(allItems: true)),
        isFalse,
      );
      expect(fixture.cubit.state.cart!.items[0].providerId, 7);
      expect(fixture.cubit.state.cart!.items[1].providerId, isNull);
      expect(fixture.cubit.state.assignProviderError, 'second failed');
      await fixture.close();
    });

    test(
      'partial failure preserves known successes when reconciliation fails',
      () async {
        final fixture = _Fixture(cart: _unassignedCart());
        fixture.cart.updateResults[2] = const ApiResult.failure(
          'second failed',
        );
        await fixture.cubit.loadCart();
        fixture.cart.getCartResults.add(
          const ApiResult.failure('refresh failed'),
        );

        expect(
          await fixture.cubit.assignProvider(_providerA(allItems: true)),
          isFalse,
        );
        expect(fixture.cubit.state.cart!.items[0].providerId, 7);
        expect(fixture.cubit.state.cart!.items[1].providerId, isNull);
        await fixture.close();
      },
    );

    test('concurrent assignment calls do not duplicate PUTs', () async {
      final pending = Completer<ApiResult<void>>();
      final fixture = _Fixture(cart: _unassignedCart());
      fixture.cart.updateFutures[1] = pending.future;
      await fixture.cubit.loadCart();

      final first = fixture.cubit.assignProvider(_providerA(allItems: true));
      final second = fixture.cubit.assignProvider(_providerA(allItems: true));
      await Future<void>.delayed(Duration.zero);

      expect(await second, isFalse);
      expect(fixture.cart.updateCalls[1], 1);
      pending.complete(const ApiResult.failure('stop'));
      expect(await first, isFalse);
      await fixture.close();
    });

    test(
      'retry after partial assignment only updates remaining item',
      () async {
        final fixture = _Fixture(cart: _unassignedCart());
        fixture.cart.updateResults[2] = const ApiResult.failure(
          'second failed',
        );
        await fixture.cubit.loadCart();
        expect(
          await fixture.cubit.assignProvider(_providerA(allItems: true)),
          isFalse,
        );

        fixture.cart.updateResults.remove(2);
        expect(
          await fixture.cubit.assignProvider(_providerA(allItems: true)),
          isTrue,
        );
        expect(fixture.cart.updateCalls[1], 1);
        expect(fixture.cart.updateCalls[2], 2);
        await fixture.close();
      },
    );
  });

  group('CartCubit remove-from-cart reliability', () {
    test('success drops the item immediately and broadcasts it', () async {
      final fixture = _Fixture(cart: _twoProviderCart());
      await fixture.cubit.loadCart();
      expect(fixture.cubit.state.cart!.items.length, 2);

      final events = <CartSyncEvent>[];
      final sub = fixture.sync.stream.listen(events.add);

      await fixture.cubit.removeFromCart(serviceId: 10, categoryId: 1);
      await fixture.waitForAsyncWork();

      // Optimistic update: gone from state without waiting for refresh.
      expect(fixture.cubit.state.cart!.items.map((item) => item.serviceId), [
        20,
      ]);
      expect(fixture.cubit.state.cart!.totalCount, 1);
      expect(fixture.cubit.state.pendingServiceIds, isEmpty);
      expect(fixture.cubit.state.cartError, isNull);
      // Repository hit exactly once...
      expect(fixture.cart.removeCalls, [10]);
      // ...and every listener (provider page, floating button) is told.
      expect(
        events.any(
          (event) => event.serviceId == 10 && event.isSelected == false,
        ),
        isTrue,
      );
      await sub.cancel();
      await fixture.close();
    });

    test('failure keeps the item and releases the pending flag', () async {
      final fixture = _Fixture(cart: _twoProviderCart());
      fixture.cart.removeResults[10] = const ApiResult.failure('remove failed');
      await fixture.cubit.loadCart();

      await fixture.cubit.removeFromCart(serviceId: 10, categoryId: 1);
      await fixture.waitForAsyncWork();

      expect(fixture.cubit.state.cart!.items.map((item) => item.serviceId), [
        10,
        20,
      ]);
      expect(fixture.cubit.state.cart!.totalCount, 2);
      expect(fixture.cubit.state.pendingServiceIds, isEmpty);
      await fixture.close();
    });
  });

  group('CartCubit branch and cart request ordering', () {
    test('empty fresh branch response rejects initial stale branch', () async {
      final fixture = _Fixture(branches: const []);
      await fixture.cubit.loadCart();
      await fixture.cubit.loadCheckout(
        initialProviderId: 7,
        initialBranch: _branch(99),
      );

      expect(fixture.cubit.state.checkoutBranches, isEmpty);
      expect(fixture.cubit.state.selectedBranch, isNull);
      expect(await fixture.cubit.createCartInvoice(), isFalse);
      expect(fixture.invoice.createCartCalls, 0);
      await fixture.close();
    });

    test('valid initial branch remains selected', () async {
      final fixture = _Fixture(branches: [_branch(70), _branch(71)]);
      await fixture.cubit.loadCart();
      await fixture.cubit.loadCheckout(
        initialProviderId: 7,
        initialBranch: _branch(71),
      );

      expect(fixture.cubit.state.selectedBranch?.branchId, 71);
      await fixture.close();
    });

    test('late branch response for old provider is ignored', () async {
      final fixture = _Fixture();
      final old = Completer<ApiResult<List<ProviderBranch>>>();
      final fresh = Completer<ApiResult<List<ProviderBranch>>>();
      fixture.network.branchResults[7] = old.future;
      fixture.network.branchResults[8] = fresh.future;

      final oldLoad = fixture.cubit.loadProviderBranches(7);
      final freshLoad = fixture.cubit.loadProviderBranches(8);
      fresh.complete(ApiResult.success([_branch(80)]));
      await freshLoad;
      old.complete(ApiResult.success([_branch(70)]));
      await oldLoad;

      expect(fixture.cubit.state.checkoutBranches.single.branchId, 80);
      expect(fixture.cubit.state.selectedBranch?.branchId, 80);
      await fixture.close();
    });

    test('older cart load cannot overwrite newer synchronization', () async {
      final fixture = _Fixture();
      final old = Completer<ApiResult<Cart>>();
      final fresh = Completer<ApiResult<Cart>>();
      fixture.cart.getCartFutures
        ..add(old.future)
        ..add(fresh.future);

      final oldLoad = fixture.cubit.loadCart();
      await Future<void>.delayed(Duration.zero);
      fixture.sync.serviceSelectionChanged(
        serviceId: 1,
        categoryId: 1,
        isSelected: true,
      );
      await Future<void>.delayed(Duration.zero);
      fresh.complete(ApiResult.success(_markerCart(200)));
      await fixture.waitForAsyncWork();
      old.complete(ApiResult.success(_markerCart(100)));
      await oldLoad;

      expect(fixture.cubit.state.cart!.items.single.serviceId, 200);
      await fixture.close();
    });
  });
}

class _Fixture {
  _Fixture({Cart? cart, List<ProviderBranch>? branches})
    : cart = _FakeCartRepository(cart ?? _providerACart()),
      invoice = _FakeInvoiceRepository(),
      sync = CartSyncService(),
      network = _FakeNetworkRepository(branches ?? [_branch(70)]) {
    cubit = CartCubit(
      this.cart,
      invoice,
      _FakeFamilyRepository(),
      network,
      cartSyncService: sync,
    );
  }

  final _FakeCartRepository cart;
  final _FakeInvoiceRepository invoice;
  final CartSyncService sync;
  final _FakeNetworkRepository network;
  late final CartCubit cubit;

  Future<void> prepareCheckout() async {
    await cubit.loadCart();
    await cubit.loadCheckout(initialProviderId: 7);
  }

  Future<void> waitForAsyncWork() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> close() async {
    await waitForAsyncWork();
    await cubit.close();
    sync.dispose();
  }
}

class _FakeCartRepository implements CartRepository {
  _FakeCartRepository(this.cart);

  Cart cart;
  final Queue<ApiResult<Cart>> getCartResults = Queue<ApiResult<Cart>>();
  final Queue<Future<ApiResult<Cart>>> getCartFutures =
      Queue<Future<ApiResult<Cart>>>();
  final Map<int, ApiResult<void>> updateResults = {};
  final Map<int, Future<ApiResult<void>>> updateFutures = {};
  final Map<int, int> updateCalls = {};
  final Map<int, ApiResult<void>> removeResults = {};
  final List<int> removeCalls = [];
  List<ProviderOption> chooseProviders = [_providerA(allItems: true)];
  int chooseProvidersCalls = 0;

  @override
  Future<ApiResult<Cart>> getCart() {
    if (getCartFutures.isNotEmpty) return getCartFutures.removeFirst();
    if (getCartResults.isNotEmpty) {
      return Future.value(getCartResults.removeFirst());
    }
    return Future.value(ApiResult.success(cart));
  }

  @override
  Future<ApiResult<List<ProviderOption>>> getChooseProviders() async {
    chooseProvidersCalls++;
    return ApiResult.success(chooseProviders);
  }

  @override
  Future<ApiResult<void>> removeFromCart(int serviceId) async {
    removeCalls.add(serviceId);
    final result = removeResults[serviceId] ?? const ApiResult.success(null);
    result.when(
      success: (_) {
        cart = cart.removeService(serviceId);
      },
      failure: (_) {},
    );
    return result;
  }

  @override
  Future<ApiResult<CategoryServices>> getCategoryServices(
    int categoryId,
  ) async {
    return const ApiResult.success(CategoryServices(items: []));
  }

  @override
  Future<ApiResult<void>> updateCartProvider({
    required int cartId,
    required int providerId,
  }) async {
    updateCalls[cartId] = (updateCalls[cartId] ?? 0) + 1;
    final result =
        await (updateFutures[cartId] ??
            Future.value(
              updateResults[cartId] ?? const ApiResult.success(null),
            ));
    result.when(
      success: (_) {
        final option = chooseProviders
            .where((p) => p.providerId == providerId)
            .firstOrNull;
        final service = option?.coveredServices
            .where((s) => s.cartItemId == cartId)
            .firstOrNull;
        cart = Cart(
          items: cart.items
              .map(
                (item) => item.cartItemId == cartId
                    ? CartItem(
                        cartItemId: item.cartItemId,
                        serviceId: item.serviceId,
                        serviceName: item.serviceName,
                        categoryId: item.categoryId,
                        categoryName: item.categoryName,
                        providerId: providerId,
                        providerName: option?.providerName ?? 'Provider A',
                        priceBefore: service?.priceBefore,
                        priceAfter: service?.priceAfter,
                      )
                    : item,
              )
              .toList(),
          totalCount: cart.totalCount,
          categoryCounters: cart.categoryCounters,
        );
      },
      failure: (_) {},
    );
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInvoiceRepository implements InvoiceRepository {
  final Queue<Future<ApiResult<CreatedInvoice>>> createCartResults =
      Queue<Future<ApiResult<CreatedInvoice>>>();
  final Set<int> throwOnCalls = {};
  int createCartCalls = 0;
  int? lastProviderId;
  int? lastBranchId;
  int? lastFamilyId;
  bool? lastIsCash;
  ApiResult<InvoicesPage>? myInvoicesResult;

  @override
  Future<ApiResult<CreatedInvoice>> createFromCart({
    required int providerId,
    required int providerBranchId,
    required bool isCash,
    int? familyId,
    String? cardNumber,
  }) {
    createCartCalls++;
    if (throwOnCalls.contains(createCartCalls)) {
      throw StateError('broken');
    }
    lastProviderId = providerId;
    lastBranchId = providerBranchId;
    lastFamilyId = familyId;
    lastIsCash = isCash;
    if (createCartResults.isNotEmpty) return createCartResults.removeFirst();
    return Future.value(_created());
  }

  @override
  Future<ApiResult<InvoicesPage>> getMyInvoices({
    int pageNumber = 1,
    int pageSize = 10,
    int? tab,
  }) async {
    return myInvoicesResult ??
        const ApiResult.success(
          InvoicesPage(
            items: [],
            pageNumber: 1,
            pageSize: 10,
            totalCount: 0,
            totalPages: 1,
          ),
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFamilyRepository implements FamilyMembersRepository {
  @override
  Future<List<FamilyMemberModel>> getFamilyMembers() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNetworkRepository extends MedicardNetworkRepository {
  _FakeNetworkRepository(this.branches) : super(_UnusedNetworkApi());

  final List<ProviderBranch> branches;
  final Map<int, Future<ApiResult<List<ProviderBranch>>>> branchResults = {};

  @override
  Future<ApiResult<List<ProviderBranch>>> getProviderBranchLocations({
    required int providerId,
  }) {
    return branchResults[providerId] ??
        Future.value(ApiResult.success(branches));
  }
}

class _UnusedNetworkApi implements MedicardNetworkApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ApiResult<CreatedInvoice> _created() =>
    const ApiResult.success(CreatedInvoice(invoiceId: 'inv-1'));

ProviderBranch _branch(int id) =>
    ProviderBranch(branchId: id, branchName: 'Branch $id');

ProviderOption _providerB() => ProviderOption(
  providerId: 8,
  providerName: 'Provider B',
  coveredCount: 2,
  uncoveredCount: 0,
  totalCount: 2,
  totalPriceBefore: 200,
  totalPriceAfter: 160,
  coveredServices: _providerA(allItems: true).coveredServices,
  uncoveredServices: const [],
);

Future<GoRouter> _pumpProviderFlow(
  WidgetTester tester,
  _Fixture fixture, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await fixture.cubit.loadCartAndProviders();
  final router = GoRouter(
    initialLocation: '/choose-provider',
    routes: [
      GoRoute(
        path: '/cart',
        builder: (_, _) => const Scaffold(body: Text('Cart')),
      ),
      GoRoute(
        path: '/choose-provider',
        builder: (_, _) => BlocProvider.value(
          value: fixture.cubit,
          child: const ChooseProviderScreen(),
        ),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, state) {
          final extra = state.extra! as Map<String, dynamic>;
          expect(extra['cubit'], same(fixture.cubit));
          return Scaffold(body: Text('Checkout for ${extra['providerId']}'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      startLocale: locale,
      fallbackLocale: const Locale('en'),
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: const _TestTranslationsLoader(),
      child: Builder(
        builder: (context) => ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

class _TestTranslationsLoader extends AssetLoader {
  const _TestTranslationsLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

ProviderOption _providerA({required bool allItems}) => ProviderOption(
  providerId: 7,
  providerName: 'Provider A',
  coveredCount: allItems ? 2 : 1,
  uncoveredCount: 0,
  totalCount: allItems ? 2 : 1,
  totalPriceBefore: 200,
  totalPriceAfter: 160,
  coveredServices: [
    const ProviderCoveredService(
      cartItemId: 1,
      serviceId: 10,
      serviceName: 'A',
      priceBefore: 100,
      priceAfter: 80,
    ),
    if (allItems)
      const ProviderCoveredService(
        cartItemId: 2,
        serviceId: 20,
        serviceName: 'B',
        priceBefore: 100,
        priceAfter: 80,
      ),
  ],
  uncoveredServices: const [],
);

Cart _providerACart() => const Cart(
  items: [
    CartItem(
      cartItemId: 1,
      serviceId: 10,
      serviceName: 'A',
      categoryId: 1,
      providerId: 7,
      providerName: 'Provider A',
    ),
  ],
  totalCount: 1,
  categoryCounters: [
    CategoryCounter(categoryId: 1, categoryName: 'C', count: 1),
  ],
);

Cart _twoProviderCart() => const Cart(
  items: [
    CartItem(
      cartItemId: 1,
      serviceId: 10,
      serviceName: 'A',
      categoryId: 1,
      providerId: 7,
      providerName: 'Provider A',
    ),
    CartItem(
      cartItemId: 2,
      serviceId: 20,
      serviceName: 'B',
      categoryId: 2,
      providerId: 8,
      providerName: 'Provider B',
    ),
  ],
  totalCount: 2,
  categoryCounters: [
    CategoryCounter(categoryId: 1, categoryName: 'C1', count: 1),
    CategoryCounter(categoryId: 2, categoryName: 'C2', count: 1),
  ],
);

Cart _providerBCart() => const Cart(
  items: [
    CartItem(
      cartItemId: 2,
      serviceId: 20,
      serviceName: 'B',
      categoryId: 2,
      providerId: 8,
      providerName: 'Provider B',
    ),
  ],
  totalCount: 1,
  categoryCounters: [
    CategoryCounter(categoryId: 2, categoryName: 'C2', count: 1),
  ],
);

Cart _unassignedCart() => const Cart(
  items: [
    CartItem(cartItemId: 1, serviceId: 10, serviceName: 'A', categoryId: 1),
    CartItem(cartItemId: 2, serviceId: 20, serviceName: 'B', categoryId: 2),
  ],
  totalCount: 2,
  categoryCounters: [
    CategoryCounter(categoryId: 1, categoryName: 'C1', count: 1),
    CategoryCounter(categoryId: 2, categoryName: 'C2', count: 1),
  ],
);

Cart _markerCart(int marker) => Cart(
  items: [
    CartItem(
      cartItemId: marker,
      serviceId: marker,
      serviceName: '$marker',
      categoryId: 1,
    ),
  ],
  totalCount: 1,
  categoryCounters: const [],
);
