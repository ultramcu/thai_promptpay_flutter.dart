# thai_promptpay_flutter

[![pub package](https://img.shields.io/pub/v/thai_promptpay_flutter.svg)](https://pub.dev/packages/thai_promptpay_flutter)
[![CI](https://github.com/ultramcu/thai_promptpay_flutter.dart/actions/workflows/ci.yml/badge.svg)](https://github.com/ultramcu/thai_promptpay_flutter.dart/actions/workflows/ci.yml)

**Flutter widgets ที่วาด QR พร้อมเพย์ (Thai PromptPay / EMVCo) จากเบอร์มือถือ /
เลขบัตรประชาชน-ภาษี / e-Wallet พร้อมจำนวนเงิน**

**Flutter widgets that render a Thai PromptPay (EMVCo) QR code from a mobile
number, National ID / Tax ID or e-Wallet, with an optional amount.**

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

## Notes

- Output is verified through the codec — `thai_promptpay` is checked byte-for-byte
  against the canonical PromptPay references.
- Scope: personal PromptPay (mobile / National ID / e-Wallet). Bill-Payment is not
  included yet.

## License

[MIT](LICENSE) © 2026 MaIII (ultramcu)
