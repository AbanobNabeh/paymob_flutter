import 'package:dio/dio.dart';
import '../models/paymob_config.dart';
import '../models/paymob_order.dart';
import '../models/billing_data.dart';
import '../models/paymob_exception.dart';
import '../models/payment_result.dart';
import '../models/wallet_type.dart';

class PaymobService {
  final PaymobConfig config;
  late final Dio _dio;

  PaymobService(this.config) {
    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      contentType: 'application/json',
      validateStatus: (status) => true,
    ));
  }

  Future<String> _getAuthToken() async {
    final response = await _dio.post('/auth/tokens', data: {
      'api_key': config.apiKey,
    });
    _assertSuccess(response, 'Auth failed');
    return response.data['token'];
  }

  Future<int> _registerOrder(String token, PaymobOrder order) async {
    final response = await _dio.post('/ecommerce/orders', data: {
      'auth_token': token,
      'delivery_needed': false,
      'amount_cents': '${order.amountCents}',
      'currency': order.currency,
      'items': [],
    });
    _assertSuccess(response, 'Order registration failed');
    final id = response.data['id'];
    return id is int ? id : int.parse(id.toString());
  }

  Future<String> _getPaymentKey(
    String token,
    int orderId,
    PaymobOrder order,
    BillingData billing, {
    int? integrationId,
  }) async {
    final response = await _dio.post('/acceptance/payment_keys', data: {
      'auth_token': token,
      'amount_cents': '${order.amountCents}',
      'expiration': 3600,
      'order_id': orderId,
      'billing_data': billing.toJson(),
      'currency': order.currency,
      'integration_id': integrationId ?? config.integrationId,
    });
    _assertSuccess(response, 'Payment key request failed');
    return response.data['token'].toString();
  }

  Future<String> getCardPaymentToken({
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    final authToken = await _getAuthToken();
    final orderId = await _registerOrder(authToken, order);
    return await _getPaymentKey(authToken, orderId, order, billing);
  }

  Future<PaymentResult> payWithCard({
    required String paymentKey,
    required String cardNumber,
    required String cardHolderName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    final response = await _dio.post(
      '/acceptance/payments/pay',
      data: {
        'source': {
          'identifier': 'AGGREGATOR',
          'subtype': 'AGGREGATOR',
          'pan': cardNumber,
          'card_holder_name': cardHolderName,
          'expiry_month': expiryMonth.padLeft(2, '0'),
          'expiry_year': expiryYear.length == 2 ? '20$expiryYear' : expiryYear,
          'cvn': cvv,
        },
        'payment_token': paymentKey,
      },
    );
    _assertSuccess(response, 'Card payment failed');
    final data = response.data as Map<String, dynamic>;
    final success = data['success'] == true;
    final transactionId = data['id']?.toString() ?? '';
    final pending = data['pending'] == true;
    if (pending) return PaymentResult.pending(transactionId);
    if (success) return PaymentResult.success(transactionId, raw: data);
    return PaymentResult.failed(data['data']?['message'] ?? 'Payment failed');
  }

  Future<Map<String, dynamic>> initiateWalletPayment({
    required PaymobOrder order,
    required BillingData billing,
    required String phoneNumber,
    required WalletType walletType,
  }) async {
    if (config.walletIntegrationId == null) {
      throw const PaymobException(message: 'walletIntegrationId is required');
    }
    final authToken = await _getAuthToken();
    final orderId = await _registerOrder(authToken, order);
    final paymentKey = await _getPaymentKey(
      authToken,
      orderId,
      order,
      billing,
      integrationId: config.walletIntegrationId,
    );
    final response = await _dio.post(
      '/acceptance/payments/pay',
      data: {
        'source': {'identifier': phoneNumber, 'subtype': 'WALLET'},
        'payment_token': paymentKey,
      },
    );
    _assertSuccess(response, 'Wallet payment failed');
    return response.data as Map<String, dynamic>;
  }

  Future<String> initiateKioskPayment({
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    if (config.kioskIntegrationId == null) {
      throw const PaymobException(message: 'kioskIntegrationId is required');
    }
    final authToken = await _getAuthToken();
    final orderId = await _registerOrder(authToken, order);
    final paymentKey = await _getPaymentKey(
      authToken,
      orderId,
      order,
      billing,
      integrationId: config.kioskIntegrationId,
    );
    final response = await _dio.post(
      '/acceptance/payments/pay',
      data: {
        'source': {'identifier': 'AGGREGATOR', 'subtype': 'AGGREGATOR'},
        'payment_token': paymentKey,
      },
    );
    _assertSuccess(response, 'Kiosk payment failed');
    final data = response.data as Map<String, dynamic>;
    final reference = data['data']?['bill_reference']?.toString() ??
        data['extra_description']?.toString() ??
        data['id']?.toString() ??
        '';
    if (reference.isEmpty) {
      throw const PaymobException(message: 'No bill reference returned');
    }
    return reference;
  }

  void _assertSuccess(Response response, String message) {
    print('=== Paymob === Status: ${response.statusCode} | ${response.data}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw PaymobException(
          message: '$message (${response.statusCode}): ${response.data}');
    }
  }
}
