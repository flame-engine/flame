import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

// The scene of most tests, seen by the default camera (looking down -z,
// x and y in [-1, 1]): a ground facing +z at z = -5 that fills the view, and
// cubes above it. The sun travels along (sunX, 0, -1): a point at height h
// above the ground casts its shadow sunX * h further along x.

const _size = 128;
const _groundZ = -5.0;

/// The ground: a square of side 2 in the z = -5 plane, facing +z.
Surface _ground(Material material) {
  final stride = VertexLayout.standard.strideInFloats;
  final vertices = Float32List(4 * stride);
  const corners = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
  for (final (i, (x, y)) in corners.indexed) {
    vertices
      ..setRange(i * stride, i * stride + 3, [x.toDouble(), y.toDouble(), -5])
      ..setRange(i * stride + 5, i * stride + 9, [1, 1, 1, 1])
      ..setRange(i * stride + 9, i * stride + 12, [0, 0, 1]);
  }
  return Surface.fromBuffers(
    vertices: vertices,
    indices: Uint16List.fromList([0, 1, 2, 2, 3, 0]),
    material: material,
  );
}

/// The bounds of the ground and of cubes of side [side] at [centers].
Aabb3 _bounds(List<Vector3> centers, double side) {
  final bounds = Aabb3.minMax(
    Vector3(-1, -1, _groundZ),
    Vector3(1, 1, _groundZ),
  );
  for (final center in centers) {
    bounds.hullPoint(center - Vector3.all(side / 2));
    bounds.hullPoint(center + Vector3.all(side / 2));
  }
  return bounds;
}

/// A hemisphere light from +z of [ambient], and a sun traveling along
/// ([sunX], 0, -1) of [sun] with [shadows].
List<Light> _lights({
  double sunX = 0.5,
  double ambient = 0.4,
  double sun = 0.5,
  ShadowSettings? shadows,
}) {
  return [
    Light(
      position: Vector3.zero(),
      source: HemisphereLight(intensity: ambient, up: Vector3(0, 0, 1)),
    ),
    Light(
      position: Vector3.zero(),
      source: DirectionalLight(
        direction: Vector3(sunX, 0, -1),
        intensity: sun,
        shadows: shadows,
      ),
    ),
  ];
}

/// Renders a frame of the default camera, with a shadow pass first when a
/// light casts shadows: [draw] records the draws of both passes.
Future<Frame> _render({
  required void Function(RenderContext3D context) draw,
  required List<Light> lights,
  required Aabb3 sceneBounds,
  GraphicsDevice? device,
  RenderContext3D? context,
  DirectionalShadowProjection? shadowProjection,
  Matrix4? view,
  Matrix4? projection,
}) async {
  final graphicsDevice = device ?? GraphicsDevice();
  final renderContext = context ?? RenderContext3D(graphicsDevice);
  graphicsDevice.begin();
  renderContext
    ..lights = lights
    ..setCamera(view ?? defaultView, projection ?? defaultProjection);
  if (renderContext.beginShadowPass(
    projection: shadowProjection ?? DirectionalShadowProjection(),
    sceneBounds: sceneBounds,
  )) {
    expect(renderContext.isShadowPass, isTrue);
    draw(renderContext);
    renderContext.endShadowPass();
  }
  expect(renderContext.isShadowPass, isFalse);
  graphicsDevice.beginPass(
    const Size(_size + 0.0, _size + 0.0),
    frontFace: renderContext.frontFace,
  );
  draw(renderContext);
  renderContext.flush();
  final image = graphicsDevice.endPass();
  graphicsDevice.end();
  final stats = RenderStats()..setFrom(graphicsDevice.lastFrameStats);
  final pixels = await readImage(image);
  image.dispose();
  return Frame(pixels, stats);
}

/// The red channel of the pixel where the point ([x], [y]) of the view
/// lands.
int _red(Frame frame, double x, double y) {
  final (px, py) = pixelAt(x, y, width: _size, height: _size);
  return frame.pixels.at(px, py).$1;
}

