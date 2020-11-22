# Forge2D

We (the Flame organization) maintains a ported version of the Box2D physics engine and our version is called Forge2D.

The Forge2D project can use can be found [here](https://github.com/flame-engine/forge2d), and it can be used in any Dart project.

If you want to use Forge2D specifically for Flame you should use our bridge library [flame_forge2d](https://github.com/flame-engine/flame_forge2d).

To use it in your game you just need to add flame_forge2d to your pubspec.yaml, which can be seen in the [Forge2D example](https://github.com/flame-engine/flame_forge2d/tree/master/example).

## Forge2DGame (BaseGame extension)

If you are going to use Forge2D in your project it can be a good idea to use the Forge2D specific extension of the `BaseGame` class.

It is called `Forge2DGame` and it will control the adding and removal of Forge2D's BodyComponents as well as your normal components.

The whole concept of a box2d's world is mapped to `world` in the `Forge2DGame` component; every Body should be a `BodyComponent`, and added to the `Forge2DGame`.

You can have for example a HUD and other non-physics-related components in your `Forge2DGame's component list along with your physical entities. When the update is called, it will use the Forge2D physics engine to properly update every child.

Simple `Forge2DGame` implementation examples can be seen in the [examples folder](https://github.com/flame-engine/flame_box2d/blob/master/examples/).

## BodyComponent

If you don't need to have a sprite on top of your body you should use the plain BodyComponent, for example if you want a circle, rectangle or polygon but only painted with a Flutter `Paint`.

## SpriteBodyComponent

Often you want to render a sprite on top of the BodyComponent that you are going to use in your Forge2DGame. This component will handle the scaling and positioning of your sprite on top of the body.

## Contact callbacks

If you are using `Forge2DGame` you can take advantage of its way of handling contacts between two `BodyComponent`s.

When creating the body definition for your `BodyComponent` make sure that you set the userdata to the current object, otherwise it will not be possible to detect collisions.
Like this:
```dart
final bodyDef = BodyDef()
  // To be able to determine object in collision
  ..setUserData(this);
```

Now you have to make an implementation of `ContactCallback` where you set which two types that it should react when they come in contact.
If you have two `BodyComponent`s named Ball and Wall and you want to do something when they come in contact you would do like this:

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

Every time `Ball` and `Wall` gets in contact `begin` will be called, and once the objects stop being in contact `end` will be called.

If you want an object to interact with all other bodies, put `BodyComponent` as the one of the parameters of your `ContactCallback` like this:

`class BallAnythingCallback implements ContactCallback<Ball, BodyComponent> ...`

An implementation example can be seen in the [examples folder](https://github.com/flame-engine/flame_box2d/blob/master/examples/contact_callbacks).
