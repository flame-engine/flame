import 'dart:collection';
import 'dart:math';

import '../position_component.dart';
import '../../../extensions.dart';
import '../../geometry/shape.dart';

mixin Hitbox on PositionComponent {
  final List<HitboxShape> _shapes = <HitboxShape>[];

  UnmodifiableListView<HitboxShape> get shapes => UnmodifiableListView(_shapes);

  void addShape(HitboxShape shape) {
    shape.component = this;
    _shapes.add(shape);
  }

  void removeShape(HitboxShape shape) {
    _shapes.remove(shape);
  }

  /// Checks whether the hitbox represented by the list of [HitboxShape]
  /// contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    return possiblyContainsPoint(point) &&
        _shapes.any((shape) => shape.containsPoint(point));
  }

  void renderShapes(Canvas canvas) {
    _shapes.forEach((shape) => shape.render(canvas, debugPaint));
  }

  /// Returns the absolute [Rect] that contains all the corners of the rotated
  /// [toAbsoluteRect] rect.
  Rect toBoundingRect() {
    final rotatedPoints = toAbsoluteRect().toVertices()
      ..forEach((v) => v.rotate(
            angle,
            center: absolutePosition,
          ));
    final minX = rotatedPoints.map<double>((v) => v.x).reduce(min);
    final minY = rotatedPoints.map<double>((v) => v.y).reduce(min);
    final maxX = rotatedPoints.map<double>((v) => v.x).reduce(max);
    final maxY = rotatedPoints.map<double>((v) => v.y).reduce(max);

    return Rect.fromPoints(Offset(minX, minY), Offset(maxX, maxY));
  }

  /// Since this is a cheaper calculation than checking towards all shapes, this
  /// check can be done first to see if it even is possible that the shapes can
  /// overlap, since the shapes have to be within the size of the component.
  bool possiblyOverlapping(Hitbox other) {
    return toBoundingRect().overlaps(other.toBoundingRect());
  }

  /// Since this is a cheaper calculation than checking towards all shapes this
  /// check can be done first to see if it even is possible that the shapes can
  /// contain the point, since the shapes have to be within the size of the
  /// component.
  bool possiblyContainsPoint(Vector2 point) {
    return toBoundingRect().containsPoint(point);
  }
}
