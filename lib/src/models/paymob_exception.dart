/// Thrown when the Paymob API returns an error or an unexpected response.
class PaymobException implements Exception {
  /// Human-readable error description.
  final String message;

  /// HTTP status code, if available.
  final int? statusCode;

  /// Creates a [PaymobException].
  const PaymobException({required this.message, this.statusCode});

  @override
  String toString() => 'PaymobException: $message'
      '${statusCode != null ? " (status: $statusCode)" : ""}';
}
