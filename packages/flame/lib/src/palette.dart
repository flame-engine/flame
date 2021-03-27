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
  static const PaletteEntry white = PaletteEntry(Color(0xFFFFFFFF));
  static const PaletteEntry black = PaletteEntry(Color(0xFF000000));
  static const PaletteEntry red = PaletteEntry(Color(0xFFFF0000));
  static const PaletteEntry green = PaletteEntry(Color(0xFF00FF00));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF0000FF));
  static const PaletteEntry magenta = PaletteEntry(Color(0xFFFF00FF));
}
