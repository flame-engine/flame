import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

/// A convenience component that aids in prototyping by being very quick to
/// create and differentiate from other components by setting the color.
///
/// ```dart
/// class MyCharacter extends PlaceholderComponent {
///   @override
///   Future<void> onLoad() async {
///     size = Vector2(50, 50);
///     color = Colors.red;
///   }
/// }
/// ```
class PlaceholderComponent extends CustomPainterComponent {
  PlaceholderComponent({
    this.color,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  });

  /// The color to paint this component
  final Color? color;

  @override
  late final painter = _PlaceholderPainter(color ?? Colors.red);
}

class _PlaceholderPainter extends CustomPainter {
  _PlaceholderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PlaceholderPainter old) => old.color != color;
}
