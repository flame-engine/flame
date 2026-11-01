import 'package:flutter/material.dart';

/// Returns why a name can't be used, or `null` if it can.
typedef NameValidator = String? Function(String name);

/// {@template name_field}
/// A text field that edits a name.
///
/// Every edit accepted by [validator] is committed with [onChanged] as the
/// user types. Rejected input shows the [validator] message, is not
/// committed, and is reverted to the last valid name when the field is
/// submitted or loses focus.
/// {@endtemplate}
class const NameField({
  /// The current name.
  required final String value,

  /// Checks the typed name.
  required final NameValidator validator,

  /// Called with the new name whenever the user types a valid one.
  required final ValueChanged<String> onChanged,

  /// The field label.
  final String label = 'Name',
  super.key,
}) extends StatefulWidget {
  /// {@macro name_field}
  this;

  @override
  State<NameField> createState() => _NameFieldState();
}

class _NameFieldState() extends State<NameField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focusNode = FocusNode();
  late String _committed;
  String? _error;

  @override
  void initState() {
    super.initState();
    _committed = widget.value;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(NameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Names this field committed itself come back here; rewriting the text
    // for them would move the cursor.
    if (widget.value != oldWidget.value && widget.value != _committed) {
      _committed = widget.value;
      _controller.text = widget.value;
      _error = null;
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

  void _revertInvalid() {
    if (_error == null) {
      return;
    }
    _controller.text = _committed;
    setState(() => _error = null);
  }

  void _onTextChanged(String name) {
    final error = name == _committed ? null : widget.validator(name);
    setState(() => _error = error);
    if (error != null || name == _committed) {
      return;
    }
    _committed = name;
    widget.onChanged(name);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _error,
        errorMaxLines: 2,
        isDense: true,
      ),
      onChanged: _onTextChanged,
      onSubmitted: (_) => _revertInvalid(),
    );
  }
}
