import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

/// Blind Test A for [PromptPayBillQr].
///
/// The expected payload is an EXTERNAL GOLDEN string taken verbatim from the
/// build contract (`/tmp/billqr_contract.md`). It is hard-coded here and is
/// NEVER computed from the widget under test — that is what makes this a
/// genuine fail-before/pass-after anchor. The codec itself was byte-checked by
/// the contract against maythiwat/promptparse + promptparse-go.
const String kBillGolden =
    '00020101021230690016A000000677010112011501055360926410102150000022016498940307INV000153037645802TH5406250.756304FB45';

void main() {
  group('PromptPayBillQr', () {
    PromptPayBillQr validWidget({double? size, int? amountSatang = 25075}) {
      return PromptPayBillQr(
        billerId: '010553609264101',
        ref1: '000002201649894',
        ref2: 'INV0001',
        amountSatang: amountSatang,
        size: size ?? 220,
      );
    }

    testWidgets(
      'renders exactly one QrImageView with the default size for valid input',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PromptPayBillQr(
                billerId: '010553609264101',
                ref1: '000002201649894',
                ref2: 'INV0001',
                amountSatang: 25075,
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);

        final qrFinder = find.byType(QrImageView);
        expect(
          qrFinder,
          findsOneWidget,
          reason: 'a valid bill payment must render exactly one QrImageView',
        );

        final qr = tester.widget<QrImageView>(qrFinder);
        // Default size per the public API is 220.
        expect(qr.size, equals(220.0));
      },
    );

    testWidgets('honours an explicit size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PromptPayBillQr(
              billerId: '010553609264101',
              ref1: '000002201649894',
              ref2: 'INV0001',
              amountSatang: 25075,
              size: 320,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      final qr = tester.widget<QrImageView>(find.byType(QrImageView));
      expect(qr.size, equals(320.0));
    });

    test('payload matches the external GOLDEN string (exact equality)', () {
      const widget = PromptPayBillQr(
        billerId: '010553609264101',
        ref1: '000002201649894',
        ref2: 'INV0001',
        amountSatang: 25075,
      );

      // Hard-coded external golden — NOT computed from the widget.
      expect(widget.payload, equals(kBillGolden));
    });

    testWidgets(
      'invalid input does not throw and shows a fallback (no QrImageView)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PromptPayBillQr(
                billerId: '123', // too short → invalid
                ref1: '000002201649894',
              ),
            ),
          ),
        );

        // The widget must swallow the codec error during build.
        expect(
          tester.takeException(),
          isNull,
          reason: 'invalid input must not throw out of build',
        );

        // No QR should be drawn for invalid input.
        expect(find.byType(QrImageView), findsNothing);
      },
    );

    testWidgets('invalid input uses a custom errorBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromptPayBillQr(
              billerId: '123', // invalid
              ref1: 'X',
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

    test('payload returns null for invalid input', () {
      const widget = PromptPayBillQr(billerId: '123', ref1: 'X');
      expect(widget.payload, isNull);
    });

    test('round-trip: decodeBillPayment(payload) recovers the fields', () {
      const widget = PromptPayBillQr(
        billerId: '010553609264101',
        ref1: '000002201649894',
        ref2: 'INV0001',
        amountSatang: 25075,
      );

      final payload = widget.payload;
      expect(payload, isNotNull);

      final decoded = decodeBillPayment(payload!);
      expect(decoded.billerId, '010553609264101');
      expect(decoded.ref1, '000002201649894');
      expect(decoded.ref2, 'INV0001');
      expect(decoded.amountSatang, 25075);
    });

    // Keep the helper referenced so an unused-element lint never fires while the
    // suite is being iterated.
    test('helper builds a widget with the requested size', () {
      expect(validWidget(size: 200).size, 200);
    });
  });
}
