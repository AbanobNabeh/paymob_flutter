/// Billing information attached to every payment request.
///
/// Only [firstName], [lastName], [email], and [phone] are required.
/// All address fields default to `'NA'` as accepted by the Paymob API.
///
/// ```dart
/// BillingData(
///   firstName: 'Ahmed',
///   lastName: 'Mohamed',
///   email: 'ahmed@example.com',
///   phone: '+201234567890',
///   city: 'Cairo',
///   country: 'EGY',
/// )
/// ```
class BillingData {
  /// Customer's first name.
  final String firstName;

  /// Customer's last name.
  final String lastName;

  /// Customer's email address.
  final String email;

  /// Customer's phone number in international format, e.g. `+201234567890`.
  final String phone;

  /// Apartment number or identifier. Defaults to `'NA'`.
  final String apartment;

  /// Floor number. Defaults to `'NA'`.
  final String floor;

  /// Street name. Defaults to `'NA'`.
  final String street;

  /// Building number. Defaults to `'NA'`.
  final String building;

  /// Shipping method description. Defaults to `'NA'`.
  final String shippingMethod;

  /// Postal / ZIP code. Defaults to `'NA'`.
  final String postalCode;

  /// City name. Defaults to `'NA'`.
  final String city;

  /// ISO 3166-1 alpha-3 country code, e.g. `'EGY'`. Defaults to `'NA'`.
  final String country;

  /// State or governorate. Defaults to `'NA'`.
  final String state;

  /// Extra key-value pairs merged into the `billing_data` request object.
  ///
  /// Use this for custom or undocumented Paymob billing fields:
  /// ```dart
  /// extra: {'custom_field': 'value'}
  /// ```
  final Map<String, dynamic>? extra;

  /// Creates a [BillingData] instance.
  const BillingData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.apartment = 'NA',
    this.floor = 'NA',
    this.street = 'NA',
    this.building = 'NA',
    this.shippingMethod = 'NA',
    this.postalCode = 'NA',
    this.city = 'NA',
    this.country = 'NA',
    this.state = 'NA',
    this.extra,
  });

  /// Serialises this object to the `billing_data` map expected by the Paymob API.
  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phone,
        'apartment': apartment,
        'floor': floor,
        'street': street,
        'building': building,
        'shipping_method': shippingMethod,
        'postal_code': postalCode,
        'city': city,
        'country': country,
        'state': state,
        ...?extra,
      };
}
