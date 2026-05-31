/// A Flutter SDK for the Paymob payment gateway.
///
/// Supports Card (WebView & Direct API), Mobile Wallet
/// (Vodafone Cash, Orange Money, Etisalat, WE), and
/// Kiosk (Fawry / Aman) payments.
///
/// ## Quick start
/// ```dart
/// final result = await Paymob.pay(
///   context: context,
///   config: PaymobConfig(
///     apiKey: 'YOUR_API_KEY',
///     integrationId: 123456,
///     iframeId: 789,
///   ),
///   order: PaymobOrder(amount: 100.0, currency: 'EGP'),
///   billing: BillingData(
///     firstName: 'Ahmed', lastName: 'Mohamed',
///     email: 'ahmed@example.com', phone: '+201234567890',
///   ),
/// );
/// ```
library paymob_flutter;

export 'src/models/paymob_config.dart';
export 'src/models/paymob_order.dart';
export 'src/models/payment_result.dart';
export 'src/models/billing_data.dart';
export 'src/models/paymob_exception.dart';
export 'src/models/wallet_type.dart';
export 'src/models/payment_mode.dart';
export 'src/paymob.dart';
