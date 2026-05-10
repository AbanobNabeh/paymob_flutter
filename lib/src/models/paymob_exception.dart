class PaymobException implements Exception {
  final String message;
  final int? statusCode;

  const PaymobException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'PaymobException: $message (status: $statusCode)';
}
