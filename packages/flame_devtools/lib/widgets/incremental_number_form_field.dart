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
            onChanged: _tryUpdate,
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
