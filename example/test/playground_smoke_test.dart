// Smoke test for the PLAYGROUND + DECODE sections (Test B in the contract).
//
// These pump each section IN ISOLATION (not the whole gallery) so assertions
// can't be masked by static text the other sections render. Anchors are chosen
// to be unique to the SECTION RESULT:
//  - the decode field echoes the raw payload, so digit anchors that appear in
//    the payload would leak; we anchor the personal decode on the target value
//    `0812345678`, which does NOT appear in its payload (encoded as
//    `…0066812345678…`), and the bill decode on the Thai result header `ชำระบิล`
//    (distinct from the `ตัวอย่างบิล` "load sample" button).
// This makes the tests fail-before/pass-after: gutting a section's QR or decode
// result makes the scoped/unique finders find nothing → red.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';
import 'package:thai_promptpay_flutter_example/playground_section.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSection(WidgetTester tester, Widget section) async {
    await binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: section))),
    );
    await tester.pumpAndSettle();
  }

  // ---- Playground -----------------------------------------------------------

  testWidgets('playground renders its own live QR + payload SelectableText', (
    tester,
  ) async {
    await pumpSection(tester, const PlaygroundSection(isThai: false));

    // The playground (default: a valid mobile number) renders exactly one live
    // QrImageView and a payload SelectableText. Gutting the QR turns this red.
    expect(find.byType(QrImageView), findsOneWidget,
        reason: 'the playground should render its own live QR');
    expect(find.byType(SelectableText), findsWidgets,
        reason: 'the playground should show its payload in a SelectableText');
    // The default payload is valid → a real PromptPay string ("0002…") shows.
    expect(find.textContaining('0002'), findsWidgets,
        reason: 'a valid default should produce a payload string');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'playground: invalid input shows the QR error placeholder, no throw', (
    tester,
  ) async {
    await pumpSection(tester, const PlaygroundSection(isThai: false));

    // Type an invalid mobile number into the first input field.
    await tester.enterText(find.byType(TextField).first, '123');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason: 'invalid input must never throw out of build');
    // The QR is replaced by its error placeholder text (the section sets one).
    expect(find.textContaining('valid'), findsWidgets,
        reason: 'an "enter valid input" hint should be shown');
  });

  // ---- Decode ---------------------------------------------------------------

  Finder decodeField() => find.byType(TextField);

  testWidgets('decode: prefilled personal sample shows the mobile number', (
    tester,
  ) async {
    await pumpSection(tester, const DecodeSection(isThai: true));

    // DecodeSection prefills a personal payload and decodes live. `0812345678`
    // is the target VALUE — it is NOT present in the payload (`…0066812345678…`)
    // nor in any sample-button label, so it can only come from the decoded
    // result. Gutting the result removes it → red.
    expect(find.textContaining('0812345678'), findsWidgets,
        reason: 'the decoded personal result should show the mobile number');
    expect(tester.takeException(), isNull);
  });

  testWidgets('decode: a bill payload shows the Thai bill result header', (
    tester,
  ) async {
    await pumpSection(tester, const DecodeSection(isThai: true));

    final billPayload = encodeBillPayment(
      billerId: '010553609264101',
      ref1: '000002201649894',
      ref2: 'INV0001',
      amountSatang: 25075,
    );
    await tester.enterText(decodeField(), billPayload);
    await tester.pumpAndSettle();

    // `ชำระบิล` is the bill RESULT header; the bill "load sample" button reads
    // `ตัวอย่างบิล` (no `ชำระบิล`), so this is unique to a successful decode.
    expect(find.textContaining('ชำระบิล'), findsWidgets,
        reason: 'a decoded bill payload should show the bill result header');
    // And the biller id surfaces in the result too.
    expect(find.textContaining('010553609264101'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('decode: garbage input shows an error and no decoded result', (
    tester,
  ) async {
    await pumpSection(tester, const DecodeSection(isThai: true));

    await tester.enterText(decodeField(), 'not a payload');
    await tester.pumpAndSettle();

    // No crash.
    expect(tester.takeException(), isNull);
    // An error/invalid message is shown.
    expect(_errorMessageFinder(), findsWidgets,
        reason: 'garbage input should surface a decode error');
    // The previously-decoded personal result (the prefill) is gone: the target
    // value `0812345678` no longer appears, and no bill header is shown.
    expect(find.textContaining('0812345678'), findsNothing,
        reason: 'a failed decode must not keep showing a personal result');
    expect(find.textContaining('ชำระบิล'), findsNothing,
        reason: 'a failed decode must not show a bill result');
  });
}

/// Text/SelectableText that reads like a decode error (but not the echoed
/// "0002…" payload, and not a sample-button label).
Finder _errorMessageFinder() => find.byWidgetPredicate((w) {
      final s = _widgetText(w);
      if (s == null) return false;
      if (s.startsWith('0002')) return false;
      final lower = s.toLowerCase();
      return lower.contains('invalid') ||
          lower.contains('error') ||
          lower.contains('format') ||
          lower.contains('tlv') ||
          lower.contains('thai_promptpay:') ||
          s.contains('ไม่');
    });

String? _widgetText(Widget w) {
  if (w is Text) return w.data;
  if (w is SelectableText) return w.data;
  return null;
}
