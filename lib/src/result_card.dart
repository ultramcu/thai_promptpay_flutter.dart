import 'package:flutter/material.dart';
import 'package:thai_promptpay/thai_promptpay.dart';
import 'package:thainum/thainum.dart';

import 'decode_result.dart';
import 'responsive.dart';

/// A drop-in Material card that displays a decoded Thai QR [ThaiQrResult]:
/// a personal PromptPay QR, a Bill Payment QR, or a Slip Verify Mini-QR.
///
/// Unlike [PromptPayQrCard] / [PromptPayBillQrCard] (which *render* a QR), this
/// card *describes* an already-decoded payload — useful after scanning. It
/// reuses the same responsive shell and `thainum` baht-text helper as those
/// cards.
class ThaiQrResultCard extends StatelessWidget {
  /// Creates a card describing an already-decoded [result].
  const ThaiQrResultCard(this.result, {super.key});

  /// Creates a card by decoding [payload] with [decodeThaiQr]. When the payload
  /// is not a recognized Thai QR (decode returns null) the card shows a
  /// graceful "Not a recognized Thai QR" state.
  ThaiQrResultCard.fromPayload(String payload, {Key? key})
    : this(decodeThaiQr(payload), key: key);

  /// The decoded result, or null when the payload was not recognized.
  final ThaiQrResult? result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ResponsiveCardBody(
      // No embedded QR here; the shell still clamps/scrolls content.
      qrSize: 0,
      childrenBuilder: (_) {
        final result = this.result;
        if (result == null) {
          return [
            Text(
              'ไม่ใช่คิวอาร์ที่รองรับ / Not a recognized Thai QR',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ];
        }
        return switch (result) {
          PromptPayResult(:final payload) => _promptPayChildren(
            payload,
            textTheme,
            theme,
          ),
          BillPaymentResult(:final payload) => _billChildren(
            payload,
            textTheme,
            theme,
          ),
          SlipResult(:final slip) => _slipChildren(slip, textTheme),
        };
      },
    );
  }

  // --- PromptPay -------------------------------------------------------------

  List<Widget> _promptPayChildren(
    PromptPayPayload payload,
    TextTheme textTheme,
    ThemeData theme,
  ) {
    final children = <Widget>[
      Text(
        'พร้อมเพย์ / PromptPay',
        style: textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      _row(
        textTheme,
        _promptPayTypeLabel(payload.target.type),
        payload.target.value,
      ),
    ];
    _appendAmount(children, payload.amountSatang, textTheme, theme);
    _appendDynamic(children, payload.isDynamic, textTheme, theme);
    return children;
  }

  String _promptPayTypeLabel(PromptPayType type) => switch (type) {
    PromptPayType.mobile => 'เบอร์โทร / Mobile',
    PromptPayType.nationalId => 'บัตรประชาชน / National ID',
    PromptPayType.eWallet => 'อีวอลเล็ต / e-Wallet',
  };

  // --- Bill Payment ----------------------------------------------------------

  List<Widget> _billChildren(
    BillPaymentPayload payload,
    TextTheme textTheme,
    ThemeData theme,
  ) {
    final children = <Widget>[
      Text(
        'ชำระบิล / Bill Payment',
        style: textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      _row(textTheme, 'Biller', payload.billerId),
      _row(textTheme, 'Ref1', payload.ref1),
    ];
    if (payload.ref2 != null) {
      children.add(_row(textTheme, 'Ref2', payload.ref2!));
    }
    _appendAmount(children, payload.amountSatang, textTheme, theme);
    _appendDynamic(children, payload.isDynamic, textTheme, theme);
    return children;
  }

  // --- Slip ------------------------------------------------------------------

  List<Widget> _slipChildren(SlipData slip, TextTheme textTheme) {
    return switch (slip) {
      BankSlip(
        :final sendingBankCode,
        :final bank,
        :final transRef,
        :final countryCode,
      ) =>
        [
          Text(
            'สลิปโอนเงิน / Bank Slip',
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _row(textTheme, 'Bank', _bankLabel(bank, sendingBankCode)),
          _row(textTheme, 'Code', sendingBankCode),
          _row(textTheme, 'Trans Ref', transRef),
          _row(textTheme, 'Country', countryCode),
        ],
      TrueMoneySlip(:final eventType, :final transactionId, :final date) => [
        Text(
          'สลิปทรูมันนี่ / TrueMoney Slip',
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _row(textTheme, 'Event', eventType),
        _row(textTheme, 'Transaction', transactionId),
        _row(textTheme, 'Date', date),
      ],
    };
  }

  String _bankLabel(ThaiBank? bank, String code) {
    if (bank == null) return 'Unknown ($code)';
    final th = bank.nameTh;
    return th.isEmpty ? bank.nameEn : '${bank.nameTh} / ${bank.nameEn}';
  }

  // --- Shared helpers --------------------------------------------------------

  /// A centered `label: value` line, matching the existing cards' text style.
  Widget _row(TextTheme textTheme, String label, String value) => Text(
    '$label: $value',
    style: textTheme.bodyMedium,
    textAlign: TextAlign.center,
  );

  /// Appends the amount as numeric THB + Thai baht text, mirroring card.dart.
  void _appendAmount(
    List<Widget> children,
    int? amountSatang,
    TextTheme textTheme,
    ThemeData theme,
  ) {
    if (amountSatang == null) return;
    final satang = Satang(amountSatang);
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
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      );
  }

  void _appendDynamic(
    List<Widget> children,
    bool isDynamic,
    TextTheme textTheme,
    ThemeData theme,
  ) {
    children
      ..add(const SizedBox(height: 8))
      ..add(
        Text(
          isDynamic ? 'แบบไดนามิก / Dynamic' : 'แบบคงที่ / Static',
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      );
  }
}
