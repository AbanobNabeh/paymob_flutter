import 'payment_mode.dart';

class PaymobConfig {
  final String apiKey;
  final int integrationId;
  final int iframeId;
  final int? walletIntegrationId;
  final int? kioskIntegrationId;
  final bool isSandbox;
  final PaymentMode paymentMode;

  const PaymobConfig({
    required this.apiKey,
    required this.integrationId,
    required this.iframeId,
    this.walletIntegrationId,
    this.kioskIntegrationId,
    this.isSandbox = true,
    this.paymentMode = PaymentMode.api,
  });

  String get baseUrl => 'https://accept.paymob.com/api';

  bool get hasWallet => walletIntegrationId != null;
  bool get hasKiosk => kioskIntegrationId != null;
  bool get isWebView => paymentMode == PaymentMode.webview;

  bool get showMethodSheet => hasWallet || hasKiosk;
}
