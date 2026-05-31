import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/payment_result.dart';

class PaymobPaymentWidget extends StatefulWidget {
  final String paymentKey;
  final int iframeId;
  final Function(PaymentResult) onResult;

  const PaymobPaymentWidget({
    super.key,
    required this.paymentKey,
    required this.iframeId,
    required this.onResult,
  });

  @override
  State<PaymobPaymentWidget> createState() => _PaymobPaymentWidgetState();
}

class _PaymobPaymentWidgetState extends State<PaymobPaymentWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final url =
        'https://accept.paymob.com/api/acceptance/iframes/${widget.iframeId}'
        '?payment_token=${widget.paymentKey}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onResult(const PaymentResult(
              status: PaymentStatus.failure,
              errorMessage: 'Cancelled by user',
            ));
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
