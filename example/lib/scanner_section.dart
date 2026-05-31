import 'package:flutter/material.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

/// A gallery section that launches the [PromptPayScanner] full-screen and shows
/// the decoded result in a [ThaiQrResultCard].
///
/// The live camera scanner needs a real device with camera permission, so this
/// section opens it on a dedicated screen (rather than inline) and falls back
/// to a friendly message if the platform has no camera.
class ScannerSection extends StatefulWidget {
  /// Creates the scanner showcase.
  const ScannerSection({super.key, required this.isThai});

  /// Whether labels are Thai (else English).
  final bool isThai;

  @override
  State<ScannerSection> createState() => _ScannerSectionState();
}

class _ScannerSectionState extends State<ScannerSection> {
  ThaiQrResult? _result;
  String? _unrecognized;

  String _t(String th, String en) => widget.isThai ? th : en;

  Future<void> _openScanner() async {
    final result = await Navigator.of(context).push<ThaiQrResult>(
      MaterialPageRoute<ThaiQrResult>(
        builder: (_) => _ScannerScreen(isThai: widget.isThai),
      ),
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _unrecognized = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: _openScanner,
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(_t('สแกน QR', 'Scan a QR')),
        ),
        const SizedBox(height: 16),
        if (_result != null)
          ThaiQrResultCard(_result!)
        else if (_unrecognized != null)
          Text(
            _t('ไม่ใช่ QR ของไทย', 'Not a recognized Thai QR'),
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Text(
            _t('แตะปุ่มเพื่อเปิดกล้อง', 'Tap the button to open the camera'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

/// A full-screen camera scanner that pops the route with the first decoded
/// [ThaiQrResult].
class _ScannerScreen extends StatelessWidget {
  const _ScannerScreen({required this.isThai});

  final bool isThai;

  String _t(String th, String en) => isThai ? th : en;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('สแกน QR', 'Scan a QR'))),
      body: PromptPayScanner(
        onResult: (result) => Navigator.of(context).pop(result),
        onUnrecognized: (raw) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t('ไม่ใช่ QR ของไทย', 'Not a recognized Thai QR')),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
