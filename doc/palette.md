# Palette

Throughout your game you are going to need to use colors in lots of places. There are two classes on `dart:ui` that can be used, `Color` and `Paint`.

The `Color` class is nothing but a wrapper over a single simple ARGB color in hexadecimal integer format, so, to create a Color object, just pass in the color as an integer in the ARGB format.

You can use Dart's hexadecimal notation to make it really easy; for instance: `0xFF00FF00` is fully opaque green (the 'mask' would be `0xAARRGGBB`). Do note the first two hexadecimal digits are for the alpha channel (transparency), unlike on regular (non-A) RGB. The max(FF = 256) means fully opaque.

There is a color enum to make it easy to use common colors; it is in the material flutter package:

```dart
    import 'package:flutter/material.dart' as material;

    Color color = material.Colors.black;
```

Some more complex methods might also take a Paint, which is a more complete option that allows you to define more options related to stroke, colors, filters, blends. However, normally when using even the more complex APIs, you want just an instance of a Paint representing just a single simple plain solid color.

You can create such a Paint like so:

```dart
  Paint green = new Paint()..color = const Color(0xFF00FF00);
```

To help that and also keep your game's color palette consistent, Flame adds the Palette class. You can use it to both easily access Colors and Paints where needed and also to define as constants the colors your game use, so you don't get those mixed up.

The `BasicPalette` class is an example of what a palette can look like, and adds black and white as colors. So to use black or white you can access those directly from the BasicPalette; for example, using `color`:

```dart
  TextConfig regular = TextConfig(color: BasicPalette.white.color);
```

Or using `paint`:

```dart
  canvas.drawRect(rect, BasicPalette.black.paint);
```

However, the idea is that you can create your own palette, following the `BasicPalette` example, and add the color palette/scheme of your game. Then you will be able to statically access any color in your components and classes, never mix up the RGBs anymore. Below is an example of a Palette implementation, from the example game [BGUG](https://github.com/luanpotter/bgug/blob/master/lib/palette.dart):

```dart
import 'dart:ui';

import 'package:flame/palette.dart';

class Palette {
  static PaletteEntry white = BasicPalette.white;

  static PaletteEntry toastBackground = PaletteEntry(Color(0xFFAC3232));
  static PaletteEntry toastText = PaletteEntry(Color(0xFFDA9A00));

  static PaletteEntry grey = PaletteEntry(Color(0xFF404040));
  static PaletteEntry green = PaletteEntry(Color(0xFF54a286));
}
```

An `PaletteEntry` is a const class that can hold information of a color, and has two attributes:

 * `color`: returns the `Color` specified
 * `paint`: creates a new `Paint` with the color specified. `Paint` is a non-const class, so this attribute actually creates a brand new instance every time it's called. It's safe to cascade mutations to this.