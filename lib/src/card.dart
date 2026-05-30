import 'package:flutter/material.dart';
import 'package:thai_promptpay/thai_promptpay.dart';
import 'package:thainum/thainum.dart';

import 'qr.dart';

/// A drop-in card showing a PromptPay [PromptPayQr] together with a title, the
/// recipient, and (when [amountSatang] is set and [showAmountText] is true) the
/// amount as Thai baht text.
class PromptPayQrCard extends StatelessWidget {
  /// Creates a PromptPay QR card for [target].
  const PromptPayQrCard({
    super.key,
    required this.target,
    this.amountSatang,
    this.title,
    this.recipientLabel,
    this.showAmountText = true,
    this.qrSize = 220,
  });

  /// The recipient (mobile / National ID / e-Wallet).
  final PromptPayTarget target;

  /// Optional amount in integer satang; null = no amount.
  final int? amountSatang;

  /// Optional heading shown above the QR (e.g. "PromptPay").
  final String? title;

  /// Optional label describing the recipient (e.g. a name); shown under the QR.
  final String? recipientLabel;

  /// Whether to show the amount as Thai baht text (via `thainum`) when an
  /// amount is set.
  final bool showAmountText;

  /// Side length of the embedded QR, in logical pixels.
  final double qrSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final children = <Widget>[
      Text(
        title ?? 'พร้อมเพย์ / PromptPay',
        style: textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      PromptPayQr(
        target: target,
        amountSatang: amountSatang,
        size: qrSize,
      ),
    ];

    if (recipientLabel != null) {
      children
        ..add(const SizedBox(height: 8))
        ..add(
          Text(
            recipientLabel!,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        );
    }

    if (amountSatang != null && showAmountText) {
      final satang = Satang(amountSatang!);
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Text(
            satang.toThb(),
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        )
        ..add(const SizedBox(height: 4))
        ..add(
          Text(
            satang.toBahtText(),
            style: textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
