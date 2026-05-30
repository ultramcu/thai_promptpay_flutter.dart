# Changelog

## 0.3.0

- **`PromptPayBillQr`** — renders a PromptPay **Bill Payment** (EMVCo tag 30) QR
  from a Biller ID + Ref1 (optional Ref2 + amount). Mirrors `PromptPayQr`:
  invalid input shows an `errorBuilder` (or a default placeholder) instead of
  throwing, and a `payload` getter exposes the exact EMVCo string it renders.
- **`PromptPayBillQrCard`** — a drop-in Material card: the bill QR + a title,
  the Biller ID / Ref1 / Ref2 rows, and the amount as Thai baht text (via
  `thainum`).
- Requires [`thai_promptpay`](https://pub.dev/packages/thai_promptpay) `^0.2.0`
  (the bill-payment codec). The new codec API (`encodeBillPayment`,
  `decodeBillPayment`, `decodeAny`, `BillPaymentPayload`) is re-exported.

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
