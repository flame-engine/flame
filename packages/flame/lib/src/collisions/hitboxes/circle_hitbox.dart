import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// A [Hitbox] in the shape of a circle.
class CircleHitbox extends CircleComponent with ShapeHitbox {
  @override
  final bool shouldFillParent;

  CircleHitbox({
    double? radius,
    Vector2? position,
    double? angle,
    Anchor? anchor,
  })  : shouldFillParent = radius == null && position == null,
        super(
          radius: radius,
          position: position,
          angle: angle,
          anchor: anchor,
        );

  /// With this constructor you define the [CircleHitbox] in relation to the
  /// [parentSize]. For example having a [relation] of 0.5 would create a circle
  /// that fills half of the [parentSize].
  CircleHitbox.relative(
    double relation, {
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
        );

  @override
  void fillParent() {
    // There is no need to do anything here since the size already is bound to
    // the parent size and the radius is defined from the shortest side.
  }
}
