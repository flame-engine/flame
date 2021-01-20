import 'dart:ui';

class PaletteEntry {
  final Color color;

  Paint get paint => Paint()..color = color;

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
}
