# Text Rendering

Flame has some dedicated classes to help you render text.

## TextRenderer

`TextRenderer` is the abstract class used by Flame to render text. Flame provides one
implementation for this called `TextPaint` but anyone can implement this abstraction
and create a custom way to render text.

## TextPaint

A Text Paint is the built in implementation of text rendering on Flame, it is based on top of
Flutter's `TextPainter` class (hence the name), it can be configured by its config class
`TextPaintConfig` which contains all typographical information required to render text; i.e., font
size and color, family, etc.

Example usage:

```dart
const TextPaint textPaint = TextPaint(
  config: TextPaintConfig(
    fontSize: 48.0,
    fontFamily: 'Awesome Font',
  ),
);
```

 - `fontFamily`: a commonly available font, like Arial (default), or a custom font added in your
 pubspec (see [here](https://flutter.io/custom-fonts/) how to do it).
 - `fontSize`: font size, in pts (default `24.0`).
 - `lineHeight`: height of text line, as a multiple of font size (default `null`).
 - `color`: the color, as a `ui.Color` (default black).

For more information regarding colors and how to create then, see the
[Colors and the Palette](palette.md) guide.

After the creation of the text paint you can use its `render` method to draw some string on a canvas:

```dart
textPaint.render(canvas, "Flame is awesome", Vector2(10, 10));
```

If you want to set the anchor of the text you can also do that in the render call, with the optional
`anchor` parameter:

```dart
textPaint.render(canvas, 'Flame is awesome', Vector2(10, 10), anchor: Anchor.topCenter);
```

## Text Components

Flame provides two text components that make it even easier to render text in your game:
`TextComponent` and `TextBoxComponent`.

### TextComponent

`TextComponent` is a simple component that renders a single line of text.

Example usage:

```dart
TextPaint regular = TextPaint(color: BasicPalette.white.color);

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    add(TextComponent('Hello, Flame', textRenderer: regular)
      ..anchor = Anchor.topCenter
      ..x = size.width / 2 // size is a property from game
      ..y = 32.0);
  }
}
```

### TextBoxComponent

`TextBoxComponent` is very similar to `TextComponent`, but as its name suggest it is used to render
text inside a bounding box, creating line breaks according to the provided box size.

You can decide if the box should grow as the text is written or if it should be static by the
`growingBox` variable in the `TextBoxConfig`.

If you want to change the margins of the box use the `margins` variable in the `TextBoxConfig`.

Example usage:

```dart
class MyTextBox extends TextBoxComponent {
  MyTextBox(String text) : super(text, textRenderer: tiny, boxConfig: TextBoxConfig(timePerChar: 0.05));

  @override
  void drawBackground(Canvas c) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = Color(0xFFFF00FF));
    c.drawRect(
        rect.deflate(boxConfig.margin),
        Paint()
          ..color = BasicPalette.black.color
          ..style = PaintingStyle.stroke);
  }
}
```

Both components are showcased in an example
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/rendering/text.dart)
