class BillingData {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const BillingData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phone,
        'apartment': 'NA',
        'floor': 'NA',
        'street': 'NA',
        'building': 'NA',
        'shipping_method': 'NA',
        'postal_code': 'NA',
        'city': 'NA',
        'country': 'NA',
        'state': 'NA',
      };
}
