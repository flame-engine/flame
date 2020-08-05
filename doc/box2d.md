# Box2D

Although Flame does not implement Box2d itself, it bundles a forked port of the Java Box2d to Dart by Google.

The source of the bundled box2d on Flame can be found [here](https://github.com/flame-engine/box2d.dart).

To use Box2D in your game you should add flame_box2d to your pubspec.yaml, which can be seen in the examples.

The examples of how to use it can be found [here](https://github.com/flame-engine/flame_box2d/blob/master/examples/), but they are not full game implementations.

## Box2DGame (BaseGame extension)

If you are going to use Box2D in your project it can be a good idea to use the Box2D specific extension of the `BaseGame` class.

It is called `Box2DGame` and it will control the adding and removal of Box2D's BodyComponents as well as your normal components.

Simple `Box2DGame` implementation examples can be seen in the [examples folder](https://github.com/flame-engine/flame_box2d/blob/master/examples/).

## SpriteBodyComponent

Often you want to render a sprite on top of the BodyComponent that you are going to use in your Box2DGame. This component will handle the scaling and positioning of your sprite on top of the body.

## Contact callbacks

If you are using `Box2DGame` you can take advantage of its way of handling contacts between two `BodyComponent`s.

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

and then you simply add `BallWallCallback` to your `Box2DGame`:

```dart
class MyGame extends Box2DGame {
  MyGame(Box2DComponent box) : super(box) {
    addContactCallback(BallWallCallback());
  }
}
```

Every time `Ball` and `Wall` gets in contact `begin` will be called, and once the objects stop being in contact `end` will be called.

If you want an object to interact with all other bodies, put `BodyComponent` as the one of the parameters of your `ContactCallback` like this:

`class BallAnythingCallback implements ContactCallback<Ball, BodyComponent> ...`

An implementation example can be seen in the [examples folder](https://github.com/flame-engine/flame_box2d/blob/master/examples/contact_callbacks).
