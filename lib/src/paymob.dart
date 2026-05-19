import 'package:flutter/material.dart';
import 'models/paymob_config.dart';
import 'models/paymob_order.dart';
import 'models/billing_data.dart';
import 'models/payment_result.dart';
import 'models/payment_mode.dart';
import 'services/paymob_service.dart';
import 'ui/card/card_payment_screen.dart';
import 'ui/wallet/wallet_payment_screen.dart';
import 'ui/kiosk/kiosk_payment_screen.dart';
import 'widgets/paymob_payment_widget.dart';

enum _PaymentMethod { card, wallet, kiosk }

class Paymob {
  static Future<PaymentResult> pay({
    required BuildContext context,
    required PaymobConfig config,
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    if (!context.mounted)
      return PaymentResult.failed('Context is no longer valid');

    if (!config.showMethodSheet) {
      return payWithCard(
          context: context, config: config, order: order, billing: billing);
    }

    final method = await showModalBottomSheet<_PaymentMethod>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PaymentMethodSheet(config: config, order: order),
    );

    if (method == null || !context.mounted) return PaymentResult.cancelled();

    switch (method) {
      case _PaymentMethod.card:
        return payWithCard(
            context: context, config: config, order: order, billing: billing);
      case _PaymentMethod.wallet:
        return payWithWallet(
            context: context, config: config, order: order, billing: billing);
      case _PaymentMethod.kiosk:
        return payWithKiosk(
            context: context, config: config, order: order, billing: billing);
    }
  }

  static Future<PaymentResult> payWithCard({
    required BuildContext context,
    required PaymobConfig config,
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    if (!context.mounted)
      return PaymentResult.failed('Context is no longer valid');

    if (config.isWebView) {
      return _payCardWithWebView(
          context: context, config: config, order: order, billing: billing);
    }

    PaymentResult? result;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CardPaymentScreen(
        config: config,
        order: order,
        billing: billing,
        onResult: (r) => result = r,
      ),
    ));
    return result ?? PaymentResult.cancelled();
  }

  static Future<PaymentResult> _payCardWithWebView({
    required BuildContext context,
    required PaymobConfig config,
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    try {
      final service = PaymobService(config);
      final paymentKey = await service.getCardPaymentToken(
        order: order,
        billing: billing,
      );
      if (!context.mounted)
        return PaymentResult.failed('Context is no longer valid');

      PaymentResult? result;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PaymobPaymentWidget(
          paymentKey: paymentKey,
          iframeId: config.iframeId,
          onResult: (r) => result = r,
        ),
      ));
      return result ?? PaymentResult.cancelled();
    } catch (e) {
      return PaymentResult.failed(e.toString());
    }
  }

  static Future<PaymentResult> payWithWallet({
    required BuildContext context,
    required PaymobConfig config,
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    if (!context.mounted)
      return PaymentResult.failed('Context is no longer valid');
    PaymentResult? result;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WalletPaymentScreen(
        config: config,
        order: order,
        billing: billing,
        onResult: (r) => result = r,
      ),
    ));
    return result ?? PaymentResult.cancelled();
  }

  static Future<PaymentResult> payWithKiosk({
    required BuildContext context,
    required PaymobConfig config,
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    if (!context.mounted)
      return PaymentResult.failed('Context is no longer valid');
    PaymentResult? result;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => KioskPaymentScreen(
        config: config,
        order: order,
        billing: billing,
        onResult: (r) => result = r,
      ),
    ));
    return result ?? PaymentResult.cancelled();
  }
}

class _PaymentMethodSheet extends StatelessWidget {
  final PaymobConfig config;
  final PaymobOrder order;

  const _PaymentMethodSheet({required this.config, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Choose Payment Method',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              )),
          const SizedBox(height: 6),
          Text('${order.amount} ${order.currency}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6C63FF))),
          if (config.isWebView) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🌐 Card via Paymob Hosted Page',
                style: TextStyle(fontSize: 11, color: Colors.blue),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _MethodTile(
            icon: Icons.credit_card_rounded,
            title: 'Credit / Debit Card',
            subtitle: config.isWebView
                ? 'Visa, Mastercard · Paymob Hosted Page'
                : 'Visa, Mastercard, Amex',
            color: const Color(0xFF6C63FF),
            isDark: isDark,
            onTap: () => Navigator.of(context).pop(_PaymentMethod.card),
          ),
          const SizedBox(height: 10),
          if (config.hasWallet) ...[
            _MethodTile(
              icon: Icons.phone_android_rounded,
              title: 'Mobile Wallet',
              subtitle: 'Vodafone Cash, Orange Money, Etisalat, WE',
              color: const Color(0xFF00A850),
              isDark: isDark,
              onTap: () => Navigator.of(context).pop(_PaymentMethod.wallet),
            ),
            const SizedBox(height: 10),
          ],
          if (config.hasKiosk) ...[
            _MethodTile(
              icon: Icons.storefront_outlined,
              title: 'Kiosk (Fawry / Aman)',
              subtitle: 'Pay cash at any kiosk near you',
              color: const Color(0xFFFF6B35),
              isDark: isDark,
              onTap: () => Navigator.of(context).pop(_PaymentMethod.kiosk),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252525) : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black45)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }
}
