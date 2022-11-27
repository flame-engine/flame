import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpriteFont', () {
    test('glyph parsing 1', () async {
      final spriteFont = SpriteFont(
        source: await generateImage(),
        size: 1,
        ascent: 1,
        glyphs: [
          Glyph('a', left: 1, top: 0),
          Glyph('b', left: 2, top: 0),
          Glyph('c', left: 3, top: 0),
          Glyph('d', left: 4, top: 0),
          Glyph('e', left: 5, top: 0),
          Glyph('f', left: 6, top: 0),
          Glyph('ff', left: 7, top: 0),
        ],
      );
      void check(String text, List<double> codes) {
        expect(spriteFont.textToGlyphs(text).map((g) => g.srcLeft), codes);
      }

      check('a', [1]);
      check('abcd', [1, 2, 3, 4]);
      check('effef', [5, 7, 5, 6]);
      check('fffff', [7, 7, 6]);
      check('feadafac', [6, 5, 1, 4, 1, 6, 1, 3]);
    });

    test('glyph parsing 2', () async {
      final spriteFont = SpriteFont(
        source: await generateImage(),
        size: 1,
        ascent: 1,
        glyphs: [
          Glyph('flame', left: 1, top: 0),
          Glyph('a', left: 2, top: 0),
          Glyph('m', left: 3, top: 0),
          Glyph('f', left: 4, top: 0),
          Glyph('lame', left: 5, top: 0),
          Glyph('am', left: 6, top: 0),
          Glyph('r', left: 7, top: 0),
          Glyph('s', left: 8, top: 0),
          Glyph('l', left: 9, top: 0),
        ],
      );
      void check(String text, List<double> codes) {
        expect(spriteFont.textToGlyphs(text).map((g) => g.srcLeft), codes);
      }

      check('a', [2]);
      check('flame', [1]);
      check('lame', [5]);
      check('flames', [1, 8]);
      check('flamers', [1, 7, 8]);
      check('salame', [8, 2, 5]);
      check('aflame', [2, 1]);
      check('flams', [4, 9, 6, 8]);

      expect(
        () => spriteFont.textToGlyphs('mom'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'No glyph data for character "o"',
          ),
        ),
      );
    });
  });
}
