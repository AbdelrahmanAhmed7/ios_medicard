import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/activity/domain/models/invoice_details.dart';

void main() {
  group('InvoiceDetails canContinuePayment', () {
    InvoiceDetails details({required String status, String? paymentLink}) {
      return InvoiceDetails(
        invoiceId: 388,
        status: status,
        date: null,
        totalBefore: 165,
        totalAfter: 132,
        discountPercentage: 20,
        paymentLink: paymentLink,
        services: const [],
      );
    }

    test('allows pending invoices with a payment link to resume payment', () {
      expect(
        details(
          status: 'Pending',
          paymentLink: 'https://pay.example/388',
        ).canContinuePayment,
        isTrue,
      );
    });

    test('does not show payment action without both pending and link', () {
      expect(details(status: 'Pending').canContinuePayment, isFalse);
      expect(
        details(
          status: 'Paid',
          paymentLink: 'https://pay.example/388',
        ).canContinuePayment,
        isFalse,
      );
    });
  });

  group('InvoiceServiceItem displayedDiscountPercentage', () {
    test('calculates service discounts from the backend prices', () {
      for (final testCase in const [
        (before: 450.0, after: 382.5, expected: 15.0),
        (before: 800.0, after: 640.0, expected: 20.0),
        (before: 2000.0, after: 600.0, expected: 70.0),
      ]) {
        final service = InvoiceServiceItem(
          id: 1,
          serviceName: 'Service',
          priceBefore: testCase.before,
          priceAfter: testCase.after,
          discountPercentage: 0,
        );

        expect(service.displayedDiscountPercentage, testCase.expected);
      }
    });

    test('preserves a non-zero backend discount percentage', () {
      const service = InvoiceServiceItem(
        id: 1,
        serviceName: 'Annual subscription',
        priceBefore: 165,
        priceAfter: 132,
        discountPercentage: 20,
      );

      expect(service.displayedDiscountPercentage, 20);
    });

    test('keeps zero when price inputs are missing', () {
      const service = InvoiceServiceItem(
        id: 1,
        serviceName: 'Annual subscription',
        priceBefore: 165,
        priceAfter: null,
        discountPercentage: 0,
      );

      expect(service.displayedDiscountPercentage, 0);
    });
  });
}
