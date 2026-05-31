import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thainum/thainum.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget card) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: card)));
    await tester.pumpAndSettle();
  }

  testWidgets('renders a PromptPay result with recipient and baht text', (
    tester,
  ) async {
    final payload = promptPayMobile('0812345678', amountSatang: 10000);
    final result = decodeThaiQr(payload)!;
    expect(result, isA<PromptPayResult>());

    await pump(tester, ThaiQrResultCard(result));

    expect(find.byType(Card), findsOneWidget);
    // Recipient value is shown.
    expect(find.textContaining('0812345678'), findsOneWidget);
    // Amount rendered as Thai baht text (computed independently).
    expect(find.text(const Satang(10000).toBahtText()), findsOneWidget);
  });

  testWidgets('renders a bank slip result with bank name and transRef', (
    tester,
  ) async {
    const payload =
        '004100060000010103014022000111222233344ABCD125102TH910417DF';

    await pump(tester, ThaiQrResultCard.fromPayload(payload));

    expect(find.byType(Card), findsOneWidget);
    expect(find.textContaining('Siam Commercial Bank'), findsOneWidget);
    expect(find.textContaining('00111222233344ABCD12'), findsOneWidget);
  });

  testWidgets('shows a graceful state for an unrecognized payload', (
    tester,
  ) async {
    await pump(tester, ThaiQrResultCard.fromPayload('garbage'));

    expect(find.textContaining('Not a recognized Thai QR'), findsOneWidget);
  });
}
