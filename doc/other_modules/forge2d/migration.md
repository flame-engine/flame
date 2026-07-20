# Migrating from forge2d 0.14

Forge2D 0.15 is a ground-up rewrite: instead of a pure Dart port of Box2D 2.x it is now a set of
bindings for [Box2D v3](https://box2d.org/), running as native code on mobile and desktop and as
WebAssembly on the web. Because of that, the entire public API changed.

If you use Forge2D through Flame, see the
[flame_forge2d migration guide](../../bridge_packages/flame_forge2d/migration.md) as well, which
covers the changes to `BodyComponent`, `Forge2DWorld`, and the contact callbacks on top of the
changes described here.

```{note}
The particle system (LiquidFun) is not part of Box2D v3 and has been removed.
If your game depends on it, stay on forge2d 0.14.
```


## Initialization is required

`await initializeForge2D()` has to complete before the first `World` is created. On native
platforms it returns immediately; on the web it loads the Box2D WebAssembly module, and creating
a world without it throws a `StateError`. There was no such call in 0.14, so add one during
startup:

```dart
await initializeForge2D();
final world = World(gravity: Vector2(0, -10));
```


## Platform requirements

The Dart SDK floor is now 3.12 (Flutter 3.44). On native platforms the bundled Box2D sources are
compiled through the Dart build hooks, so a C toolchain is needed: Xcode on iOS and macOS, the NDK
on Android, Visual Studio Build Tools on Windows, and clang or gcc on Linux. On the web the
bundled WebAssembly module is found automatically in the common hosting setups, so beyond
awaiting `initializeForge2D()` no extra setup is needed.


## Fixtures are gone, bodies carry shapes

A `Body` no longer holds `Fixture`s. It holds `Shape`s, which are created from an immutable
`ShapeGeometry` and an optional `ShapeDef`. Friction and restitution moved into the def's
`material`.

```dart
// Before
final shape = CircleShape()..radius = 5;
body.createFixture(FixtureDef(shape, restitution: 0.8, friction: 0.4, density: 2));

// After
body.createShape(
  Circle(radius: 5),
  ShapeDef(
    material: SurfaceMaterial(restitution: 0.8, friction: 0.4),
    density: 2,
  ),
);
```

```{warning}
The default friction changed. `FixtureDef` defaulted to a friction of 0,
while `SurfaceMaterial` defaults to 0.6. Box2D mixes the friction of a
contact as `sqrt(frictionA * frictionB)`, so a pair where one side relied on
the old default was frictionless and no longer is. Pass
`SurfaceMaterial(friction: 0)` explicitly wherever you relied on it.
```

`body.fixtures` becomes `body.shapes`, and `fixture.testPoint` becomes `shape.testPoint` (still in
world coordinates). The shape's geometry can be read back for rendering or inspection with
`shape.geometry`, which returns the sealed `ShapeGeometry` type:

```dart
switch (shape.geometry) {
  case Circle(:final center, :final radius):
  case Capsule(:final center1, :final center2, :final radius):
  case Segment(:final point1, :final point2):
  case Polygon(:final points, :final radius):
}
```


## Shape construction

| Before | After |
|---|---|
| `CircleShape()..radius = r` | `Circle(radius: r, center: c)` |
| `EdgeShape()..set(a, b)` | `Segment(point1: a, point2: b)` |
| `PolygonShape()..set(vertices)` | `Polygon(vertices)` |
| `PolygonShape()..setAsBoxXY(w, h)` | `Polygon.box(w, h)` |
| `ChainShape()..createChain(points)` | `body.createChain(ChainDef(points: points))` |
| `ChainShape()..createLoop(points)` | `body.createChain(ChainDef(points: points, isLoop: true))` |

`Capsule` is new; there is no 0.14 equivalent.

Chains now require at least four points, and they are one-sided: the solid surface is to the right
of the winding direction, so wind loops counter-clockwise and list open ground chains from right to
left. For an open chain the first and last points are ghost anchors used for smooth collision and
are not part of the collidable segments, so a four-point open chain produces one segment. The
segments of a chain are available through `chain.segments`.


## Contact listeners become polled events

`ContactListener` and `world.setContactListener` no longer exist. After each step the world exposes
the events that occurred during it, and each shape has to opt in to the events it should generate.

```dart
// Before
class MyListener extends ContactListener {
  @override
  void beginContact(Contact contact) { ... }
}
world.setContactListener(MyListener());

// After
body.createShape(Circle(radius: 1), ShapeDef(enableContactEvents: true));

world.step(1 / 60);
for (final event in world.contactEvents.begin) {
  // event.shapeA, event.shapeB, event.normal, event.points
}
```

- `world.contactEvents` holds `begin`, `end`, and `hit` lists. Begin events carry the contact
  normal and the contact points, which replace the old `Manifold`.
- `world.sensorEvents` holds the `begin` and `end` sensor overlaps, each with a `sensor` and a
  `visitor` shape. Both the sensor and its visitors need `ShapeDef.enableSensorEvents`.
- `world.bodyMoveEvents` reports the bodies that moved during the step.
- End events can reference shapes that were destroyed in the meantime, so check `Shape.isValid`
  before using them.

`preSolve` becomes the world-level `world.preSolveCallback`, which returns whether the contact
should be solved this step and requires `ShapeDef.enablePreSolveEvents` on the shapes. There is no
`postSolve` and no `ContactImpulse`: for impact strength enable `ShapeDef.enableHitEvents` and read
`world.contactEvents.hit`, whose events carry a `point`, a `normal`, and an `approachSpeed`.
Custom pair filtering, previously done by subclassing the contact filter, is now
`world.customFilterCallback`.

The old `Contact` class is gone entirely, so its methods have no direct replacement. In particular
`contact.isTouching()`, which was commonly used to guard callbacks, is no longer needed because a
begin event means the shapes started touching, and `contact.getWorldManifold(...)` is replaced by
the `normal` and `points` on the begin event.


## Queries return their results

The ray cast and query callback classes are replaced by methods on `World` that return their
results. Note that the ray is now expressed as an origin and a translation, not two points.

```dart
// Before
class MyCallback extends RayCastCallback {
  @override
  double reportFixture(
    Fixture fixture,
    Vector2 point,
    Vector2 normal,
    double fraction,
  ) { ... }
}
world.raycast(MyCallback(), start, end);

// After
final hit = world.castRayClosest(start, end - start);
final allHits = world.castRayAll(start, end - start);
world.castRay(start, end - start, (hit) => 1);
```

Each `RayHit` carries the `shape`, `point`, `normal`, and `fraction`. `world.queryAABB(callback,
aabb)` becomes `world.overlapAabb(aabb)`, returning the overlapping shapes, and the axis-aligned
bounding box class was renamed from `AABB` to `Aabb`. `world.clearForces()` is gone, as forces are
applied per step in Box2D v3. Explosions are available through `world.explode(ExplosionDef(...))`.


## Joints

Joints are created through typed methods on the world and destroyed on the joint itself. The
`initialize` helpers on the defs are gone; anchors are given as local points, which you can compute
with `body.localPoint(worldAnchor)`.

```dart
// Before
final jointDef = RevoluteJointDef()..initialize(bodyA, bodyB, anchor);
final joint = RevoluteJoint(jointDef);
world.createJoint(joint);
world.destroyJoint(joint);

// After
final joint = world.createRevoluteJoint(
  RevoluteJointDef(
    bodyA: bodyA,
    bodyB: bodyB,
    localAnchorA: bodyA.localPoint(anchor),
    localAnchorB: bodyB.localPoint(anchor),
  ),
);
joint.destroy();
```

The available joints are distance, filter, motor, mouse, prismatic, revolute, weld, and wheel. The
gear, pulley, rope, friction, and constant-volume joints do not exist in Box2D v3. `FilterJoint`
(which only disables collision between two bodies) and `WheelJoint` are new.

Spring parameters are named `hertz` instead of `frequencyHz`, and springs generally have to be
enabled explicitly with `enableSpring`. Joint accessors are now getters and setters rather than
`getX()`/`setX()` methods, for example `joint.motorSpeed = 2` and `joint.angle`, and the limit
setters take named arguments: `joint.setLimits(lower: 0, upper: pi)`.

The world-space anchors `joint.anchorA` and `joint.anchorB` no longer exist; only the local
anchors do. Compute the world position when you need it, for example when rendering a joint:

```dart
final anchorA = joint.bodyA.worldPoint(joint.localAnchorA);
final anchorB = joint.bodyB.worldPoint(joint.localAnchorB);
```


## World and body changes

- `world.stepDt(dt)` becomes `world.step(dt, subStepCount: 4)`. The velocity and position iteration
  counts are replaced by the single `subStepCount`, which defaults to 4.
- There is no `world.bodies`. Track the bodies you create yourself, or use `world.bodyMoveEvents`.
- `World`, `Body`, `Shape`, `Chain`, and the joints are cheap value-like handles over ids in the
  native engine. Destroy them explicitly with `destroy()`, and check `isValid` when a handle may
  refer to something that has already been destroyed.
- Rotations are represented by `Rot` (a cosine/sine pair), so `BodyDef(angle: a)` becomes
  `BodyDef(rotation: Rot.fromAngle(a))` and `body.setTransform(position, rotation)` takes a `Rot`.
  `body.angle` still exists.
- Body renames: `worldCenter` is now `worldCenterOfMass`, `getLocalCenter()` is
  `localCenterOfMass`, `setAwake(value)` is `isAwake = value`, `getInertia()` is
  `rotationalInertia`, `bodyType` is `type`, `resetMassData()` is `applyMassFromShapes()`,
  `setMassData(data)` is `massData = data`, `worldVector(v)` is `rotation.rotate(v)`, and
  `localVector(v)` is `rotation.inverseRotate(v)`.
- `BodyDef` renames: `allowSleep` is now `enableSleep`, `bullet` is `isBullet`, and `active` is
  `isEnabled`. `gravityOverride` has no replacement; use `gravityScale` or apply your own forces.
- `userData` is stored on the Dart side in the world instead of a native pointer, and is cleared
  when the owning handle is destroyed.
