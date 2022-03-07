import '../../../collisions.dart';
import '../../../components.dart';

/// In this [PositionComponent] hitboxes can be added to emulate a hitbox
/// that is a composition of other hitboxes.
///
/// If you want to form a hat for example you might want to use to
/// [RectangleHitbox]s to follow that hats edges properly, then you can add
/// those hitboxes to an instance of this class and react to collisions to the
/// whole hat, instead of for just each hitbox separately.
class CompositeHitbox extends PositionComponent
    with CollisionCallbacks, CollisionPassthrough {}
