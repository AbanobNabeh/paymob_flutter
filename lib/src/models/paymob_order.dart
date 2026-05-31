/// Represents the order being paid for.
///
/// ```dart
/// PaymobOrder(
///   amount: 150.0,
///   currency: 'EGP',
///   items: [
///     OrderItem(name: 'Deposit', amount: 150.0, quantity: 1),
///   ],
/// )
/// ```
class PaymobOrder {
  /// Amount in major currency units (e.g. `100.0` = 100 EGP).
  final double amount;

  /// ISO 4217 currency code. Defaults to `'EGP'`.
  final String currency;

  /// Line items included in the order. Can be empty.
  final List<OrderItem> items;

  /// Whether the order requires physical delivery. Defaults to `false`.
  final bool deliveryNeeded;

  /// Optional merchant-side order identifier for reconciliation.
  final String? merchantOrderId;

  /// Extra key-value pairs merged into the `/ecommerce/orders` request body.
  ///
  /// ```dart
  /// extra: {'notes': 'VIP customer'}
  /// ```
  final Map<String, dynamic>? extra;

  /// Creates a [PaymobOrder].
  const PaymobOrder({
    required this.amount,
    this.currency = 'EGP',
    this.items = const [],
    this.deliveryNeeded = false,
    this.merchantOrderId,
    this.extra,
  });

  /// Amount converted to cents/piastres as required by the Paymob API.
  int get amountCents => (amount * 100).toInt();
}

/// A single line item inside a [PaymobOrder].
class OrderItem {
  /// Product or service name.
  final String name;

  /// Item price in major currency units.
  final double amount;

  /// Number of units purchased.
  final int quantity;

  /// Optional longer description shown on the receipt.
  final String? description;

  /// Optional stock-keeping unit identifier.
  final String? sku;

  /// Optional product category.
  final String? category;

  /// Extra key-value pairs merged into this item's JSON object.
  final Map<String, dynamic>? extra;

  /// Creates an [OrderItem].
  const OrderItem({
    required this.name,
    required this.amount,
    required this.quantity,
    this.description,
    this.sku,
    this.category,
    this.extra,
  });

  /// Serialises this item to the format expected by the Paymob API.
  Map<String, dynamic> toJson() => {
        'name': name,
        'amount_cents': (amount * 100).toInt().toString(),
        'description': description ?? name,
        'quantity': quantity,
        if (sku != null) 'sku': sku,
        if (category != null) 'category': category,
        ...?extra,
      };
}
