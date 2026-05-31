# paymob_flutter

A Flutter SDK for Paymob payment gateway. Supports **Card** (WebView & Direct API), **Mobile Wallet** (Vodafone Cash, Orange Money, Etisalat, WE), and **Kiosk** (Fawry / Aman) payments.

<p align="center">
  <a href="https://pub.dev/packages/paymob_flutter">
    <img src="https://img.shields.io/pub/v/paymob_flutter.svg" alt="pub version">
  </a>
  <a href="https://github.com/AbanobNabeh/paymob_flutter/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/AbanobNabeh/paymob_flutter" alt="license">
  </a>
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Platform-Flutter-blue.svg" alt="platform">
  </a>
</p>

---

### 💳 Card API

![Card API Demo](https://raw.githubusercontent.com/AbanobNabeh/paymob_flutter/main/demo/Card_API.gif)

---

### 🌐 Card WebView

![Card WebView Demo](https://raw.githubusercontent.com/AbanobNabeh/paymob_flutter/main/demo/Card_webview.gif)

---

### 📱 Wallet Payment

![Wallet Demo](https://raw.githubusercontent.com/AbanobNabeh/paymob_flutter/main/demo/Wallet.gif)

---

### 🏧 Kiosk Payment

![Kiosk Demo](https://raw.githubusercontent.com/AbanobNabeh/paymob_flutter/main/demo/kiosk.gif)

## ✨ What's New in 0.1.3

- ✅ Full dartdoc coverage — 160/160 pub points
- ✅ Fixed `isSandbox` — now correctly switches between sandbox and production URLs
- ✅ Replaced deprecated `withOpacity()` with `withValues(alpha:)` throughout
- ✅ `tokenExpiration` — configure payment-key lifetime (default 3600 s)
- ✅ `extraPaymentKeyData` — merge custom fields into the payment-key request
- ✅ `extraOrderData` — merge custom fields into the order-registration request
- ✅ `PaymobOrder.merchantOrderId` — link Paymob orders to your own order IDs
- ✅ `PaymobOrder.deliveryNeeded` — control delivery flag per order
- ✅ `OrderItem` — optional `description`, `sku`, `category`, and `extra` fields
- ✅ `BillingData` — all address fields are now optional (default `'NA'`), plus `extra` map
- ✅ `PaymobService` is now fully public with dartdocs for advanced use

---

## 📦 Installation

```yaml
dependencies:
  paymob_flutter: ^0.1.3
```

---

## 🚀 Quick Start

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
} else if (result.isPending) {
  print('Pending: ${result.transactionId}');
} else if (result.isCancelled) {
  print('Cancelled by user');
} else {
  print('Failed: ${result.errorMessage}');
}
```

---

## 🎛️ Payment Modes

### API Mode (Recommended)
No WebView — full native Flutter UI.

```dart
PaymobConfig(
  apiKey: 'YOUR_API_KEY',
  integrationId: 123456,
  iframeId: 789,
  paymentMode: PaymentMode.api, // default
)
```

### WebView Mode
Classic Paymob hosted iframe page.

```dart
PaymobConfig(
  apiKey: 'YOUR_API_KEY',
  integrationId: 123456,
  iframeId: 789,
  paymentMode: PaymentMode.webview,
)
```

> **Note:** WebView mode only supports Card payments.
> Wallet and Kiosk always use Direct API regardless of `paymentMode`.

---

## 💳 Adding Wallet Support

```dart
PaymobConfig(
  apiKey: 'YOUR_API_KEY',
  integrationId: 123456,
  walletIntegrationId: 789012,
  iframeId: 789,
)
```

Supported wallets: 📱 Vodafone Cash · 🟠 Orange Money · 💚 Etisalat Cash · 🔵 WE Pay

---

## 🏧 Adding Kiosk Support

```dart
PaymobConfig(
  apiKey: 'YOUR_API_KEY',
  integrationId: 123456,
  kioskIntegrationId: 345678,
  iframeId: 789,
)
```

Returns a **bill reference** number — user pays cash at any Fawry or Aman kiosk.

---

## 🔀 All Three Methods

```dart
PaymobConfig(
  apiKey: 'YOUR_API_KEY',
  integrationId: 123456,
  walletIntegrationId: 789012,
  kioskIntegrationId: 345678,
  iframeId: 789,
  isSandbox: true,
  paymentMode: PaymentMode.api,
)
```

Bottom sheet will show: **Card / Wallet / Kiosk**

---

## ⚙️ Advanced Configuration

### Token expiration

```dart
PaymobConfig(
  apiKey: 'YOUR_API_KEY',
  integrationId: 123456,
  iframeId: 789,
  tokenExpiration: 7200, // 2 hours instead of the default 1 hour
)
```

### Extra request fields

Inject any custom or undocumented Paymob field without modifying the SDK:

```dart
PaymobConfig(
  apiKey: 'YOUR_API_KEY',
  integrationId: 123456,
  iframeId: 789,
  extraPaymentKeyData: {'lock_order_when_paid': true},
  extraOrderData: {'notes': 'VIP customer'},
)
```

### Merchant order ID

Link Paymob orders back to your own order IDs for reconciliation:

```dart
PaymobOrder(
  amount: 150.0,
  currency: 'EGP',
  merchantOrderId: 'MY-ORDER-001',
  items: [OrderItem(name: 'Deposit', amount: 150.0, quantity: 1)],
)
```

### Full BillingData example

```dart
BillingData(
  firstName: 'Ahmed',
  lastName: 'Mohamed',
  email: 'ahmed@example.com',
  phone: '+201234567890',
  city: 'Cairo',
  country: 'EGY',
  street: 'Tahrir Square',
  postalCode: '11511',
  extra: {'custom_field': 'value'}, // any extra Paymob billing field
)
```

---

## 🎯 Direct Methods

```dart
// Card only
await Paymob.payWithCard(context: context, config: config, order: order, billing: billing);

// Wallet only
await Paymob.payWithWallet(context: context, config: config, order: order, billing: billing);

// Kiosk only
await Paymob.payWithKiosk(context: context, config: config, order: order, billing: billing);
```
PaymobConfig 
---

## ⚙️ PaymobConfig Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| apiKey | String | ✅ | — | Your Paymob API Key |
| integrationId | int | ✅ | — | Card integration ID |
| iframeId | int | ✅ | — | Iframe ID from dashboard |
| walletIntegrationId | int? | ❌ | null | Wallet integration ID |
| kioskIntegrationId | int? | ❌ | null | Kiosk integration ID |
| isSandbox | bool | ❌ | true | Switch between sandbox / production |
| paymentMode | PaymentMode | ❌ | api | `api` (native UI) or `webview` |
| tokenExpiration | int | ❌ | 3600 | Payment-key lifetime in seconds |
| extraPaymentKeyData | Map? | ❌ | null | Extra fields for the payment-key request |
| extraOrderData | Map? | ❌ | null | Extra fields for the order request |

---

## 📊 PaymentResult

| Property | Type | Description |
|---|---|---|
| isSuccess | bool | Payment completed successfully |
| isPending | bool | Kiosk reference generated / Wallet OTP sent |
| isCancelled | bool | User cancelled |
| transactionId | String? | Transaction ID or Kiosk bill reference |
| errorMessage | String? | Error message if failed |
| rawResponse | Map? | Full Paymob API response |

---

## 🔑 Getting Paymob Credentials

1. Go to [Paymob Dashboard](https://accept.paymob.com)
2. **API Key** → Settings → Account Info
3. **Card Integration ID** → Developers → Payment Integrations → Card
4. **Wallet Integration ID** → Developers → Payment Integrations → Wallet
5. **Kiosk Integration ID** → Developers → Payment Integrations → Kiosk
6. **Iframe ID** → Developers → Iframes

---

## 🧪 Sandbox Test Cards

| Card | Number | Expiry | CVV |
|---|---|---|---|
| ✅ Success | `4987654321098769` | Any future date | Any 3 digits |
| ❌ Failure | `4111111111111111` | Any future date | Any 3 digits |

---

## 👨‍💻 Author

**Abanob Nabeh**

<p>
  <a href="https://github.com/AbanobNabeh">
    <img src="https://img.shields.io/badge/GitHub-AbanobNabeh-181717?style=flat&logo=github" alt="GitHub">
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/abanobnabeh/">
    <img src="https://img.shields.io/badge/LinkedIn-Abanob%20Nabeh-0077B5?style=flat&logo=linkedin" alt="LinkedIn">
  </a>
  &nbsp;
  <a href="https://www.instagram.com/abanobnabeeh/">
    <img src="https://img.shields.io/badge/Instagram-abanobnabeeh-E4405F?style=flat&logo=instagram" alt="Instagram">
  </a>
</p>

---

## 📄 License

MIT License — feel free to use in commercial projects.
