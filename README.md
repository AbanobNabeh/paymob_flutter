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

## 📹 Demo Videos

### WebView Mode
https://github.com/AbanobNabeh/paymob_flutter/raw/main/demo/Paymob_Webview.mp4

### API Mode (Native UI)
https://github.com/AbanobNabeh/paymob_flutter/raw/main/demo/Paymob_API.mp4

---

## ✨ What's New in 0.1.0

- ✅ Direct API card payment — no WebView required
- ✅ Mobile Wallet support (Vodafone Cash, Orange Money, Etisalat, WE)
- ✅ Kiosk support (Fawry / Aman) with bill reference
- ✅ Dynamic bottom sheet — only shows available payment methods
- ✅ `PaymentMode.api` or `PaymentMode.webview` — your choice
- ✅ `PaymentResult` with `success`, `failed`, `pending`, `cancelled`

---

## 📦 Installation

```yaml
dependencies:
  paymob_flutter: ^0.1.0
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

## 🎯 Direct Methods

```dart
// Card only
await Paymob.payWithCard(context: context, config: config, order: order, billing: billing);

// Wallet only
await Paymob.payWithWallet(context: context, config: config, order: order, billing: billing);

// Kiosk only
await Paymob.payWithKiosk(context: context, config: config, order: order, billing: billing);
```

---

## ⚙️ PaymobConfig Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| apiKey | String | ✅ | Your Paymob API Key |
| integrationId | int | ✅ | Card integration ID |
| iframeId | int | ✅ | Iframe ID from dashboard |
| walletIntegrationId | int? | ❌ | Wallet integration ID |
| kioskIntegrationId | int? | ❌ | Kiosk integration ID |
| isSandbox | bool | ❌ | Default: `true` |
| paymentMode | PaymentMode | ❌ | `api` (default) or `webview` |

---

## 📊 PaymentResult

| Property | Type | Description |
|---|---|---|
| isSuccess | bool | Payment completed successfully |
| isPending | bool | Kiosk reference generated / Wallet OTP sent |
| isCancelled | bool | User cancelled |
| transactionId | String? | Transaction ID or Kiosk reference |
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