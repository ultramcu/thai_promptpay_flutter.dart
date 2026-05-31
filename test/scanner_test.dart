import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

void main() {
  group('PromptPayScanner', () {
    // mobile_scanner needs a real camera/platform, so we don't drive the
    // camera here — we only assert the widget configures itself and builds
    // without throwing. The MobileScanner preview is a platform view that no-ops
    // under the test binding, so pumping it is safe.
    testWidgets('builds inside a MaterialApp without throwing', (tester) async {
      var hits = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromptPayScanner(
              onResult: (_) => hits++,
              onUnrecognized: (_) {},
            ),
          ),
        ),
      );

      // The widget mounted and is in the tree.
      expect(find.byType(PromptPayScanner), findsOneWidget);
      // No camera frames arrive headless, so onResult never fires.
      expect(hits, 0);
    });

    testWidgets('disposes cleanly when removed from the tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PromptPayScanner(onResult: (_) {}))),
      );
      expect(find.byType(PromptPayScanner), findsOneWidget);

      // Replacing the subtree triggers PromptPayScannerState.dispose, which
      // disposes the MobileScannerController. Should not throw.
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      expect(find.byType(PromptPayScanner), findsNothing);
    });
  });

  group('decodeThaiQrFromImage', () {
    test('returns null (no throw) for a nonexistent path', () async {
      // analyzeImage is unsupported / errors under the headless test binding;
      // the helper must swallow that and report "no Thai QR".
      final result = await decodeThaiQrFromImage('nonexistent.png');
      expect(result, isNull);
    });
  });
}
