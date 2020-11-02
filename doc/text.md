# Text Rendering

Flame has some dedicated classes to help you render text.

# TextConfig

A Text Config contains all typographical information required to render text; i.e., font size and color, family, etc.

Example usage:

```dart
const TextConfig config = TextConfig(fontSize: 48.0, fontFamily: 'Awesome Font');
```

* fontFamily : a commonly available font, like Arial (default), or a custom font added in your pubspec (see [here](https://flutter.io/custom-fonts/) how to do it)
* fontSize : font size, in pts (default `24.0`)
* lineHeight: height of text line, as a multiple of font size (default `null`)
* color : the color, as a `ui.Color` (default black)

For more information regarding colors and how to create then, see the [Colors and the Palette](/doc/palette.md) guide.

After the creation of the config you can use its `render` method to draw some string on a canvas:

```dart
config.render(canvas, "Flame is awesome", Position(10, 10));
```

If you want to set the anchor of the text you can also do that in the render call, with the optional parameter `anchor`:

```dart
config.render(canvas, "Flame is awesome", Position(10, 10), anchor: Anchor.topCenter);
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

`TextBoxComponent` is very similar to `TextComponent`, but as its name suggest it is used to render text inside a bounding box, creating line breaks according to the provided box size.

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

Both components are showcased in a working example [here](https://github.com/luanpotter/flame/tree/master/doc/examples/text)
