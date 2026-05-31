import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thainum/thainum.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

void main() {
  // Helper: pump a PromptPayQrCard inside a minimal MaterialApp scaffold.
  Future<void> pumpCard(
    WidgetTester tester, {
    int? amountSatang,
    String? title,
    String? recipientLabel,
    bool showAmountText = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PromptPayQrCard(
            target: const PromptPayTarget(PromptPayType.mobile, '0812345678'),
            amountSatang: amountSatang,
            title: title,
            recipientLabel: recipientLabel,
            showAmountText: showAmountText,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('1. renders a Card with embedded QR, title and recipient label', (
    tester,
  ) async {
    await pumpCard(
      tester,
      amountSatang: 10000,
      title: 'Pay me',
      recipientLabel: 'ร้านกาแฟ',
    );

    // A Material Card is present.
    expect(find.byType(Card), findsOneWidget);

    // The embedded QR renders: either the package's PromptPayQr wrapper,
    // or the underlying qr_flutter QrImageView.
    final hasPromptPayQr = find.byType(PromptPayQr).evaluate().isNotEmpty;
    final hasQrImageView = find.byType(QrImageView).evaluate().isNotEmpty;
    expect(
      hasPromptPayQr || hasQrImageView,
      isTrue,
      reason: 'Expected an embedded PromptPayQr or QrImageView to render',
    );

    // Title and recipient label texts are shown.
    expect(find.text('Pay me'), findsOneWidget);
    expect(find.text('ร้านกาแฟ'), findsOneWidget);
  });

  testWidgets(
    '2. shows Thai baht text (and numeric THB) when amount set & showAmountText',
    (tester) async {
      // Computed independently from the package under test.
      final expectedBahtText = const Satang(10000).toBahtText();
      final expectedThb = const Satang(10000).toThb();

      // Guard the independent computation against the documented value.
      expect(expectedBahtText, 'หนึ่งร้อยบาทถ้วน');
      expect(expectedThb, '฿100.00');

      await pumpCard(
        tester,
        amountSatang: 10000,
        title: 'Pay me',
        showAmountText: true,
      );

      // The Thai baht text for 100.00 baht must appear.
      expect(find.text(expectedBahtText), findsOneWidget);

      // If the card also surfaces the numeric THB string, it should match.
      // (Not all designs show it; assert only when present.)
      final thbFinder = find.text(expectedThb);
      if (thbFinder.evaluate().isNotEmpty) {
        expect(thbFinder, findsOneWidget);
      }
    },
  );

  testWidgets('3a. no baht text when amountSatang is null', (tester) async {
    final bahtText = const Satang(10000).toBahtText();

    await pumpCard(
      tester,
      amountSatang: null,
      title: 'Pay me',
      showAmountText: true,
    );

    expect(find.text(bahtText), findsNothing);
  });

  testWidgets('3b. no baht text when showAmountText is false', (tester) async {
    final bahtText = const Satang(10000).toBahtText();

    await pumpCard(
      tester,
      amountSatang: 10000,
      title: 'Pay me',
      showAmountText: false,
    );

    expect(find.text(bahtText), findsNothing);
  });
}
