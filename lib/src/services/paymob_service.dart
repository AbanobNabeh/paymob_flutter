import 'package:dio/dio.dart';
import '../models/paymob_config.dart';
import '../models/paymob_order.dart';
import '../models/billing_data.dart';
import '../models/paymob_exception.dart';
import '../models/payment_result.dart';
import '../models/wallet_type.dart';

/// Low-level Paymob API client.
///
/// You rarely need to use this directly — prefer [Paymob.pay] and its
/// targeted variants. Use [PaymobService] only when you need fine-grained
/// control over individual API steps.
class PaymobService {
  /// The configuration used for all requests made by this instance.
  final PaymobConfig config;

  late final Dio _dio;

  /// Creates a [PaymobService] bound to the given [config].
  PaymobService(this.config) {
    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      contentType: 'application/json',
      validateStatus: (_) => true,
    ));
  }

  // ─── Auth ────────────────────────────────────────────────────────────────

  Future<String> _getAuthToken() async {
    final response =
        await _dio.post('/auth/tokens', data: {'api_key': config.apiKey});
    _assertSuccess(response, 'Auth failed');
    return response.data['token'] as String;
  }

  // ─── Order ───────────────────────────────────────────────────────────────

  Future<int> _registerOrder(String token, PaymobOrder order) async {
    print(
        'Registering order with amount ${order.items.map((e) => e.toJson()).toList()} ${order.amountCents} ${order.items}');
    final body = <String, dynamic>{
      'auth_token': token,
      'delivery_needed': order.deliveryNeeded == true,
      'amount_cents': order.amountCents,
      'currency': order.currency,
      'items': order.items.map((e) => e.toJson()).toList(),
      if (order.merchantOrderId != null)
        'merchant_order_id': order.merchantOrderId,
      ...?order.extra,
      ...?config.extraOrderData,
    };
    final response = await _dio.post('/ecommerce/orders', data: body);
    print('Order registration response: ${response.statusCode}');
    _assertSuccess(response, 'Order registration failed');
    final id = response.data['id'];
    return id is int ? id : int.parse(id.toString());
  }

  // ─── Payment Key ─────────────────────────────────────────────────────────

  Future<String> _getPaymentKey(
    String token,
    int orderId,
    PaymobOrder order,
    BillingData billing, {
    int? integrationId,
  }) async {
    final body = <String, dynamic>{
      'auth_token': token,
      'amount_cents': '${order.amountCents}',
      'expiration': config.tokenExpiration,
      'order_id': orderId,
      'billing_data': billing.toJson(),
      'currency': order.currency,
      'integration_id': integrationId ?? config.integrationId,
      ...?config.extraPaymentKeyData,
    };
    final response = await _dio.post('/acceptance/payment_keys', data: body);
    _assertSuccess(response, 'Payment key request failed');
    return response.data['token'].toString();
  }

  // ─── Card ─────────────────────────────────────────────────────────────────

  /// Runs the Auth → Order → PaymentKey flow and returns the card payment token.
  ///
  /// Pass this token to [payWithCard] or to a WebView iframe.
  Future<String> getCardPaymentToken({
    required PaymobOrder order,
    required BillingData billing,
  }) async {
    final authToken = await _getAuthToken();
    final orderId = await _registerOrder(authToken, order);
    return _getPaymentKey(authToken, orderId, order, billing);
  }

  /// Submits card details to the Paymob API and returns a [PaymentResult].
  ///
  /// [extraSourceData] is merged into the `source` object — use it for
  /// 3DS or any additional fields required by your integration.
  Future<PaymentResult> payWithCard({
    required String paymentKey,
    required String cardNumber,
    required String cardHolderName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    Map<String, dynamic>? extraSourceData,
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
          ...?extraSourceData,
        },
        'payment_token': paymentKey,
      },
    );
    _assertSuccess(response, 'Card payment failed');
    final data = response.data as Map<String, dynamic>;
    final transactionId = data['id']?.toString() ?? '';
    if (data['pending'] == true) return PaymentResult.pending(transactionId);
    if (data['success'] == true) {
      return PaymentResult.success(transactionId, raw: data);
    }
    return PaymentResult.failed(
        data['data']?['message']?.toString() ?? 'Payment failed');
  }

  // ─── Wallet ───────────────────────────────────────────────────────────────

  /// Runs the full Auth → Order → PaymentKey → Pay flow for mobile wallets.
  ///
  /// [walletType] is informational (used for UI only); the actual routing
  /// is determined by the [phoneNumber] the user enters.
  /// [extraSourceData] is merged into the `source` object.
  ///
  /// Returns the raw Paymob API response map so callers can inspect
  /// the redirect URL or OTP status.
  Future<Map<String, dynamic>> initiateWalletPayment({
    required PaymobOrder order,
    required BillingData billing,
    required String phoneNumber,
    required WalletType walletType,
    Map<String, dynamic>? extraSourceData,
  }) async {
    if (config.walletIntegrationId == null) {
      throw const PaymobException(
          message: 'walletIntegrationId is required in PaymobConfig');
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
        'source': {
          'identifier': phoneNumber,
          'subtype': 'WALLET',
          ...?extraSourceData,
        },
        'payment_token': paymentKey,
      },
    );
    _assertSuccess(response, 'Wallet payment failed');
    return response.data as Map<String, dynamic>;
  }

  // ─── Kiosk ────────────────────────────────────────────────────────────────

  /// Runs the full Auth → Order → PaymentKey → Pay flow for kiosk payments.
  ///
  /// Returns the Fawry / Aman bill reference number that the customer
  /// presents at the kiosk to complete cash payment.
  /// [extraSourceData] is merged into the `source` object.
  Future<String> initiateKioskPayment({
    required PaymobOrder order,
    required BillingData billing,
    Map<String, dynamic>? extraSourceData,
  }) async {
    if (config.kioskIntegrationId == null) {
      throw const PaymobException(
          message: 'kioskIntegrationId is required in PaymobConfig');
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
        'source': {
          'identifier': 'AGGREGATOR',
          'subtype': 'AGGREGATOR',
          ...?extraSourceData,
        },
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

  // ─── Helper ───────────────────────────────────────────────────────────────

  void _assertSuccess(Response<dynamic> response, String message) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw PaymobException(
        message: '$message (${response.statusCode}): ${response.data}',
        statusCode: response.statusCode,
      );
    }
  }
}
