// Blind Test B (Bug-Driven Rabbit) for the baht amount formatter + parsers.
// Written from the public API spec only — does NOT read lib/src/amount.dart.
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

void main() {
  group('satangFromBahtString — valid', () {
    test("'100' -> 10000", () {
      expect(satangFromBahtString('100'), 10000);
    });
    test("'100.5' -> 10050", () {
      expect(satangFromBahtString('100.5'), 10050);
    });
    test("'100.50' -> 10050", () {
      expect(satangFromBahtString('100.50'), 10050);
    });
    test("'0.50' -> 50", () {
      expect(satangFromBahtString('0.50'), 50);
    });
    test("'.5' -> 50 (leading dot)", () {
      expect(satangFromBahtString('.5'), 50);
    });
    test("'0' -> 0", () {
      expect(satangFromBahtString('0'), 0);
    });
    test("'100.' -> 10000 (trailing dot)", () {
      expect(satangFromBahtString('100.'), 10000);
    });
  });

  group('satangFromBahtString — invalid/empty -> null', () {
    test("'' -> null", () {
      expect(satangFromBahtString(''), isNull);
    });
    test("'  ' (whitespace) -> null", () {
      expect(satangFromBahtString('  '), isNull);
    });
    test("'abc' -> null", () {
      expect(satangFromBahtString('abc'), isNull);
    });
    test("'1.2.3' (two dots) -> null", () {
      expect(satangFromBahtString('1.2.3'), isNull);
    });
    test("'1.234' (3 decimals) -> null", () {
      expect(satangFromBahtString('1.234'), isNull);
    });
    test("'-5' (negative) -> null", () {
      expect(satangFromBahtString('-5'), isNull);
    });
    test("'1,000' (comma) -> null", () {
      expect(satangFromBahtString('1,000'), isNull);
    });
  });

  group('bahtStringFromSatang', () {
    test('10000 -> "100"', () {
      expect(bahtStringFromSatang(10000), '100');
    });
    test('10050 -> "100.50"', () {
      expect(bahtStringFromSatang(10050), '100.50');
    });
    test('50 -> "0.50"', () {
      expect(bahtStringFromSatang(50), '0.50');
    });
    test('0 -> "0"', () {
      expect(bahtStringFromSatang(0), '0');
    });
  });

  group('round-trip satang -> baht string -> satang', () {
    for (final s in <int>[0, 1, 50, 99, 100, 10000, 10050, 999999]) {
      test('round-trip $s', () {
        final str = bahtStringFromSatang(s);
        expect(satangFromBahtString(str), s, reason: 'baht string was "$str"');
      });
    }
  });

  group('BahtAmountInputFormatter — accept (returns newValue)', () {
    const formatter = BahtAmountInputFormatter();
    TextEditingValue v(String t) => TextEditingValue(text: t);

    void accept(String oldText, String newText) {
      final result = formatter.formatEditUpdate(v(oldText), v(newText));
      expect(
        result.text,
        newText,
        reason: 'old="$oldText" new="$newText" should be accepted',
      );
    }

    test("accept ''", () => accept('1', ''));
    test("accept '1'", () => accept('', '1'));
    test("accept '100'", () => accept('10', '100'));
    test("accept '100.'", () => accept('100', '100.'));
    test("accept '100.5'", () => accept('100.', '100.5'));
    test("accept '100.50'", () => accept('100.5', '100.50'));
  });

  group('BahtAmountInputFormatter — reject (returns oldValue)', () {
    const formatter = BahtAmountInputFormatter();
    TextEditingValue v(String t) => TextEditingValue(text: t);

    void reject(String oldText, String newText) {
      final result = formatter.formatEditUpdate(v(oldText), v(newText));
      expect(
        result.text,
        oldText,
        reason: 'old="$oldText" new="$newText" should be rejected',
      );
    }

    test('reject 2nd dot', () => reject('100.5', '100.5.'));
    test('reject 3rd decimal', () => reject('100.50', '100.505'));
    test('reject letter', () => reject('100', '100a'));
  });
}
