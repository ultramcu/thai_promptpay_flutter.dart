# thai_promptpay_flutter

[![pub package](https://img.shields.io/pub/v/thai_promptpay_flutter.svg)](https://pub.dev/packages/thai_promptpay_flutter)
[![CI](https://github.com/ultramcu/thai_promptpay_flutter.dart/actions/workflows/ci.yml/badge.svg)](https://github.com/ultramcu/thai_promptpay_flutter.dart/actions/workflows/ci.yml)

**Flutter widgets สำหรับสร้าง QR พร้อมเพย์ (Thai PromptPay / EMVCo) จากเบอร์มือถือ /
เลขบัตรประชาชน-เลขที่ผู้เสียภาษี / e-Wallet พร้อมจำนวนเงิน**

**Flutter widgets that render a Thai PromptPay (EMVCo) QR code from a mobile
number, National ID / Tax ID or e-Wallet, with an optional amount.**

**▶ [Live demo](https://ultramcu.github.io/thai_promptpay_flutter.dart/)** —
every widget plus an interactive "build your QR" playground and a decode demo,
running in your browser.

This is the Flutter rendering layer on top of the pure-Dart
[`thai_promptpay`](https://pub.dev/packages/thai_promptpay) codec (kept pure-Dart
so it still runs back-end / CLI). This package adds the widgets — it depends on
`flutter` + [`qr_flutter`](https://pub.dev/packages/qr_flutter) + `thai_promptpay`
+ [`thainum`](https://pub.dev/packages/thainum) (for the baht text), and
**re-exports the codec**, so importing this package alone gives you
`encodePromptPay` / `decodePromptPay` / `PromptPayTarget` etc. too.

```sh
flutter pub add thai_promptpay_flutter
```

## `PromptPayQr` — the QR widget

```dart
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

// Convenience constructors (accept 0812345678, 081-234-5678, +66…):
PromptPayQr.mobile('0812345678', amountSatang: 10000); // 100.00 baht
PromptPayQr.nationalId('1101700230708');
PromptPayQr.eWallet('004999000000001', size: 180);

// Or pass a target directly:
PromptPayQr(
  target: const PromptPayTarget(PromptPayType.mobile, '0812345678'),
  amountSatang: 5000,
  size: 240,
);
```

Money is in integer **satang** (1 baht = 100 satang) — exact, no `double`. If the
number/ID is invalid the widget shows `errorBuilder` (a default placeholder when
null) instead of throwing:

```dart
PromptPayQr.mobile(
  userInput,
  errorBuilder: (context, error) => const Text('Invalid PromptPay number'),
);
```

## `PromptPayQrCard` — a drop-in card

A Material card with the QR, a title, the recipient, and the amount shown as Thai
baht text (via `thainum`):

```dart
PromptPayQrCard(
  target: const PromptPayTarget(PromptPayType.mobile, '0812345678'),
  amountSatang: 10000,            // shows '฿100.00' + 'หนึ่งร้อยบาทถ้วน'
  title: 'พร้อมเพย์ / PromptPay',
  recipientLabel: 'ร้านกาแฟ',
);
```

## `PromptPayAmountField` — enter an amount (v0.2.0+)

A text field for entering a baht amount that reports integer **satang** (exact,
no `double`). Restricts input to digits + at most two decimals and shows a `฿`
prefix. Wire it to a `PromptPayQr` for a live "enter an amount" screen:

```dart
int? satang;

Column(children: [
  PromptPayAmountField(onChanged: (s) => setState(() => satang = s)),
  PromptPayQr.mobile('0812345678', amountSatang: satang),
]);
```

The exact baht↔satang helpers behind it are exported for reuse:
`satangFromBahtString('100.50')` → `10050`, `bahtStringFromSatang(10050)` →
`'100.50'`, and `BahtAmountInputFormatter()` for your own `TextField`s.

## `PromptPayBillQr` / `PromptPayBillQrCard` — Bill Payment (v0.3.0+)

Render a PromptPay **Bill Payment** (EMVCo tag 30) QR — the one on invoices /
utilities / tax forms — from a Biller ID + Ref1 (optional Ref2 + amount):

```dart
// The bare QR widget:
PromptPayBillQr(
  billerId: '010553609264101',   // 13- or 15-digit Tax ID [+ suffix]
  ref1: '000002201649894',
  ref2: 'INV0001',               // optional
  amountSatang: 25075,           // optional → 250.75 baht
);

// A drop-in card: QR + title + Biller/Ref rows + amount as Thai baht text:
PromptPayBillQrCard(
  billerId: '010553609264101',
  ref1: '000002201649894',
  ref2: 'INV0001',
  amountSatang: 25075,
  billerLabel: 'การไฟฟ้านครหลวง',
);
```

Like `PromptPayQr`, invalid input shows an `errorBuilder` (or a default
placeholder) instead of throwing, and a `payload` getter exposes the exact EMVCo
string the widget renders. The bill-payment payload is verified byte-for-byte by
the underlying [`thai_promptpay`](https://pub.dev/packages/thai_promptpay) codec.

## Scanning / decoding (v0.4.0+)

Decode a Thai QR — personal **PromptPay**, **Bill Payment**, or a **Slip Verify
Mini-QR** — from the camera, a still image, or a raw payload string.

**Pure decode** (no UI, never throws — `null` when unrecognized):

```dart
final ThaiQrResult? result = decodeThaiQr(payload);
switch (result) {
  case PromptPayResult(:final payload):     // personal PromptPay (tag 29)
  case BillPaymentResult(:final payload):   // bill payment (tag 30)
  case SlipResult(:final slip):             // slip verify mini-QR
  case null:                                // not a recognized Thai QR
}
```

**Camera scanner** — `PromptPayScanner` wraps
[`mobile_scanner`](https://pub.dev/packages/mobile_scanner) and reports the first
recognized Thai QR via `onResult`:

```dart
PromptPayScanner(
  onResult: (result) {
    switch (result) {
      case PromptPayResult(:final payload): /* ... */
      case BillPaymentResult(:final payload): /* ... */
      case SlipResult(:final slip): /* ... */
    }
  },
  onUnrecognized: (rawValue) { /* a QR, but not a Thai one */ },
)
```

Pair a decoded `ThaiQrResult` with **`ThaiQrResultCard`** for a ready-made
display widget:

```dart
ThaiQrResultCard(result);             // from a ThaiQrResult
ThaiQrResultCard.fromPayload(payload); // decode + display in one step
```

**Still image** — decode a Thai QR from a photo/file path:

```dart
final ThaiQrResult? result = await decodeThaiQrFromImage('/path/to/photo.jpg');
```

### Camera permission / platform setup

`PromptPayScanner` (and `decodeThaiQrFromImage`) need the camera setup that
`mobile_scanner` requires. From the
[mobile_scanner README](https://pub.dev/packages/mobile_scanner):

- **iOS** — add a camera-usage description to `ios/Runner/Info.plist`:

  ```xml
  <key>NSCameraUsageDescription</key>
  <string>This app needs camera access to scan QR codes.</string>
  ```

  `mobile_scanner` 7.x targets an iOS deployment target of **12.0** or higher.

- **Android** — `mobile_scanner` 7.x requires a `minSdkVersion` of **23** or
  higher (set in `android/app/build.gradle`). The `<uses-permission
  android:name="android.permission.CAMERA" />` and `<uses-feature>` entries are
  contributed by the plugin's manifest, so you do not normally add them
  yourself.

- **macOS** — enable the camera entitlement and add `NSCameraUsageDescription`
  (see the mobile_scanner README for details).

Image analysis (`decodeThaiQrFromImage`) is supported on Android, physical iOS
devices, and macOS (not the iOS Simulator or web); the helper returns `null`
rather than throwing where it is unsupported.

## Notes

- Output is verified through the codec — `thai_promptpay` is checked byte-for-byte
  against the canonical PromptPay references.
- Scope: personal PromptPay (mobile / National ID / e-Wallet) **and** Bill Payment
  (tag 30). The tag-62 additional-data block (Ref3) is tolerated on decode but not
  generated.

## License

[MIT](LICENSE) © 2026 MaIII (ultramcu)
