import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show Color;

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

/// A square covering the whole default view (at z = -5), whose texture
/// coordinates run from 0 to [uScale] left to right and from 0 to [vScale] top
/// to bottom.
Surface _texturedQuad(
  Material material, {
  double uScale = 1,
  double vScale = 1,
  double halfSize = 1,
}) {
  final stride = VertexLayout.standard.strideInFloats;
  final vertices = Float32List(4 * stride);
  const corners = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
  for (final (i, (x, y)) in corners.indexed) {
    vertices
      ..setRange(i * stride, i * stride + 3, [x * halfSize, y * halfSize, -5])
      ..setRange(i * stride + 3, i * stride + 5, [
        (x + 1) / 2 * uScale,
        (1 - y) / 2 * vScale,
      ])
      ..setRange(i * stride + 5, i * stride + 9, [1, 1, 1, 1])
      ..setRange(i * stride + 9, i * stride + 12, [0, 0, 1]);
  }
  return Surface.fromBuffers(
    vertices: vertices,
    indices: Uint16List.fromList([0, 1, 2, 2, 3, 0]),
    material: material,
  );
}

/// A texture of [colors] in a row of `colors.length`x1 pixels (or a column,
/// when [vertical]).
Texture _strip(
  List<Color> colors, {
  TextureSampler sampler = TextureSampler.nearest,
  bool vertical = false,
}) {
  return Texture(
    ByteData.sublistView(
      Uint8List.fromList([
        for (final color in colors) ...[
          (color.r * 255).round(),
          (color.g * 255).round(),
          (color.b * 255).round(),
          (color.a * 255).round(),
        ],
      ]),
    ),
    width: vertical ? 1 : colors.length,
    height: vertical ? colors.length : 1,
    sampler: sampler,
  );
}

UnlitMaterial _textured(Texture texture) {
  return UnlitMaterial(albedoTexture: texture)
    ..renderState = RenderState.opaque;
}

const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _black = Color(0xFF000000);
const _white = Color(0xFFFFFFFF);

void main() {
  setUpGpu();

  group('texture sampling', () {
    testGpuEngine('nearest and linear magnification', () async {
      final texture = _strip([_black, _white]);
      final surface = _texturedQuad(_textured(texture));

      Future<int> redAt(double u) async {
        final frame = await renderFrame(
          draw: (context) => context.drawSurface(surface),
        );
        return frame.pixels.at((u * 64).floor(), 32).$1;
      }

      // The texel centers are at u = 0.25 and u = 0.75.
      expect(await redAt(0.375), 0);
      expect(await redAt(0.625), 255);

      texture.sampler = TextureSampler.linear;
      expect(await redAt(0.375), closeTo(64, 6));
      expect(await redAt(0.5), closeTo(128, 6));
      expect(await redAt(0.625), closeTo(191, 6));
    });

    for (final (wrap, expected) in [
      (TextureWrap.clamp, (_green, _green)),
      (TextureWrap.repeat, (_red, _green)),
      (TextureWrap.mirror, (_green, _red)),
    ]) {
      testGpuEngine('${wrap.name} wrapping', () async {
        final horizontal = _texturedQuad(
          _textured(
            _strip(
              [_red, _green],
              sampler: TextureSampler(wrapU: wrap),
            ),
          ),
          uScale: 2,
        );
        final vertical = _texturedQuad(
          _textured(
            _strip(
              [_red, _green],
              sampler: TextureSampler(wrapV: wrap),
              vertical: true,
            ),
          ),
          vScale: 2,
        );

        Future<(Color, Color)> colorsAlong(
          Surface surface, {
          required bool vertical,
        }) async {
          final frame = await renderFrame(
            draw: (context) => context.drawSurface(surface),
          );
          // Texture coordinates 1.25 and 1.75.
          Color at(int i) {
            final (r, g, b, a) = vertical
                ? frame.pixels.at(32, i)
                : frame.pixels.at(i, 32);
            return Color.fromARGB(a, r, g, b);
          }

          return (at(40), at(56));
        }

        expect(await colorsAlong(horizontal, vertical: false), expected);
        expect(await colorsAlong(vertical, vertical: true), expected);
      });
    }

    testGpuEngine('mipmaps average a texture drawn small', () async {
      // A 64x64 checkerboard of single black and white pixels.
      final pixels = Uint8List(64 * 64 * 4);
      for (var y = 0; y < 64; y++) {
        for (var x = 0; x < 64; x++) {
          final value = (x + y).isEven ? 255 : 0;
          pixels.setRange((y * 64 + x) * 4, (y * 64 + x) * 4 + 4, [
            value,
            value,
            value,
            255,
          ]);
        }
      }

      Future<List<int>> draw({required bool mipmaps}) async {
        final texture = Texture(
          ByteData.sublistView(pixels),
          width: 64,
          height: 64,
          mipmaps: mipmaps,
          sampler: mipmaps ? TextureSampler.linear : TextureSampler.nearest,
        );
        // Drawn on 8x8 pixels: one pixel covers 8x8 texels.
        final surface = _texturedQuad(_textured(texture), halfSize: 0.125);
        final frame = await renderFrame(
          draw: (context) => context.drawSurface(surface),
        );
        if (mipmaps) {
          expect(texture.mipLevelCount, greaterThan(3));
        }
        return [
          for (var y = 29; y < 35; y++)
            for (var x = 29; x < 35; x++) frame.pixels.at(x, y).$1,
        ];
      }

      // Without mipmaps, each pixel picks a single texel: black or white.
      expect(
        await draw(mipmaps: false),
        everyElement(anyOf(0, 255)),
      );
      // With them, each pixel averages its texels.
      expect(await draw(mipmaps: true), everyElement(closeTo(128, 8)));
    });

    testGpuEngine('image textures share the image without a copy', () async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawColor(const Color(0xFF3080F0), ui.BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(4, 4);
      picture.dispose();

      final texture = await ImageTexture.create(image);
      expect(texture.sourceData, isNull);

      final surface = _texturedQuad(_textured(texture));
      final frame = await renderFrame(
        draw: (context) => context.drawSurface(surface),
      );
      image.dispose();

      final (r, g, b, a) = frame.pixels.at(32, 32);
      expect([r, g, b, a], [0x30, 0x80, 0xF0, 255]);
    });

    testGpuEngine('image textures with mipmaps are uploaded', () async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawColor(const Color(0xFF20C040), ui.BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(16, 16);
      picture.dispose();

      final texture = await ImageTexture.create(
        image,
        mipmaps: true,
        sampler: TextureSampler.linear,
      );
      image.dispose();
      expect(texture.sourceData, isNotNull);

      final surface = _texturedQuad(_textured(texture), halfSize: 0.25);
      final frame = await renderFrame(
        draw: (context) => context.drawSurface(surface),
      );

      expect(texture.mipLevelCount, greaterThan(1));
      final (r, g, b, a) = frame.pixels.at(32, 32);
      expect([r, g, b, a], [0x20, 0xC0, 0x40, 255]);
    });
  });
}
