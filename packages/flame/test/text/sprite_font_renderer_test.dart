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
