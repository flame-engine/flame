import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:meta/meta.dart';

class RectangleComponent extends PolygonComponent {
  RectangleComponent({
    super.position,
    super.size,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.paint,
    super.paintLayers,
  }) : super(sizeToVertices(size ?? Vector2.zero(), anchor)) {
    size.addListener(
      () => refreshVertices(
        newVertices: sizeToVertices(size, anchor),
        shrinkToBoundsOverride: false,
      ),
    );
  }

  RectangleComponent.square({
    double size = 0,
    super.position,
    super.angle,
    super.anchor,
    super.priority,
    super.paint,
    super.paintLayers,
    super.children,
  }) : super(sizeToVertices(Vector2.all(size), anchor)) {
    this.size.addListener(
          () => refreshVertices(
            newVertices: sizeToVertices(this.size, anchor),
            shrinkToBoundsOverride: false,
          ),
        );
  }

  /// With this constructor you define the [RectangleComponent] in relation to
  /// the `parentSize`. For example having [relation] as of (0.8, 0.5) would
  /// create a rectangle that fills 80% of the width and 50% of the height of
  /// `parentSize`.
  RectangleComponent.relative(
    Vector2 relation, {
    required super.parentSize,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
    super.paint,
    super.paintLayers,
    super.shrinkToBounds,
  }) : super.relative([
          relation.clone(),
          Vector2(relation.x, -relation.y),
          -relation,
          Vector2(-relation.x, relation.y),
        ]) {
    size.addListener(
      () => refreshVertices(
        newVertices: sizeToVertices(size, anchor),
        shrinkToBoundsOverride: false,
      ),
    );
  }

  /// This factory will create a [RectangleComponent] from a positioned [Rect].
  factory RectangleComponent.fromRect(
    Rect rect, {
    double? angle,
    Anchor anchor = Anchor.topLeft,
    int? priority,
    Paint? paint,
    List<Paint>? paintLayers,
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
      paint: paint,
      paintLayers: paintLayers,
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
