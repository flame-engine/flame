

# Flame SVG

Flame provides a simple API to render SVG images in your game.

Svg support is provided by the `flame_svg` external package, be sure to put it in your pubspec file
to use it.

To use it just import the `Svg` class from `'package:flame_svg/flame_svg.dart'`, and use the
following snippet to render it on the canvas:

```dart
Svg svgInstance = Svg('android.svg');

final position = Vector2(100, 100);
final size = Vector2(300, 300);

svgInstance.renderPosition(canvas, position, size);
```

or use the [SvgComponent]:

```dart
class MyGame extends FlameGame {
    Future<void> onLoad() async {
      final svgInstance = await Svg.load('android.svg');
      final size = Vector2.all(100);
      final svgComponent = SvgComponent.fromSvg(size, svgInstance);
      svgComponent.x = 100;
      svgComponent.y = 100;

      add(svgComponent);
    }
}
```

More [here](https://docs.flame-engine.org/main/images.html#svg).
