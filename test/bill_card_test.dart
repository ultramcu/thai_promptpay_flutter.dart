import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

void main() {
  // Anchor values from the contract's GOLDEN example.
  const billerId = '010553609264101';
  const ref1 = '000002201649894';
  const ref2 = 'INV0001';

  // Helper: pump a PromptPayBillQrCard inside a minimal MaterialApp scaffold.
  Future<void> pumpCard(
    WidgetTester tester, {
    String? ref2,
    int? amountSatang,
    String? title,
    String? billerLabel,
    bool showReferences = true,
    bool showAmountText = true,
    double qrSize = 220,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PromptPayBillQrCard(
            billerId: billerId,
            ref1: ref1,
            ref2: ref2,
            amountSatang: amountSatang,
            title: title,
            billerLabel: billerLabel,
            showReferences: showReferences,
            showAmountText: showAmountText,
            qrSize: qrSize,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      '1. valid input renders one Card with one PromptPayBillQr and one '
      'QrImageView, no exception', (tester) async {
    await pumpCard(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(PromptPayBillQrCard), findsOneWidget);
    expect(find.byType(PromptPayBillQr), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('2a. showReferences=true (default) shows biller id and ref1 text',
      (tester) async {
    await pumpCard(tester);

    expect(find.textContaining(billerId), findsWidgets);
    expect(find.textContaining(ref1), findsWidgets);
  });

  testWidgets('2b. ref2, when provided, is shown', (tester) async {
    await pumpCard(tester, ref2: ref2);

    expect(find.textContaining(ref2), findsWidgets);
  });

  testWidgets('2c. showReferences=false hides the Ref1: label row',
      (tester) async {
    await pumpCard(tester, showReferences: false);

    expect(find.textContaining('Ref1:'), findsNothing);
  });

  testWidgets(
      '3a. amountSatang set + showAmountText shows the baht amount (250.75)',
      (tester) async {
    await pumpCard(tester, amountSatang: 25075, showAmountText: true);

    // Satang(25075).toThb() -> '฿250.75'; assert the numeric substring.
    expect(find.textContaining('250.75'), findsWidgets);
  });

  testWidgets('3b. showAmountText=false hides the baht amount text',
      (tester) async {
    await pumpCard(tester, amountSatang: 25075, showAmountText: false);

    expect(find.textContaining('250.75'), findsNothing);
  });

  testWidgets('4. billerLabel, when provided, is shown', (tester) async {
    await pumpCard(tester, billerLabel: 'การไฟฟ้านครหลวง');

    expect(find.text('การไฟฟ้านครหลวง'), findsOneWidget);
  });

  testWidgets('5. qrSize is forwarded to the inner QrImageView',
      (tester) async {
    await pumpCard(tester, qrSize: 300);

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.size, 300);
  });
}
