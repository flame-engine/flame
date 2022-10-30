import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import '../_resources/load_image.dart';

void main() {
  group('SpriteFontRenderer', () {
    test('creating SpriteFontRenderer', () async {
      final renderer = await createRenderer();
      expect(renderer.formatter.font.source, isA<Image>());
      expect(renderer.formatter.font.size, 6);
      expect(renderer.formatter.scale, 1.0);
      expect(renderer.formatter.letterSpacing, 0);

      expect(
        () => renderer.render(MockCanvas(), 'Ї', Vector2.zero()),
        throwsA(
          isArgumentError.having(
            (e) => e.message,
            'message',
            'No glyph data for character "Ї"',
          ),
        ),
      );
    });

    for (final p in [false, true]) {
      testGolden(
        'text rendering at different scales [legacy=$p]',
        (game) async {
          game.addAll([
            RectangleComponent(size: Vector2(800, 600)),
            TextBoxComponent(
              text: textSample,
              textRenderer: await createRenderer(letterSpacing: 1, legacy: p),
              boxConfig: TextBoxConfig(maxWidth: 800),
            ),
            TextBoxComponent(
              text: textSample,
              textRenderer: await createRenderer(scale: 2, legacy: p),
              boxConfig: TextBoxConfig(maxWidth: 800),
              position: Vector2(0, 100),
            ),
            TextComponent(
              text: 'FLAME',
              textRenderer: (await createRenderer(scale: 25, legacy: p))
                ..formatter.paint.color = const Color(0x44000000),
              position: Vector2(400, 500),
              anchor: Anchor.center,
            ),
          ]);
        },
        goldenFile: '../_goldens/sprite_font_renderer_1.png',
      );
    }

    testGolden(
      'Render text with ligatures',
      (game) async {
        final font = SpriteFont(
          source: await loadImage('sprite_font.png'),
          size: 18,
          ascent: 14,
          glyphs: [
            Glyph('a', left: 5, top: 1, width: 10),
            Glyph('b', left: 26, top: 1, width: 9),
            Glyph('c', left: 46, top: 1, width: 9),
            Glyph('d', left: 66, top: 1, width: 9),
            Glyph('e', left: 86, top: 1, width: 9),
            Glyph('f', left: 51, top: 21, width: 6),
            Glyph('ff', left: 66, top: 21, width: 10),
            Glyph('g', left: 86, top: 21, width: 9),
            Glyph('Flame', left: 3, top: 21, width: 41),
            Glyph(
              ' ',
              left: 0,
              top: 0,
              width: 9,
              srcTop: 0,
              srcBottom: 0,
              srcLeft: 0,
              srcRight: 0,
            ),
          ],
        );
        game.addAll([
          RectangleComponent(
            size: Vector2(200, 200),
            paint: Paint()..color = const Color(0xffd1dae1),
          ),
          TextComponent(
            text: 'facade',
            textRenderer: SpriteFontRenderer.fromFont(font),
            position: Vector2(10, 10),
          ),
          TextComponent(
            text: 'caffefe',
            textRenderer: SpriteFontRenderer.fromFont(font, scale: 2),
            position: Vector2(10, 30),
          ),
          TextComponent(
            text: 'Flame bag',
            textRenderer: SpriteFontRenderer.fromFont(font, scale: 2),
            position: Vector2(10, 70),
          ),
          TextComponent(
            text: 'faded cabbage gaffe',
            textRenderer: SpriteFontRenderer.fromFont(font, letterSpacing: 1),
            position: Vector2(10, 110),
          ),
        ]);
      },
      goldenFile: '../_goldens/sprite_font_renderer_2.png',
      size: Vector2(200, 140),
    );

    testGolden(
      'Render text with large src rectangles',
      (game) async {
        final font = SpriteFont(
          source: await loadImage('sprite_font.png'),
          size: 18,
          ascent: 14,
          glyphs: [
            Glyph(
              'a',
              left: 5,
              top: 1,
              width: 10,
              srcLeft: 0,
              srcTop: 0,
              srcRight: 20,
              srcBottom: 20,
            ),
            Glyph(
              'b',
              left: 26,
              top: 1,
              width: 9,
              srcLeft: 20,
              srcTop: 0,
              srcBottom: 20,
              srcRight: 40,
            ),
            Glyph(
              'c',
              left: 46,
              top: 1,
              width: 9,
              srcLeft: 40,
              srcTop: 0,
              srcBottom: 20,
              srcRight: 60,
            ),
            Glyph(
              'd',
              left: 66,
              top: 1,
              width: 9,
              srcLeft: 60,
              srcTop: 0,
              srcBottom: 20,
              srcRight: 80,
            ),
            Glyph(
              'e',
              left: 86,
              top: 1,
              width: 9,
              srcLeft: 80,
              srcTop: 0,
              srcBottom: 20,
              srcRight: 100,
            ),
            Glyph(
              'f',
              left: 51,
              top: 21,
              width: 6,
              srcLeft: 46,
              srcTop: 20,
              srcBottom: 40,
              srcRight: 61,
            ),
            Glyph(
              'g',
              left: 86,
              top: 21,
              width: 9,
              srcLeft: 80,
              srcTop: 20,
              srcBottom: 40,
              srcRight: 100,
            ),
          ],
        );
        game.addAll([
          RectangleComponent(
            size: Vector2(200, 200),
            paint: Paint()..color = const Color(0xffd8e1c4),
          ),
          TextComponent(
            text: 'badface',
            textRenderer: SpriteFontRenderer.fromFont(font),
            position: Vector2(10, 10),
          ),
          TextComponent(
            text: 'badface',
            textRenderer: SpriteFontRenderer.fromFont(font, letterSpacing: 11),
            position: Vector2(10, 40),
          ),
        ]);
      },
      goldenFile: '../_goldens/sprite_font_renderer_3.png',
      size: Vector2(200, 70),
    );

    testGolden(
      'Render colored text',
      (game) async {
        const lines = [
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz',
        ];
        final font = SpriteFont(
          source: await loadImage('alphabet.png'),
          size: 6,
          ascent: 6,
          glyphs: [
            for (var j = 0; j < lines.length; j++)
              for (var i = 0; i < lines[j].length; i++)
                Glyph(lines[j][i], left: i * 6, top: 1 + j * 6)
          ],
        );
        const colors = [
          Color(0xffff0000),
          Color(0x66ff0000),
          Color(0x33ff0000),
          Color(0x11ff0000),
          Color(0xffffffff),
          Color(0xff8c27c9),
        ];
        game.addAll([
          RectangleComponent(
            size: Vector2(200, 200),
            paint: Paint()..color = const Color(0xffcfc6e5),
          ),
          for (var i = 0; i < colors.length; i++)
            TextComponent(
              text: 'pandemonium',
              textRenderer: SpriteFontRenderer.fromFont(
                font,
                scale: 2,
                color: colors[i],
              ),
              position: Vector2(10, 10 + i * 20),
            ),
        ]);
      },
      goldenFile: '../_goldens/sprite_font_renderer_4.png',
      size: Vector2(200, 130),
    );
  });
}

