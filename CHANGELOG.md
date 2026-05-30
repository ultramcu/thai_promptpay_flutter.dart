# Changelog

## 0.2.0

- **`PromptPayAmountField`** — a text field for entering a Thai baht amount,
  reporting the value as integer **satang** via `onChanged` (null when empty).
  Restricts input to digits + at most two decimals, shows a `฿` prefix, and
  owns/disposes its controller safely. Wire it to a `PromptPayQr` for a live
  "enter an amount" payment screen.
- **`BahtAmountInputFormatter`** + `satangFromBahtString` / `bahtStringFromSatang`
  — the exact (no `double`) baht↔satang helpers behind the field, exported for
  reuse.

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
