# Forge2D

We (the Flame organization) maintain a ported version of the Box2D physics engine and our version
is called Forge2D.

If you want to use Forge2D specifically for Flame you should use our bridge library
[flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d) and if you
just want to use it in a Dart project you can use the
[forge2d](https://github.com/flame-engine/forge2d) library directly.

To use it in your game you just need to add `flame_forge2d` to your pubspec.yaml, as can be seen
in the
[Forge2D example](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d/example)
and in the pub.dev [installation instructions](https://pub.dev/packages/flame_forge2d).

## Forge2DGame (FlameGame extension)

If you are going to use Forge2D in your project it can be a good idea to use the Forge2D specific
extension of the `FlameGame` class.

It is called `Forge2DGame` and it will control the adding and removal of Forge2D's `BodyComponents`
as well as your normal components.

In `Forge2DGame` the `Camera` has a zoom level set to 10 by default, so your components will be a
lot bigger than in a normal Flame game. This is due to the speed limitation in the `Forge2D` world,
which you would hit very quickly if you are using it with `zoom = 1.0`. You can easily change the
zoom level eiter by calling `super(zoom: yourZoom)` in your constructor, or do
`game.camera.zoom = yourZoom;` at a later stage.

If you are previously familiar with Box2D it can be good to know that the whole concept of the
Box2d world is mapped to `world` in the `Forge2DGame` component and every `Body` should be a
`BodyComponent`, and added to your `Forge2DGame`.

You can have for example a HUD and other non-physics-related components in your `Forge2DGame`'s
component list along with your physical entities. When the update is called, it will use the Forge2D
physics engine to properly update every child.

A simple `Forge2DGame` implementation examples can be seen in the
[examples folder](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d/example).

## BodyComponent

If you don't need to have a sprite on top of your body you should use the plain `BodyComponent`, for
example if you want a circle, rectangle or polygon but only painted with a Flutter `Paint`.

The `BodyComponent` is by default having `debugMode = true`, since otherwise it wouldn't show
anything after you have created a `Body` and added the `BodyComponent` to the game. If you want to
turn it off you can either override `debugMode` to set it to false or assign false to it in your
component constructor.

## SpriteBodyComponent

Often you want to render a sprite on top of the `BodyComponent` that you are going to use in your
`Forge2DGame`. This component will handle the scaling and positioning of your sprite on top of the
body.

## PositionBodyComponent

One of the most commonly used classes in Flame is the `PositionComponent`, many of the commonly used
components in Flame are subclasses of `PositionComponent`. If you want to put a `PositionComponent`
or any of its subclasses on top of a Forge2D body you can use the `PositionBodyComponent` and it
will, just like with the `SpriteBodyComponent`, handle the rotation, positioning and scaling of that
component so that it follows the underlying `Body`.

## Contact callbacks

If you are using `Forge2DGame` you can take advantage of its way of handling contacts between two
`BodyComponent`s.

When creating the body definition for your `BodyComponent` make sure that you set the userdata to
the current object, otherwise it will not be possible to detect collisions.
Like this:
```dart
final bodyDef = BodyDef()
  // To be able to know which component that is involved in a collision
  ..setUserData(this);
```

Now you have to make an implementation of `ContactCallback` where you set which two types that it
should react when they come in contact.
If you have two `BodyComponent`s named `Ball` and `Wall` and you want to do something when they come
in contact, you could do something like this:

```dart
class BallWallCallback implements ContactCallback<Ball, Wall> {
  BallWallCallback();

  @override
  void begin(Ball ball, Wall wall, Contact contact) {
    wall.remove();
  }

  @override
  void end(Ball ball, Wall wall, Contact contact) {}
}
```

and then you simply add `BallWallCallback` to your `Forge2DGame`:

```dart
class MyGame extends Forge2DGame {
  MyGame(Forge2DComponent box) : super(box) {
    addContactCallback(BallWallCallback());
  }
}
```

Every time `Ball` and `Wall` gets in contact `begin` will be called, and once the objects stop being
in contact `end` will be called.

If you want an object to interact with all other bodies, put `BodyComponent` as the one of the
parameters of your `ContactCallback` like this:

`class BallAnythingCallback implements ContactCallback<Ball, BodyComponent> ...`

An implementation example can be seen in the
[Flame Forge2D example](https://github.com/flame-engine/flame_forge2d/blob/main/example).

## Viewport and Camera

`Forge2DGame` is using an implementation of the normal Flame `Viewport` and `Camera`, which can be
read more about [here](camera_and_viewport.md).

If you see your screen as a window and the outside as the Forge2D world, then the `Viewport` is the
part of the world outside that you can see through the window, so the parts that you can see on
your screen.

To move around what you see in that window you use the `Camera`, which can also be very useful if
you want to follow one of your components around in the Forge2D world, or know where in the world
a point on the screen is or vice versa.
