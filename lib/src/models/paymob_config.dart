class PaymobConfig {
  final String apiKey;
  final int integrationId;
  final int iframeId;
  final bool isSandbox;

  const PaymobConfig({
    required this.apiKey,
    required this.integrationId,
    required this.iframeId,
    this.isSandbox = true,
  });

  String get baseUrl => isSandbox
      ? 'https://accept.paymob.com/api'
      : 'https://accept.paymob.com/api';
}