/// The x coordinates of the view where the row through [y] crosses from one
/// side of [threshold] to the other, in the red channel.
List<double> _edges(Frame frame, double y, int threshold) {
  final (_, py) = pixelAt(0, y, width: _size, height: _size);
  final edges = <double>[];
  for (var px = 1; px < _size; px++) {
    final before = frame.pixels.at(px - 1, py).$1;
    final after = frame.pixels.at(px, py).$1;
    if ((before < threshold) != (after < threshold)) {
      // Where the red channel crosses the threshold, between the centers of
      // the two pixels.
      final t = (threshold - before) / (after - before);
      edges.add((px - 0.5 + t) / _size * 2 - 1);
    }
  }
  return edges;
}

void main() {
  setUpGpu();

  // Lit by the sun: 0.4 + 0.5 * cos(26.57°); in shadow: 0.4.
  const lit = 216;
  const shadowed = 102;

  group('Shadows', () {
    testGpuEngine('a cube shadows the ground where the sun puts it', () async {
      final material = StylizedMaterial();
      final ground = _ground(material);
      final cube = CuboidMesh(size: Vector3.all(0.4), material: material);
      final center = Vector3(0, 0, -4);

      final frame = await _render(
        lights: _lights(shadows: ShadowSettings()),
        sceneBounds: _bounds([center], 0.4),
        draw: (context) => context
          ..drawSurface(ground)
          ..drawMesh(cube, transform: Matrix4.translation(center)),
      );

      // The cube spans heights 0.8 to 1.2 and x -0.2 to 0.2: its shadow
      // spans x 0.2 to 0.8 and y -0.2 to 0.2.
      expect(_red(frame, 0.5, 0), closeTo(shadowed, 3));
      expect(_red(frame, 0.3, 0.1), closeTo(shadowed, 3));
      expect(_red(frame, 0.7, -0.1), closeTo(shadowed, 3));
      expect(_red(frame, 0.5, 0.5), closeTo(lit, 3));
      expect(_red(frame, 0.5, -0.5), closeTo(lit, 3));
      expect(_red(frame, -0.5, 0), closeTo(lit, 3));
      expect(_red(frame, 0.9, 0), closeTo(lit, 3));
      // The top of the cube, lit like the ground.
      expect(_red(frame, 0, 0), closeTo(lit, 3));

      const midway = (lit + shadowed) ~/ 2;
      final edges = _edges(frame, 0.05, midway);
      debugPrint('shadow edges along x: $edges');
      expect(edges, hasLength(2));
      expect(edges[0], closeTo(0.2, 1.5 / _size * 2));
      expect(edges[1], closeTo(0.8, 1.5 / _size * 2));

      expect(frame.stats.renderPasses, 2);
      expect(frame.stats.shadowPasses, 1);
      // The ground and the cube, which both cast.
      expect(frame.stats.shadowDrawCalls, 2);
    });

    testGpuEngine('nothing is shadowed without shadows', () async {
      final material = StylizedMaterial();
      final ground = _ground(material);
      final cube = CuboidMesh(size: Vector3.all(0.4), material: material);
      final center = Vector3(0, 0, -4);

      final frame = await _render(
        lights: _lights(),
        sceneBounds: _bounds([center], 0.4),
        draw: (context) => context
          ..drawSurface(ground)
          ..drawMesh(cube, transform: Matrix4.translation(center)),
      );

      expect(_red(frame, 0.5, 0), closeTo(lit, 3));
      expect(_red(frame, -0.5, 0), closeTo(lit, 3));
      expect(frame.stats.renderPasses, 1);
      expect(frame.stats.shadowPasses, 0);
      expect(frame.stats.shadowDrawCalls, 0);
    });

    testGpuEngine(
      'depths packed into RGBA8 shadow like 32-bit floats',
      () async {
        Future<Frame> render(ShadowMapEncoding encoding) {
          final material = StylizedMaterial();
          final ground = _ground(material);
          final cube = CuboidMesh(size: Vector3.all(0.4), material: material);
          final center = Vector3(0.1, 0.2, -4);
          return _render(
            lights: _lights(shadows: ShadowSettings(encoding: encoding)),
            sceneBounds: _bounds([center], 0.4),
            draw: (context) => context
              ..drawSurface(ground)
              ..drawMesh(cube, transform: Matrix4.translation(center)),
          );
        }

        final float = await render(ShadowMapEncoding.float32);
        final packed = await render(ShadowMapEncoding.rgba8);
        expect(_red(packed, 0.6, 0.2), closeTo(shadowed, 3));
        expect(_red(packed, -0.5, 0), closeTo(lit, 3));
        expect(differingPixels(float.pixels, packed.pixels, tolerance: 1), 0);
      },
    );

    testGpuEngine('surfaces do not shadow themselves', () async {
      for (final sunX in [0.0, 0.36, 1.0, 2.0, 4.0]) {
        Future<Frame> render({required bool shadows}) {
          final material = StylizedMaterial();
          final ground = _ground(material);
          // A cube off the view, whose shadow stays off it too, so that the
          // map covers a deep range.
          final center = Vector3(-1, 6, -2);
          final cube = CuboidMesh(size: Vector3.all(0.4), material: material);
          return _render(
            lights: _lights(
              sunX: sunX,
              shadows: shadows ? ShadowSettings() : null,
            ),
            sceneBounds: _bounds([center], 0.4),
            draw: (context) => context
              ..drawSurface(ground)
              ..drawMesh(cube, transform: Matrix4.translation(center)),
          );
        }

        final withShadows = await render(shadows: true);
        final without = await render(shadows: false);
        expect(
          differingPixels(withShadows.pixels, without.pixels, tolerance: 1),
          0,
          reason: 'sun along ($sunX, 0, -1)',
        );
      }
    });

    testGpuEngine('shadows start where a cube meets the ground', () async {
      final material = StylizedMaterial();
      final ground = _ground(material);
      final cube = CuboidMesh(size: Vector3.all(0.4), material: material);
      // Resting on the ground: its bottom is at z = -5.
      final center = Vector3(0, 0, -4.8);

      final frame = await _render(
        lights: _lights(sunX: 1, shadows: ShadowSettings()),
        sceneBounds: _bounds([center], 0.4),
        draw: (context) => context
          ..drawSurface(ground)
          ..drawMesh(cube, transform: Matrix4.translation(center)),
      );

      // The pixel right next to the cube on the side away from the sun.
      const pixel = 2 / _size;
      expect(_red(frame, 0.2 + pixel, 0), closeTo(shadowed, 3));
      expect(_red(frame, 0.2 + 0.35, 0), closeTo(shadowed, 3));
      // Lit by 0.4 + 0.5 * cos(45°): towards the sun, and past the shadow
      // (x 0.2 to 0.6).
      const litAt45 = 192;
      expect(_red(frame, -0.2 - pixel, 0), closeTo(litAt45, 3));
      expect(_red(frame, 0.6 + 2 * pixel, 0), closeTo(litAt45, 3));
    });

    testGpuEngine('materials and draws that cast nothing', () async {
      Future<Frame> render(Material cubeMaterial) {
        final material = StylizedMaterial();
        final ground = _ground(material);
        final cube = CuboidMesh(size: Vector3.all(0.4), material: cubeMaterial);
        final center = Vector3(0, 0, -4);
        return _render(
          lights: _lights(shadows: ShadowSettings()),
          sceneBounds: _bounds([center], 0.4),
          draw: (context) => context
            ..drawSurface(ground)
            ..drawMesh(cube, transform: Matrix4.translation(center)),
        );
      }

      // Opaque, but told not to cast.
      final opaque = await render(StylizedMaterial()..castsShadows = false);
      expect(_red(opaque, 0.5, 0), closeTo(lit, 3));
      // Only the ground cast.
      expect(opaque.stats.shadowDrawCalls, 1);

      // Translucent and additive materials cast nothing by default.
      final glass = await render(StylizedMaterial(translucent: true));
      expect(_red(glass, 0.5, 0), closeTo(lit, 3));
      final glow = await render(
        UnlitMaterial()..renderState = RenderState.additive,
      );
      expect(_red(glow, 0.5, 0), closeTo(lit, 3));

      // Unless told to.
      final castingGlass = await render(
        StylizedMaterial(translucent: true)..castsShadows = true,
      );
      expect(_red(castingGlass, 0.5, 0), closeTo(shadowed, 3));
    });

    testGpuEngine('instanced casters cast one shadow each', () async {
      final material = StylizedMaterial();
      final ground = _ground(material);
      final cube = CuboidMesh(size: Vector3.all(0.2), material: material);
      final centers = [
        for (final x in [-0.8, -0.3, 0.2]) Vector3(x, 0.4, -4.4),
      ];

      final frame = await _render(
        lights: _lights(shadows: ShadowSettings()),
        sceneBounds: _bounds(centers, 0.2),
        draw: (context) {
          context.drawSurface(ground);
          for (final center in centers) {
            context.drawMesh(cube, transform: Matrix4.translation(center));
          }
        },
      );

      // Each cube spans heights 0.5 to 0.7: its shadow is 0.25 to 0.35
      // further along x.
      for (final center in centers) {
        expect(_red(frame, center.x + 0.3, 0.4), closeTo(shadowed, 3));
        expect(_red(frame, center.x + 0.3, 0.1), closeTo(lit, 3));
      }
      // The ground, and one instanced draw of the three cubes.
      expect(frame.stats.shadowDrawCalls, 2);
      expect(frame.stats.drawCalls, 4);
    });

    testGpuEngine('skinned casters cast their skinned shape', () async {
      final material = StylizedMaterial();
      final ground = _ground(material);
      // A square at rest at x = -0.5, 0.6 above the ground, whose vertices
      // follow joint 0: moved 1 along x, it casts its shadow from x = 0.5.
      final stride = VertexLayout.standard.strideInFloats;
      final vertices = Float32List(4 * stride);
      const corners = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
      for (final (i, (x, y)) in corners.indexed) {
        vertices
          ..setRange(i * stride, i * stride + 3, [
            -0.5 + x * 0.15,
            y * 0.15,
            -4.4,
          ])
          ..setRange(i * stride + 5, i * stride + 9, [1, 1, 1, 1])
          ..setRange(i * stride + 9, i * stride + 12, [0, 0, 1])
          // Joint 0, weight 1.
          ..setRange(i * stride + 16, i * stride + 20, [1, 0, 0, 0]);
      }
      final square = Surface.fromBuffers(
        vertices: vertices,
        indices: Uint16List.fromList([0, 1, 2, 2, 3, 0]),
        material: material,
      );
      final joints = [Matrix4.translationValues(1, 0, 0)];

      final frame = await _render(
        lights: _lights(shadows: ShadowSettings()),
        sceneBounds: _bounds([Vector3(0.5, 0, -4.4)], 0.3),
        draw: (context) => context
          ..drawSurface(ground)
          ..drawSurface(square, jointTransforms: joints),
      );

      // The square is drawn at x = 0.5 and casts its shadow 0.3 further.
      expect(_red(frame, 0.85, 0), closeTo(shadowed, 3));
      // Nothing where its rest position would have cast.
      expect(_red(frame, -0.15, 0), closeTo(lit, 3));
    });

    testGpuEngine('skinned StylizedMaterial surfaces cast their skinned '
        'shape', () async {
      final material = StylizedMaterial();
      final ground = _ground(material);
      // The same square in StylizedMaterial.skinnedVertexLayout: its vertices
      // follow joint 1, moved 1 along x.
      final square = StylizedMaterial.buildSurface(
        positions: [
          for (final (x, y) in [(-1, -1), (1, -1), (1, 1), (-1, 1)]) ...[
            -0.5 + x * 0.15,
            y * 0.15,
            -4.4,
          ],
        ],
        normals: [
          for (var i = 0; i < 4; i++) ...[0.0, 0.0, 1.0],
        ],
        joints: [
          for (var i = 0; i < 4; i++) ...[1.0, 0.0, 0.0, 0.0],
        ],
        weights: [
          for (var i = 0; i < 4; i++) ...[1.0, 0.0, 0.0, 0.0],
        ],
        indices: [0, 1, 2, 2, 3, 0],
        material: material,
      );
      expect(square.layout, StylizedMaterial.skinnedVertexLayout);
      final joints = [Matrix4.identity(), Matrix4.translationValues(1, 0, 0)];

      final frame = await _render(
        lights: _lights(shadows: ShadowSettings()),
        sceneBounds: _bounds([Vector3(0.5, 0, -4.4)], 0.3),
        draw: (context) => context
          ..drawSurface(ground)
          ..drawSurface(square, jointTransforms: joints),
      );

      expect(_red(frame, 0.85, 0), closeTo(shadowed, 3));
      expect(_red(frame, -0.15, 0), closeTo(lit, 3));
    });

    testGpuEngine(
      'shadows tint and dim only the light that casts them',
      () async {
        Future<Frame> render(ShadowSettings shadows, {bool secondSun = false}) {
          final material = StylizedMaterial();
          final ground = _ground(material);
          final cube = CuboidMesh(size: Vector3.all(0.4), material: material);
          final center = Vector3(0, 0, -4);
          return _render(
            lights: [
              ..._lights(shadows: shadows),
              if (secondSun)
                Light(
                  position: Vector3.zero(),
                  source: DirectionalLight(
                    direction: Vector3(0, 0, -1),
                    intensity: 0.2,
                  ),
                ),
            ],
            sceneBounds: _bounds([center], 0.4),
            draw: (context) => context
              ..drawSurface(ground)
              ..drawMesh(cube, transform: Matrix4.translation(center)),
          );
        }

        (int, int, int, int) shadowPixel(Frame frame) {
          final (px, py) = pixelAt(0.5, 0, width: _size, height: _size);
          return frame.pixels.at(px, py);
        }

        // The sun's light, 0.5 * cos(26.57°) = 0.447, is multiplied by
        // (0.5, 0.5, 1) in the shadow; the hemisphere light stays.
        final tinted = shadowPixel(
          await render(ShadowSettings(color: const Color(0xFF8080FF))),
        );
        expect(tinted.$1, closeTo((0.4 + 0.447 * 128 / 255) * 255, 3));
        expect(tinted.$3, closeTo(lit, 3));

        // At half strength, half of the sun's light is taken away.
        final half = shadowPixel(await render(ShadowSettings(strength: 0.5)));
        expect(half.$1, closeTo((0.4 + 0.447 * 0.5) * 255, 3));

        // A second sun without shadows still lights the shadow.
        final twoSuns = shadowPixel(
          await render(ShadowSettings(), secondSun: true),
        );
        expect(twoSuns.$1, closeTo(shadowed + 0.2 * 255, 3));
      },
    );

    testGpuEngine('softness widens the edges of the shadows', () async {
      Future<int> softPixels(int softness) async {
        final material = StylizedMaterial();
        final ground = _ground(material);
        final cube = CuboidMesh(size: Vector3.all(0.4), material: material);
        final center = Vector3(0, 0, -4);
        final frame = await _render(
          lights: _lights(
            // A coarse map: about 2.4 pixels per texel.
            shadows: ShadowSettings(resolution: 64, softness: softness),
          ),
          sceneBounds: _bounds([center], 0.4),
          draw: (context) => context
            ..drawSurface(ground)
            ..drawMesh(cube, transform: Matrix4.translation(center)),
        );
        // The pixels between lit and shadowed along the edge at x = 0.8.
        final (_, py) = pixelAt(0, 0.05, width: _size, height: _size);
        var count = 0;
        for (var px = _size * 3 ~/ 4; px < _size; px++) {
          final red = frame.pixels.at(px, py).$1;
          if (red > shadowed + 6 && red < lit - 6) {
            count++;
          }
        }
        return count;
      }

      final hard = await softPixels(0);
      final soft = await softPixels(3);
      debugPrint('pixels across the edge: softness 0 $hard, softness 3 $soft');
      expect(hard, greaterThan(0));
      expect(soft, greaterThan(hard * 2));
    });
  });
}
