import 'package:flutter_test/flutter_test.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

void main() {
  group('decodeThaiQr', () {
    test('decodes a personal PromptPay QR into a PromptPayResult', () {
      final payload = promptPayMobile('0812345678', amountSatang: 5000);

      final result = decodeThaiQr(payload);

      expect(result, isA<PromptPayResult>());
      final payment = (result! as PromptPayResult).payload;
      expect(payment.target.type, PromptPayType.mobile);
      expect(payment.target.value, '0812345678');
      expect(payment.amountSatang, 5000);
    });

    test('decodes a Bill Payment QR into a BillPaymentResult', () {
      final payload = encodeBillPayment(
        billerId: '1234567890123',
        ref1: 'INV001',
        amountSatang: 25000,
      );

      final result = decodeThaiQr(payload);

      expect(result, isA<BillPaymentResult>());
      final bill = (result! as BillPaymentResult).payload;
      expect(bill.billerId, '1234567890123');
      expect(bill.ref1, 'INV001');
      expect(bill.amountSatang, 25000);
    });

    test('decodes a bank Slip Verify Mini-QR into a SlipResult/BankSlip', () {
      const payload =
          '004100060000010103014022000111222233344ABCD125102TH910417DF';

      final result = decodeThaiQr(payload);

      expect(result, isA<SlipResult>());
      final slip = (result! as SlipResult).slip;
      expect(slip, isA<BankSlip>());
      final bank = slip as BankSlip;
      expect(bank.sendingBankCode, '014');
      expect(bank.transRef, '00111222233344ABCD12');
      expect(bank.bank?.nameEn, 'Siam Commercial Bank');
      expect(bank.countryCode, 'TH');
    });

    test('decodes a TrueMoney slip into a SlipResult/TrueMoneySlip', () {
      const payload =
          '00490002010102010203P2P0314TXID12345678900408310520269104f05e';

      final result = decodeThaiQr(payload);

      expect(result, isA<SlipResult>());
      final slip = (result! as SlipResult).slip;
      expect(slip, isA<TrueMoneySlip>());
      final tm = slip as TrueMoneySlip;
      expect(tm.eventType, 'P2P');
      expect(tm.transactionId, 'TXID1234567890');
    });

    test('returns null for an unrecognized payload', () {
      expect(decodeThaiQr('garbage'), isNull);
    });
  });
}
