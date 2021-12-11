# Text Rendering

Flame has some dedicated classes to help you render text.

## TextRenderer

`TextRenderer` is the abstract class used by Flame to render text. Flame provides one
implementation for this called `TextPaint` but anyone can implement this abstraction
and create a custom way to render text.

## TextPaint

A `TextPaint` is the built in implementation of text rendering in Flame, it is based on top of
Flutter's `TextPainter` class (hence the name), it can be configured by the style class `TextStyle`
which contains all typographical information required to render text; i.e., font size and color,
font family, etc.

Example usage:

```dart
const TextPaint textPaint = TextPaint(
  style: TextStyle(
    fontSize: 48.0,
    fontFamily: 'Awesome Font',
  ),
);
```

Note: there are several packages that contain the class `TextStyle`, make sure that you import
either `package:flutter/material.dart` or `package:flutter/painting.dart` and if you also need to
import `dart:ui` you need to import it like this (since that contains another class that is also
named `TextStyle`):

```dart
import 'dart:ui' hide TextStyle;
```

Some common properties of `TextStyle` are the following (here is the
[full list](https://api.flutter.dev/flutter/painting/TextStyle-class.html)):

 - `fontFamily`: a commonly available font, like Arial (default), or a custom font added in your
 pubspec (see [here](https://flutter.io/custom-fonts/) how to do it).
 - `fontSize`: font size, in pts (default `24.0`).
 - `height`: height of text line, as a multiple of font size (default `null`).
 - `color`: the color, as a `ui.Color` (default white).

For more information regarding colors and how to create then, see the
[Colors and the Palette](palette.md) guide.

After the creation of the `TextPaint` object you can use its `render` method to draw strings on
a canvas:

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
final style = TextStyle(color: BasicPalette.white.color);
final regular = TextPaint(style: style);

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    add(TextComponent(text: 'Hello, Flame', textRenderer: regular)
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
  MyTextBox(String text) : super(text: text, textRenderer: tiny, boxConfig: TextBoxConfig(timePerChar: 0.05));

  @override
  void drawBackground(Canvas c) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = Color(0xFFFF00FF));
    c.drawRect(
        rect.deflate(boxConfig.margin),
        BasicPalette.black.Paint()
          ..style = PaintingStyle.stroke,
    );
  }
}
```

Both components are showcased in an example
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/rendering/text.dart)
