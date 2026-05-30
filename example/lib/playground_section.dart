import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

// Interactive sections for the gallery (Dev B): a "build your QR" playground and
// a "decode a payload" demo. `isThai` selects the label language.

/// The kind of recipient the playground builds a QR for. Mirrors the personal
/// [PromptPayType]s plus a Bill Payment option (a different codec path).
enum _PlaygroundKind { mobile, nationalId, eWallet, bill }

/// A `฿`-prefixed baht amount for an integer satang value, e.g. `25075` →
/// `'฿250.75'`. Uses the re-exported [bahtStringFromSatang] so we stay clear of
/// importing `thainum` directly (which the example does not depend on).
String _thb(int satang) => '฿${bahtStringFromSatang(satang)}';

/// An interactive playground: pick a recipient type, enter the number /
/// biller + references and an amount, and see the live QR + payload string.
class PlaygroundSection extends StatefulWidget {
  /// Creates the playground.
  const PlaygroundSection({super.key, required this.isThai});

  /// Whether labels are Thai (else English).
  final bool isThai;

  @override
  State<PlaygroundSection> createState() => _PlaygroundSectionState();
}

class _PlaygroundSectionState extends State<PlaygroundSection> {
  // The reference numbers from the build contract (all codec-valid).
  static const _refMobile = '0812345678';
  static const _refNationalId = '1101700230708';
  static const _refEWallet = '004999000000001';
  static const _refBillerId = '010553609264101';
  static const _refRef1 = '000002201649894';
  static const _refRef2 = 'INV0001';

  _PlaygroundKind _kind = _PlaygroundKind.mobile;
  int? _satang;

  // The single "number / ID" field for the personal kinds, prefilled with the
  // mobile reference number to start.
  final _numberCtrl = TextEditingController(text: _refMobile);

  // The three bill-payment fields, prefilled with the reference bill.
  final _billerCtrl = TextEditingController(text: _refBillerId);
  final _ref1Ctrl = TextEditingController(text: _refRef1);
  final _ref2Ctrl = TextEditingController(text: _refRef2);

