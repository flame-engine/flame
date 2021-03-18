import 'package:flame/palette.dart';
import 'package:test/test.dart';

void main() {
  group('Palette', () {
    test('memoizes the paint created', () {
      final paint = BasicPalette.white.paint;
      final paint2 = BasicPalette.white.paint;
      expect(paint, paint2);
    });
  });
}
