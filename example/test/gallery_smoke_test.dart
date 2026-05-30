// Blind smoke test (Test A) for the thai_promptpay_flutter gallery.
//
// Authored from the build CONTRACT only — the Dev section implementations
// (showcase_sections.dart / playground_section.dart) were NOT read. Assertions
// come from the contract's promised behavior + the public gallery shell
// (main.dart). If a section is still a stub the QR/label assertions fail
// (fail-before) — they are intentionally not weakened.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thai_promptpay_flutter_example/main.dart';

/// Case-insensitive substring finder over [Text] widgets' data.
Finder findTextContainingCi(String needle) {
  final lower = needle.toLowerCase();
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        widget.data!.toLowerCase().contains(lower),
    description: 'Text containing (case-insensitive) "$needle"',
  );
}

void main() {
  // The gallery mounts every section eagerly inside a SingleChildScrollView +
  // Column, so a small default test surface would overflow during layout. Use a
  // large surface (inside each test, where `setSurfaceSize` is permitted) so all
  // eager-mounted sections lay out, then reset on tear-down.
  Future<void> useLargeSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('gallery mounts: app bar + eager QR widgets, no exception',
      (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // No exception on the first frame at a normal (large) test surface.
    expect(tester.takeException(), isNull);

    // App bar title from the gallery shell.
    expect(find.text('thai_promptpay_flutter'), findsOneWidget);

    // The gallery mounts all sections eagerly, so several QR widgets render.
    expect(find.byType(QrImageView), findsWidgets);
  });

  testWidgets('TH/EN toggle switches labels to English and flips toggle text',
      (tester) async {
    await useLargeSurface(tester);
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // Default language is Thai → the toggle reads 'EN'.
    expect(find.text('EN'), findsOneWidget);

    // Tap the toggle to switch to English.
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    // An English section label now appears.
    expect(findTextContainingCi('Bill Payment'), findsWidgets);

    // The toggle now offers the way back to Thai.
    expect(find.text('ไทย'), findsOneWidget);

    // Still no exception after toggling.
    expect(tester.takeException(), isNull);
  });
}
