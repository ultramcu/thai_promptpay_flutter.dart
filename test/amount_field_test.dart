// Blind Test A (Bug-Driven Rabbit) for PromptPayAmountField.
// Written from the public API + spec only; the implementation in
// lib/src/amount_field.dart was NOT read.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

/// Pumps [child] inside a minimal MaterialApp/Scaffold so a TextField can mount.
Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

/// Reads the live text out of the (single) TextField under test.
String _fieldText(WidgetTester tester) {
  return tester.widget<TextField>(find.byType(TextField)).controller!.text;
}

void main() {
  group('PromptPayAmountField', () {
    testWidgets('onChanged reports integer satang (null when empty)', (
      tester,
    ) async {
      int? captured = -1; // sentinel distinct from null
      await _pump(tester, PromptPayAmountField(onChanged: (s) => captured = s));

      await tester.enterText(find.byType(TextField), '100.50');
      await tester.pump();
      expect(captured, 10050, reason: '100.50 baht == 10050 satang');

      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();
      expect(captured, 10000, reason: '100 baht == 10000 satang');

      await tester.enterText(find.byType(TextField), '0.50');
      await tester.pump();
      expect(captured, 50, reason: '0.50 baht == 50 satang');

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(captured, isNull, reason: 'empty field reports null');
    });

    testWidgets('initialSatang prefills the field (round-trips)', (
      tester,
    ) async {
      await _pump(tester, const PromptPayAmountField(initialSatang: 12345));

      final text = _fieldText(tester);
      // The prefilled text must decode back to the original satang amount.
      expect(
        satangFromBahtString(text),
        12345,
        reason: 'initialSatang 12345 should round-trip; got "$text"',
      );
    });

    testWidgets('default decoration shows the ฿ prefix', (tester) async {
      await _pump(tester, PromptPayAmountField(onChanged: (_) {}));

      final field = tester.widget<TextField>(find.byType(TextField));
      final prefix = field.decoration?.prefixText;
      // Accept either a rendered ฿ text widget or a prefixText of '฿'.
      final hasPrefixText = prefix != null && prefix.contains('฿');
      final hasPrefixWidget = find.text('฿').evaluate().isNotEmpty;
      expect(
        hasPrefixText || hasPrefixWidget,
        isTrue,
        reason: 'expected a ฿ prefix; prefixText was "$prefix"',
      );
    });

    testWidgets('formatter restricts input to digits + at most 2 decimals', (
      tester,
    ) async {
      await _pump(tester, PromptPayAmountField(onChanged: (_) {}));

      final ok = RegExp(r'^\d*(\.\d{0,2})?$');

      // A 3rd decimal digit must be rejected (result stays <= 2 dp).
      await tester.enterText(find.byType(TextField), '1.234');
      await tester.pump();
      final after3dp = _fieldText(tester);
      expect(
        ok.hasMatch(after3dp),
        isTrue,
        reason: '3-decimal input should be clamped to <=2dp; got "$after3dp"',
      );
      // The result must never be a 3-decimal string. (Atomic enterText may
      // either clamp to "1.23" or reject the whole edit and keep ""; both are
      // spec-valid as long as no >2dp value survives.)
      expect(
        after3dp.contains('.234'),
        isFalse,
        reason: 'the 3rd decimal must not survive; got "$after3dp"',
      );
      if (after3dp.isNotEmpty) {
        expect(
          satangFromBahtString(after3dp),
          isNotNull,
          reason: '"$after3dp" must be a valid <=2dp baht string',
        );
      }

      // Incremental: once "1.23" is in place, the formatter must not let a
      // 3rd decimal be appended (this is the load-bearing clamp behavior).
      final field = tester.widget<TextField>(find.byType(TextField));
      field.controller!.text = '1.23';
      await tester.pump();
      // Simulate appending a '4' at the end via the diff the keyboard sends.
      await tester.enterText(find.byType(TextField), '1.234');
      await tester.pump();
      final appended = _fieldText(tester);
      expect(
        appended.contains('.234'),
        isFalse,
        reason: 'appending a 3rd decimal must be rejected; got "$appended"',
      );

      // A second dot must not survive.
      await tester.enterText(find.byType(TextField), '1.2.3');
      await tester.pump();
      final afterTwoDots = _fieldText(tester);
      expect(
        '.'.allMatches(afterTwoDots).length <= 1,
        isTrue,
        reason: 'at most one decimal point allowed; got "$afterTwoDots"',
      );
      expect(
        ok.hasMatch(afterTwoDots),
        isTrue,
        reason: 'two-dot input should be sanitized; got "$afterTwoDots"',
      );
    });

    testWidgets('owned controller is disposed cleanly (no leak/exception)', (
      tester,
    ) async {
      await _pump(tester, PromptPayAmountField(onChanged: (_) {}));
      await tester.enterText(find.byType(TextField), '12.34');
      await tester.pump();

      // Replace the field with a different widget to force dispose().
      await _pump(tester, const SizedBox.shrink());
      expect(
        tester.takeException(),
        isNull,
        reason: 'disposing the field must not throw',
      );
    });

    testWidgets('external controller is NOT disposed by the field', (
      tester,
    ) async {
      final external = TextEditingController();
      addTearDown(external.dispose); // we still own it

      await _pump(
        tester,
        PromptPayAmountField(controller: external, onChanged: (_) {}),
      );
      await tester.enterText(find.byType(TextField), '5.00');
      await tester.pump();
      expect(
        external.text.isNotEmpty,
        isTrue,
        reason: 'external controller should receive typed text',
      );

      // Dispose the field by swapping the tree.
      await _pump(tester, const SizedBox.shrink());
      expect(
        tester.takeException(),
        isNull,
        reason: 'field dispose must not throw with an external controller',
      );

      // If the field had disposed our controller, touching it now would throw.
      expect(
        () => external.text,
        returnsNormally,
        reason: 'external controller must still be usable after field dispose',
      );
      expect(
        () => external.text = '9.99',
        returnsNormally,
        reason: 'external controller must not be disposed by the field',
      );
    });
  });
}
