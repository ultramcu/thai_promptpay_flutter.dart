# thai_promptpay_flutter — gallery example

A runnable gallery that tours every widget in
[`thai_promptpay_flutter`](https://pub.dev/packages/thai_promptpay_flutter),
plus two interactive demos. Runs on mobile, desktop, and **web**.

```sh
cd example
flutter run            # or: flutter run -d chrome
```

Use the **EN / ไทย** button in the app bar to switch languages.

## What's inside

- **PromptPay QR** — `PromptPayQr.mobile/.nationalId/.eWallet`
- **QR card** — `PromptPayQrCard` (with Thai baht text)
- **Amount field (live)** — `PromptPayAmountField` → the QR updates as you type
- **Bill Payment QR** — `PromptPayBillQr` (Biller ID + Ref1/Ref2)
- **Bill Payment card** — `PromptPayBillQrCard`
- **Playground** — pick a recipient type, enter the number/biller + amount, and
  watch the live QR + copyable payload string
- **Decode a payload** — paste any PromptPay payload and see who / how much via
  `decodeAny` (personal *or* bill payment)

Money is handled as integer **satang** throughout (no `double`).
