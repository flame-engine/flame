import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

/// Draws the vertex color times the instance color, from a surface that may
/// only have positions and colors.
class _VertexColorMaterial() extends Material {
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          'test/vertex_color.shaderbundle',
          slots: [RenderContext3D.cameraMatricesBlock],
        ),
        fragmentShader: FragmentShader.fromAsset(
          'test/vertex_color.shaderbundle',
        ),
      );
}

/// A material whose shader reads its model matrix from a uniform block, set
/// for every draw.
class _UniformModelMaterial() extends Material {
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          'test/uniform_model.shaderbundle',
          slots: ['VertexInfo'],
        ),
        fragmentShader: FragmentShader.fromAsset(
          'test/uniform_model.shaderbundle',
        ),
      );

  int applied = 0;

  @override
  void apply(RenderContext context) {
    final renderContext = context as RenderContext3D;
    applied++;
    vertexShader
      ..setMatrix4('VertexInfo.model', renderContext.model)
      ..setMatrix4('VertexInfo.view', renderContext.view)
      ..setMatrix4('VertexInfo.projection', renderContext.projection);
  }
}

final _positionAndColor = VertexLayout(const [
  VertexAttribute('vertexPosition', 3),
  VertexAttribute('vertexColor', 4),
]);

/// A square of side `2 * halfSize` facing +z, with a red, green, blue and
/// white corner (bottom left, bottom right, top right, top left).
Surface _colorQuad(Material material, {double halfSize = 1}) {
  final h = halfSize;
  return Surface.fromBuffers(
    vertices: Float32List.fromList([
      -h, -h, 0, 1, 0, 0, 1, //
      h, -h, 0, 0, 1, 0, 1, //
      h, h, 0, 0, 0, 1, 1, //
      -h, h, 0, 1, 1, 1, 1, //
    ]),
    indices: Uint16List.fromList([0, 1, 2, 2, 3, 0]),
    layout: _positionAndColor,
    material: material,
  );
}

