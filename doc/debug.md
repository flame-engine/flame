# Debug features

## FPS counter

Flame provides the `FPSCounter` mixin for recording the fps, this mixin can be applied on any class
that extends from `Game`. Once applied you can access the current fps by using the `fps` method,
like shown in the example below.

```dart
class MyGame extends Game with FPSCounter {
  static final fpsTextConfig = TextConfig(color: BasicPalette.white.color);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    fpsTextConfig.render(canvas, fps(120).toString(), Vector2(0, 50));
  }
}
```

## BaseGame features

If you are using `BaseGame`, you don't have to apply the `FPSCounter` mixin to get access to the current FPS,
because it is already applied by default (so you can use the `fps` method directly).

Flame provides some debugging features for the `BaseGame` class. These features are enabled when
the `debugMode` property is set to `true` (or overridden to be `true`).
When `debugMode` is enabled, each `PositionComponent` will be rendered with their bounding size, and have
their positions written on the screen. This way, you can visually verify the components boundaries and
positions.

To see a working example of the debugging features of the `BaseGame`,
check this [example](https://github.com/flame-engine/flame/tree/master/doc/examples/debug).
