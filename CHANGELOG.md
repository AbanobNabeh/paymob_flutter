## 0.1.4

### Added
- Demo GIFs for all payment methods (Card API, Card WebView, Wallet, Kiosk)

---

## 0.1.3

### Added
- Full dartdoc coverage across all public API elements (achieves 160/160 pub points)
- `PaymobConfig.tokenExpiration` — configure payment-key lifetime in seconds (default: 3600)
- `PaymobConfig.extraPaymentKeyData` — merge custom fields into the payment-key request body
- `PaymobConfig.extraOrderData` — merge custom fields into the order-registration request body
- `PaymobOrder.merchantOrderId` — link Paymob orders to your own order IDs
- `PaymobOrder.deliveryNeeded` — explicit control over the delivery flag
- `OrderItem.description`, `OrderItem.sku`, `OrderItem.category`, `OrderItem.extra`
- `BillingData.extra` — inject custom billing fields without SDK changes
- All `BillingData` address fields are now optional (default `'NA'`)

### Fixed
- `isSandbox` now correctly switches the base URL between sandbox and production
- Replaced all deprecated `Color.withOpacity()` calls with `Color.withValues(alpha:)`
- `PaymobException.toString()` no longer appends `(status: null)` when status code is absent

---

## 0.1.2

### Added
- Wallet payment support (Vodafone Cash, Orange Money, Etisalat Cash, WE Pay)
- Kiosk payment support (Fawry / Aman)
- Native API payment flow without WebView
- Animated payment states and transitions

### Improved
- Better loading indicators
- Improved error handling
- Enhanced payment UX

### Fixed
- Minor payment flow issues