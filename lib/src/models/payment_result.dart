enum PaymentStatus { success, failure, pending }

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? errorMessage;

  const PaymentResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
  });

  bool get isSuccess => status == PaymentStatus.success;
}
