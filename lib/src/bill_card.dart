import 'package:flutter/material.dart';
import 'package:thainum/thainum.dart';

import 'bill_qr.dart';
import 'responsive.dart';

/// A drop-in card showing a PromptPay Bill Payment [PromptPayBillQr] together
/// with a title, the biller / references, and (when [amountSatang] is set and
/// [showAmountText] is true) the amount as Thai baht text.
class PromptPayBillQrCard extends StatelessWidget {
  /// Creates a Bill Payment QR card for [billerId] + [ref1].
  const PromptPayBillQrCard({
    super.key,
    required this.billerId,
    required this.ref1,
    this.ref2,
    this.amountSatang,
    this.title,
    this.billerLabel,
    this.showReferences = true,
    this.showAmountText = true,
    this.qrSize = 220,
  });

  /// The Biller ID (13- or 15-digit Tax ID [+ 2-digit suffix]).
  final String billerId;

  /// Reference 1 (required).
  final String ref1;

  /// Reference 2 (optional).
  final String? ref2;

  /// Optional amount in integer satang; null = no amount.
  final int? amountSatang;

  /// Optional heading shown above the QR (e.g. "Bill Payment").
  final String? title;

  /// Optional human-readable biller name shown under the QR.
  final String? billerLabel;

  /// Whether to show the Biller ID / Ref1 / Ref2 rows.
  final bool showReferences;

  /// Whether to show the amount as Thai baht text (via `thainum`) when an
  /// amount is set.
  final bool showAmountText;

  /// Side length of the embedded QR, in logical pixels.
  final double qrSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ResponsiveCardBody(
      qrSize: qrSize,
      childrenBuilder: (effectiveQrSize) {
        final children = <Widget>[
          Text(
            title ?? 'ชำระบิล / Bill Payment',
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          PromptPayBillQr(
            billerId: billerId,
            ref1: ref1,
            ref2: ref2,
            amountSatang: amountSatang,
            size: effectiveQrSize,
          ),
        ];

        if (billerLabel != null) {
          children
            ..add(const SizedBox(height: 8))
            ..add(
              Text(
                billerLabel!,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            );
        }

        if (showReferences) {
          children
            ..add(const SizedBox(height: 8))
            ..add(
              Text(
                'Biller: $billerId',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
            ..add(
              Text(
                'Ref1: $ref1',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            );
          if (ref2 != null) {
            children.add(
              Text(
                'Ref2: ${ref2!}',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            );
          }
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

        return children;
      },
    );
  }
}
