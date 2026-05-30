import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

void main() {
  // The card under test carries full content (title, recipient label, amount
  // text) so the fixed Column is at its tallest / the QR at its widest — the
  // worst case for overflow.
  Widget buildCard({double? qrSize}) {
    return PromptPayQrCard(
      target: const PromptPayTarget(PromptPayType.mobile, '0812345678'),
      amountSatang: 25075,
      title: 'พร้อมเพย์',
      recipientLabel: 'ร้านกาแฟ',
      qrSize: qrSize ?? 220.0,
    );
  }

  testWidgets('NARROW: width 150 — no overflow, QR clamps to <= 150',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 150,
              height: 1000,
              child: buildCard(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fail-before: the raw 220 QR is wider than the 150 surface and throws a
    // RenderFlex overflow. Pass-after: the helper clamps the QR side.
    expect(tester.takeException(), isNull);

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(
      qr.size,
      lessThanOrEqualTo(150.0),
      reason: 'QR side must shrink to fit the 150px surface',
    );
  });

  testWidgets('SHORT: height 250 — no overflow, card scrolls, QR present',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 250,
              child: buildCard(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fail-before: the Column is taller than 250 and throws a vertical
    // RenderFlex overflow. Pass-after: the helper scrolls.
    expect(tester.takeException(), isNull);

    // The card body scrolls vertically when the surface is too short.
    expect(find.byType(SingleChildScrollView), findsWidgets);

    // The QR still renders.
    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('WIDE: qrSize 300 on a roomy surface — clamp is a no-op',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildCard(qrSize: 300),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(
      qr.size,
      equals(300.0),
      reason: 'With room to spare the QR keeps its requested size',
    );
  });
}
