# Forge2D

Blue Fire maintains a ported version of the Box2D physics engine and our
version is called Forge2D.

If you want to use Forge2D specifically for Flame you should use our bridge library
[flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d) and if you
just want to use it in a Dart project you can use the
[forge2d](https://github.com/flame-engine/forge2d) library directly.

To use it in your game you just need to add `flame_forge2d` to your
`pubspec.yaml`, as can be seen in the [Forge2D
[example](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d/example)
and the pub. dev [installation
instructions](https://pub.dev/packages/flame_forge2d)](<https://pub.dev/packages/flame_forge2d>).


## Forge2DGame

If you are going to use Forge2D in your project it can be a good idea to use the Forge2D-specific
`FlameGame` class, `Forge2DGame`.

It is called `Forge2DGame` and supports both the special Forge2D components called `BodyComponents`
as well as normal Flame components.

`Forge2DGame` has a built-in `CameraComponent` and has a zoom level set to 10 by default, so your
components will be a lot bigger than in a normal Flame game. This is due to the speed limit in the
`Forge2D` world, which you would hit very quickly if you are using it with `zoom = 1.0`. You can
easily change the zoom level either by calling `super(zoom: yourZoom)` in your constructor or
doing `game.cameraComponent.viewfinder.zoom = yourZoom;` at a later stage.

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


## BodyComponent

The `BodyComponent` is a wrapper for the `Forge2D` body, which is the body that the physics engine
is interacting with. To create a `BodyComponent` you need to override `createBody()` and create and
return your created body.

The `BodyComponent` is by default having `renderBody = true`, since otherwise, it wouldn't show
anything after you have created a `Body` and added the `BodyComponent` to the game. If you want to
turn it off you can just set (or override) `renderBody` to false.

Just like any other Flame component you can add children to the `BodyComponent`, which can be very
useful if you want to add for example animations or other components on top of your body.

The body that you create in `createBody` should be defined according to Flame's coordinate system,
not according to the coordinate system of Forge2D (where the Y-axis is flipped).

:exclamation: In Forge2D you shouldn't add any bodies as children to other components,
since Forge2D doesn't have a concept of nested bodies.
So bodies should live on the top level in the physics world, `Forge2DGame.world`.
So instead of `add(Weapon()))`, `world.add(Weapon())` should be used (as below), and the `Player`
should also of course initially be added to the world.

```dart
class Weapon extends BodyComponent  {
  @override
  void onLoad() {
    ...
  }
}

class Player extends BodyComponent  {
  @override
  void onLoad() {
    world.add(Weapon());
  }
}
```

Later you might want to add bullets coming from your weapon, these are added to the world in the
same sense, but if they are going to be moving very fast, make sure that you set `isBullet = true`
to avoid some tunneling problems.


## Contact callbacks

`Forge2DGame` provides a simple out-of-the-box solution to propagate contact events.

Contact events occur whenever two `Fixture`s meet each other. These events allow listening when
these `Fixture`s begin to come in contact (`beginContact`) and cease being in contact
(`endContact`).

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

For the above to work, the `Ball`'s `body.userData` or contacting `fixture.userData` must be
set to a `ContactCallback`. And if `Wall` is a `BodyComponent` it's `body.userData` or contacting
`fixture.userData` must be set to `Wall`.

If `userData` is `null` the contact events are ignored, it is `null` by default.

A convenient way of setting `userData` is to assign it when creating the body. For example:

```dart
class Ball extends BodyComponent with ContactCallbacks {
  ...

  @override
  Body createBody() {
    ...
    final bodyDef = BodyDef(
      userData: this,
    );
    ...
  }

}
```

Every time `Ball` and `Wall` begin to come in contact `beginContact` will be called, and once the
fixtures cease being in contact, `endContact` will be called.

An implementation example can be seen in the [Flame Forge2D
example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/bridge_libraries/flame_forge2d/utils/balls.dart).
