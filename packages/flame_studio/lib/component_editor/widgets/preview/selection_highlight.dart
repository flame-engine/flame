import 'package:flame/components.dart' as flame;
import 'package:flutter/painting.dart';

/// {@template selection_highlight}
/// Draws a thick magenta border around [target], the Flame component of
/// the node selected in the editor.
///
/// It is added to the world, above everything else, instead of to
/// [target]: that keeps it on top of overlapping siblings, and the
/// children of the previewed components match the component tree.
/// {@endtemplate}
class SelectionHighlight() extends flame.Component {
  /// {@macro selection_highlight}
  this : super(priority: 1 << 30);

  /// The color of the border.
  static const color = Color(0xFFFF00FF);

  /// The width of the border on screen, whatever the [zoom].
  static const strokeWidth = 4.0;

  final _paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;

  /// The component to highlight, if any.
  flame.PositionComponent? target;

  /// The zoom of the camera, which scales the border too: it is drawn
  /// thinner when zoomed in, so it keeps the same width on screen.
  double get zoom => _zoom;
  double _zoom = 1;
  set zoom(double value) {
    _zoom = value;
    _paint.strokeWidth = worldStrokeWidth;
  }

  /// The width of the border in world coordinates.
  double get worldStrokeWidth => strokeWidth / _zoom;

  @override
  void render(Canvas canvas) {
    final target = this.target;
    if (target == null || !target.isMounted) {
      return;
    }
    // Rotated with the component (and its ancestors), around its top left
    // corner.
    final topLeft = target.absoluteTopLeftPosition;
    final size = target.absoluteScaledSize;
    canvas
      ..save()
      ..translate(topLeft.x, topLeft.y)
      ..rotate(target.absoluteAngle)
      // Drawn outside of the component, so it doesn't hide its own edges.
      ..drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y).inflate(worldStrokeWidth / 2),
        _paint,
      )
      ..restore();
  }
}
