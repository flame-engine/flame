# Migrating from flame_forge2d 0.19

flame_forge2d 0.20 is built on Forge2D 0.15, which replaced the pure Dart port of Box2D 2.x with
bindings for [Box2D v3](https://box2d.org/). The whole underlying API changed, so this is a large
breaking change.

This page covers the flame_forge2d side of the migration: `BodyComponent`, `Forge2DWorld`,
`Forge2DGame`, and the contact callbacks. Everything you do directly with the physics engine
(shapes, joints, queries, world stepping) is described in the
[Forge2D migration guide](../../other_modules/forge2d/migration.md), which is worth reading first.

```{note}
The particle system (LiquidFun) no longer exists in Box2D v3 and has been
removed, together with `Forge2DWorld.raycastParticle`. If your game depends on
it, stay on flame_forge2d 0.19.
```


## Platform requirements

The SDK floor is now Dart 3.12 (Flutter 3.44), and building for native platforms requires a C
toolchain (Xcode on iOS and macOS, the NDK on Android, Visual Studio Build Tools on Windows, and
clang or gcc on Linux) because Box2D is compiled through the Dart build hooks. On the web the
WebAssembly module is bundled into the app automatically, so no build setup is needed there
either.

Forge2D now needs `await initializeForge2D()` before a physics world is created, which is what
loads that module on the web. `Forge2DGame` awaits it in its `onLoad` and creates the physics
world lazily, so games need no change. Code that creates a `Forge2DWorld` or a raw Forge2D
`World` on its own, including tests, has to await it first.


## BodyComponent

Fixtures are gone; bodies now carry shapes created from a `ShapeGeometry` and a `ShapeDef`. The
`fixtureDefs` constructor argument is replaced by `shapeSpecs`, a list of `ShapeSpec`, which pairs
a geometry with an optional def:

```dart
// Before
BodyComponent(
  bodyDef: BodyDef(type: BodyType.dynamic),
  fixtureDefs: [
    FixtureDef(CircleShape()..radius = 5, restitution: 0.8, friction: 0.4),
  ],
);

// After
BodyComponent(
  bodyDef: BodyDef(type: BodyType.dynamic),
  shapeSpecs: [
    ShapeSpec(
      Circle(radius: 5),
      ShapeDef(material: SurfaceMaterial(restitution: 0.8, friction: 0.4)),
    ),
  ],
);
```

If you override `createBody` instead, replace `createFixture`/`createFixtureFromShape` with
`createShape`:

```dart
// Before
@override
Body createBody() {
  final shape = EdgeShape()..set(start, end);
  final fixtureDef = FixtureDef(shape, friction: 0.3);
  return world.createBody(BodyDef())..createFixture(fixtureDef);
}

// After
@override
Body createBody() {
  final shapeDef = ShapeDef(material: SurfaceMaterial(friction: 0.3));
  return world.createBody(BodyDef())
    ..createShape(Segment(point1: start, point2: end), shapeDef);
}
```

The rendering hooks changed accordingly, and now read the geometry back from the shape:

| Before | After |
|---|---|
| `renderFixture(Canvas, Fixture)` | `renderShape(Canvas, Shape)` |
| `renderEdge(Canvas, Offset, Offset)` | `renderSegment(Canvas, Offset, Offset)` |
| `renderChain(Canvas, List<Offset>)` | removed, chain segments render through `renderSegment` |
| | `renderCapsule(Canvas, Offset, Offset, double)` is new |

`renderCircle` and `renderPolygon` are unchanged. `BodyComponent.center` now returns
`body.worldCenterOfMass`, and `BodyDef(angle: a)` becomes `BodyDef(rotation: Rot.fromAngle(a))`.

```{warning}
The default friction changed: `FixtureDef` defaulted to 0, while
`SurfaceMaterial` defaults to 0.6. Shapes that relied on the old default are
no longer frictionless, so pass `SurfaceMaterial(friction: 0)` explicitly
where you need the old behavior.
```

Chains changed from two-sided to one-sided, which is easy to miss because it
compiles fine and only shows up as bodies falling through your level geometry.
The solid surface is to the right of the winding direction, and since Flame's
y-axis points down, that is the opposite order from what Box2D's own
documentation describes: list ground chains from **left to right**, and wind
loops clockwise on screen. If bodies fall through a chain, reverse its points.

A one-sided chain is the right shape for ground and walls that are only ever
approached from one side. For solid level geometry that has to block from
every direction, such as a ramp or a platform that bodies can reach from
below, use a `Polygon` instead: a chain loop is hollow, so bodies that get
past one edge end up trapped inside it.


## Contact callbacks

`ContactCallbacks` keeps the same shape, so components that only implement `beginContact` and
`endContact` mostly keep working:

```dart
class Ball extends BodyComponent with ContactCallbacks {
  @override
  void beginContact(Object other, Contact contact) {
    if (other is Wall) { ... }
  }
}
```

What changed:

- `Contact` is now a small flame_forge2d class instead of the Forge2D one. It carries `shapeA`,
  `shapeB`, `bodyA`, `bodyB`, `isSensorEvent`, and, for begin events, `normal` and `points`. Since
  end events can arrive after a shape was destroyed, check `contact.isValid` before using the
  bodies. `contact.fixtureA`/`fixtureB` become `contact.shapeA`/`shapeB`. The old `isTouching()`
  and `getWorldManifold()` methods are gone: a begin event already means the shapes started
  touching, and the manifold data is on the event itself.
- **Contact events are opt-in per shape.** Box2D v3 only generates events for shapes that asked
  for them, so the involved shapes need `ShapeDef(enableContactEvents: true)`, and sensors together
  with their visitors need `enableSensorEvents: true`. The default `BodyComponent.createBody()`
  sets both flags automatically for shapes created through `shapeSpecs` when the `bodyDef`'s or the
  `ShapeDef`'s `userData` is a `ContactCallbacks`, but if you override `createBody` you have to set
  them yourself.
- `preSolve` and `postSolve` are removed from `ContactCallbacks`. To veto a contact before it is
  solved, set `world.preSolveCallback` and enable `ShapeDef.enablePreSolveEvents` on the shapes.
  For impact strength, enable `ShapeDef.enableHitEvents` and read
  `world.physicsWorld.contactEvents.hit`, whose events carry an `approachSpeed`. `Manifold` and
  `ContactImpulse` no longer exist.
- `WorldContactListener` is replaced by `ContactEventsDispatcher`, which the world polls once per
  update. Subclass it if you customized the dispatch algorithm, and pass it through the
  `contactEventsDispatcher` argument of `Forge2DGame` or `Forge2DWorld`, which replaced the
  `contactListener` argument.

Also note that a body destroyed while it is touching something does not produce a final
`endContact` for that contact any more, because the userData needed to route the event is cleared
together with the body.


## Forge2DWorld

- Joint helpers were removed. Create joints on the physics world with the typed methods and destroy
  them on the joint: `world.physicsWorld.createRevoluteJoint(def)` and `joint.destroy()` replace
  `world.createJoint(joint)` and `world.destroyJoint(joint)`.
- Queries follow the new Forge2D API: `raycast(callback, p1, p2)` becomes `castRayClosest`,
  `castRay`, or `castRayAll` (taking an origin and a translation), and `queryAABB(callback, aabb)`
  becomes `overlapAabb(aabb)`, whose bounding box type was renamed from `AABB` to `Aabb`.
  `clearForces()` and `raycastParticle` are gone.
- `world.preSolveCallback` and `world.customFilterCallback` are new forwarding setters.
- `subStepCount` (default 4) controls how many sub-steps each update performs, replacing the old
  velocity and position iteration counts.
- Forge2D no longer exposes a list of all bodies, so `world.physicsWorld.bodies` becomes
  `world.bodies`, which tracks the bodies created through `world.createBody`. Bodies created
  directly on `world.physicsWorld` are not included, and are not woken by the gravity setter.
- The physics world is never destroyed automatically, so that a world can be removed and added back
  later. Call `world.physicsWorld.destroy()` yourself when you are permanently done with a world.


## Forge2DGame

The meters-to-pixels scaling no longer goes through the camera's zoom, so the zoom is free for
zooming the camera in and out.

- `Forge2DGame(zoom: 24)` becomes `Forge2DGame(metersToPixels: 24)`, and
  `game.camera.viewfinder.zoom = 24` becomes `game.metersToPixels = 24`.
- The default changed from 10 to 100, so a game that never set a zoom now renders ten times
  larger. Pass `metersToPixels: 10` to keep it exactly as it was, but read
  [](forge2d.md#units-and-scale) first: the old default came with advice to lay the world out much
  smaller than a meter, and that advice is now actively harmful.
- The camera of a `Forge2DGame` uses a `Forge2DViewfinder`, which renders one meter of the physics
  world as `metersToPixels` pixels. Its `zoom` is applied on top of that and now starts at 1. If
  you pass your own `camera`, its viewfinder is replaced with a `Forge2DViewfinder`, so pass one
  yourself if you have a custom viewfinder.
- Nothing outside of the rendering changed units: body positions,
  `camera.viewfinder.position`, `camera.viewfinder.visibleGameSize`, `camera.visibleWorldRect` and
  the local positions that events report are all still in meters.
- Code that used the zoom to convert between meters and pixels, for example when positioning a
  Flutter widget on top of a body, should use `game.metersToPixels` instead.


## World scale

This is the change most likely to break a game that otherwise compiles and runs.

flame_forge2d used to tell you to lay your world out in meters much smaller than a pixel, because
Box2D v2 clamped every body to `maxTranslation` of 2 meters per step, about 120 m/s. Box2D v3
replaced that with `WorldDef.maximumLinearSpeed`, which defaults to 400 m/s and is settable per
world, and it added speculative contacts, which report a contact as soon as two shapes are within
`Tolerances.speculativeDistance` (0.02 meters) of each other.

The upshot is that a world that was deliberately laid out at a sub-meter scale now reports
contacts across visible gaps, never bounces, and puts bodies to sleep while they are still moving.
See [](forge2d.md#units-and-scale) for the full picture; in short:

- Prefer scaling the world up so that moving bodies are roughly 0.1 to 10 meters. Multiply lengths
  **and gravity** by the same factor, which leaves the timing of the simulation unchanged, then
  divide `metersToPixels` by it to keep everything the same size on screen. There is a table of
  how the other quantities scale in the same section.
- If that is impractical, pass `lengthUnitsPerMeter` to the `Forge2DGame` constructor to move
  Box2D's tolerances to your scale instead, for example `super(lengthUnitsPerMeter: 0.04)` for a
  world where a person is 0.04 units tall.

In debug mode flame_forge2d prints a warning once when it creates a moving body that is small
enough for this to bite.


## Name collisions

Forge2D exports a `World`, which collides with Flame's `World` component, so files that use both
need `import 'package:flame_forge2d/flame_forge2d.dart' hide World;`. That was already the case
before, as was the collision between Forge2D's `Transform` and the one in
`flutter/material.dart`, but Forge2D now also exports `Circle`, `Polygon`, and `Segment`, which
can collide with `flame/geometry.dart`. Resolve them per file with `hide` or a prefixed import,
for example:

```dart
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform, World;
```