  @override
  void initState() {
    super.initState();
    // Rebuild the live QR + payload on every keystroke.
    for (final c in [_numberCtrl, _billerCtrl, _ref1Ctrl, _ref2Ctrl]) {
      c.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _billerCtrl.dispose();
    _ref1Ctrl.dispose();
    _ref2Ctrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  String _t(String th, String en) => widget.isThai ? th : en;

  /// Prefills the relevant field with this kind's reference value when the type
  /// changes (only the personal "number" field — the bill fields keep their own
  /// values).
  void _selectKind(_PlaygroundKind kind) {
    setState(() {
      _kind = kind;
      switch (kind) {
        case _PlaygroundKind.mobile:
          _numberCtrl.text = _refMobile;
        case _PlaygroundKind.nationalId:
          _numberCtrl.text = _refNationalId;
        case _PlaygroundKind.eWallet:
          _numberCtrl.text = _refEWallet;
        case _PlaygroundKind.bill:
          break;
      }
    });
  }

  String _kindLabel(_PlaygroundKind kind) {
    switch (kind) {
      case _PlaygroundKind.mobile:
        return _t('มือถือ', 'Mobile');
      case _PlaygroundKind.nationalId:
        return _t('บัตร ปชช.', 'National ID');
      case _PlaygroundKind.eWallet:
        return 'e-Wallet';
      case _PlaygroundKind.bill:
        return _t('ชำระบิล', 'Bill Payment');
    }
  }

  /// The QR widget for the current inputs. It renders its own error placeholder
  /// (via [errorBuilder]) on invalid input — it never throws.
  Widget _buildQr() {
    if (_kind == _PlaygroundKind.bill) {
      final ref2 = _ref2Ctrl.text;
      return PromptPayBillQr(
        billerId: _billerCtrl.text,
        ref1: _ref1Ctrl.text,
        ref2: ref2.isEmpty ? null : ref2,
        amountSatang: _satang,
        size: 200,
        errorBuilder: _qrError,
      );
    }
    final type = switch (_kind) {
      _PlaygroundKind.mobile => PromptPayType.mobile,
      _PlaygroundKind.nationalId => PromptPayType.nationalId,
      _PlaygroundKind.eWallet => PromptPayType.eWallet,
      _PlaygroundKind.bill => PromptPayType.mobile, // unreachable
    };
    return PromptPayQr(
      target: PromptPayTarget(type, _numberCtrl.text),
      amountSatang: _satang,
      size: 200,
      errorBuilder: _qrError,
    );
  }

  /// The current payload string, or null when the inputs are invalid.
  String? get _payload {
    if (_kind == _PlaygroundKind.bill) {
      final ref2 = _ref2Ctrl.text;
      return PromptPayBillQr(
        billerId: _billerCtrl.text,
        ref1: _ref1Ctrl.text,
        ref2: ref2.isEmpty ? null : ref2,
        amountSatang: _satang,
      ).payload;
    }
    final type = switch (_kind) {
      _PlaygroundKind.mobile => PromptPayType.mobile,
      _PlaygroundKind.nationalId => PromptPayType.nationalId,
      _PlaygroundKind.eWallet => PromptPayType.eWallet,
      _PlaygroundKind.bill => PromptPayType.mobile, // unreachable
    };
    return PromptPayQr(
      target: PromptPayTarget(type, _numberCtrl.text),
      amountSatang: _satang,
    ).payload;
  }

  Widget _qrError(BuildContext context, Object error) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 200,
      height: 200,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2, color: scheme.onErrorContainer),
          const SizedBox(height: 8),
          Text(
            _t('ใส่ข้อมูลให้ถูกต้องเพื่อสร้าง QR',
                'Enter valid input to build a QR'),
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onErrorContainer, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(String payload) async {
    await Clipboard.setData(ClipboardData(text: payload));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_t('คัดลอก payload แล้ว', 'Payload copied')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payload = _payload;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Type selector.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final kind in _PlaygroundKind.values)
              ChoiceChip(
                label: Text(_kindLabel(kind)),
                selected: _kind == kind,
                onSelected: (_) => _selectKind(kind),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Input field(s) for the selected kind.
        if (_kind == _PlaygroundKind.bill) ...[
          TextField(
            controller: _billerCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _t('รหัสผู้รับชำระ (Biller ID)', 'Biller ID'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ref1Ctrl,
            decoration: const InputDecoration(
              labelText: 'Ref1',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ref2Ctrl,
            decoration: InputDecoration(
              labelText: _t('Ref2 (ไม่บังคับ)', 'Ref2 (optional)'),
              border: const OutlineInputBorder(),
            ),
          ),
        ] else
          TextField(
            controller: _numberCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _t('หมายเลข / เลขประจำตัว', 'Number / ID'),
              border: const OutlineInputBorder(),
            ),
          ),
        const SizedBox(height: 16),

        // Amount.
        Center(
          child: SizedBox(
            width: 200,
            child: PromptPayAmountField(
              onChanged: (s) => setState(() => _satang = s),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Live QR.
        Center(child: _buildQr()),
        const SizedBox(height: 16),

        // Payload string + copy button.
        Text(
          _t('payload ที่ได้:', 'Payload:'),
          style: textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        SelectableText(
          payload ??
              _t('(ข้อมูลไม่ถูกต้อง — ยังสร้าง payload ไม่ได้)',
                  '(invalid input — no payload yet)'),
          style: textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: payload == null ? Theme.of(context).colorScheme.error : null,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: payload == null ? null : () => _copy(payload),
            icon: const Icon(Icons.copy, size: 18),
            label: Text(_t('คัดลอก', 'Copy')),
          ),
        ),
      ],
    );
  }
}

/// A decode demo: paste a PromptPay payload and see who/how-much via
/// [decodeAny] (personal or bill payment). Decoding runs live on every change.
class DecodeSection extends StatefulWidget {
  /// Creates the decode demo.
  const DecodeSection({super.key, required this.isThai});

  /// Whether labels are Thai (else English).
  final bool isThai;

  @override
  State<DecodeSection> createState() => _DecodeSectionState();
}

class _DecodeSectionState extends State<DecodeSection> {
  late final TextEditingController _input;

  @override
  void initState() {
    super.initState();
    // Prefilled with a valid personal sample, built at runtime.
    _input = TextEditingController(
      text: promptPayMobile('0812345678', amountSatang: 10000),
    )..addListener(_onChanged);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  String _t(String th, String en) => widget.isThai ? th : en;

  void _loadPersonal() =>
      _input.text = promptPayMobile('0812345678', amountSatang: 10000);

  void _loadBill() => _input.text = encodeBillPayment(
        billerId: '010553609264101',
        ref1: '000002201649894',
        ref2: 'INV0001',
        amountSatang: 25075,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _input,
          maxLines: 4,
          minLines: 2,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontFamily: 'monospace'),
          decoration: InputDecoration(
            labelText: _t('วาง payload พร้อมเพย์', 'Paste a PromptPay payload'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: _loadPersonal,
              child: Text(_t('ตัวอย่างบุคคล', 'Personal sample')),
            ),
            OutlinedButton(
              onPressed: _loadBill,
              child: Text(_t('ตัวอย่างบิล', 'Bill sample')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildResult(context),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    PromptPayQrPayload decoded;
    try {
      decoded = decodeAny(_input.text);
    } on FormatException catch (e) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                e.message,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      );
    }

    final rows = <Widget>[];
    switch (decoded) {
      case PromptPayPayload p:
        rows.add(_kindHeader(_t('บุคคล', 'Personal')));
        rows.add(_row(_t('ชนิด', 'Type'), p.target.type.name));
        rows.add(_row(_t('ค่า', 'Value'), p.target.value));
        rows.add(_row(
          _t('จำนวนเงิน', 'Amount'),
          p.amountSatang == null ? _t('ไม่ระบุ', '—') : _thb(p.amountSatang!),
        ));
        rows.add(_row(
          _t('ไดนามิก (ครั้งเดียว)', 'Dynamic (one-time)'),
          p.isDynamic ? _t('ใช่', 'yes') : _t('ไม่', 'no'),
        ));
      case BillPaymentPayload b:
        rows.add(_kindHeader(_t('ชำระบิล', 'Bill Payment')));
        rows.add(_row('Biller ID', b.billerId));
        rows.add(_row('Ref1', b.ref1));
        rows.add(_row('Ref2', b.ref2 ?? _t('ไม่มี', '—')));
        rows.add(_row(
          _t('จำนวนเงิน', 'Amount'),
          b.amountSatang == null ? _t('ไม่ระบุ', '—') : _thb(b.amountSatang!),
        ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _kindHeader(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Expanded(
              child: SelectableText(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
}
