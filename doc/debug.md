# Debug features

## FPS counter

Flame provides the `FPSCounter` mixin for recording the fps, this mixin can be applied on any class
that extends from `Game`. Once applied you can access the current fps by using the `fps` method`,
like shown in the example below.

```dart
class MyGame extends Game with FPSCounter {
  static final fpsTextConfig = TextConfig(color: const Color(0xFFFFFFFF));

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    fpsTextConfig.render(canvas, fps(120).toString(), Vector2(0, 50));
  }
}
```

## BaseGame features

On `BaseGame` you don't have to apply the `FPSCounter` mixin to get access to the current fps,
because it is already applied by default in `BaseGame`, so you can use the `fps` method directly.

Flame provides some features other for debugging your `BaseGame`, these features are enabled when
the `debugMode` from the is set to `true` (or overridden to be true).
When `debugMode` is enabled all `PositionComponent`s will be wrapped into a rectangle, and have
their positions rendered on the screen, so you can visually verify the components boundaries and
positions.

To see a working example of the debugging features of the `BaseGame`,
check this [example](https://github.com/flame-engine/flame/tree/master/doc/examples/debug).
