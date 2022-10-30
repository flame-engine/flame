import 'dart:ui';

class PaletteEntry {
  final Color color;

  Paint paint() => Paint()..color = color;

  const PaletteEntry(this.color);

  PaletteEntry withAlpha(int alpha) {
    return PaletteEntry(color.withAlpha(alpha));
  }

  PaletteEntry withRed(int red) {
    return PaletteEntry(color.withRed(red));
  }

  PaletteEntry withGreen(int green) {
    return PaletteEntry(color.withGreen(green));
  }

  PaletteEntry withBlue(int blue) {
    return PaletteEntry(color.withBlue(blue));
  }
}

class BasicPalette {
  static const PaletteEntry transparent = PaletteEntry(Color(0x00FFFFFF));
  static const PaletteEntry white = PaletteEntry(Color(0xFFFFFFFF));
  static const PaletteEntry black = PaletteEntry(Color(0xFF000000));
  static const PaletteEntry red = PaletteEntry(Color(0xFFFF0000));
  static const PaletteEntry green = PaletteEntry(Color(0xFF00FF00));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF0000FF));
  static const PaletteEntry magenta = PaletteEntry(Color(0xFFFF00FF));
  static const PaletteEntry brown = PaletteEntry(Color(0xFFA52A2A));
  static const PaletteEntry cyan = PaletteEntry(Color(0xFF00FFFF));
  static const PaletteEntry darkBlue = PaletteEntry(Color(0xFF000080));
  static const PaletteEntry darkGray = PaletteEntry(Color(0xFFA9A9A9));
  static const PaletteEntry darkGreen = PaletteEntry(Color(0xFF006400));
  static const PaletteEntry darkPink = PaletteEntry(Color(0xFFFFC0CB));
  static const PaletteEntry darkRed = PaletteEntry(Color(0xFFB22222));
  static const PaletteEntry gray = PaletteEntry(Color(0xFF808080));
  static const PaletteEntry lime = PaletteEntry(Color(0xFF32CD32));
  static const PaletteEntry lightBlue = PaletteEntry(Color(0xFF00BFFF));
  static const PaletteEntry lightGreen = PaletteEntry(Color(0xFF7CFC00));
  static const PaletteEntry lightGray = PaletteEntry(Color(0xFFD3D3D3));
  static const PaletteEntry lightOrange = PaletteEntry(Color(0xFFFF8C00));
  static const PaletteEntry lightPink = PaletteEntry(Color(0xFFFFB6C1));
  static const PaletteEntry lightRed = PaletteEntry(Color(0xFFFFA07A));
  static const PaletteEntry orange = PaletteEntry(Color(0xFFFFA500));
  static const PaletteEntry pink = PaletteEntry(Color(0xFFFF69B4));
  static const PaletteEntry purple = PaletteEntry(Color(0xFF800080));
  static const PaletteEntry teal = PaletteEntry(Color(0xFF008080));
  static const PaletteEntry yellow = PaletteEntry(Color(0xFFFFFF00));
}
