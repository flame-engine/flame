import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// A [Hitbox] in the shape of a rectangle (a simplified polygon).
class RectangleHitbox extends RectangleComponent with ShapeHitbox {
  @override
  final bool shouldFillParent;

  RectangleHitbox({
    Vector2? position,
    Vector2? size,
    double? angle,
    Anchor? anchor,
    int? priority,
  })  : shouldFillParent = size == null && position == null,
        super(
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  /// With this constructor you define the [RectangleHitbox] in relation to
  /// the [parentSize]. For example having [relation] as of (0.8, 0.5) would
  /// create a rectangle that fills 80% of the width and 50% of the height of
  /// [parentSize].
  RectangleHitbox.relative(
    Vector2 relation, {
    Vector2? position,
    required Vector2 parentSize,
    double angle = 0,
    Anchor? anchor,
  })  : shouldFillParent = false,
        super.relative(
          relation,
          position: position,
          parentSize: parentSize,
          angle: angle,
          anchor: anchor,
          shrinkToBounds: true,
        );

  @override
  void fillParent() {
    refreshVertices(
      newVertices: RectangleComponent.sizeToVertices(size, anchor),
    );
  }
}
