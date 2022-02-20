import 'dart:ui';

import 'package:meta/meta.dart';

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
          sizeToVertices(size ?? Vector2.zero()),
          position: position,
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

  Rectangle.fromNormals(
    List<Vector2> normals, {
    Vector2? position,
    required Vector2 size,
    double angle = 0,
    Anchor? anchor,
  })  : assert(normals.length == 4, 'A rectangle needs 4 normals'),
        super.fromNormals(
          normals,
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
        );

  /// This factory will create a [Rectangle] from a positioned [Rect].
  factory Rectangle.fromRect(
    Rect rect, {
    double? angle,
    Anchor anchor = Anchor.topLeft,
    int? priority,
  }) {
    return Rectangle(
      position: anchor == Anchor.topLeft
          ? rect.topLeft.toVector2()
          : Anchor.topLeft.toOtherAnchorPosition(
              rect.topLeft.toVector2(),
              anchor,
              rect.size.toVector2(),
            ),
      size: rect.size.toVector2(),
      angle: angle,
      anchor: anchor,
      priority: priority,
    );
  }

  @protected
  static List<Vector2> sizeToVertices(Vector2 size) {
    return [
      Vector2.zero(),
      Vector2(0, size.y),
      size.clone(),
      Vector2(size.x, 0),
    ];
  }
}
