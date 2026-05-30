# Changelog

## 0.1.0

Initial release. Flutter widgets for Thai PromptPay (EMVCo) QR codes, built on
the pure-Dart [`thai_promptpay`](https://pub.dev/packages/thai_promptpay) codec
+ `qr_flutter` (and `thainum` for baht text). Re-exports the codec.

- `PromptPayQr` — renders the QR for a mobile number / National ID / e-Wallet,
  with an optional amount (integer satang). Convenience constructors
  `PromptPayQr.mobile/.nationalId/.eWallet`. Invalid input shows an
  `errorBuilder` (or a default placeholder) instead of throwing. A `payload`
  getter exposes the exact EMVCo string the widget renders (for share/copy).
- `PromptPayQrCard` — a drop-in Material card: the QR + a title, the recipient,
  and the amount shown as Thai baht text (via `thainum`).
