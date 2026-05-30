import 'package:flutter/material.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'thai_promptpay_flutter',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('thai_promptpay_flutter')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A drop-in card: QR + recipient + amount in baht text.
                const PromptPayQrCard(
                  target: PromptPayTarget(
                    PromptPayType.mobile,
                    '0812345678',
                  ),
                  amountSatang: 10000, // 100.00 baht
                  title: 'พร้อมเพย์ / PromptPay',
                  recipientLabel: 'ร้านกาแฟ',
                ),
                const SizedBox(height: 24),
                // The bare QR widget (static, no amount) via a convenience ctor.
                PromptPayQr.mobile('0898765432', size: 180),
                const SizedBox(height: 24),
                // A live "enter an amount" QR.
                const _LiveAmountDemo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Type a baht amount and watch the QR update.
class _LiveAmountDemo extends StatefulWidget {
  const _LiveAmountDemo();

  @override
  State<_LiveAmountDemo> createState() => _LiveAmountDemoState();
}

class _LiveAmountDemoState extends State<_LiveAmountDemo> {
  int? _satang;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          child: PromptPayAmountField(
            onChanged: (s) => setState(() => _satang = s),
          ),
        ),
        const SizedBox(height: 12),
        PromptPayQr.mobile('0811112222', amountSatang: _satang, size: 180),
      ],
    );
  }
}
