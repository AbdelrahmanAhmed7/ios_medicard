import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/core/routing/app_router.dart';
import 'package:medicard/features/activity/domain/models/invoice_details.dart';
import 'package:medicard/features/activity/domain/repositories/invoice_repository.dart';
import 'package:medicard/features/notifications/push_notification_service.dart';

class _FakeInvoiceRepository extends Fake implements InvoiceRepository {
  InvoiceDetails? detailsToReturn;
  String? errorToReturn;
  int? lastRequestedInvoiceId;

  @override
  Future<ApiResult<InvoiceDetails>> getInvoiceDetails(int invoiceId) async {
    lastRequestedInvoiceId = invoiceId;
    if (errorToReturn != null) {
      return ApiResult.failure(errorToReturn!);
    }
    return ApiResult.success(
      detailsToReturn ??
          InvoiceDetails(
            invoiceId: invoiceId,
            status: 'Pending',
            date: DateTime(2026, 10, 29),
            totalBefore: 1000,
            totalAfter: 800,
            discountPercentage: 20,
            providerName: 'Al-Amal Hospital',
            branchName: 'Nasr City',
            services: const [],
          ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PushNotificationService openNotificationInvoice', () {
    late _FakeInvoiceRepository fakeRepository;
    late GoRouter testRouter;
    String? pushedLocation;
    Object? pushedExtra;

    setUp(() async {
      await sl.reset();
      fakeRepository = _FakeInvoiceRepository();
      sl.registerSingleton<InvoiceRepository>(fakeRepository);

      testRouter = GoRouter(
        initialLocation: '/notifications',
        routes: [
          GoRoute(path: '/notifications', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/invoice-details', builder: (_, _) => const SizedBox()),
        ],
      );
      AppRouter.current = testRouter;
      pushedLocation = null;
      pushedExtra = null;
    });

    tearDown(() async {
      AppRouter.current = null;
      await sl.reset();
    });

    test('fetches invoice details and opens /invoice-details', () async {
      fakeRepository.detailsToReturn = InvoiceDetails(
        invoiceId: 999,
        status: 'Paid',
        date: DateTime(2026, 10, 29),
        totalBefore: 500,
        totalAfter: 400,
        discountPercentage: 20,
        providerName: 'Health Clinic',
        branchName: 'Maadi',
        services: const [],
      );

      final result = await PushNotificationService.openNotificationInvoice(999);

      expect(result, isTrue);
      expect(fakeRepository.lastRequestedInvoiceId, 999);
    });

    test('returns false when getInvoiceDetails fails', () async {
      fakeRepository.errorToReturn = 'Invoice not found';

      final result = await PushNotificationService.openNotificationInvoice(404);

      expect(result, isFalse);
      expect(fakeRepository.lastRequestedInvoiceId, 404);
    });
  });
}
