# Flame SVG

flame_svg provides a simple API for rendering SVG images in your game.


## Installation

Svg support is provided by the `flame_svg` bridge package, be sure to put it in your pubspec file
to use it.

If you want to know more about the installation visit
[flame_svg on pubdev](https://pub.dev/packages/flame_svg/install).


## How to use flame_svg

To use it just import the `Svg` class from `'package:flame_svg/flame_svg.dart'`, and use the
following snippet to render it on the canvas:

```dart
Svg svgInstance = Svg('android.svg');

final position = Vector2(100, 100);
final size = Vector2(300, 300);

svgInstance.renderPosition(canvas, position, size);
```

or use the `SvgComponent` and add it to the component tree:

```dart
class MyGame extends FlameGame {
  Future<void> onLoad() async {
    final svgInstance = await Svg.load('android.svg');
    final size = Vector2.all(100);
    final position = Vector2.all(100);
    final svgComponent = SvgComponent.fromSvg(
      size,
      position,
      svgInstance,
    );

    add(svgComponent);
  }
}
```
