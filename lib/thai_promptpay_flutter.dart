/// Flutter widgets that render a Thai PromptPay (EMVCo) QR code from a mobile
/// number, National ID / Tax ID or e-Wallet, with an optional amount.
///
/// The pure-Dart [thai_promptpay] codec is re-exported, so importing this
/// package alone gives you `encodePromptPay` / `decodePromptPay`, the
/// `PromptPayTarget` / `PromptPayType` types, etc. for free.
library;

export 'package:thai_promptpay/thai_promptpay.dart';

export 'src/amount.dart'
    show BahtAmountInputFormatter, satangFromBahtString, bahtStringFromSatang;
export 'src/amount_field.dart';
export 'src/card.dart';
export 'src/qr.dart';
