import 'package:flutter/material.dart';

class const IncrementalNumberFormField<T extends num>({
  required final T initialValue,
  required final String label,
  final void Function(T)? onChanged,
  super.key,
}) extends StatefulWidget {
  @override
  State<IncrementalNumberFormField<T>> createState() =>
      _IncrementalNumberFormFieldState<T>();
}

class _IncrementalNumberFormFieldState<T extends num>()
    extends State<IncrementalNumberFormField<T>> {
  late final _controller = TextEditingController()
    ..text = widget.initialValue.toString();
  late final _focusNode = FocusNode()..addListener(_onFocusChange);

  String? errorText;

  /// Whether a new value arrived while the field was being edited.
  var _hasPendingValue = false;

  @override
  void didUpdateWidget(covariant IncrementalNumberFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      // A value that is being edited isn't overwritten, the field shows the
      // latest value when it loses focus instead.
      if (_focusNode.hasFocus) {
        _hasPendingValue = true;
      } else {
        _showInitialValue();
      }
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _hasPendingValue) {
      _showInitialValue();
    }
  }

  void _showInitialValue() {
    _hasPendingValue = false;
    setState(() {
      _controller.text = widget.initialValue.toString();
      errorText = null;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  T? _parse() {
    final text = _controller.text;
    final value = T == double ? double.tryParse(text) : int.tryParse(text);
    return value as T?;
  }

  void _tryUpdate(String _) {
    final value = _parse();
    if (value == null) {
      setState(() {
        errorText = 'Invalid number';
      });
    } else {
      _update(value);
    }
  }

  void _update(T value) {
    setState(() {
      errorText = null;
    });
    widget.onChanged?.call(value);
  }

  void _step(int delta) {
    final value = _parse();
    if (value == null) {
      _tryUpdate(_controller.text);
      return;
    }
    final next = (value + delta) as T;
    _controller.text = next.toString();
    _update(next);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _step(-1),
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: InputDecoration(
              labelText: widget.label,
              errorText: errorText,
            ),
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _tryUpdate,
            onSubmitted: (_) => _focusNode.unfocus(),
            onTapOutside: (_) => _focusNode.unfocus(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _step(1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
