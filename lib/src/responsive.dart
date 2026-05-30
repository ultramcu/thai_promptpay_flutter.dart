import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The shared responsive shell for the PromptPay QR cards.
///
/// Renders a [Card] (with [padding], default 16) whose content never overflows:
/// - the embedded QR's side length is clamped to the available width, so it
///   never overflows horizontally on a narrow screen;
/// - the content column is wrapped in a [SingleChildScrollView], so it scrolls
///   instead of overflowing when the available height is tight.
///
/// In normal (height-unbounded) use the column shrink-wraps and nothing scrolls,
/// so the card looks identical to a plain `Card > Padding > Column`.
///
/// [childrenBuilder] receives the effective QR side length — `min(qrSize,
/// availableWidth)` (or [qrSize] when the width is unbounded) — and returns the
/// column children. Callers must build their QR widget with that size.
class ResponsiveCardBody extends StatelessWidget {
  /// Creates the responsive card shell.
  const ResponsiveCardBody({
    super.key,
    required this.qrSize,
    required this.childrenBuilder,
    this.padding = const EdgeInsets.all(16),
  });

  /// The requested QR side length; the effective size is clamped to the
  /// available width.
  final double qrSize;

  /// Builds the column children given the effective (clamped) QR side length.
  final List<Widget> Function(double effectiveQrSize) childrenBuilder;

  /// Padding inside the card around the content.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final effectiveQrSize =
                maxWidth.isFinite ? math.min(qrSize, maxWidth) : qrSize;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: childrenBuilder(effectiveQrSize),
              ),
            );
          },
        ),
      ),
    );
  }
}
