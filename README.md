# paymob_flutter

A Flutter SDK for Paymob payment gateway. Supports Card payments via WebView.

## Installation

```yaml
dependencies:
  paymob_flutter: ^0.0.1
```

## Usage

```dart
import 'package:paymob_flutter/paymob_flutter.dart';

final result = await Paymob.pay(
  context: context,
  config: PaymobConfig(
    apiKey: 'YOUR_API_KEY',
    integrationId: 123456,
    iframeId: 789,
    isSandbox: true,
  ),
  order: PaymobOrder(
    amount: 100.0,
    currency: 'EGP',
    items: [
      OrderItem(name: 'Product', amount: 100.0, quantity: 1),
    ],
  ),
  billing: BillingData(
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    phone: '+201234567890',
  ),
);

if (result.isSuccess) {
  print('Payment ID: ${result.transactionId}');
}
```

## PaymobConfig Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| apiKey | String | ✅ | Your Paymob API Key |
| integrationId | int | ✅ | Card integration ID |
| iframeId | int | ✅ | Iframe ID from dashboard |
| isSandbox | bool | ❌ | Default: true |

## Getting Paymob Credentials
1. Go to [Paymob Dashboard](https://accept.paymob.com)
2. **API Key** → Settings → Account Info
3. **Integration ID** → Developers → Payment Integrations
4. **Iframe ID** → Developers → Iframes