# Palette

Throughout your game you are going to need to use colors in lots of places. There are two classes on
`dart:ui` that can be used, `Color` and `Paint`.

The `Color` class represents a ARGB color in a hexadecimal integer
format. So to create a `Color` instance you just need to pass the color as an integer in the ARGB
format.

You can use Dart's hexadecimal notation to make it really easy; for instance: `0xFF00FF00` is fully
opaque green (the 'mask' would be `0xAARRGGBB`). 

**Note**: The first two hexadecimal digits are for
the alpha channel (transparency), unlike on regular (non-A) RGB. The max(FF = 255) for the two first
digits means fully opaque, and the min (00 = 0) means fully transparent.

In the material flutter package there is a `Colors` class that provides common colors as constants:

```dart
import 'package:flutter/material.dart';

const black = Colors.black;
```

Some more complex methods might also take a `Paint` object, which is a more complete option that
allows you to define more options related to stroke, colors, filters and blends.
However, normally when using even the more complex APIs, you just want an instance of a `Paint`
object representing just a single simple plain solid color.

You can create such an object like this:

```dart
Paint green = Paint()..color = const Color(0xFF00FF00);
```

To help you with this and to also keep your game's color palette consistent, Flame adds the `Palette`
class. You can use it to easily access both `Color`s and `Paint`s where needed and also to define
the colors your game use as constants, so you don't get those mixed up.

The `BasicPalette` class is an example of what a palette can look like, and adds black and white as
colors. So to use black or white you can access those directly from the BasicPalette; for example,
using `color`:

```dart
TextConfig regular = TextConfig(color: BasicPalette.white.color);
```

Or using `paint`:

```dart
canvas.drawRect(rect, BasicPalette.black.paint);
```

However, the idea is that you can create your own palette, following the `BasicPalette` example, and
add the color palette/scheme of your game. Then you will be able to statically access any color in
your components and classes. Below is an example of a `Palette` implementation, from the example
game [BGUG](https://github.com/fireslime/bgug/blob/master/lib/palette.dart):

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

A `PaletteEntry` is a const class that can hold information of a color, with the following members:

 - `color`: returns the `Color` specified
 - `paint`: creates a new `Paint` with the color specified. `Paint` is a non-const class, so this
  attribute actually creates a brand new instance every time it's called. It's safe to cascade
  mutations to this.
