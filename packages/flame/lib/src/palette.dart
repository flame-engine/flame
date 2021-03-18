import 'dart:ui';

class _MemoizedPaint {
  final Color color;
  Paint? _paint;

  _MemoizedPaint(this.color);

  Paint get value {
    _paint ??= Paint()..color;
    return _paint!;
  }
}

class PaletteEntry {
  final Color color;
  late _MemoizedPaint _paint;

  Paint get paint => _paint.value;

  PaletteEntry(this.color) {
    _paint = _MemoizedPaint(color);
  }

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
  static PaletteEntry white = PaletteEntry(Color(0xFFFFFFFF));
  static PaletteEntry black = PaletteEntry(Color(0xFF000000));
}
