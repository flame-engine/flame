import 'dart:async';

import 'package:flame_devtools/material.dart';

class const IncrementalNumberFormField<T extends num>({
  required final T initialValue,
  required final String label,
  final FutureOr<void> Function(T)? onChanged,
  final double? scrubStep,
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

  /// The value when the label started being dragged, or null when it isn't
  /// being dragged.
  T? _scrubStartValue;

  /// How far the label has been dragged horizontally, in logical pixels.
  var _scrubDistance = 0.0;

  /// Whether [IncrementalNumberFormField.onChanged] hasn't completed yet.
  var _isSending = false;

  /// The latest value that changed while a value was being sent, which is
  /// sent when that completes.
  T? _queuedValue;

  bool get _isEditing => _focusNode.hasFocus || _scrubStartValue != null;

  @override
  void didUpdateWidget(covariant IncrementalNumberFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      // A value that is being edited isn't overwritten, the field shows the
      // latest value when the editing ends instead.
      if (_isEditing) {
        _hasPendingValue = true;
      } else {
        _showInitialValue();
      }
    }
  }

  void _onFocusChange() {
    if (!_isEditing && _hasPendingValue) {
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
    unawaited(_send(value));
  }

  /// Sends [value] through [IncrementalNumberFormField.onChanged].
  ///
  /// Only one value is sent at a time. Values that change while one is being
  /// sent replace each other, and only the latest of them is sent next, so
  /// that fast changes, like dragging the label, don't send more values than
  /// the game can handle.
  Future<void> _send(T value) async {
    if (_isSending) {
      _queuedValue = value;
      return;
    }
    _isSending = true;
    try {
      T? next = value;
      while (next != null && mounted) {
        _queuedValue = null;
        await widget.onChanged?.call(next);
        next = _queuedValue;
      }
    } finally {
      _isSending = false;
    }
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

  void _onScrubStart(DragStartDetails _) {
    final value = _parse();
    if (value == null) {
      return;
    }
    _scrubStartValue = value;
    _scrubDistance = 0;
  }

  void _onScrubUpdate(DragUpdateDetails details) {
    final start = _scrubStartValue;
    final step = widget.scrubStep;
    if (start == null || step == null) {
      return;
    }
    _scrubDistance += details.delta.dx;
    final next = _scrubbedValue(start, step);
    if (next == _parse()) {
      return;
    }
    _controller.text = next.toString();
    _update(next);
  }

  void _onScrubEnd() {
    _scrubStartValue = null;
    if (!_isEditing && _hasPendingValue) {
      _showInitialValue();
    }
  }

  /// The value after the label has been dragged [_scrubDistance] logical
  /// pixels from where it started, rounded to the precision of the [step], so
  /// that a step of `0.01` doesn't give values like `0.30000000000000004`.
  T _scrubbedValue(T start, double step) {
    final value = start + _scrubDistance * step;
    if (T == int) {
      return value.round() as T;
    }
    final fractionDigits = _fractionDigits(step);
    return double.parse(value.toStringAsFixed(fractionDigits)) as T;
  }

  static int _fractionDigits(double step) {
    final text = step.toString();
    final dot = text.indexOf('.');
    if (dot == -1 || text.contains('e')) {
      return 0;
    }
    final fraction = text.substring(dot + 1).replaceFirst(RegExp(r'0+$'), '');
    return fraction.length;
  }

  /// The label is shown above the text field instead of as the label of its
  /// decoration, since a floating decoration label is only hit tested where
  /// it would be when it isn't floating, so it can't be dragged.
  Widget _buildLabel(BuildContext context) {
    final theme = Theme.of(context);
    final label = Text(
      widget.label,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    if (widget.scrubStep == null) {
      return label;
    }
    // The whole width above the text field can be dragged, since labels like
    // "X" are too narrow to grab.
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _onScrubStart,
        onHorizontalDragUpdate: _onScrubUpdate,
        onHorizontalDragEnd: (_) => _onScrubEnd(),
        onHorizontalDragCancel: _onScrubEnd,
        child: SizedBox(width: double.infinity, child: label),
      ),
    );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLabel(context),
              TextField(
                decoration: InputDecoration(
                  isDense: true,
                  errorText: errorText,
                ),
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _tryUpdate,
                onSubmitted: (_) => _focusNode.unfocus(),
                onTapOutside: (_) => _focusNode.unfocus(),
              ),
            ],
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
