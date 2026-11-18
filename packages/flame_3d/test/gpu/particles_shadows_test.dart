import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

// Particle systems in a scene whose sun casts shadows. The default camera
// looks down -z at a ground facing +z at z = -5; the sun travels along
// (0.5, 0, -1), so a point at height h above the ground casts its shadow
// 0.5 * h further along x.

const _size = 128;

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

List<Light> _lights() {
  return [
    Light(
      position: Vector3.zero(),
      source: HemisphereLight(intensity: 0.4, up: Vector3(0, 0, 1)),
    ),
    Light(
      position: Vector3.zero(),
      source: DirectionalLight(
        direction: Vector3(0.5, 0, -1),
        intensity: 0.5,
        shadows: ShadowSettings(),
      ),
    ),
  ];
}

Future<Frame> _render(void Function(RenderContext3D context) draw) async {
  final device = GraphicsDevice();
  final context = RenderContext3D(device);
  device.begin();
  context
    ..lights = _lights()
    ..setCamera(defaultView, defaultProjection);
  final bounds = Aabb3.minMax(Vector3(-1, -1, -5), Vector3(1, 1, -3.5));
  if (context.beginShadowPass(
    projection: DirectionalShadowProjection(),
    sceneBounds: bounds,
  )) {
    draw(context);
    context.endShadowPass();
  }
  device.beginPass(
    const Size(_size + 0.0, _size + 0.0),
    frontFace: context.frontFace,
  );
  draw(context);
  context.flush();
  final image = device.endPass();
  device.end();
  final stats = RenderStats()..setFrom(device.lastFrameStats);
  final pixels = await readImage(image);
  image.dispose();
  return Frame(pixels, stats);
}

int _red(Frame frame, double x, double y) {
  final (px, py) = pixelAt(x, y, width: _size, height: _size);
  return frame.pixels.at(px, py).$1;
}

void main() {
  setUpGpu();

  // Lit by the sun: 0.4 + 0.5 * cos(26.57°); in shadow: 0.4.
  const lit = 216;
  const shadowed = 102;

  group('particles with shadows', () {
    testGpuEngine('opaque mesh particles cast shadows', () async {
      final material = StylizedMaterial();
      final ground = _ground(material);
      final system = ParticleSystem3D(
        capacity: 4,
        mesh: CuboidMesh(size: Vector3.all(1), material: material),
      )..spawn(position: Vector3(0, 0, -4), size: 0.4);

      final frame = await _render((context) {
        context.drawSurface(ground);
        system.draw(context);
      });

      // The particle spans heights 0.8 to 1.2 and x -0.2 to 0.2, as the cube
      // of the shadow tests: its shadow spans x 0.2 to 0.8.
      expect(_red(frame, 0.5, 0), closeTo(shadowed, 4));
      expect(_red(frame, -0.5, 0), closeTo(lit, 4));
      expect(frame.stats.shadowPasses, 1);
      // The ground and the particles.
      expect(frame.stats.shadowDrawCalls, 2);
      // The particle is drawn into the map and into the picture.
      expect(frame.stats.particles, 2);
    });

    testGpuEngine('translucent billboards cast no shadows', () async {
      final material = StylizedMaterial();
      final ground = _ground(material);
      final system = ParticleSystem3D(
        capacity: 4,
        material: ParticleMaterial(sprite: ParticleSprite.texture),
      )..spawn(position: Vector3(0, 0, -4), size: 0.4);

      final frame = await _render((context) {
        context.drawSurface(ground);
        system.draw(context);
      });

      expect(_red(frame, 0.5, 0), closeTo(lit, 4));
      // Only the ground casts.
      expect(frame.stats.shadowDrawCalls, 1);
      // The shadow pass skips the particles altogether.
      expect(frame.stats.particles, 1);
    });
  });
}
