import 'dart:ui';

import 'package:meta/meta.dart';

import '../../components.dart';
import '../../extensions.dart';
import '../../geometry.dart';

class RectangleComponent extends PolygonComponent {
  RectangleComponent({
    Vector2? position,
    Vector2? size,
    double? angle,
    Anchor? anchor,
    int? priority,
    Paint? paint,
  }) : super(
          sizeToVertices(size ?? Vector2.zero(), anchor),
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
          priority: priority,
          paint: paint,
        );

  RectangleComponent.square({
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

  /// With this constructor you define the [RectangleComponent] in relation to
  /// the [size]. For example having [normal] as of (0.8, 0.5) would create a
  /// rectangle that fills 80% of the width and 50% of the height of [size].
  RectangleComponent.fromNormals(
    Vector2 normal, {
    Vector2? position,
    required Vector2 size,
    double angle = 0,
    Anchor? anchor,
  }) : super.fromNormals(
          [
            normal.clone(),
            Vector2(normal.x, -normal.y),
            -normal,
            Vector2(-normal.x, normal.y),
          ],
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
        );

  /// This factory will create a [RectangleComponent] from a positioned [Rect].
  factory RectangleComponent.fromRect(
    Rect rect, {
    double? angle,
    Anchor anchor = Anchor.topLeft,
    int? priority,
  }) {
    return RectangleComponent(
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
  static List<Vector2> sizeToVertices(
    Vector2 size,
    Anchor? componentAnchor,
  ) {
    final anchor = componentAnchor ?? Anchor.topLeft;
    return [
      Vector2(-size.x * anchor.x, -size.y * anchor.y),
      Vector2(-size.x * anchor.x, size.y - size.y * anchor.y),
      Vector2(size.x - size.x * anchor.x, size.y - size.y * anchor.y),
      Vector2(size.x - size.x * anchor.x, -size.y * anchor.y),
    ];
  }
}
