import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

/// {@template clip_component}
/// A component that will clip its content.
/// {@endtemplate}
abstract class ClipComponent extends PositionComponent {
  /// {@macro clip_component}
  ///
  /// Clips the canvas based its shape and size.
  ClipComponent({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  });

  late Path _path;
  late Shape _shape;

  @override
  Future<void> onLoad() async {
    _prepare();
    size.addListener(_prepare);
  }

  Shape _buildShape();

  void _prepare() {
    _shape = _buildShape();
    _path = _shape.asPath();
  }

  @override
  void render(Canvas canvas) => canvas.clipPath(_path);

  @override
  bool containsPoint(Vector2 point) {
    return _shape.containsPoint(point - position);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return _shape.containsPoint(point);
  }
}

/// {@template circle_clip_component}
///
/// A component that will clip its content to a circle.
class CircleClipComponent extends ClipComponent {
  /// {@macro circle_clip_component}
  ///
  /// Clips the canvas in the form of a circle based on its size.
  CircleClipComponent({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  });

  @override
  Shape _buildShape() {
    return Circle(size / 2, size.x / 2);
  }
}

/// {@template rectangle_clip_component}
///
/// A component that will clip its content to a rectangle.
class RectangleClipComponent extends ClipComponent {
  /// {@macro rectangle_clip_component}
  ///
  /// Clips the canvas in the form of a rectangle based on its size.
  RectangleClipComponent({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  });

  @override
  Shape _buildShape() {
    return Rectangle.fromRect(size.toRect());
  }
}

/// {@template polygon_clip_component}
///
/// A component that will clip its content to a polygon.
class PolygonClipComponent extends ClipComponent {
  /// {@macro polygon_clip_component}
  ///
  /// Clips the canvas in the form of a polygon based on its size.
  PolygonClipComponent({
    required List<Vector2> points,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  })  : assert(
          points.length > 2,
          'PolygonClipComponent requires at least 3 points.',
        ),
        _points = points;

  final List<Vector2> _points;

  @override
  Shape _buildShape() {
    final translatedPoints = _points
        .map(
          (p) => p.clone()..multiply(size),
        )
        .toList();
    return Polygon(translatedPoints);
  }
}
