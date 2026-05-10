import 'package:flutter/material.dart';
import 'models/paymob_config.dart';
import 'models/paymob_order.dart';
import 'models/billing_data.dart';
import 'models/payment_result.dart';
import 'services/paymob_service.dart';
import 'widgets/paymob_payment_widget.dart';

class Paymob {
  static Future<PaymentResult> pay({
    required BuildContext context,
    required PaymobConfig config,
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    final service = PaymobService(config);

    final paymentKey = await service.getPaymentToken(
      order: order,
      billing: billing,
    );

    if (!context.mounted) {
      return const PaymentResult(
        status: PaymentStatus.failure,
        errorMessage: 'Context is no longer valid',
      );
    }

    PaymentResult? result;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymobPaymentWidget(
          paymentKey: paymentKey,
          iframeId: config.iframeId,
          onResult: (r) => result = r,
        ),
      ),
    );

    return result ??
        const PaymentResult(
          status: PaymentStatus.failure,
          errorMessage: 'Unknown error',
        );
  }
}
