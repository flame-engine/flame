import 'package:flutter/material.dart';

/// {@template number_field}
/// A text field that edits a number, by default a non-negative one.
///
/// Every valid edit is committed with [onChanged] as the user types.
/// Invalid input, including numbers below [min], is not committed, and is
/// reverted to the last valid value when the field is submitted or loses
/// focus.
/// {@endtemplate}
class const NumberField({
  /// The field label.
  required final String label,

  /// The current value.
  required final double value,

  /// Called with the new value whenever the user types a valid number.
  required final ValueChanged<double> onChanged,

  /// The smallest accepted value, or `null` to accept any number.
  final double? min = 0,
  super.key,
}) extends StatefulWidget {
  /// {@macro number_field}
  this;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState() extends State<NumberField> {
  late final _controller = TextEditingController(text: _format(widget.value));
  final _focusNode = FocusNode();
  late double _committed;

  @override
  void initState() {
    super.initState();
    _committed = widget.value;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Values this field committed itself come back here; rewriting the
    // text for them would move the cursor and drop input like "1.50".
    if (widget.value != oldWidget.value && widget.value != _committed) {
      _committed = widget.value;
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _revertInvalid();
    }
  }

  /// Parses the text, or returns `null` if it is not an accepted number.
  double? _parse() {
    final value = double.tryParse(_controller.text.trim());
    final min = widget.min;
    if (value == null || (min != null && value < min)) {
      return null;
    }
    return value;
  }

  void _revertInvalid() {
    if (_parse() == null) {
      _controller.text = _format(_committed);
    }
  }

  void _onTextChanged(String _) {
    final value = _parse();
    if (value == null || value == _committed) {
      return;
    }
    _committed = value;
    widget.onChanged(value);
  }

  static String _format(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: widget.min == null || widget.min! < 0,
      ),
      decoration: InputDecoration(labelText: widget.label, isDense: true),
      onChanged: _onTextChanged,
      onSubmitted: (_) => _revertInvalid(),
    );
  }
}
