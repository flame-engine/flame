import 'dart:ui';

import '../../components.dart';
import '../../extensions.dart';
import '../../geometry.dart';

class Rectangle extends Polygon {
  Rectangle({
    Vector2? position,
    Vector2? size,
    double? angle,
    Anchor? anchor,
    int? priority,
    Paint? paint,
  }) : super(
          [
            _toCorner(position, size, anchor, Anchor.topLeft),
            _toCorner(position, size, anchor, Anchor.bottomLeft),
            _toCorner(position, size, anchor, Anchor.bottomRight),
            _toCorner(position, size, anchor, Anchor.topRight),
          ],
          angle: angle,
          anchor: anchor,
          priority: priority,
          paint: paint,
        );

  Rectangle.square({
    Vector2? position,
    double? size,
    double? angle,
    Anchor? anchor,
    int? priority,
    Paint? paint,
  }) : this(
          position: position,
          size: size != null ? Vector2.all(size) : null,
          angle: angle,
          anchor: anchor,
          priority: priority,
          paint: paint,
        );

  /// This factory will create a [Rectangle] from a positioned [Rect].
  factory Rectangle.fromRect(
    Rect rect, {
    double? angle,
    Anchor anchor = Anchor.topLeft,
    int? priority,
  }) {
    return Rectangle(
      position: Anchor.center.toOtherAnchorPosition(
        rect.center.toVector2(),
        anchor,
        rect.size.toVector2(),
      ),
      size: rect.size.toVector2(),
      angle: angle,
      anchor: anchor,
      priority: priority,
    );
  }

  static Vector2 _toCorner(
    Vector2? position,
    Vector2? size,
    Anchor? anchor,
    Anchor corner,
  ) {
    return (anchor ?? Anchor.topLeft).toOtherAnchorPosition(
      position ?? Vector2.zero(),
      corner,
      size ?? Vector2.zero(),
    );
  }
}
