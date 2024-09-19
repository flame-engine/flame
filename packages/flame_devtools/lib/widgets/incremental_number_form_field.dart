import 'package:flutter/material.dart';

class IncrementalNumberFormField<T extends num> extends StatefulWidget {
  const IncrementalNumberFormField({
    required this.initialValue,
    required this.label,
    this.onChanged,
    super.key,
  });

  final String label;
  final T initialValue;
  final void Function(T)? onChanged;

  @override
  State<IncrementalNumberFormField<T>> createState() =>
      _IncrementalNumberFormFieldState<T>();
}

class _IncrementalNumberFormFieldState<T extends num>
    extends State<IncrementalNumberFormField<T>> {
  late final _controller = TextEditingController()
    ..text = widget.initialValue.toString();

  String? errorText;

  @override
  void didUpdateWidget(covariant IncrementalNumberFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _controller.text = widget.initialValue.toString();
        errorText = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  T _parse() {
    if (T == double) {
      return double.parse(_controller.text) as T;
    } else {
      return int.parse(_controller.text) as T;
    }
  }

  void _tryUpdate(String value) {
    try {
      final value = _parse();
      _update(value);
    } on Exception catch (_) {
      setState(() {
        errorText = 'Invalid number';
      });
    }
  }

  void _update(T v) {
    setState(() {
      errorText = null;
    });

    widget.onChanged?.call(v);
  }

  void _increment() {
    final value = _parse() + 1 as T;
    _update(value);
    _controller.text = value.toString();
  }

  void _decrement() {
    final value = _parse() - 1 as T;
    _update(value);
    _controller.text = value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _decrement,
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
            onChanged: _tryUpdate,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _increment,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
