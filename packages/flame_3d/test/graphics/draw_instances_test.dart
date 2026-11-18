import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

void main() {
  group('RenderContext3D.drawInstances', () {
    late FakeGpuBackend backend;
    late GraphicsDevice device;
    late RenderContext3D context;

    void frame(void Function() draw) {
      device.begin();
      context.setCamera(
        Matrix4.identity(),
        Matrix4.identity()..setAsPerspective(60, 1, 0.1, 100),
      );
      device.beginPass(const Size(16, 16), frontFace: context.frontFace);
      draw();
      context.flush();
      device
        ..endPass()
        ..end();
    }

    Surface triangle(Material material) {
      return Surface(
        vertices: [
          Vertex(position: Vector3.zero(), texCoord: Vector2.zero()),
          Vertex(position: Vector3(1, 0, 0), texCoord: Vector2.zero()),
          Vertex(position: Vector3(0, 1, 0), texCoord: Vector2.zero()),
        ],
        indices: [0, 1, 2],
        material: material,
      );
    }

    Float32List instances(int count) {
      return Float32List(count * VertexLayout.instanceStrideInFloats);
    }

    setUp(() {
      backend = FakeGpuBackend();
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
    });

    test('draws all the instances with one draw, never batched', () {
      final material = UnlitMaterial()..renderState = RenderState.opaque;
      final surface = triangle(material);
      final data = instances(40);
      frame(() {
        context
          ..drawInstances(surface, instances: data, count: 40)
          ..drawInstances(surface, instances: data, count: 25)
          ..drawSurface(surface)
          ..drawInstances(surface, instances: data, count: 0);
      });
      expect(backend.countCommands('drawIndexed'), 3);
      expect(backend.commands, contains('drawIndexed 3 x40'));
      expect(backend.commands, contains('drawIndexed 3 x25'));
      expect(backend.commands, contains('drawIndexed 3 x1'));
      expect(device.lastFrameStats.instances, 66);
      expect(context.drawCount, 3);
    });

    test('uploads the instances it is given', () {
      final surface = triangle(UnlitMaterial());
      final data = instances(2)
        ..[0] = 7
        ..[VertexLayout.instanceStrideInFloats + 23] = 9;
      frame(() => context.drawInstances(surface, instances: data, count: 2));
      final (buffer, offset, count) = backend.drawnInstances.single;
      expect(count, 2);
      final uploaded = buffer.contents.buffer.asFloat32List(
        offset,
        2 * VertexLayout.instanceStrideInFloats,
      );
      expect(uploaded, data);
    });

    test('orders translucent draws by their center', () {
      final material = UnlitMaterial()..renderState = RenderState.alphaBlend;
      final surface = triangle(material);
      final data = instances(2);
      frame(() {
        context
          ..drawInstances(
            surface,
            instances: data,
            count: 1,
            center: Vector3(0, 0, -2),
          )
          ..drawInstances(
            surface,
            instances: data,
            count: 2,
            center: Vector3(0, 0, -9),
          );
      });
      final draws = backend.commands.where((c) => c.startsWith('drawIndexed'));
      // Back to front: the far draw (two instances) first.
      expect(draws, ['drawIndexed 3 x2', 'drawIndexed 3 x1']);
    });

    test('needs a material drawn instanced', () {
      backend = FakeGpuBackend(inputs: const []);
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
      final surface = triangle(UnlitMaterial());
      device.begin();
      context.setCamera(Matrix4.identity(), Matrix4.identity());
      device.beginPass(const Size(4, 4));
      expect(
        () => context.drawInstances(surface, instances: instances(1), count: 1),
        throwsStateError,
      );
    });
  });
}
