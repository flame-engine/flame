import 'package:flame/components.dart' show Anchor, Vector2;
import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/widgets/common/studio_text_field.dart';
import 'package:flame_studio/src/widgets/common/studio_tooltip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Formats [value] with up to three decimals, without trailing zeros.
String formatNumber(double value) {
  if (!value.isFinite) {
    return value.toString();
  }
  final text = value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
  return text == '-0' ? '0' : text;
}

/// A label that changes a numeric value when dragged horizontally, like the
/// field labels in the Unity inspector.
///
/// When [onDrag] is null, this is a plain label.
class const ScrubLabel(
  final String text, {
  final ValueChanged<double>? onDrag,
  final String? tooltip,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: theme.dimTextColor),
    );
    final onDrag = this.onDrag;
    final result = onDrag == null
        ? label
        : MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
              child: label,
            ),
          );
    final tooltip = this.tooltip;
    return tooltip == null
        ? result
        : StudioTooltip(message: tooltip, child: result);
  }
}

class const ReadOnlyValue(final String text, {super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

/// Shows a number, which can be edited when [onSubmitted] is not null.
///
/// Input that is not a valid number is discarded.
class const NumberField(
  final double value, {
  final ValueChanged<double>? onSubmitted,
  final bool isInteger = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final text = isInteger ? value.round().toString() : formatNumber(value);
    final onSubmitted = this.onSubmitted;
    if (onSubmitted == null) {
      return ReadOnlyValue(text);
    }
    return StudioTextField(
      value: text,
      selectAllOnFocus: true,
      onSubmitted: (text) {
        final number = double.tryParse(text.trim());
        if (number != null && number.isFinite) {
          onSubmitted(number);
        }
      },
    );
  }
}

/// Edits the two components of a [Vector2], each with its own [ScrubLabel].
class const Vector2Field(
  final Vector2 value, {
  final ValueChanged<Vector2>? onChanged,
  final double step = 1.0,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final x = value.x;
    final y = value.y;
    final setX = onChanged == null
        ? null
        : (double newX) => onChanged(Vector2(newX, y));
    final setY = onChanged == null
        ? null
        : (double newY) => onChanged(Vector2(x, newY));

    return Row(
      children: [
        ScrubLabel(
          'X',
          onDrag: setX == null ? null : (dx) => setX(x + dx * step),
        ),
        const SizedBox(width: 4),
        Expanded(child: NumberField(x, onSubmitted: setX)),
        const SizedBox(width: 8),
        ScrubLabel(
          'Y',
          onDrag: setY == null ? null : (dx) => setY(y + dx * step),
        ),
        const SizedBox(width: 4),
        Expanded(child: NumberField(y, onSubmitted: setY)),
      ],
    );
  }
}

class const StudioCheckbox({
  required final bool value,
  final ValueChanged<bool>? onChanged,
  super.key,
}) extends ConsumerWidget {
  static const double _size = 14.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final onChanged = this.onChanged;
    final box = CustomPaint(
      size: const Size.square(_size),
      painter: _CheckboxPainter(
        isChecked: value,
        fillColor: onChanged == null ? theme.dimTextColor : theme.accentColor,
        borderColor: theme.fieldBorderColor,
        backgroundColor: theme.fieldColor,
      ),
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: onChanged == null
          ? box
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged(!value),
                child: box,
              ),
            ),
    );
  }
}

class _CheckboxPainter({
  required final bool isChecked,
  required final Color fillColor,
  required final Color borderColor,
  required final Color backgroundColor,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(3),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = isChecked ? fillColor : backgroundColor,
    );
    if (isChecked) {
      final check = Path()
        ..moveTo(size.width * 0.22, size.height * 0.52)
        ..lineTo(size.width * 0.42, size.height * 0.72)
        ..lineTo(size.width * 0.78, size.height * 0.3);
      canvas.drawPath(
        check,
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawRRect(
        rect.deflate(0.5),
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckboxPainter old) =>
      isChecked != old.isChecked ||
      fillColor != old.fillColor ||
      borderColor != old.borderColor ||
      backgroundColor != old.backgroundColor;
}

/// Picks one of the nine predefined anchors from a 3x3 grid. Custom anchors
/// are shown, but can only be replaced by one of the predefined ones.
class const AnchorPicker(
  final Anchor value, {
  final ValueChanged<Anchor>? onChanged,
  super.key,
}) extends ConsumerWidget {
  static const List<List<Anchor>> _grid = [
    [Anchor.topLeft, Anchor.topCenter, Anchor.topRight],
    [Anchor.centerLeft, Anchor.center, Anchor.centerRight],
    [Anchor.bottomLeft, Anchor.bottomCenter, Anchor.bottomRight],
  ];
  static const double _cellSize = 6.0;
  static const double _gap = 1.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final onChanged = this.onChanged;
    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final row in _grid)
              Padding(
                padding: const EdgeInsets.all(_gap / 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final anchor in row)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _gap / 2,
                        ),
                        child: _AnchorCell(
                          anchor.toString(),
                          size: _cellSize,
                          isSelected: anchor == value,
                          color: anchor == value
                              ? theme.accentColor
                              : theme.dimTextColor,
                          onTap: onChanged == null
                              ? null
                              : () => onChanged(anchor),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(child: ReadOnlyValue(value.toString())),
      ],
    );
  }
}

class const _AnchorCell(
  final String name, {
  required final double size,
  required final bool isSelected,
  required final Color color,
  required final VoidCallback? onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cell = Semantics(
      label: name,
      selected: isSelected,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected ? color : null,
          border: Border.all(color: color, width: 0.5),
        ),
      ),
    );
    final onTap = this.onTap;
    return StudioTooltip(
      message: name,
      child: onTap == null
          ? cell
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(onTap: onTap, child: cell),
            ),
    );
  }
}
