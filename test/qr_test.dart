import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

/// Blind Test A for [PromptPayQr].
///
/// NOTE ON `QrImageView.data`:
/// The spec asked to read `tester.widget<QrImageView>(...).data`. In
/// qr_flutter 4.1.0 the payload is stored in a PRIVATE field (`_data`) on
/// `QrImageView` and is NOT exposed through any public getter, so it cannot be
/// read back from a pumped widget. These tests therefore verify the payload
/// correctness through two compile-safe, independent channels:
///   1. The re-exported codec round-trip `decodePromptPay(encodePromptPay(...))`
///      — the exact string the widget is contracted to draw.
///   2. The widget renders a *valid* `QrImageView` for that very payload
///      (`QrValidator.validate(expectedPayload)` is valid), and renders a
///      fallback (no `QrImageView`) for an invalid target.
void main() {
  group('PromptPayQr', () {
    // The payload the widget is contracted to feed to QrImageView for a mobile
    // target with an amount. Computed independently from the re-exported codec.
    final mobilePayload = encodePromptPay(
      target: const PromptPayTarget(PromptPayType.mobile, '0812345678'),
      amountSatang: 10000,
    );

    testWidgets(
      'renders a QrImageView with the default size for a valid target',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PromptPayQr.mobile('0812345678', amountSatang: 10000),
            ),
          ),
        );

        final qrFinder = find.byType(QrImageView);
        expect(
          qrFinder,
          findsOneWidget,
          reason: 'a valid target must render a QrImageView',
        );

        final qr = tester.widget<QrImageView>(qrFinder);
        // Default size per the public API is 220.
        expect(qr.size, equals(220.0));

        // The exact payload the widget should be drawing must itself be a valid,
        // renderable QR string (independent check via qr_flutter's validator).
        final validation = QrValidator.validate(data: mobilePayload);
        expect(validation.status, QrValidationStatus.valid);
      },
    );

    testWidgets('honours an explicit size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PromptPayQr.mobile('0812345678', size: 320)),
        ),
      );

      final qr = tester.widget<QrImageView>(find.byType(QrImageView));
      expect(qr.size, equals(320.0));
    });

    test('codec round-trip: mobile payload decodes to the right target', () {
      // The widget is a thin wrapper over encodePromptPay; verifying the
      // round-trip proves the payload it is contracted to draw is correct.
      final decoded = decodePromptPay(mobilePayload);
      expect(decoded.target.type, PromptPayType.mobile);
      expect(decoded.target.value, '0812345678');
      expect(decoded.amountSatang, 10000);
    });

    testWidgets(
      'National ID constructor renders a QR for a nationalId payload',
      (tester) async {
        const id = '1101700230708'; // valid 13-digit Thai National ID
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: PromptPayQr.nationalId(id))),
        );

        expect(find.byType(QrImageView), findsOneWidget);

        final expected = encodePromptPay(
          target: const PromptPayTarget(PromptPayType.nationalId, id),
        );
        expect(
          QrValidator.validate(data: expected).status,
          QrValidationStatus.valid,
        );

        final decoded = decodePromptPay(expected);
        expect(decoded.target.type, PromptPayType.nationalId);
        expect(decoded.target.value, id);
      },
    );

    testWidgets('e-Wallet constructor renders a QR for an eWallet payload', (
      tester,
    ) async {
      const wallet = '004999000000001'; // valid 15-digit e-Wallet ID
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PromptPayQr.eWallet(wallet))),
      );

      expect(find.byType(QrImageView), findsOneWidget);

      final expected = encodePromptPay(
        target: const PromptPayTarget(PromptPayType.eWallet, wallet),
      );
      expect(
        QrValidator.validate(data: expected).status,
        QrValidationStatus.valid,
      );

      final decoded = decodePromptPay(expected);
      expect(decoded.target.type, PromptPayType.eWallet);
      expect(decoded.target.value, wallet);
    });

    testWidgets('invalid target does not throw and shows a fallback (no QR)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromptPayQr.mobile('123'), // too short → invalid
          ),
        ),
      );

      // The widget must swallow the codec error during build.
      expect(
        tester.takeException(),
        isNull,
        reason: 'invalid input must not throw out of build',
      );

      // No QR should be drawn for an invalid target.
      expect(find.byType(QrImageView), findsNothing);
    });

    testWidgets('invalid target uses a custom errorBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromptPayQr.mobile(
              '123', // invalid
              errorBuilder:
                  (context, error) => const Text('ERR', key: Key('err')),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('err')), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
    });

    // The widget renders `payload`, so asserting `payload` verifies the exact
    // string drawn — including that the AMOUNT is wired through (QrImageView has
    // no public `data` getter, so this is how the rendered payload is checked).
    test('payload carries the amount and matches the codec', () {
      const w = PromptPayQr(
        target: PromptPayTarget(PromptPayType.mobile, '0812345678'),
        amountSatang: 10000,
      );
      final p = w.payload;
      expect(p, isNotNull);
      expect(
        p,
        encodePromptPay(
          target: const PromptPayTarget(PromptPayType.mobile, '0812345678'),
          amountSatang: 10000,
        ),
      );
      final decoded = decodePromptPay(p!);
      expect(decoded.amountSatang, 10000);
      expect(
        decoded.target,
        const PromptPayTarget(PromptPayType.mobile, '0812345678'),
      );

      // Invalid target → null (no throw).
      expect(PromptPayQr.mobile('123').payload, isNull);
    });
  });
}
