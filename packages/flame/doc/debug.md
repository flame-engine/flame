# Debug features

## FPS counter

Flame provides the `FPSCounter` mixin for recording the fps, this mixin can be applied on any class that extends from `Game`. When applied you have to implemented the `recordFps` method and it should return `true` if you want to access the current fps by using the `fps` method`.

```dart
class MyGame extends Game with FPS {
  @override
  bool recordFps() => true;
}
```

## BaseGame features

Flame provides some features for debugging, these features are enabled when the `debugMode` from the `BaseGame` class is set to `true` (or overridden to be true).
When it's enabled all `PositionComponent`s will be wrapped into a rectangle, and have its position rendered on the screen, so you can visually verify the component boundaries and position.

To see a working example of the debugging features of the `BaseGame`, [check this example](https://github.com/flame-engine/flame/tree/master/doc/examples/debug).
