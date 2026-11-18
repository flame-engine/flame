import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

void main() {
  setUpGpu();

  group('depth', () {
    for (final nearFirst in [true, false]) {
      testGpuEngine(
        'keeps the nearest opaque surface in front when it is recorded '
        '${nearFirst ? 'first' : 'last'}',
        () async {
          final near = quad(
            opaqueUnlit(const Color(0xFF00FF00)),
            halfSize: 0.3,
          );
          final far = quad(opaqueUnlit(const Color(0xFFFF0000)), halfSize: 0.6);

          final frame = await renderFrame(
            draw: (context) {
              void drawNear() => context.drawSurface(
                near,
                transform: Matrix4.translationValues(0, 0, -4),
              );
              void drawFar() => context.drawSurface(
                far,
                transform: Matrix4.translationValues(0, 0, -6),
              );
              if (nearFirst) {
                drawNear();
                drawFar();
              } else {
                drawFar();
                drawNear();
              }
            },
          );

          final (cx, cy) = pixelAt(0, 0);
          expect(frame.pixels.at(cx, cy), (0, 255, 0, 255));
          final (ex, ey) = pixelAt(0.45, 0);
          expect(frame.pixels.at(ex, ey), (255, 0, 0, 255));
        },
      );
    }

    testGpuEngine('resolves intersecting surfaces per pixel', () async {
      // Two quads crossing each other: each is in front on one side.
      final red = quad(opaqueUnlit(const Color(0xFFFF0000)), halfSize: 0.8);
      final blue = quad(opaqueUnlit(const Color(0xFF0000FF)), halfSize: 0.8);

      final frame = await renderFrame(
        draw: (context) {
          context
            ..drawSurface(
              red,
              transform: Matrix4.translationValues(0, 0, -5)..rotateY(0.6),
            )
            ..drawSurface(
              blue,
              transform: Matrix4.translationValues(0, 0, -5)..rotateY(-0.6),
            );
        },
      );

      // Rotated by +0.6 around y, the red quad comes closer on the left.
      final (lx, ly) = pixelAt(-0.5, 0);
      final (rx, ry) = pixelAt(0.5, 0);
      expect(frame.pixels.at(lx, ly), (255, 0, 0, 255));
      expect(frame.pixels.at(rx, ry), (0, 0, 255, 255));
    });
  });

  group('translucent draws', () {
    testGpuEngine('are blended back to front whatever their order', () async {
      final near = quad(
        UnlitMaterial(albedoColor: const Color(0x80FF0000))
          ..renderState = RenderState.alphaBlend,
      );
      final far = quad(
        UnlitMaterial(albedoColor: const Color(0x800000FF))
          ..renderState = RenderState.alphaBlend,
      );

      final frame = await renderFrame(
        draw: (context) {
          context
            ..drawSurface(
              near,
              transform: Matrix4.translationValues(-0.2, 0, -4),
            )
            ..drawSurface(
              far,
              transform: Matrix4.translationValues(0.2, 0, -6),
            );
        },
      );

      // Far blue first: (0, 0, .5) alpha .5; then near red over it:
      // red * .5 + (0, 0, .5) * .5 = (.5, 0, .25), alpha .5 + .5 * .5 = .75.
      final (x, y) = pixelAt(0, 0);
      final (r, g, b, a) = frame.pixels.at(x, y);
      expect(r, closeTo(128, 2));
      expect(g, 0);
      expect(b, closeTo(64, 2));
      expect(a, closeTo(191, 2));
    });

    testGpuEngine('are drawn after the opaque ones', () async {
      final glass = quad(
        UnlitMaterial(albedoColor: const Color(0x80FFFFFF))
          ..renderState = RenderState.alphaBlend,
        halfSize: 0.3,
      );
      final wall = quad(opaqueUnlit(const Color(0xFF000080)), halfSize: 0.6);

      final frame = await renderFrame(
        draw: (context) {
          // The translucent glass is recorded first but must blend over the
          // opaque wall behind it.
          context
            ..drawSurface(glass, transform: Matrix4.translationValues(0, 0, -4))
            ..drawSurface(wall, transform: Matrix4.translationValues(0, 0, -6));
        },
      );

      final (x, y) = pixelAt(0, 0);
      final (r, g, b, a) = frame.pixels.at(x, y);
      // White * .5 + (0, 0, .5) * .5.
      expect(r, closeTo(128, 2));
      expect(g, closeTo(128, 2));
      expect(b, closeTo(192, 2));
      expect(a, 255);
    });

    testGpuEngine('are hidden behind nearer opaque surfaces', () async {
      final glass = quad(
        UnlitMaterial(albedoColor: const Color(0x80FFFFFF))
          ..renderState = RenderState.alphaBlend,
        halfSize: 0.6,
      );
      final wall = quad(opaqueUnlit(const Color(0xFF000080)), halfSize: 0.3);

      final frame = await renderFrame(
        draw: (context) {
          context
            ..drawSurface(glass, transform: Matrix4.translationValues(0, 0, -6))
            ..drawSurface(wall, transform: Matrix4.translationValues(0, 0, -4));
        },
      );

      final (x, y) = pixelAt(0, 0);
      expect(frame.pixels.at(x, y), (0, 0, 128, 255));
    });
  });
}
