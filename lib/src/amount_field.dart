import 'package:flutter/material.dart';

import 'amount.dart';

/// A text field for entering a Thai baht amount, reporting the value as integer
/// **satang** through [onChanged] (null when the field is empty). Input is
/// restricted to digits and at most two decimal places, with a `฿` prefix.
///
/// Wire it to a `PromptPayQr` to build a live "enter an amount" payment screen.
class PromptPayAmountField extends StatefulWidget {
  /// Creates a baht amount field.
  const PromptPayAmountField({
    super.key,
    this.initialSatang,
    this.onChanged,
    this.decoration,
    this.controller,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
  });

  /// Initial amount in satang to pre-fill (formatted as baht); null = empty.
  final int? initialSatang;

  /// Called with the entered amount in integer satang (null when empty).
  final ValueChanged<int?>? onChanged;

  /// Decoration override; a sensible default (label + `฿` prefix) is used when
  /// null.
  final InputDecoration? decoration;

  /// Optional external controller. When null the field owns one and disposes it.
  final TextEditingController? controller;

  /// Optional validator receiving the parsed satang (null when empty/invalid).
  final String? Function(int? satang)? validator;

  /// Whether the field is interactive.
  final bool enabled;

  /// Whether the field autofocuses.
  final bool autofocus;

  @override
  State<PromptPayAmountField> createState() => _PromptPayAmountFieldState();
}

class _PromptPayAmountFieldState extends State<PromptPayAmountField> {
  /// A controller created and owned by this State when [widget.controller] is
  /// null; disposed exactly once in [dispose]. Stays null when the consumer
  /// supplied their own controller (which we must NOT dispose).
  TextEditingController? _ownController;

  /// The controller actually wired to the field: the external one if given,
  /// otherwise our owned one.
  TextEditingController get _controller => widget.controller ?? _ownController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      // We own this controller, so we may safely seed and later dispose it.
      _ownController = TextEditingController(
        text:
            widget.initialSatang == null
                ? ''
                : bahtStringFromSatang(widget.initialSatang!),
      );
    } else if (widget.initialSatang != null &&
        widget.controller!.text.isEmpty) {
      // Honour initialSatang only when the external controller is empty, so we
      // never clobber text the consumer already placed in their controller.
      widget.controller!.text = bahtStringFromSatang(widget.initialSatang!);
    }
  }

  @override
  void dispose() {
    // Dispose ONLY the controller we created. The external controller belongs
    // to the consumer and must outlive this widget.
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: const [BahtAmountInputFormatter()],
      decoration:
          widget.decoration ??
          const InputDecoration(labelText: 'จำนวนเงิน (บาท)', prefixText: '฿'),
      onChanged: (text) => widget.onChanged?.call(satangFromBahtString(text)),
      validator:
          widget.validator == null
              ? null
              : (text) => widget.validator!(satangFromBahtString(text ?? '')),
    );
  }
}
