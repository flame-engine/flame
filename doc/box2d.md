# Box2D

Although Flame does not implements Box2d itself, it bundles a forked port of the Java Box2d to Dart 
by Google.

The source of the bundled box2d on Flame can be found [here](https://github.com/feroult/box2d.dart).

There is a simple example game [here](https://github.com/feroult/haunt) that can be used as 
reference of how to use box2d on Flame, although it is a little bit outdated and doesn't use 
`Box2DGame`.

There are some updated examples of how to use it [here](./examples/box2d), 
but they are not full game implementations.

## BaseGame extension

If you are going to use Box2D in your project it can be a good idea to use the Box2D specific
extension of the `BaseGame` class. It is called `Box2DGame` and it will control the adding and
removal of Box2D's BodyComponents from your root `Box2DComponent`.

A simple `Box2DGame` implementation example can be seen in the 
[examples folder](./examples/box2d/simple).

## Contact callbacks

If you are using `Box2DGame` you can take advantage of its way of handling contacts between two 
`BodyComponent`s.

To do this you have to make an implementation of `ContactCallback` where you set which two types 
that it should react when they come in contact.
If you have two `BodyComponent`s named Ball and Wall and you want to do something when they come in 
contact you would do like this:

```dart
class BallContactCallback implements ContactCallback<Ball, Wall> {
  @override
  ContactTypes types = ContactTypes(Ball, Wall);

  BallContactCallback();

  @override
  void begin(Ball ball, Wall wall) {
    wall.remove();
  }

  @override
  void end(Ball ball, Wall wall) {}
}
```

and then you simply add `BallContactCallback` to your `Box2DGame`:

```dart
class MyGame extends Box2DGame {
  MyGame(Box2DComponent box) : super(box) {
    addContactCallback(BallContactCallback());
  }
}
```

Every time `Ball` and `Wall` gets in contact `begin` will be called, and once the objects stop 
being in contact `end` will be called.

An implementation example can be seen in the [examples folder](./examples/box2d/contact_callbacks).
