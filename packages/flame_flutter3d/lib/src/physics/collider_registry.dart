import 'package:flame/collisions.dart' show CollisionCallbacks;
import 'package:flame/components.dart';
import 'package:flame_flutter3d/src/physics/collision_bridge.dart';
import 'package:flame_flutter3d/src/physics/physics_step_component.dart';
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flutter3d_physics/flutter3d_physics.dart';

/// Which Flame component each collider belongs to, for a [CollisionBridge]
/// to hand over as the other side of a contact.
///
/// **The map every game with contacts kept by hand.** A collider knows
/// nothing of Flame, so `resolveOther` had to be answered from a map the game
/// filled when it made a body and emptied when the body went, and a body
/// removed without emptying it was a contact reported against a component no
/// longer in the game. Here an entry leaves when its component is removed
/// from the game, on its own, and comes back if the component is added
/// again, a pooled ship say. A component moved to another parent keeps it:
/// Flame moves by removing and mounting at once, and the move dropped the
/// entry for good.
final class ColliderRegistry {
  final Map<Collider, PositionComponent> _components =
      <Collider, PositionComponent>{};

  /// Which registration of a collider is the live one: a watch left over
  /// from an earlier one, or from before [unregister], does nothing.
  final Expando<Object> _tickets = Expando<Object>();

  /// [collider] belongs to [component] while [component] is in a game,
  /// until [unregister] is called.
  void register(Collider collider, PositionComponent component) {
    final ticket = _tickets[collider] = Object();
    _components[collider] = component;
    _watch(collider, component, ticket);
  }

  void _watch(Collider collider, PositionComponent component, Object ticket) {
    component.removed.then((_) {
      if (!identical(_tickets[collider], ticket)) {
        return;
      }
      if (component.isMounted) {
        _watch(collider, component, ticket);
        return;
      }
      _components.remove(collider);
      component.mounted.then((_) {
        if (!identical(_tickets[collider], ticket)) {
          return;
        }
        _components[collider] = component;
        _watch(collider, component, ticket);
      });
    });
  }

  /// [collider] belongs to nothing any more.
  void unregister(Collider collider) {
    _tickets[collider] = null;
    _components.remove(collider);
  }

  /// The component [collider] belongs to, or null for level geometry and
  /// anything else nothing on the Flame side stands for.
  PositionComponent? componentFor(Collider collider) => _components[collider];

  /// Relays [collider]'s contacts to [component], the other side of each
  /// looked up here. [collider] is usually [component]'s body's, and may be a
  /// sensor riding on it.
  ///
  /// Handed [stepper], its `onCollision` comes once a frame, as Flame's does;
  /// see [CollisionBridge.stepper].
  CollisionBridge bridge({
    required Collider collider,
    required CollisionCallbacks component,
    PhysicsStepComponent? stepper,
  }) => CollisionBridge(
    collider: collider,
    component: component,
    resolveOther: componentFor,
    stepper: stepper,
  );

  /// Fires a ray across [plane] from [from] to [to], in Flame's coordinates
  /// [lift] off the plane, through [world], and says what it met first: the
  /// component it belongs to, if one is registered, where on the plane, and
  /// the collider.
  ///
  /// **What a Flame game could not ask the world.** A turret's line of
  /// sight, a laser's reach, a grenade's arc checked against a wall: the
  /// world answers them exactly, per shape, and a game reached for Flame's
  /// own raycast, which knows only Flame's hitboxes and none of the level.
  /// [mask] is the layers it can see, as a collider's is; triggers are
  /// seen only when asked for.
  ({PositionComponent? component, Vector2 point, Collider collider})? raycast(
    CollisionWorld world,
    BridgePlane plane,
    Vector2 from,
    Vector2 to, {
    double lift = 0.0,
    int mask = Layers.all,
    Collider? ignore,
    bool includeTriggers = false,
  }) {
    final start = plane.to3d(from, at: plane.constant + lift);
    final along = plane.to3d(to, at: plane.constant + lift)..sub(start);
    final length = along.length;
    if (length == 0.0) {
      return null;
    }
    along.scale(1.0 / length);
    final hit = RayHit();
    if (!world.raycast(
      start,
      along,
      length,
      hit,
      mask: mask,
      ignore: ignore,
      includeTriggers: includeTriggers,
    )) {
      return null;
    }
    final met = hit.collider!;
    return (
      component: componentFor(met),
      point: plane.to2d(hit.point),
      collider: met,
    );
  }
}
