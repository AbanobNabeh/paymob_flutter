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
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (request) {
          _handleCallback(request.url);
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(url));
  }

  void _handleCallback(String url) {
    if (url.contains('success=true')) {
      final transactionId = Uri.parse(url).queryParameters['id'];
      widget.onResult(PaymentResult(
        status: PaymentStatus.success,
        transactionId: transactionId,
      ));
      Navigator.of(context).pop();
    } else if (url.contains('success=false')) {
      widget.onResult(PaymentResult(
        status: PaymentStatus.failure,
        errorMessage: 'Payment failed',
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onResult(PaymentResult(
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
