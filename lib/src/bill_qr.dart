import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thai_promptpay/thai_promptpay.dart';

/// A widget that renders a PromptPay **Bill Payment** (EMVCo tag 30) QR code for
/// [billerId] + [ref1] (optionally [ref2] and an [amountSatang], integer
/// satang). Builds the payload with `encodeBillPayment` and draws it with
/// `qr_flutter`.
///
/// If the payload cannot be built (e.g. an invalid biller ID / reference),
/// [errorBuilder] is shown (a default error placeholder when null) — no
/// exception escapes [build].
class PromptPayBillQr extends StatelessWidget {
  /// Creates a Bill Payment QR for [billerId] + [ref1].
  const PromptPayBillQr({
    super.key,
    required this.billerId,
    required this.ref1,
    this.ref2,
    this.amountSatang,
    this.size = 220,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.errorBuilder,
  });

  /// The Biller ID (13- or 15-digit Tax ID [+ 2-digit suffix]).
  final String billerId;

  /// Reference 1 (required).
  final String ref1;

  /// Reference 2 (optional).
  final String? ref2;

  /// Optional amount in integer satang (1 baht = 100 satang); null = no amount.
  final int? amountSatang;

  /// Side length of the QR, in logical pixels.
  final double size;

  /// Padding around the QR (the QR "quiet zone").
  final EdgeInsetsGeometry padding;

  /// Background color behind the QR; null uses a white background.
  final Color? backgroundColor;

  /// Builds a widget shown when the payload cannot be built. When null, a
  /// default placeholder is shown.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// The exact EMVCo bill-payment payload this widget renders — i.e.
  /// `encodeBillPayment(billerId: billerId, ref1: ref1, ref2: ref2,
  /// amountSatang: amountSatang)` — or `null` when the inputs are invalid.
  /// [build] renders this same value.
  String? get payload {
    try {
      return encodeBillPayment(
        billerId: billerId,
        ref1: ref1,
        ref2: ref2,
        amountSatang: amountSatang,
      );
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = payload;
    if (data == null) {
      // Invalid biller ID / reference (PromptPayException implements
      // FormatException). Re-run to surface the specific error to the builder;
      // any non-format error propagates from there.
      Object error = const FormatException(
        'thai_promptpay: invalid bill payment',
      );
      try {
        encodeBillPayment(
          billerId: billerId,
          ref1: ref1,
          ref2: ref2,
          amountSatang: amountSatang,
        );
      } on FormatException catch (e) {
        error = e;
      }
      if (errorBuilder != null) return errorBuilder!(context, error);
      return _defaultError(context, error);
    }

    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      padding: padding.resolve(Directionality.maybeOf(context)),
      backgroundColor: backgroundColor ?? const Color(0xFFFFFFFF),
    );
  }

  /// The fallback placeholder shown when no [errorBuilder] is supplied.
  Widget _defaultError(BuildContext context, Object error) {
    final resolved = padding.resolve(Directionality.maybeOf(context));
    return Container(
      width: size,
      height: size,
      padding: resolved,
      color: backgroundColor ?? const Color(0xFFFFFFFF),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Color(0xFFB00020)),
            SizedBox(height: 8),
            Text(
              'Invalid Bill Payment',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFFB00020)),
            ),
          ],
        ),
      ),
    );
  }
}
