import 'payment_mode.dart';

/// Configuration object passed to every [Paymob.pay] call.
///
/// At minimum you need [apiKey], [integrationId], and [iframeId].
/// Add [walletIntegrationId] and/or [kioskIntegrationId] to enable those
/// payment methods — the bottom sheet will show only the methods you provide.
///
/// ```dart
/// PaymobConfig(
///   apiKey: 'YOUR_API_KEY',
///   integrationId: 123456,
///   iframeId: 789,
///   walletIntegrationId: 111,
///   kioskIntegrationId: 222,
///   isSandbox: true,
/// )
/// ```
class PaymobConfig {
  /// Your Paymob API key — found under Settings → Account Info.
  final String apiKey;

  /// Card payment integration ID — from Developers → Payment Integrations → Card.
  final int integrationId;

  /// Iframe ID — from Developers → Iframes. Required even in API mode.
  final int iframeId;

  /// Wallet integration ID — from Developers → Payment Integrations → Wallet.
  /// Leave `null` to hide the Wallet option.
  final int? walletIntegrationId;

  /// Kiosk integration ID — from Developers → Payment Integrations → Kiosk.
  /// Leave `null` to hide the Kiosk option.
  final int? kioskIntegrationId;

  /// Use the Paymob sandbox environment. Defaults to `true`.
  final bool isSandbox;

  /// How card payments are rendered. Defaults to [PaymentMode.api].
  final PaymentMode paymentMode;

  /// Payment-key expiration in seconds. Defaults to `3600` (1 hour).
  final int tokenExpiration;

  /// Extra key-value pairs merged into the `/acceptance/payment_keys` request body.
  ///
  /// Use this for any Paymob field not covered by the SDK:
  /// ```dart
  /// extraPaymentKeyData: {'lock_order_when_paid': true}
  /// ```
  final Map<String, dynamic>? extraPaymentKeyData;

  /// Extra key-value pairs merged into the `/ecommerce/orders` request body.
  final Map<String, dynamic>? extraOrderData;

  /// Creates a [PaymobConfig].
  const PaymobConfig({
    required this.apiKey,
    required this.integrationId,
    required this.iframeId,
    this.walletIntegrationId,
    this.kioskIntegrationId,
    this.isSandbox = true,
    this.paymentMode = PaymentMode.api,
    this.tokenExpiration = 3600,
    this.extraPaymentKeyData,
    this.extraOrderData,
  });

  /// Base API URL — switches between sandbox and production based on [isSandbox].
  String get baseUrl => isSandbox
      ? 'https://accept.paymobsolutions.com/api'
      : 'https://accept.paymob.com/api';

  /// `true` when [walletIntegrationId] is set.
  bool get hasWallet => walletIntegrationId != null;

  /// `true` when [kioskIntegrationId] is set.
  bool get hasKiosk => kioskIntegrationId != null;

  /// `true` when [paymentMode] is [PaymentMode.webview].
  bool get isWebView => paymentMode == PaymentMode.webview;

  /// `true` when there is more than one payment method to choose from.
  bool get showMethodSheet => hasWallet || hasKiosk;
}
