import 'package:thai_promptpay/thai_promptpay.dart';

/// A decoded Thai QR of any supported kind.
///
/// Returned by [decodeThaiQr], which unifies the three distinct Thai QR codecs
/// (`decodeAny` for payable PromptPay/Bill QRs and `tryDecodeSlip` for the
/// receipt-verification Slip Verify Mini-QR) behind one result type. `switch`
/// over it exhaustively (it is `sealed`):
///
/// ```dart
/// final result = decodeThaiQr(payload);
/// switch (result) {
///   case PromptPayResult(:final payload): ...
///   case BillPaymentResult(:final payload): ...
///   case SlipResult(:final slip): ...
///   case null: // not a recognized Thai QR
/// }
/// ```
sealed class ThaiQrResult {
  /// Const supertype constructor.
  const ThaiQrResult();
}

/// A personal PromptPay QR (EMVCo tag 29).
class PromptPayResult extends ThaiQrResult {
  /// Creates a result wrapping a decoded [payload].
  const PromptPayResult(this.payload);

  /// The decoded personal PromptPay payload.
  final PromptPayPayload payload;

  @override
  bool operator ==(Object other) =>
      other is PromptPayResult && other.payload == payload;

  @override
  int get hashCode => payload.hashCode;

  @override
  String toString() => 'PromptPayResult($payload)';
}

/// A Bill Payment QR (EMVCo tag 30).
class BillPaymentResult extends ThaiQrResult {
  /// Creates a result wrapping a decoded [payload].
  const BillPaymentResult(this.payload);

  /// The decoded bill-payment payload.
  final BillPaymentPayload payload;

  @override
  bool operator ==(Object other) =>
      other is BillPaymentResult && other.payload == payload;

  @override
  int get hashCode => payload.hashCode;

  @override
  String toString() => 'BillPaymentResult($payload)';
}

/// A Slip Verify Mini-QR (receipt verification).
class SlipResult extends ThaiQrResult {
  /// Creates a result wrapping a decoded [slip].
  const SlipResult(this.slip);

  /// The decoded slip data (a [BankSlip] or [TrueMoneySlip]).
  final SlipData slip;

  @override
  bool operator ==(Object other) => other is SlipResult && other.slip == slip;

  @override
  int get hashCode => slip.hashCode;

  @override
  String toString() => 'SlipResult($slip)';
}

/// Decodes any supported Thai QR [payload].
///
/// Tries a payable PromptPay / Bill Payment QR first (`decodeAny`), wrapping a
/// [PromptPayPayload] in a [PromptPayResult] and a [BillPaymentPayload] in a
/// [BillPaymentResult]. If that does not match, tries the Slip Verify Mini-QR
/// (`tryDecodeSlip`) and wraps a [SlipData] in a [SlipResult].
///
/// Returns null when [payload] is neither (or its CRC fails). Never throws.
ThaiQrResult? decodeThaiQr(String payload) {
  try {
    final payable = decodeAny(payload);
    switch (payable) {
      case PromptPayPayload():
        return PromptPayResult(payable);
      case BillPaymentPayload():
        return BillPaymentResult(payable);
    }
  } on FormatException {
    // Not a payable PromptPay/Bill QR — fall through to the slip decoder.
  }

  final slip = tryDecodeSlip(payload);
  if (slip != null) {
    return SlipResult(slip);
  }

  return null;
}
