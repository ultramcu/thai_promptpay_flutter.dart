import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thai_promptpay/thai_promptpay.dart';

/// A widget that renders a PromptPay QR code for [target] (optionally for
/// [amountSatang], integer satang). Builds the EMVCo payload with
/// `encodePromptPay` and draws it with `qr_flutter`.
///
/// If the payload cannot be built (e.g. an invalid number/ID), [errorBuilder]
/// is shown (a default error placeholder when null).
class PromptPayQr extends StatelessWidget {
  /// Creates a PromptPay QR for [target].
  const PromptPayQr({
    super.key,
    required this.target,
    this.amountSatang,
    this.size = 220,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.errorBuilder,
  });

  /// Creates a PromptPay QR paying a Thai mobile number (10-digit local form,
  /// e.g. `'0812345678'`).
  PromptPayQr.mobile(
    String phone, {
    Key? key,
    int? amountSatang,
    double size = 220,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? backgroundColor,
    Widget Function(BuildContext context, Object error)? errorBuilder,
  }) : this(
          key: key,
          target: PromptPayTarget(PromptPayType.mobile, phone),
          amountSatang: amountSatang,
          size: size,
          padding: padding,
          backgroundColor: backgroundColor,
          errorBuilder: errorBuilder,
        );

  /// Creates a PromptPay QR paying a 13-digit National ID / personal Tax ID.
  PromptPayQr.nationalId(
    String id, {
    Key? key,
    int? amountSatang,
    double size = 220,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? backgroundColor,
    Widget Function(BuildContext context, Object error)? errorBuilder,
  }) : this(
          key: key,
          target: PromptPayTarget(PromptPayType.nationalId, id),
          amountSatang: amountSatang,
          size: size,
          padding: padding,
          backgroundColor: backgroundColor,
          errorBuilder: errorBuilder,
        );

  /// Creates a PromptPay QR paying a 15-digit e-Wallet ID.
  PromptPayQr.eWallet(
    String id, {
    Key? key,
    int? amountSatang,
    double size = 220,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? backgroundColor,
    Widget Function(BuildContext context, Object error)? errorBuilder,
  }) : this(
          key: key,
          target: PromptPayTarget(PromptPayType.eWallet, id),
          amountSatang: amountSatang,
          size: size,
          padding: padding,
          backgroundColor: backgroundColor,
          errorBuilder: errorBuilder,
        );

  /// The recipient (mobile / National ID / e-Wallet).
  final PromptPayTarget target;

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

  /// The exact EMVCo PromptPay payload this widget renders — i.e.
  /// `encodePromptPay(target: target, amountSatang: amountSatang)` — or `null`
  /// when [target]/[amountSatang] is invalid. Handy for sharing or copying the
  /// underlying payment string. [build] renders this same value.
  String? get payload {
    try {
      return encodePromptPay(target: target, amountSatang: amountSatang);
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = payload;
    if (data == null) {
      // Invalid number/ID (PromptPayException implements FormatException).
      // Re-run to surface the specific error to the builder; any non-format
      // error propagates from there.
      Object error = const FormatException('thai_promptpay: invalid target');
      try {
        encodePromptPay(target: target, amountSatang: amountSatang);
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
              'Invalid PromptPay target',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFFB00020)),
            ),
          ],
        ),
      ),
    );
  }
}
