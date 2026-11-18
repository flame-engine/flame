import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

void main() {
  setUpGpu();

  group('per-material render state', () {
    Future<(int, int, int, int)> renderOne(
      Color color,
      RenderState state,
    ) async {
      final surface = quad(
        UnlitMaterial(albedoColor: color)..renderState = state,
      );
      final frame = await renderFrame(
        draw: (context) => context.drawSurface(
          surface,
          transform: Matrix4.translationValues(0, 0, -5),
        ),
      );
      final (x, y) = pixelAt(0, 0);
      return frame.pixels.at(x, y);
    }

    testGpuEngine('blends straight alpha', () async {
      final (r, g, b, a) = await renderOne(
        const Color(0x80CC0000),
        RenderState.alphaBlend,
      );
      // .8 * .5 over the transparent target.
      expect(r, closeTo(102, 2));
      expect((g, b), (0, 0));
      expect(a, closeTo(128, 1));
    });

    testGpuEngine('blends premultiplied alpha', () async {
      final (r, g, b, a) = await renderOne(
        const Color(0x80CC0000),
        RenderState.premultipliedAlphaBlend,
      );
      expect(r, closeTo(204, 1));
      expect((g, b), (0, 0));
      expect(a, closeTo(128, 1));
    });

    testGpuEngine('does not blend opaque draws', () async {
      final (r, g, b, a) = await renderOne(
        const Color(0x80CC0000),
        RenderState.opaque,
      );
      expect(r, closeTo(204, 1));
      expect((g, b), (0, 0));
      expect(a, closeTo(128, 1));
    });

    testGpuEngine('adds additive draws', () async {
      final red = quad(
        UnlitMaterial(albedoColor: const Color(0x80800000))
          ..renderState = RenderState.additive,
      );
      final green = quad(
        UnlitMaterial(albedoColor: const Color(0x80008000))
          ..renderState = RenderState.additive,
      );
      final frame = await renderFrame(
        draw: (context) => context
          ..drawSurface(red, transform: Matrix4.translationValues(0, 0, -4))
          ..drawSurface(green, transform: Matrix4.translationValues(0, 0, -6)),
      );
      final (x, y) = pixelAt(0, 0);
      final (r, g, b, a) = frame.pixels.at(x, y);
      expect(r, closeTo(128, 1));
      expect(g, closeTo(128, 1));
      expect(b, 0);
      // Added light covers nothing: the clear target stays transparent, so
      // the image adds its color to whatever it is drawn over.
      expect(a, 0);
    });

    testGpuEngine('keeps the alpha of what additive draws add to', () async {
      final glow = quad(
        UnlitMaterial(albedoColor: const Color(0xFF004000))
          ..renderState = RenderState.additive,
        halfSize: 0.3,
      );
      final half = quad(
        UnlitMaterial(albedoColor: const Color(0x80800000))
          ..renderState = RenderState.premultipliedAlphaBlend,
        halfSize: 0.3,
      );
      final frame = await renderFrame(
        draw: (context) => context
          // Over an opaque surface, over a half transparent one, over nothing.
          ..drawSurface(glow, transform: Matrix4.translationValues(-0.6, 0, -4))
          ..drawSurface(glow, transform: Matrix4.translationValues(0, 0, -4))
          ..drawSurface(glow, transform: Matrix4.translationValues(0.6, 0, -4))
          ..drawSurface(
            quad(opaqueUnlit(const Color(0xFF000080)), halfSize: 0.3),
            transform: Matrix4.translationValues(-0.6, 0, -6),
          )
          ..drawSurface(half, transform: Matrix4.translationValues(0, 0, -6)),
      );
      final (ox, oy) = pixelAt(-0.6, 0);
      final (hx, hy) = pixelAt(0, 0);
      final (nx, ny) = pixelAt(0.6, 0);
      final opaque = frame.pixels.at(ox, oy);
      expect(opaque.$2, closeTo(64, 1));
      expect(opaque.$3, closeTo(128, 1));
      expect(opaque.$4, 255);
      final translucent = frame.pixels.at(hx, hy);
      expect(translucent.$1, closeTo(128, 1));
      expect(translucent.$2, closeTo(64, 1));
      expect(translucent.$4, closeTo(128, 1));
      final alone = frame.pixels.at(nx, ny);
      expect(alone.$2, closeTo(64, 1));
      expect(alone.$4, 0);
    });

    testGpuEngine('writes no color with a depth-only draw', () async {
      final prepass = quad(
        UnlitMaterial()..renderState = RenderState.depthOnly,
        halfSize: 0.3,
      );
      final behind = quad(opaqueUnlit(const Color(0xFF0000FF)), halfSize: 0.6);
      final frame = await renderFrame(
        draw: (context) => context
          ..drawSurface(behind, transform: Matrix4.translationValues(0, 0, -6))
          ..drawSurface(prepass, transform: Matrix4.translationValues(0, 0, -4))
          ..drawSurface(
            prepass,
            transform: Matrix4.translationValues(0.7, 0, -4),
          ),
      );
      final (cx, cy) = pixelAt(0, 0);
      final (ex, ey) = pixelAt(0.75, 0);
      // What is behind the depth-only quads keeps its color, and so does
      // the cleared target.
      expect(frame.pixels.at(cx, cy), (0, 0, 255, 255));
      expect(frame.pixels.isClear(ex, ey), isTrue);
      expect(RenderState.depthOnly.translucent, isTrue);
      expect(RenderState.depthOnly.depthWrite, isTrue);
    });

    testGpuEngine('fades an object as one piece after a prepass', () async {
      // Two overlapping quads of one surface: a near red one, a far blue one.
      Surface pair(Material material) {
        const stride = 20;
        final vertices = Float32List(8 * stride);
        const corners = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
        for (final (q, (dx, z, color)) in [
          (0.0, -4.0, [1.0, 0.0, 0.0, 1.0]),
          (0.3, -6.0, [0.0, 0.0, 1.0, 1.0]),
        ].indexed) {
          for (final (i, (x, y)) in corners.indexed) {
            final o = (q * 4 + i) * stride;
            vertices
              ..setRange(o, o + 3, [dx + x * 0.4, y * 0.4, z])
              ..setRange(o + 5, o + 9, color)
              ..setRange(o + 9, o + 12, [0, 0, 1]);
          }
        }
        return Surface.fromBuffers(
          vertices: vertices,
          indices: Uint16List.fromList([
            0, 1, 2, 2, 3, 0, 4, 5, 6, 6, 7, 4, //
          ]),
          material: material,
        );
      }

      final faded = UnlitMaterial(albedoColor: const Color(0x80FFFFFF))
        ..renderState = RenderState.premultipliedAlphaBlend.copyWith(
          depthCompare: CompareFunction.lessEqual,
        );
      final prepass = UnlitMaterial()..renderState = RenderState.depthOnly;
      final surface = pair(faded);

      Future<(int, int, int, int)> overlap({required bool withPrepass}) async {
        final frame = await renderFrame(
          draw: (context) {
            if (withPrepass) {
              context.drawSurface(surface, material: prepass);
            }
            context.drawSurface(surface);
          },
        );
        final (x, y) = pixelAt(0.2, 0);
        return frame.pixels.at(x, y);
      }

      // Without a prepass, the far blue quad shows through the near red one.
      final seeThrough = await overlap(withPrepass: false);
      expect(seeThrough.$3, greaterThan(30));
      // With one, only the red quad blends, at half opacity (the unlit
      // material's colors are not premultiplied).
      final (r, g, b, a) = await overlap(withPrepass: true);
      expect(r, 255);
      expect((g, b), (0, 0));
      expect(a, closeTo(128, 1));
    });

    testGpuEngine('applies a different state to each draw of a pass', () async {
      final opaque = quad(opaqueUnlit(const Color(0xFF0000FF)), halfSize: 0.2);
      final alpha = quad(
        UnlitMaterial(albedoColor: const Color(0x80FF0000))
          ..renderState = RenderState.alphaBlend,
        halfSize: 0.2,
      );
      final additive = quad(
        UnlitMaterial(albedoColor: const Color(0x8000FF00))
          ..renderState = RenderState.additive,
        halfSize: 0.2,
      );
      final frame = await renderFrame(
        draw: (context) => context
          ..drawSurface(alpha, transform: Matrix4.translationValues(0, 0.5, -5))
          ..drawSurface(
            additive,
            transform: Matrix4.translationValues(0.5, -0.5, -5),
          )
          ..drawSurface(
            opaque,
            transform: Matrix4.translationValues(-0.5, -0.5, -5),
          ),
      );
      final (ax, ay) = pixelAt(0, 0.5);
      final (dx, dy) = pixelAt(0.5, -0.5);
      final (ox, oy) = pixelAt(-0.5, -0.5);
      expect(frame.pixels.at(ax, ay).$1, closeTo(128, 1));
      expect(frame.pixels.at(dx, dy).$2, 255);
      expect(frame.pixels.at(ox, oy), (0, 0, 255, 255));
    });

    testGpuEngine('draws over nearer surfaces without depth test', () async {
      final wall = quad(opaqueUnlit(const Color(0xFF0000FF)), halfSize: 0.6);
      final overlay = quad(
        UnlitMaterial(albedoColor: const Color(0xFFFF0000))
          ..renderState = const RenderState(
            depthTest: false,
            translucent: true,
          ),
        halfSize: 0.3,
      );
      final hidden = quad(
        UnlitMaterial(albedoColor: const Color(0xFF00FF00))
          ..renderState = const RenderState(translucent: true),
        halfSize: 0.3,
      );
      final frame = await renderFrame(
        draw: (context) => context
          ..drawSurface(wall, transform: Matrix4.translationValues(0, 0, -4))
          ..drawSurface(
            overlay,
            transform: Matrix4.translationValues(-0.3, 0, -6),
          )
          ..drawSurface(
            hidden,
            transform: Matrix4.translationValues(0.3, 0, -6),
          ),
      );
      final (lx, ly) = pixelAt(-0.3, 0);
      final (rx, ry) = pixelAt(0.3, 0);
      expect(frame.pixels.at(lx, ly), (255, 0, 0, 255));
      expect(frame.pixels.at(rx, ry), (0, 0, 255, 255));
    });

    testGpuEngine(
      'lets farther surfaces through without depth writes',
      () async {
        // Both opaque; the near one is drawn first (lower material id) but does
        // not write depth, so the far one covers it.
        final near = quad(
          UnlitMaterial(albedoColor: const Color(0xFFFF0000))
            ..renderState = const RenderState(depthWrite: false),
          halfSize: 0.3,
        );
        final far = quad(opaqueUnlit(const Color(0xFF0000FF)), halfSize: 0.6);
        final frame = await renderFrame(
          draw: (context) => context
            ..drawSurface(near, transform: Matrix4.translationValues(0, 0, -4))
            ..drawSurface(far, transform: Matrix4.translationValues(0, 0, -6)),
        );
        final (x, y) = pixelAt(0, 0);
        expect(frame.pixels.at(x, y), (0, 0, 255, 255));
      },
    );

    testGpuEngine('passes the depth test with the material compare', () async {
      final far = quad(opaqueUnlit(const Color(0xFF0000FF)), halfSize: 0.6);
      final near = quad(opaqueUnlit(const Color(0xFFFF0000)), halfSize: 0.3);
      // Drawn last, behind the others, but its compare passes when farther.
      final behind = quad(
        UnlitMaterial(albedoColor: const Color(0xFF00FF00))
          ..renderState = const RenderState(
            depthCompare: CompareFunction.greaterEqual,
            depthWrite: false,
            translucent: true,
          ),
        halfSize: 0.9,
      );
      final frame = await renderFrame(
        draw: (context) => context
          ..drawSurface(far, transform: Matrix4.translationValues(0, 0, -6))
          ..drawSurface(near, transform: Matrix4.translationValues(0, 0, -4))
          ..drawSurface(behind, transform: Matrix4.translationValues(0, 0, -8)),
      );
      final (cx, cy) = pixelAt(0, 0);
      final (ex, ey) = pixelAt(0.75, 0);
      // Where something nearer was drawn, the farther quad passes.
      expect(frame.pixels.at(cx, cy), (0, 255, 0, 255));
      // Where only the cleared depth (the far plane) is, it fails.
      expect(frame.pixels.isClear(ex, ey), isTrue);
    });

    for (final (cullMode, visible) in [
      (CullMode.none, true),
      (CullMode.backFace, true),
      (CullMode.frontFace, false),
    ]) {
      testGpuEngine(
        '${visible ? 'keeps' : 'culls'} a front face with ${cullMode.name}',
        () async {
          final (_, _, _, a) = await renderOne(
            const Color(0xFFFFFFFF),
            RenderState(cullMode: cullMode),
          );
          expect(a, visible ? 255 : 0);
        },
      );
    }
  });
}
