import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

/// A function that creates a shape based on a size represented by a [Vector2]
typedef ShapeBuilder = Shape Function(Vector2 size);

/// {@template clip_component}
/// A component that will clip its content.
/// {@endtemplate}
class ClipComponent extends PositionComponent {
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
    super.key,
  }) : _builder = builder;

  /// {@macro circle_clip_component}
  ///
  /// Clips the canvas in the form of a circle based on its size.
  ClipComponent.circle({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
    ComponentKey? key,
  }) : this(
         builder: (size) => Circle(size / 2, size.x / 2),
         position: position,
         size: size,
         scale: scale,
         angle: angle,
         anchor: anchor,
         children: children,
         priority: priority,
         key: key,
       );

  /// {@macro rectangle_clip_component}
  ///
  /// Clips the canvas in the form of a rectangle based on its size.
  ClipComponent.rectangle({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
    ComponentKey? key,
  }) : this(
         builder: (size) => Rectangle.fromRect(size.toRect()),
         position: position,
         size: size,
         scale: scale,
         angle: angle,
         anchor: anchor,
         children: children,
         priority: priority,
         key: key,
       );

  /// {@macro polygon_clip_component}
  ///
  /// Clips the canvas in the form of a polygon based on its size.
  ClipComponent.polygon({
    required List<Vector2> points,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
    ComponentKey? key,
  }) : this(
         builder: _polygonShapeBuilder(points),
         position: position,
         size: size,
         scale: scale,
         angle: angle,
         anchor: anchor,
         children: children,
         priority: priority,
         key: key,
       );

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

  /// Returns the [ShapeBuilder] function that builds a polygon
  ///
  /// this allows us to use an assertion during Constructor initialization
  /// rather than at the execution of the builder function.
  static ShapeBuilder _polygonShapeBuilder(List<Vector2> points) {
    assert(
      points.length >= 3,
      'PolygonClipComponent requires at least 3 points.',
    );

    return (Vector2 size) => _polygonBuilder(points, size);
  }

  static Shape _polygonBuilder(List<Vector2> points, Vector2 size) {
    final translatedPoints = points
        .map(
          (p) => p.clone()..multiply(size),
        )
        .toList();
    return Polygon(translatedPoints);
  }
}
