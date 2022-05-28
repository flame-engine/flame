import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// In this [PositionComponent] hitboxes can be added to emulate a hitbox
/// that is a composition of other hitboxes.
///
/// If you want to form a hat for example you might want to use to
/// [RectangleHitbox]s to follow that hats edges properly, then you can add
/// those hitboxes to an instance of this class and react to collisions to the
/// whole hat, instead of for just each hitbox separately.
class CompositeHitbox extends PositionComponent
    with CollisionCallbacks, CollisionPassthrough {
  CompositeHitbox({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<ShapeHitbox>? children,
    int? priority,
  }) : super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
        );
}
