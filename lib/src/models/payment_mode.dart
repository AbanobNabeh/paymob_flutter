/// Controls how card payments are rendered.
enum PaymentMode {
  /// Native Flutter UI — no WebView required. Recommended.
  api,

  /// Paymob-hosted iframe page rendered inside a WebView.
  ///
  /// Note: WebView mode only supports card payments.
  /// Wallet and Kiosk always use the Direct API regardless of this setting.
  webview,
}
