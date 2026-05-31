/// Possible outcomes of a payment attempt.
enum PaymentStatus {
  /// The payment was authorised and completed.
  success,

  /// The payment was rejected or encountered an error.
  failure,

  /// A Kiosk reference was generated or a Wallet OTP is awaiting confirmation.
  pending,

  /// The user dismissed the payment screen without completing payment.
  cancelled,
}

/// The result returned by every [Paymob.pay] call.
///
/// Check [isSuccess], [isPending], [isCancelled] or compare [status] directly.
///
/// ```dart
/// final result = await Paymob.pay(...);
/// if (result.isSuccess) {
///   print('Transaction: ${result.transactionId}');
/// }
/// ```
class PaymentResult {
  /// The final status of the payment attempt.
  final PaymentStatus status;

  /// Paymob transaction ID on success, or Kiosk bill-reference on pending.
  final String? transactionId;

  /// Error description when [status] is [PaymentStatus.failure].
  final String? errorMessage;

  /// Full raw response map from the Paymob API, if available.
  final Map<String, dynamic>? rawResponse;

  /// Creates a [PaymentResult].
  const PaymentResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
    this.rawResponse,
  });

  /// `true` when the payment completed successfully.
  bool get isSuccess => status == PaymentStatus.success;

  /// `true` when the payment is awaiting user action (Kiosk / Wallet OTP).
  bool get isPending => status == PaymentStatus.pending;

  /// `true` when the user cancelled without paying.
  bool get isCancelled => status == PaymentStatus.cancelled;

  /// Creates a successful result with the given [transactionId].
  factory PaymentResult.success(String transactionId,
          {Map<String, dynamic>? raw}) =>
      PaymentResult(
        status: PaymentStatus.success,
        transactionId: transactionId,
        rawResponse: raw,
      );

  /// Creates a failed result with the given error [message].
  factory PaymentResult.failed(String message) =>
      PaymentResult(status: PaymentStatus.failure, errorMessage: message);

  /// Creates a cancelled result.
  factory PaymentResult.cancelled() =>
      const PaymentResult(status: PaymentStatus.cancelled);

  /// Creates a pending result (Kiosk reference or Wallet OTP sent).
  factory PaymentResult.pending(String transactionId) => PaymentResult(
      status: PaymentStatus.pending, transactionId: transactionId);
}
