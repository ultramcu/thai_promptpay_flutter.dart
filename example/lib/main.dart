import 'package:flutter/material.dart';

import 'playground_section.dart';
import 'showcase_sections.dart';

void main() => runApp(const ExampleApp());

/// The thai_promptpay_flutter gallery: a runnable tour of every widget plus an
/// interactive "build your QR" playground and a "decode a payload" demo.
class ExampleApp extends StatefulWidget {
  /// Creates the gallery app.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _isThai = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'thai_promptpay_flutter gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: GalleryHome(
        isThai: _isThai,
        onToggleLanguage: () => setState(() => _isThai = !_isThai),
      ),
    );
  }
}

/// The gallery scaffold: an app bar with a TH/EN toggle and a scrolling list of
/// titled demo sections.
class GalleryHome extends StatelessWidget {
  /// Creates the gallery home.
  const GalleryHome({
    super.key,
    required this.isThai,
    required this.onToggleLanguage,
  });

  /// Whether section labels are shown in Thai (else English).
  final bool isThai;

  /// Toggles the gallery language.
  final VoidCallback onToggleLanguage;

  String _t(String th, String en) => isThai ? th : en;

  @override
  Widget build(BuildContext context) {
    final sections = <(_DemoMeta, Widget)>[
      (
        _DemoMeta(
          _t('QR พร้อมเพย์ (มือถือ/บัตร ปชช./e-Wallet)',
              'PromptPay QR (mobile / National ID / e-Wallet)'),
          _t('วิดเจ็ต PromptPayQr ผ่าน constructor ลัด',
              'The PromptPayQr widget via its convenience constructors'),
        ),
        BareQrSection(isThai: isThai),
      ),
      (
        _DemoMeta(
          _t('การ์ด QR', 'QR card'),
          _t('PromptPayQrCard — การ์ดสำเร็จรูปพร้อมข้อความบาทไทย',
              'PromptPayQrCard — a drop-in card with Thai baht text'),
        ),
        QrCardSection(isThai: isThai),
      ),
      (
        _DemoMeta(
          _t('ช่องกรอกจำนวนเงิน (สด)', 'Amount field (live)'),
          _t('พิมพ์จำนวนเงิน → QR อัปเดตทันที',
              'Type an amount → the QR updates live'),
        ),
        AmountFieldSection(isThai: isThai),
      ),
      (
        _DemoMeta(
          _t('QR ชำระบิล', 'Bill Payment QR'),
          _t('PromptPayBillQr — Biller ID + Ref1/Ref2',
              'PromptPayBillQr — Biller ID + Ref1/Ref2'),
        ),
        BillQrSection(isThai: isThai),
      ),
      (
        _DemoMeta(
          _t('การ์ดชำระบิล', 'Bill Payment card'),
          _t('PromptPayBillQrCard — การ์ดบิลพร้อม Ref + จำนวนเงิน',
              'PromptPayBillQrCard — a bill card with references + amount'),
        ),
        BillCardSection(isThai: isThai),
      ),
      (
        _DemoMeta(
          _t('สนามทดลอง (สร้าง QR เอง)', 'Playground (build your QR)'),
          _t('เลือกชนิด กรอกเลข + จำนวนเงิน → QR + payload สด',
              'Pick a type, enter the number + amount → live QR + payload'),
        ),
        PlaygroundSection(isThai: isThai),
      ),
      (
        _DemoMeta(
          _t('ถอดรหัส payload', 'Decode a payload'),
          _t('วาง payload พร้อมเพย์ → ดูว่าใคร/เท่าไร (decodeAny)',
              'Paste a PromptPay payload → see who / how much (decodeAny)'),
        ),
        DecodeSection(isThai: isThai),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('thai_promptpay_flutter'),
        actions: [
          TextButton(
            onPressed: onToggleLanguage,
            child: Text(
              isThai ? 'EN' : 'ไทย',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // A Column in a SingleChildScrollView mounts every section eagerly (unlike
      // a lazy ListView), so the whole gallery is visible/scrollable and every
      // demo is exercised.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final (meta, child) in sections)
                  _DemoCard(meta: meta, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Title + subtitle for a demo section.
class _DemoMeta {
  const _DemoMeta(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

/// A titled card that wraps a single demo [child].
class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.meta, required this.child});

  final _DemoMeta meta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meta.title, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              meta.subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