void main() {
  setUpGpu();

  setUpAll(() async {
    if (gpuAvailable) {
      await registerTestShaders(['vertex_color', 'uniform_model']);
    }
  });

  group('custom vertex layouts', () {
    testGpuEngine('draw a surface with its own attributes', () async {
      final surface = _colorQuad(_VertexColorMaterial());

      final frame = await renderFrame(
        draw: (context) => context.drawSurface(
          surface,
          transform: Matrix4.translationValues(0, 0, -5),
        ),
      );

      void expectNear((int, int, int, int) pixel, (int, int, int) color) {
        expect(pixel.$1, closeTo(color.$1, 12));
        expect(pixel.$2, closeTo(color.$2, 12));
        expect(pixel.$3, closeTo(color.$3, 12));
        expect(pixel.$4, 255);
      }

      expectNear(frame.pixels.at(0, 63), (255, 0, 0));
      expectNear(frame.pixels.at(63, 63), (0, 255, 0));
      expectNear(frame.pixels.at(63, 0), (0, 0, 255));
      expectNear(frame.pixels.at(0, 0), (255, 255, 255));
    });

    testGpuEngine('batch instances with per-instance colors', () async {
      final surface = _colorQuad(_VertexColorMaterial(), halfSize: 0.2);
      const tints = [Color(0xFFFF0000), Color(0xFF00FF00), Color(0xFF0000FF)];

      final frame = await renderFrame(
        draw: (context) {
          for (final (i, tint) in tints.indexed) {
            context.drawSurface(
              surface,
              transform: Matrix4.translationValues(-0.6 + i * 0.6, 0, -5),
              color: tint,
            );
          }
        },
      );

      expect(frame.stats.drawCalls, 1);
      expect(frame.stats.instances, 3);
      // At the top left corner of each quad the vertex color is white, so
      // the instance color shows.
      for (final (i, tint) in tints.indexed) {
        final (x, y) = pixelAt(-0.6 + i * 0.6 - 0.17, 0.17);
        final (r, g, b, _) = frame.pixels.at(x, y);
        expect(r, closeTo(tint.r * 230, 30));
        expect(g, closeTo(tint.g * 230, 30));
        expect(b, closeTo(tint.b * 230, 30));
      }
    });

    testGpuEngine('get a pipeline per layout of the same material', () async {
      final material = _VertexColorMaterial();
      // The standard layout provides the position and color too.
      final standard = quad(material, halfSize: 0.3);
      final custom = _colorQuad(material, halfSize: 0.3);

      final frame = await renderFrame(
        draw: (context) => context
          ..drawSurface(
            standard,
            transform: Matrix4.translationValues(-0.5, 0, -5),
          )
          ..drawSurface(
            custom,
            transform: Matrix4.translationValues(0.5, 0, -5),
          ),
      );

      expect(frame.stats.pipelineChanges, 2);
      expect(frame.stats.drawCalls, 2);
      final (lx, ly) = pixelAt(-0.5, 0);
      final (rx, ry) = pixelAt(0.5, 0);
      // The standard quad's vertex colors are white.
      expect(frame.pixels.at(lx, ly), (255, 255, 255, 255));
      expect(frame.pixels.isClear(rx, ry), isFalse);
    });

    testGpuEngine('reject surfaces missing a shader input', () async {
      final surface = Surface.fromBuffers(
        vertices: Float32List(9),
        indices: Uint16List.fromList([0, 1, 2]),
        layout: VertexLayout(const [VertexAttribute('vertexPosition', 3)]),
        material: _VertexColorMaterial(),
      );

      await expectLater(
        renderFrame(draw: (context) => context.drawSurface(surface)),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('vertexColor'),
          ),
        ),
      );
    });
  });

  group('materials without instance inputs', () {
    testGpuEngine('draw each object with its own model matrix', () async {
      final material = _UniformModelMaterial();
      final surface = _colorQuad(material, halfSize: 0.2);

      final frame = await renderFrame(
        draw: (context) {
          for (var i = 0; i < 3; i++) {
            context.drawSurface(
              surface,
              transform: Matrix4.translationValues(-0.6 + i * 0.6, 0, -5),
            );
          }
        },
      );

      expect(frame.stats.drawCalls, 3);
      expect(material.applied, 3);
      for (var i = 0; i < 3; i++) {
        final (x, y) = pixelAt(-0.6 + i * 0.6, 0);
        expect(frame.pixels.isClear(x, y), isFalse);
      }
      final (x, y) = pixelAt(-0.3, 0);
      expect(frame.pixels.isClear(x, y), isTrue);
    });
  });

  group('32-bit indices', () {
    testGpuEngine('draw vertices past index 65,535', () async {
      const vertexCount = 70000;
      final stride = VertexLayout.standard.strideInFloats;
      final vertices = Float32List(vertexCount * stride);
      const corners = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
      for (final (i, (x, y)) in corners.indexed) {
        final base = (vertexCount - 4 + i) * stride;
        vertices
          ..setRange(base, base + 3, [x * 0.5, y * 0.5, 0])
          ..setRange(base + 5, base + 9, [1, 1, 1, 1]);
      }
      const first = vertexCount - 4;
      final surface = Surface.fromBuffers(
        vertices: vertices,
        indices: Uint32List.fromList([
          first,
          first + 1,
          first + 2,
          first + 2,
          first + 3,
          first,
        ]),
        material: opaqueUnlit(const Color(0xFFFF8000)),
      );
      expect(surface.indexType, GpuIndexType.uint32);

      final frame = await renderFrame(
        draw: (context) => context.drawSurface(
          surface,
          transform: Matrix4.translationValues(0, 0, -5),
        ),
      );

      final (x, y) = pixelAt(0, 0);
      expect(frame.pixels.at(x, y), (255, 128, 0, 255));
      expect(frame.pixels.isClear(1, 1), isTrue);
    });
  });
}
