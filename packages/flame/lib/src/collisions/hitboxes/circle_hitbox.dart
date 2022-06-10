// ignore_for_file: comment_references

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// A [Hitbox] in the shape of a circle.
class CircleHitbox extends CircleComponent with ShapeHitbox {
  @override
  final bool shouldFillParent;

  CircleHitbox({
    super.radius,
    super.position,
    super.angle,
    super.anchor,
  }) : shouldFillParent = radius == null && position == null;

  /// With this constructor you define the [CircleHitbox] in relation to the
  /// [parentSize]. For example having a [relation] of 0.5 would create a circle
  /// that fills half of the [parentSize].
  CircleHitbox.relative(
    super.relation, {
    super.position,
    required super.parentSize,
    super.angle,
    super.anchor,
  })  : shouldFillParent = false,
        super.relative();

  @override
  void fillParent() {
    // There is no need to do anything here since the size already is bound to
    // the parent size and the radius is defined from the shortest side.
  }
}
