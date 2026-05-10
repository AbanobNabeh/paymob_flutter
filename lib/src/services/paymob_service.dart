import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/paymob_config.dart';
import '../models/paymob_order.dart';
import '../models/billing_data.dart';
import '../models/paymob_exception.dart';

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
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw PaymobException(message: 'Auth failed');
    }
    return response.data['token'];
  }

  Future<int> _registerOrder(String token, PaymobOrder order) async {
    final response = await _dio.post(
      '/ecommerce/orders',
      data:
          '{"auth_token":"$token","delivery_needed":false,"amount_cents":"${order.amountCents}","currency":"${order.currency}","items":[]}',
      options: Options(contentType: 'application/json'),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw PaymobException(message: 'Order registration failed');
    }
    final id = response.data['id'];
    return id is int ? id : int.parse(id.toString());
  }

  Future<String> _getPaymentKey(
    String token,
    int orderId,
    PaymobOrder order,
    BillingData billing,
  ) async {
    final response = await _dio.post('/acceptance/payment_keys', data: {
      'auth_token': token,
      'amount_cents': '${order.amountCents}',
      'expiration': 3600,
      'order_id': orderId,
      'billing_data': billing.toJson(),
      'currency': order.currency,
      'integration_id': config.integrationId,
    });
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw PaymobException(message: 'Payment key request failed');
    }
    return response.data['token'].toString();
  }

  Future<String> getPaymentToken({
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    final authToken = await _getAuthToken();
    final orderId = await _registerOrder(authToken, order);
    return await _getPaymentKey(authToken, orderId, order, billing);
  }
}
