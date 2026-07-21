# Forge2D

Blue Fire maintains Forge2D, Dart bindings for the [Box2D](https://box2d.org/) physics engine
(native on mobile and desktop, WebAssembly on the web).

If you want to use Forge2D specifically for Flame you should use our bridge library
[flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d) and if you
just want to use it in a Dart project you can use the
[forge2d](https://github.com/flame-engine/forge2d) library directly.

To use it in your game you just need to add `flame_forge2d` to your `pubspec.yaml`, as can be
seen in the
[Forge2D example](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d/example)
and the pub.dev [installation instructions](https://pub.dev/packages/flame_forge2d).

Since Forge2D runs Box2D as native code, a C toolchain is required when building for native
platforms (Xcode on iOS/macOS, the NDK on Android, Visual Studio Build Tools on Windows and
clang or gcc on Linux). On the web a bundled WebAssembly build of Box2D is used instead.

Forge2D has to be initialized with `await initializeForge2D()` before any physics world is
created, which on the web is what loads that WebAssembly module. `Forge2DGame` awaits this in its
`onLoad`, so games don't have to do anything, but that also means that a `Forge2DGame` subclass
which overrides `onLoad` has to await `super.onLoad()` before it creates any bodies:

```dart
class MyGame extends Forge2DGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();  // Not awaiting this breaks the game on the web.
    world.add(MyBody());
  }
}
```

If you create a `Forge2DWorld` or a raw Forge2D `World` outside of a `Forge2DGame`, await
`initializeForge2D()` yourself first, or the world creation will throw on the web.

If you are upgrading an existing game from flame_forge2d 0.19, see the
[migration guide](migration.md).


## Forge2DGame

If you are going to use Forge2D in your project it can be a good idea to use the Forge2D-specific
`FlameGame` class, `Forge2DGame`.

It is called `Forge2DGame` and supports both the special Forge2D components called `BodyComponents`
as well as normal Flame components.

`Forge2DGame` has a built-in `CameraComponent` that uses a `Forge2DViewfinder`. The physics world
is measured in meters, and the viewfinder renders one meter as `metersToPixels` pixels, which is
10 by default. Your components will therefore be a lot bigger than in a normal Flame game, which
is what you want: there is a speed limit in the `Forge2D` world that you would hit very quickly if
one meter was one pixel.

You can change the scale either by calling `super(metersToPixels: yourScale)` in your constructor
or by doing `game.metersToPixels = yourScale;` at a later stage.

The `zoom` of the viewfinder is applied on top of `metersToPixels` and defaults to 1, so it is free
for what it is normally used for: zooming the camera in and out. Everything except the rendering
stays in meters, so body positions, `camera.viewfinder.position`, `camera.visibleWorldRect` and the
local positions that events report are all still expressed in meters.

If you are previously familiar with Box2D it can be good to know that the whole concept of the
Box2d world is mapped to `world` in the `Forge2DGame` component and every `Body` that you want to
use as a component should be wrapped in a `BodyComponent`, and added to the `world` in your
`Forge2DGame`.

You can have have non-physics-related components in your `Forge2DGame` world's component list along
with your physical entities. When the update is called, it will use the Forge2D physics engine to
properly update every `BodyComponent` and other components in the game will be updated according to
the normal `FlameGame` way.

In `Forge2DGame` the gravity is flipped compared to `Forge2D` to keep the same coordinate system as
in Flame, so a positive y-axis in the gravity like `Vector2(0, 10)` would be pulling bodies
downwards, meanwhile, a negative y-axis would pull them upwards. The gravity can be set directly in
the constructor of the `Forge2DGame`.

A simple `Forge2DGame` implementation example can be seen in the
[examples folder](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d/example).


## Forge2DWorld

The `Forge2DWorld` is a the world that all your [`BodyComponent`]s live in. In the `Forge2DGame`
there is a `Forge2DWorld` instance called `world` by default, which is where you should add your
`BodyComponent`s.

If you want to swap between worlds you can create your own `Forge2DWorld` instance and assign it
to the `Forge2DGame` instance's `world` property, `game.world = Forge2DWorld()`.

If you would like to re-use a world later and have it keep its physics state you have to make sure
that the bodies aren't destroyed when the world is removed from the game. You can do this by
setting `world.destroyBodiesOnRemove` to false, like `game.world.destroyBodiesOnRemove = false;`.

The underlying Forge2D physics world is available as `world.physicsWorld`, which you can use to
access the parts of the Forge2D API that `Forge2DWorld` doesn't wrap, like creating joints or
polling the raw event streams.


## BodyComponent

The `BodyComponent` is a wrapper for the `Forge2D` body, which is the body that the physics engine
is interacting with. A body carries one or more `Shape`s, which are created from a
`ShapeGeometry` (`Circle`, `Capsule`, `Segment` or `Polygon`, plus chains via
`body.createChain`) and an optional `ShapeDef` that holds the surface material (friction,
restitution), density, filter, and event flags.

To create a `BodyComponent` you can either:

- override `createBody()` and create and return your created body;
- use the default `createBody()` implementation by passing a `BodyDef` instance (and optionally a
list of `ShapeSpec` instances, which pair a `ShapeGeometry` with an optional `ShapeDef`) to the
BodyComponent's constructor;
- use the default `createBody()` implementation and assign a `BodyDef` instance to `this.bodyDef`,
and optionally a list of `ShapeSpec` instances to `this.shapeSpecs`.

```dart
final ball = BodyComponent(
  bodyDef: BodyDef(type: BodyType.dynamic),
  shapeSpecs: [
    ShapeSpec(
      Circle(radius: 5),
      ShapeDef(material: SurfaceMaterial(restitution: 0.8)),
    ),
  ],
);
```

The `BodyComponent` is by default having `renderBody = true`, since otherwise, it wouldn't show
anything after you have created a `Body` and added the `BodyComponent` to the game. If you want to
turn it off you can just set (or override) `renderBody` to false.

Just like any other Flame component you can add children to the `BodyComponent`, which can be very
useful if you want to add for example animations or other components on top of your body.

The body that you create should be defined according to Flame's coordinate system,
not according to the coordinate system of Forge2D (where the Y-axis is flipped).

:exclamation: In Forge2D you shouldn't add any bodies as children to other components,
since Forge2D doesn't have a concept of nested bodies.
So bodies should live on the top level in the physics world, `Forge2DGame.world`.
So instead of `add(Weapon()))`, `world.add(Weapon())` should be used (as below), and the `Player`
should also of course initially be added to the world.

```dart
class Weapon extends BodyComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // ...
  }
}

class Player extends BodyComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world.add(Weapon());
  }
}
```

Later you might want to add bullets coming from your weapon, these are added to the world in the
same sense, but if they are going to be moving very fast, make sure that you set `isBullet = true`
to avoid some tunneling problems.


## Contact callbacks

`Forge2DGame` provides a simple out-of-the-box solution to propagate contact events.

Contact events occur whenever two `Shape`s meet each other. These events allow listening when
these `Shape`s begin to come in contact (`beginContact`) and cease being in contact
(`endContact`). Sensor overlaps are delivered through the same callbacks.

There are multiple ways to listen to these events. One common way is to use the `ContactCallbacks`
class as a mixin in the `BodyComponent` where you are interested in these events.

```dart
class Ball extends BodyComponent with ContactCallbacks {
  ...
  void beginContact(Object other, Contact contact) {
    if (other is Wall) {
      // Do something here.
    }
  }
  ...
}
```

For the above to work, the `Ball`'s `body.userData` or contacting `shape.userData` must be
set to a `ContactCallbacks`. And if `Wall` is a `BodyComponent` its `body.userData` or contacting
`shape.userData` must be set to `Wall`.

If `userData` is `null` the contact events are ignored, it is `null` by default.

Forge2D only generates events for shapes that have opted in to them, so the involved shapes also
need `ShapeDef.enableContactEvents` set to true (and `ShapeDef.enableSensorEvents` for sensors
and their visitors). The default `createBody()` implementation of `BodyComponent` enables these
flags automatically for shapes created through `shapeSpecs` when a `ContactCallbacks` is present
in the body's or shape's userData, but if you override `createBody()` you need to set them
yourself:

```dart
class Ball extends BodyComponent with ContactCallbacks {
  ...

  @override
  Body createBody() {
    ...
    final bodyDef = BodyDef(
      userData: this,
    );
    final shapeDef = ShapeDef(
      enableContactEvents: true,
    );
    ...
  }

}
```

Every time `Ball` and `Wall` begin to come in contact `beginContact` will be called, and once the
shapes cease being in contact, `endContact` will be called.

The old `preSolve` and `postSolve` callbacks no longer exist. To disable a contact before it is
solved (for example for one-sided platforms), use `world.preSolveCallback` together with
`ShapeDef.enablePreSolveEvents`. To measure impact strength, enable `ShapeDef.enableHitEvents`
and poll `world.physicsWorld.contactEvents.hit`.

An implementation example can be seen in the [Flame Forge2D
example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/bridge_libraries/flame_forge2d/utils/balls.dart).
