import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

void main() {
  // Golden card under test (from the contract's Test B example).
  Widget buildCard({double qrSize = 220}) {
    return PromptPayBillQrCard(
      billerId: '010553609264101',
      ref1: '000002201649894',
      ref2: 'INV0001',
      amountSatang: 25075,
      billerLabel: 'การไฟฟ้านครหลวง',
      qrSize: qrSize,
    );
  }

  // Pump the card inside a constrained box (MaterialApp > Scaffold > Center).
  Future<void> pumpConstrained(
    WidgetTester tester, {
    required double width,
    required double height,
    double qrSize = 220,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: buildCard(qrSize: qrSize),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    '1. NARROW width:150 -> no overflow, QR clamped to <= 150',
    (tester) async {
      await pumpConstrained(tester, width: 150, height: 1000);

      expect(tester.takeException(), isNull);
      final qr = tester.widget<QrImageView>(find.byType(QrImageView));
      expect(qr.size, lessThanOrEqualTo(150.0));
    },
  );

  testWidgets(
    '2. SHORT height:250 -> no overflow, scrollable, QR still present',
    (tester) async {
      await pumpConstrained(tester, width: 400, height: 250);

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.byType(QrImageView), findsOneWidget);
    },
  );

  testWidgets(
    '3. WIDE qrSize:300 -> clamp is a no-op, QR size == 300',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: buildCard(qrSize: 300)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final qr = tester.widget<QrImageView>(find.byType(QrImageView));
      expect(qr.size, 300.0);
    },
  );
}
