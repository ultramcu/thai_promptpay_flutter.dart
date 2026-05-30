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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
