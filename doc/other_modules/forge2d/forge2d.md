# Forge2D

The **forge2d** library provides Dart bindings for the [Box2D](https://box2d.org/) physics engine,
running the engine as native code on mobile and desktop platforms and as WebAssembly on the web.
It can be used in any Dart project, with or without Flame.

If you want to use Forge2D in a Flame game you should use the
[flame_forge2d](../../bridge_packages/flame_forge2d/flame_forge2d.md) bridge package instead, which
wraps the concepts described here in Flame components.

If you are upgrading from forge2d 0.14, see the [migration guide](migration.md).


## Getting started

Add `forge2d` to your `pubspec.yaml`, initialize Forge2D, and create a world:

```dart
import 'package:forge2d/forge2d.dart';

Future<void> main() async {
  // Required before any world is created. See "Initialization" below.
  await initializeForge2D();

  final world = World(gravity: Vector2(0, -10));

  final ground = world.createBody(BodyDef(position: Vector2(0, -1)));
  ground.createShape(Polygon.box(50, 1));

  final ball = world.createBody(
    BodyDef(type: BodyType.dynamic, position: Vector2(0, 10)),
  );
  ball.createShape(
    Circle(radius: 0.5),
    ShapeDef(material: SurfaceMaterial(restitution: 0.8)),
  );

  for (var i = 0; i < 120; i++) {
    world.step(1 / 60);
    print(ball.position.y);
  }

  world.destroy();
}
```

Note that when forge2d is used standalone the world uses Box2D's y-up convention, so a downwards
gravity has a negative y value. The `flame_forge2d` bridge flips this for you to match Flame's
y-down coordinate system.


## Initialization

`await initializeForge2D()` has to complete before the first `World` is created. On native
platforms it returns immediately, but on the web it fetches and instantiates the Box2D
WebAssembly module, and creating a world before it has finished throws a `StateError`. Since the
same code should run on every platform, always await it once during startup:

```dart
await initializeForge2D();
```

The web module is looked up at the package asset path served by the Dart web tooling, at the
asset that Flutter web bundles automatically, and finally at a `box2d.wasm` next to the page, so
no extra setup is needed for the common cases. If you host the module somewhere else, point
Forge2D at it with `initializeForge2D(wasmUri: ...)`.

`flame_forge2d` awaits this for you in `Forge2DGame.onLoad`, so games built on it don't need to
call it, unless they create a `World` outside of the game.

`World`, `Body`, `Shape`, `Chain`, and the joints are cheap value-like handles over ids inside the
native engine. Destruction is explicit: call `destroy()` on the handle when you are done with it,
and `world.destroy()` frees the whole simulation.


## Shapes

Bodies carry shapes, which are created from an immutable `ShapeGeometry` (`Circle`, `Capsule`,
`Segment`, or `Polygon`) and an optional `ShapeDef` holding the density, the collision filter, the
event flags, and the `SurfaceMaterial` (friction, restitution, and more). Chains of line segments
for static level geometry are created with `body.createChain(ChainDef(points: ...))`.


## Events and queries

Contact, sensor, and body-move events are polled from the world after each step through
`world.contactEvents`, `world.sensorEvents`, and `world.bodyMoveEvents`. Events are only generated
for shapes that have opted in through the `ShapeDef` event flags, like `enableContactEvents` and
`enableSensorEvents`.

Ray casts (`castRayClosest`, `castRay`, `castRayAll`) and AABB overlap queries (`overlapAabb`)
are available directly on `World`, returning their results instead of using callback classes,
and explosions are applied with `World.explode`.


## Joints

Eight joint types are supported: distance, filter, motor, mouse, prismatic, revolute, weld, and
wheel. A joint is created by passing its def to the corresponding typed method on the world, for
example `world.createRevoluteJoint(RevoluteJointDef(bodyA: ..., bodyB: ...))`, and removed with
`joint.destroy()`. See the [flame_forge2d joints
documentation](../../bridge_packages/flame_forge2d/joints.md) for a description of each joint.


## Platform support

Forge2D supports Android, iOS, macOS, Windows, Linux, and the web. On native platforms the bundled
Box2D sources are compiled by the Dart build hooks, which requires a C toolchain (Xcode on
iOS/macOS, the NDK on Android, Visual Studio Build Tools on Windows, and clang or gcc on Linux).
On the web a bundled WebAssembly build of Box2D is used, which is served automatically by the Dart
web tooling and bundled automatically into Flutter web builds.

For more details, see the [forge2d repository](https://github.com/flame-engine/forge2d).
