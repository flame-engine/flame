# Text Rendering

Flame has some dedicated classes to help you render text.

# TextConfig

A Text Config contains all typographical information required to render texts; i.e., font size and color, family, etc.

Example usage:

```dart
const TextConfig config = TextConfig(fontSize: 48.0, fontFamily: 'Awesome Font', anchor: Anchor.rightBottom);
```

* fontFamily : a commonly available font, like Arial (default), or a custom font added in your pubspec (see [here](https://flutter.io/custom-fonts/) how to do it)
* fontSize : font size, in pts (default `24.0`)
* color : the color, as a `ui.Color` (see below, default black)

To create a Color object, just pass in the color as an integer in the ARGB format.

You can use Dart's hexadecimal notation to make it really easy; for instance: `0xFF00FF00` is fully opaque green (the 'mask' would be `0xAARRGGBB`).

There is a color enum to make it easy to use common colors; it is in the material flutter package:

```dart
    import 'package:flutter/material.dart' as material;

    Color color = material.Colors.black;
```

After the creation of the config you can use its `render` method to draw some string on a canvas:

```dart
config.render(canvas, "Flame is awesome", Position(10, 10));

```

## Text Components

Flame provides two text components that make it even easier to render text in your game: `TextComponent` and `TextBoxComponent`.

### TextComponent

`TextComponent` is a simple component that renders a single line of text.

Example usage:

```dart
TextConfig regular = TextConfig(color: BasicPalette.white.color);

class MyGame extends BaseGame {
  MyGame() {
    _start();
  }

  _start() async {
    Size size = await Flame.util.initialDimensions();

    add(TextComponent('Hello, Flame', config: regular)
      ..anchor = Anchor.topCenter
      ..x = size.width / 2
      ..y = 32.0);
  }
}
```

### TextBoxComponent

`TextBoxComponent` is very similar to `TextComponent`, but as its name suggest, is used to render a text inside a bounding box, creating line breaks according to the provided box size.

Example usage:

```dart
class MyTextBox extends TextBoxComponent {
  MyTextBox(String text) : super(text, config: tiny, boxConfig: TextBoxConfig(timePerChar: 0.05));

  @override
  void drawBackground(Canvas c) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, new Paint()..color = Color(0xFFFF00FF));
    c.drawRect(
        rect.deflate(boxConfig.margin),
        new Paint()
          ..color = BasicPalette.black.color
          ..style = PaintingStyle.stroke);
  }
}
```

Both components are showcased on a working example [here](https://github.com/luanpotter/flame/tree/master/doc/examples/text)
