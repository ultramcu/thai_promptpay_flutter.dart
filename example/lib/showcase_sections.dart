import 'package:flutter/material.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

// Showcase sections for the gallery (Dev A). Each is a small, self-contained
// demo of one widget. `isThai` selects the label language.

/// Bare [PromptPayQr] via the `.mobile` / `.nationalId` / `.eWallet` ctors.
class BareQrSection extends StatelessWidget {
  /// Creates the bare-QR showcase.
  const BareQrSection({super.key, required this.isThai});

  /// Whether labels are Thai (else English).
  final bool isThai;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _QrWithCaption(
          qr: PromptPayQr.mobile('0812345678', size: 130),
          caption: isThai ? 'มือถือ' : 'Mobile',
        ),
        _QrWithCaption(
          qr: PromptPayQr.nationalId('1101700230708', size: 130),
          caption: isThai ? 'บัตร ปชช.' : 'National ID',
        ),
        _QrWithCaption(
          qr: PromptPayQr.eWallet('004999000000001', size: 130),
          caption: 'e-Wallet',
        ),
      ],
    );
  }
}

/// A small QR with a caption beneath it.
class _QrWithCaption extends StatelessWidget {
  const _QrWithCaption({required this.qr, required this.caption});

  final Widget qr;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        qr,
        const SizedBox(height: 4),
        Text(caption, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// A [PromptPayQrCard] showcase.
class QrCardSection extends StatelessWidget {
  /// Creates the QR-card showcase.
  const QrCardSection({super.key, required this.isThai});

  /// Whether labels are Thai (else English).
  final bool isThai;

  @override
  Widget build(BuildContext context) {
    return PromptPayQrCard(
      target: const PromptPayTarget(PromptPayType.mobile, '0812345678'),
      amountSatang: 10000,
      title: isThai ? 'พร้อมเพย์' : 'PromptPay',
      recipientLabel: isThai ? 'ร้านกาแฟ' : 'Coffee shop',
    );
  }
}

/// A live "type an amount → QR updates" showcase using [PromptPayAmountField].
class AmountFieldSection extends StatefulWidget {
  /// Creates the amount-field showcase.
  const AmountFieldSection({super.key, required this.isThai});

  /// Whether labels are Thai (else English).
  final bool isThai;

  @override
  State<AmountFieldSection> createState() => _AmountFieldSectionState();
}

class _AmountFieldSectionState extends State<AmountFieldSection> {
  int? _satang;

  @override
  Widget build(BuildContext context) {
    final isThai = widget.isThai;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          child: PromptPayAmountField(
            onChanged: (s) => setState(() => _satang = s),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isThai
              ? 'พิมพ์จำนวนเงิน → QR อัปเดต'
              : 'Type an amount → the QR updates',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        PromptPayQr.mobile('0811112222', amountSatang: _satang, size: 170),
      ],
    );
  }
}

/// A [PromptPayBillQr] showcase.
class BillQrSection extends StatelessWidget {
  /// Creates the bill-QR showcase.
  const BillQrSection({super.key, required this.isThai});

  /// Whether labels are Thai (else English).
  final bool isThai;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PromptPayBillQr(
          billerId: '010553609264101',
          ref1: '000002201649894',
          ref2: 'INV0001',
          amountSatang: 25075,
          size: 190,
        ),
        const SizedBox(height: 8),
        Text(
          isThai ? 'บิล: การไฟฟ้า' : 'Bill: electricity',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A [PromptPayBillQrCard] showcase.
class BillCardSection extends StatelessWidget {
  /// Creates the bill-card showcase.
  const BillCardSection({super.key, required this.isThai});

  /// Whether labels are Thai (else English).
  final bool isThai;

  @override
  Widget build(BuildContext context) {
    return PromptPayBillQrCard(
      billerId: '010553609264101',
      ref1: '000002201649894',
      ref2: 'INV0001',
      amountSatang: 25075,
      title: isThai ? 'ชำระบิล' : 'Bill Payment',
      billerLabel: isThai ? 'การไฟฟ้านครหลวง' : 'Metropolitan Electricity',
    );
  }
}
