import 'package:flutter/services.dart';

/// Matches a valid in-progress baht amount: any number of digits, an optional
/// single decimal point, and at most two fractional digits. The empty string
/// also matches (so the field can be cleared).
final RegExp _bahtInProgress = RegExp(r'^\d*(\.\d{0,2})?$');

/// A [TextInputFormatter] that restricts input to a Thai baht amount: digits, a
/// single decimal point, and at most two fractional digits (e.g. `100`,
/// `100.5`, `100.50`). Used by [PromptPayAmountField].
///
/// The edit is accepted only when the resulting text is a valid in-progress
/// baht amount; otherwise the previous value (and its selection) is kept,
/// effectively rejecting the keystroke. In-progress forms like `''`, `'100.'`
/// and `'100.5'` are accepted; a second `.`, a third fractional digit, and any
/// non-digit/non-dot character are rejected.
class BahtAmountInputFormatter extends TextInputFormatter {
  /// Creates the formatter.
  const BahtAmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_bahtInProgress.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Parses a baht amount string (`'100'`, `'100.5'`, `'100.50'`) into integer
/// satang (1 baht = 100 satang). Returns null when [text] is empty or not a
/// valid amount. Exact — no `double`.
///
/// Rules (after trimming surrounding whitespace):
/// - Accepted: an optional whole part and an optional fractional part of at
///   most two digits, separated by at most one `.`. A leading `.` (`'.5'` →
///   50) and a trailing `.` (`'100.'` → 10000) are permitted. Examples:
///   `'100'` → 10000, `'100.5'` → 10050, `'100.50'` → 10050, `'0.50'` → 50,
///   `'.5'` → 50, `'0'` / `'0.00'` → 0.
/// - Rejected (returns null): empty / whitespace-only, non-numeric characters,
///   more than one `.`, more than two fractional digits, a leading sign
///   (`+`/`-`, so no negatives), or a value with no digits at all (e.g. `'.'`).
int? satangFromBahtString(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;

  // Reject anything outside the permitted shape up front: digits, an optional
  // single `.`, at most two fractional digits. This blocks signs, spaces,
  // non-numeric characters and extra dots.
  if (!RegExp(r'^\d*(\.\d{0,2})?$').hasMatch(trimmed)) return null;

  final dot = trimmed.indexOf('.');
  final String wholePart;
  final String fracPart;
  if (dot < 0) {
    wholePart = trimmed;
    fracPart = '';
  } else {
    wholePart = trimmed.substring(0, dot);
    fracPart = trimmed.substring(dot + 1);
  }

  // Require at least one digit overall (rejects '.' and '').
  if (wholePart.isEmpty && fracPart.isEmpty) return null;

  final int baht = wholePart.isEmpty ? 0 : int.parse(wholePart);
  // Pad the fractional part to exactly two digits (satang). '' → 0, '5' → 50,
  // '50' → 50.
  final fracPadded = fracPart.padRight(2, '0');
  final int frac = fracPadded.isEmpty ? 0 : int.parse(fracPadded);

  return baht * 100 + frac;
}

/// Formats integer [satang] as a clean, editable baht string that parses back
/// via [satangFromBahtString]: `10000` → `'100'`, `10050` → `'100.50'`, `50`
/// → `'0.50'`, `0` → `'0'`. Whole-baht values omit the `.00` suffix.
///
/// Negative [satang] is rejected with an [ArgumentError]; the round-trip
/// property `satangFromBahtString(bahtStringFromSatang(s)) == s` holds for all
/// `s >= 0`.
String bahtStringFromSatang(int satang) {
  if (satang < 0) {
    throw ArgumentError.value(satang, 'satang', 'must not be negative');
  }
  final int baht = satang ~/ 100;
  final int frac = satang % 100;
  if (frac == 0) {
    return '$baht';
  }
  final fracStr = frac.toString().padLeft(2, '0');
  return '$baht.$fracStr';
}