const textSample = 'We hold these truths to be self-evident, that all men are '
    'created equal, that they are endowed by their Creator with certain '
    'unalienable Rights, that among these are Life, Liberty and the pursuit of '
    'Happiness. — That to secure these rights, Governments are instituted '
    'among Men, deriving their just powers from the consent of the governed, '
    '— That whenever any Form of Government becomes destructive of these ends, '
    'it is the Right of the People to alter or to abolish it, and to institute '
    'new Government, laying its foundation on such principles and organizing '
    'its powers in such form, as to them shall seem most likely to effect '
    'their Safety and Happiness. Prudence, indeed, will dictate that '
    'Governments long established should not be changed for light and '
    'transient causes; and accordingly all experience hath shewn, that mankind '
    'are more disposed to suffer, while evils are sufferable, than to right '
    'themselves by abolishing the forms to which they are accustomed. But when '
    'a long train of abuses and usurpations, pursuing invariably the same '
    'Object evinces a design to reduce them under absolute Despotism, it is '
    'their right, it is their duty, to throw off such Government, and to '
    'provide new Guards for their future security.';

Future<SpriteFontRenderer> createRenderer({
  double scale = 1,
  double letterSpacing = 0,
  bool legacy = false,
}) async {
  const lines = [
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'abcdefghijklmnopqrstuvwxyz',
    r'0123456789.,:;—_!?@$%+-=/*',
    '#^&()[]{}<>|\\\'"`~←→↑↓ ',
  ];
  if (legacy) {
    // ignore: deprecated_member_use_from_same_package
    return SpriteFontRenderer(
      source: await loadImage('alphabet.png'),
      charHeight: 6,
      charWidth: 6,
      scale: scale,
      glyphs: {
        for (var j = 0; j < lines.length; j++)
          for (var i = 0; i < lines[j].length; i++)
            // ignore: deprecated_member_use_from_same_package
            lines[j][i]: GlyphData(left: i * 6, top: 1 + j * 6)
      },
      letterSpacing: letterSpacing,
    );
  } else {
    return SpriteFontRenderer.fromFont(
      SpriteFont(
        source: await loadImage('alphabet.png'),
        size: 6,
        ascent: 6,
        glyphs: [
          for (var j = 0; j < lines.length; j++)
            for (var i = 0; i < lines[j].length; i++)
              Glyph(lines[j][i], left: i * 6, top: 1 + j * 6)
        ],
      ),
      scale: scale,
      letterSpacing: letterSpacing,
    );
  }
}
