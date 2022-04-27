# Debug features

## Tracking FPS

Flame provides the `HasFPS` mixin for recording the fps; this mixin can be applied on any class
that extends from `Game`. Once applied you can access the current fps by using the `fps` property,
like shown in the example below.

```dart
class MyGame extends FlameGame with HasFPS {
  static final fpsTextConfig = TextConfig(color: BasicPalette.white.color);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    fpsTextConfig.render(canvas, '$fps', Vector2(0, 50));
  }
}
```

## FlameGame features

Flame provides some debugging features for the `FlameGame` class. These features are enabled when
the `debugMode` property is set to `true` (or overridden to be `true`).
When `debugMode` is enabled, each `PositionComponent` will be rendered with their bounding size, and
have their positions written on the screen. This way, you can visually verify the components
boundaries and positions.

To see a working example of the debugging features of the `FlameGame`, check this
[example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/components/debug_example.dart).
