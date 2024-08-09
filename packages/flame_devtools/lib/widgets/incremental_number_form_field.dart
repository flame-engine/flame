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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  T _parse() {
    if (T is double) {
      return double.parse(_controller.text) as T;
    } else {
      return int.parse(_controller.text) as T;
    }
  }

  void _update(T v) {
    widget.onChanged?.call(v);
    setState(() {
      _controller.text = v.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            _update(_parse() - 1 as T);
          },
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: InputDecoration(
              labelText: widget.label,
            ),
            controller: _controller,
            // TODO(erickzanardo): Implement this
            // onChanged: (v) => _update(v as T),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            _update(_parse() + 1 as T);
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
