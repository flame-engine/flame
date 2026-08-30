import 'package:flame/palette.dart';
import 'package:test/test.dart';

void main() {
  group('Palette', () {
    test('updates color', () {
      const entry = BasicPalette.red;
      expect(entry.color, const Color(0xFFFF0000));
      expect(entry.withAlpha(100).color, const Color(0x64FF0000));
      expect(entry.withRed(100).color, const Color(0xFF640000));
      expect(entry.withGreen(100).color, const Color(0xFFFF6400));
      expect(entry.withBlue(100).color, const Color(0xFFFF0064));
    });

    test('darkens and brightens color', () {
      const entry = BasicPalette.red;
      expect(entry.color, const Color(0xFFFF0000));
      expect(entry.darken(0.5).color, const Color(0xFF800000));
      expect(entry.brighten(0.5).color, const Color(0xFFFF8080));
    });
  });
}
