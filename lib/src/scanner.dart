import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'decode_result.dart';

/// A camera QR scanner that decodes Thai PromptPay / Bill / Slip QRs.
///
/// Wraps [`mobile_scanner`](https://pub.dev/packages/mobile_scanner): it shows a
/// live camera preview and, for every detected barcode, runs the raw value
/// through [decodeThaiQr]. The first recognized Thai QR is reported once via
/// [onResult]; an unrecognized QR (a non-Thai-QR barcode) is reported via
/// [onUnrecognized].
///
/// Requires camera permission and platform setup — see the package README
/// ("Scanning / decoding") for the iOS `NSCameraUsageDescription` and Android
/// `CAMERA` / min-SDK requirements that `mobile_scanner` imposes.
///
/// ```dart
/// PromptPayScanner(
///   onResult: (result) {
///     switch (result) {
///       case PromptPayResult(:final payload): ...
///       case BillPaymentResult(:final payload): ...
///       case SlipResult(:final slip): ...
///     }
///   },
/// )
/// ```
///
/// The scanner itself is intentionally thin: all decode intelligence lives in
/// [decodeThaiQr]. To render a decoded result, pair it with `ThaiQrResultCard`.
class PromptPayScanner extends StatefulWidget {
  /// Creates a camera scanner that reports decoded Thai QRs to [onResult].
  const PromptPayScanner({
    super.key,
    required this.onResult,
    this.onUnrecognized,
    this.fit = BoxFit.cover,
  });

  /// Called once with the first successfully-decoded Thai QR.
  ///
  /// After the first recognized QR fires, the scanner stops reporting further
  /// results until [reset] is called on its state via a [GlobalKey], so the
  /// callback is not spammed. Distinct unrecognized codes still flow to
  /// [onUnrecognized].
  final void Function(ThaiQrResult result) onResult;

  /// Called when a barcode is detected but is NOT a recognized Thai QR.
  ///
  /// Receives the barcode's raw value. De-duplicated: the same raw value is
  /// reported at most once.
  final void Function(String rawValue)? onUnrecognized;

  /// The [BoxFit] for the camera preview. Defaults to [BoxFit.cover].
  final BoxFit fit;

  @override
  State<PromptPayScanner> createState() => PromptPayScannerState();
}

/// State for [PromptPayScanner]; exposed so callers holding a [GlobalKey] can
/// [reset] the de-dupe latch to scan again after a hit.
class PromptPayScannerState extends State<PromptPayScanner> {
  final MobileScannerController _controller = MobileScannerController();

  /// Whether a recognized Thai QR has already been reported. Once true, further
  /// detections are ignored until [reset].
  bool _reported = false;

  /// Raw values already routed to `onUnrecognized`, to avoid repeat callbacks.
  final Set<String> _seenUnrecognized = <String>{};

  /// Clears the de-dupe state so the scanner reports the next QR again.
  void reset() {
    _reported = false;
    _seenUnrecognized.clear();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_reported) return;
    if (capture.barcodes.isEmpty) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    final result = decodeThaiQr(raw);
    if (result != null) {
      _reported = true;
      widget.onResult(result);
      return;
    }

    if (_seenUnrecognized.add(raw)) {
      widget.onUnrecognized?.call(raw);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
      fit: widget.fit,
      onDetect: _handleDetect,
    );
  }
}

/// Decodes the first recognized Thai QR found in the still image at [path].
///
/// Uses `mobile_scanner`'s image-analysis API ([MobileScannerController.analyzeImage])
/// to scan the image for barcodes, then runs each raw value through
/// [decodeThaiQr], returning the first [ThaiQrResult] found.
///
/// Returns null when the image has no barcode, no barcode decodes to a Thai QR,
/// or the platform does not support image analysis. Never throws on a bad path
/// or a non-QR image.
Future<ThaiQrResult?> decodeThaiQrFromImage(String path) async {
  final controller = MobileScannerController();
  try {
    final capture = await controller.analyzeImage(path);
    if (capture == null) return null;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;
      final result = decodeThaiQr(raw);
      if (result != null) return result;
    }
    return null;
  } catch (_) {
    // analyzeImage can throw on unsupported platforms, a missing file, or a
    // non-image; keep the helper robust by reporting "no Thai QR".
    return null;
  } finally {
    await controller.dispose();
  }
}
