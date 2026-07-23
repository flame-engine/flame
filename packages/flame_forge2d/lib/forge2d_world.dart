import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:forge2d/forge2d.dart' as forge2d;

/// The root component when using [Forge2DGame], can handle both
/// [BodyComponent]s and normal Flame components.
///
/// Wraps the world class that comes from Forge2D ([forge2d.World]).
class Forge2DWorld extends World {
  /// Creates a [Forge2DWorld] with the given [gravity], which defaults to
  /// [defaultGravity].
  ///
  /// A [definition] can be passed to configure the underlying physics world.
  /// Be aware that [WorldDef.gravity] uses the y-up Box2D convention with a
  /// default of (0, -10), while Flame's y-axis points down, so set its
  /// gravity explicitly (or use the [gravity] argument, which takes
  /// precedence) when you provide a definition.
  Forge2DWorld({
    Vector2? gravity,
    forge2d.WorldDef? definition,
    ContactEventsDispatcher? contactEventsDispatcher,
    super.children,
  }) : _gravity = gravity ?? definition?.gravity ?? defaultGravity,
       _definition = definition,
       contactEventsDispatcher =
           contactEventsDispatcher ?? ContactEventsDispatcher();

  static final Vector2 defaultGravity = Vector2(0, 10.0);

  Vector2 _gravity;
  final forge2d.WorldDef? _definition;
  forge2d.World? _physicsWorld;

  /// The underlying Forge2D physics world.
  ///
  /// It is created the first time it is used rather than in the constructor,
  /// because Forge2D has to be initialized before a world can be created,
  /// and on the web that initialization is asynchronous. [Forge2DGame] awaits
  /// it in its `onLoad`; if you use a [Forge2DWorld] outside of a
  /// [Forge2DGame] you have to `await initializeForge2D()` yourself before
  /// the world is used.
  ///
  /// The world is never destroyed by the component, so that it can be
  /// re-added to the component tree later. Since it holds native resources
  /// that are not garbage collected, and Box2D allows only a limited number
  /// of simultaneous worlds, call `physicsWorld.destroy()` when you are
  /// permanently done with it, for example when you tear down a game that
  /// you don't intend to show again.
  forge2d.World get physicsWorld {
    final existingWorld = _physicsWorld;
    if (existingWorld != null) {
      return existingWorld;
    }
    final createdWorld = forge2d.World(
      gravity: _gravity,
      definition: _definition,
    );
    if (!createdWorld.isValid) {
      // Checked at runtime rather than with an assert, since an invalid world
      // is cached and used by every later step and API call, which would crash
      // far from the cause in a release build where asserts are stripped.
      throw StateError(
        'The physics world could not be created. Box2D allows a limited number '
        'of simultaneous worlds, and Forge2D worlds are not freed '
        'automatically, so call physicsWorld.destroy() on the worlds that you '
        'are done with.',
      );
    }
    return _physicsWorld = createdWorld;
  }

  /// Routes the contact and sensor events that the physics world generated
  /// during a step to the [ContactCallbacks] in the involved userData.
  final ContactEventsDispatcher contactEventsDispatcher;

  /// The number of sub-steps that the physics world performs for each
  /// [update].
  int subStepCount = 4;

  /// If true, all bodies will be destroyed when the world is removed from
  /// the component tree.
  /// Set this to false if you want to keep the bodies state for later, if
  /// you for example plan to add the world back to the component tree.
  bool destroyBodiesOnRemove = true;

  final Set<Body> _bodies = {};

  /// The bodies that have been created through [createBody] and not yet
  /// destroyed.
  ///
  /// Bodies created directly on the [physicsWorld] are not included.
  Set<Body> get bodies {
    _pruneDestroyedBodies();
    return UnmodifiableSetView(_bodies);
  }

  /// Drops the bodies that have been destroyed without going through
  /// [destroyBody], for example by calling [Body.destroy] directly.
  ///
  /// Keeping them would be worse than a leak: Box2D reuses the slots of
  /// destroyed bodies, so a stale handle silently reads and writes whichever
  /// body took its place.
  void _pruneDestroyedBodies() {
    _bodies.removeWhere((body) => !body.isValid);
  }

  @override
  void update(double dt) {
    physicsWorld.step(dt, subStepCount: subStepCount);
    contactEventsDispatcher.dispatch(
      physicsWorld.contactEvents,
      physicsWorld.sensorEvents,
    );
  }

  Body createBody([BodyDef? def]) {
    final body = physicsWorld.createBody(def);
    _bodies.add(body);
    return body;
  }

  void destroyBody(Body body) {
    _bodies.remove(body);
    if (body.isValid) {
      body.destroy();
    }
  }

  /// Casts a ray from [origin] along [translation] and returns the closest
  /// hit, or null when nothing is hit.
  RayHit? castRayClosest(
    Vector2 origin,
    Vector2 translation, {
    QueryFilter? filter,
  }) {
    return physicsWorld.castRayClosest(origin, translation, filter: filter);
  }

  /// Casts a ray from [origin] along [translation], invoking [callback] for
  /// every candidate hit in an arbitrary order.
  ///
  /// The callback controls the rest of the cast with its return value:
  /// -1 to ignore the hit, 0 to stop, the hit's fraction to clip the ray to
  /// the hit, or 1 to continue looking without clipping.
  void castRay(
    Vector2 origin,
    Vector2 translation,
    double Function(RayHit hit) callback, {
    QueryFilter? filter,
  }) {
    physicsWorld.castRay(origin, translation, callback, filter: filter);
  }

  /// Casts a ray from [origin] along [translation] and returns every hit,
  /// sorted from nearest to farthest.
  List<RayHit> castRayAll(
    Vector2 origin,
    Vector2 translation, {
    QueryFilter? filter,
  }) {
    return physicsWorld.castRayAll(origin, translation, filter: filter);
  }

  /// Returns all shapes whose bounding boxes overlap [aabb].
  List<Shape> overlapAabb(Aabb aabb, {QueryFilter? filter}) {
    return physicsWorld.overlapAabb(aabb, filter: filter);
  }

  /// A callback that runs before contacts are solved, which can veto a
  /// contact for the step by returning false.
  ///
  /// Only called for contacts between shapes that have
  /// [ShapeDef.enablePreSolveEvents] set. The callback runs during the
  /// physics step and must not access the world.
  set preSolveCallback(
    bool Function(Shape shapeA, Shape shapeB, Vector2 normal)? callback,
  ) {
    physicsWorld.preSolveCallback = callback;
  }

  /// A callback that decides whether two shapes that pass the regular
  /// category filtering may collide.
  ///
  /// The callback runs during the physics step and must not access the
  /// world.
  set customFilterCallback(
    bool Function(Shape shapeA, Shape shapeB)? callback,
  ) {
    physicsWorld.customFilterCallback = callback;
  }

  /// Don't change the gravity object directly, use the setter instead.
  Vector2 get gravity => _physicsWorld?.gravity ?? _gravity;

  /// Sets the gravity of the world and wakes up all bodies that were created
  /// through [createBody].
  set gravity(Vector2? gravity) {
    _gravity = gravity ?? defaultGravity;
    final existingWorld = _physicsWorld;
    if (existingWorld == null) {
      // The world picks the gravity up when it is created.
      return;
    }
    existingWorld.gravity = _gravity;
    _pruneDestroyedBodies();
    for (final body in _bodies) {
      body.isAwake = true;
    }
  }
}
