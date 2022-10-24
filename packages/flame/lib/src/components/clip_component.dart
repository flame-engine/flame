import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';

/// A function that creates a shape based on a size represented by a [Vector2]
typedef ShapeBuilder = Shape Function(Vector2 size);

/// {@template clip_component}
/// A component that will clip its content.
/// {@endtemplate}
class ClipComponent extends PositionComponent implements SizeProvider {
  /// {@macro clip_component}
  ///
  /// Clips the canvas based its shape and size.
  ClipComponent({
    required ShapeBuilder builder,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : _builder = builder;

  /// {@macro circle_clip_component}
  ///
  /// Clips the canvas in the form of a circle based on its size.
  factory ClipComponent.circle({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  }) {
    return ClipComponent(
      builder: (size) => Circle(size / 2, size.x / 2),
      position: position,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      children: children,
      priority: priority,
    );
  }

  /// {@macro rectangle_clip_component}
  ///
  /// Clips the canvas in the form of a rectangle based on its size.
  factory ClipComponent.rectangle({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  }) {
    return ClipComponent(
      builder: (size) => Rectangle.fromRect(size.toRect()),
      position: position,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      children: children,
      priority: priority,
    );
  }

  /// {@macro polygon_clip_component}
  ///
  /// Clips the canvas in the form of a polygon based on its size.
  factory ClipComponent.polygon({
    required List<Vector2> points,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  }) {
    assert(
      points.length > 2,
      'PolygonClipComponent requires at least 3 points.',
    );

    return ClipComponent(
      builder: (size) {
        final translatedPoints = points
            .map(
              (p) => p.clone()..multiply(size),
            )
            .toList();
        return Polygon(translatedPoints);
      },
      position: position,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      children: children,
      priority: priority,
    );
  }

  late Path _path;
  late Shape _shape;
  final ShapeBuilder _builder;

  @override
  Future<void> onLoad() async {
    _prepare();
    size.addListener(_prepare);
  }

  void _prepare() {
    _shape = _builder(size);
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
