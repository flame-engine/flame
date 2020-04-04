# Box2D

Although Flame does not implements Box2d itself, it bundles a forked port of the Java Box2d to Dart by Google.

The source of the bundled box2d on Flame can be found [here](https://github.com/feroult/box2d.dart).

There is also a simple example game that can be used as reference of how to use box2d on Flame [here](https://github.com/feroult/haunt).

## BaseGame extension

If you are going to use Box2D in your project it can be a good idea to use the Box2D specific
extension of the `BaseGame` class. It is called `Box2DGame` and it will control the adding and
removal of Box2D's BodyComponents from your root `Box2DComponent`.

A simple `Box2DGame` implementation example can be seen in the [examples folder](./examples/box2d).

