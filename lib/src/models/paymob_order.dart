class PaymobOrder {
  final double amount;
  final String currency;
  final List<OrderItem> items;

  const PaymobOrder({
    required this.amount,
    this.currency = 'EGP',
    required this.items,
  });

  int get amountCents => (amount * 100).toInt();
}

class OrderItem {
  final String name;
  final double amount;
  final int quantity;

  const OrderItem({
    required this.name,
    required this.amount,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': (amount * 100).toInt().toString(),
        'description': name,
        'quantity': quantity,
      };
}
