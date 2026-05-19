enum PaymentStatus { success, failure, pending, cancelled }

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? errorMessage;
  final Map<String, dynamic>? rawResponse;

  const PaymentResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
    this.rawResponse,
  });

  bool get isSuccess => status == PaymentStatus.success;
  bool get isPending => status == PaymentStatus.pending;
  bool get isCancelled => status == PaymentStatus.cancelled;

  factory PaymentResult.success(String transactionId,
          {Map<String, dynamic>? raw}) =>
      PaymentResult(
        status: PaymentStatus.success,
        transactionId: transactionId,
        rawResponse: raw,
      );

  factory PaymentResult.failed(String message) =>
      PaymentResult(status: PaymentStatus.failure, errorMessage: message);

  factory PaymentResult.cancelled() =>
      const PaymentResult(status: PaymentStatus.cancelled);

  factory PaymentResult.pending(String transactionId) => PaymentResult(
      status: PaymentStatus.pending, transactionId: transactionId);
}
