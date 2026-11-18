import 'dart:typed_data';

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

/// Draws the instance data of each object as its color.
class _InstanceDataMaterial() extends Material {
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          'test/instance_data.shaderbundle',
          slots: [RenderContext3D.cameraMatricesBlock],
        ),
        fragmentShader: FragmentShader.fromAsset(
          'test/instance_data.shaderbundle',
        ),
      );
}

/// Reads only the model matrix of the instancing chunk.
class _ModelOnlyMaterial() extends Material {
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          'test/model_only.shaderbundle',
          slots: [RenderContext3D.cameraMatricesBlock],
        ),
        fragmentShader: FragmentShader.fromAsset(
          'test/model_only.shaderbundle',
        ),
      );
}

/// A square of side `2 * halfSize` facing +z, with positions only.
Surface _square(Material material, {double halfSize = 0.2}) {
  final h = halfSize;
  return Surface.fromBuffers(
    vertices: Float32List.fromList([-h, -h, 0, h, -h, 0, h, h, 0, -h, h, 0]),
    indices: Uint16List.fromList([0, 1, 2, 2, 3, 0]),
    layout: VertexLayout(const [
      VertexAttribute(VertexLayout.positionAttribute, 3),
    ]),
    material: material,
  );
}

(int, int, int, int) _bytes(Vector4 data) {
  int channel(double value) => (value.clamp(0.0, 1.0) * 255).round();
  return (
    channel(data.x),
    channel(data.y),
    channel(data.z),
    channel(data.w),
  );
}

void main() {
  setUpGpu();

  setUpAll(() async {
    if (gpuAvailable) {
      await registerTestShaders(['instance_data', 'model_only']);
    }
  });

  group('instance data', () {
    testGpuEngine('reaches the shader of every instance of a batch', () async {
      final surface = _square(_InstanceDataMaterial());
      final data = [
        Vector4(1, 0.25, 0, 1),
        Vector4(0, 0.5, 1, 1),
        Vector4(0.75, 1, 0.5, 1),
      ];

      final frame = await renderFrame(
        draw: (context) {
          for (final (i, values) in data.indexed) {
            context.drawSurface(
              surface,
              transform: Matrix4.translationValues(-0.6 + i * 0.6, 0, -5),
              instanceData: values,
            );
          }
          // Without instance data: zero.
          context.drawSurface(
            surface,
            transform: Matrix4.translationValues(0, 0.6, -5),
          );
        },
      );

      expect(frame.stats.drawCalls, 1);
      expect(frame.stats.instances, 4);
      for (final (i, values) in data.indexed) {
        final (x, y) = pixelAt(-0.6 + i * 0.6, 0);
        final pixel = frame.pixels.at(x, y);
        final expected = _bytes(values);
        expect(pixel.$1, closeTo(expected.$1, 1), reason: 'instance $i');
        expect(pixel.$2, closeTo(expected.$2, 1), reason: 'instance $i');
        expect(pixel.$3, closeTo(expected.$3, 1), reason: 'instance $i');
      }
      final (x, y) = pixelAt(0, 0.6);
      expect(frame.pixels.at(x, y), (0, 0, 0, 0));
    });

    testGpuEngine('is optional for shaders that include instancing', () async {
      final surface = _square(_ModelOnlyMaterial());

      final frame = await renderFrame(
        draw: (context) {
          for (var i = 0; i < 3; i++) {
            context.drawSurface(
              surface,
              transform: Matrix4.translationValues(-0.6 + i * 0.6, 0, -5),
              instanceData: Vector4.all(1),
            );
          }
        },
      );

      expect(frame.stats.drawCalls, 1);
      for (var i = 0; i < 3; i++) {
        final (x, y) = pixelAt(-0.6 + i * 0.6, 0);
        expect(frame.pixels.at(x, y), (255, 128, 0, 255));
      }
    });

    testGpu('comes from MeshComponent.instanceData', (tester) async {
      final mesh = Mesh()..addSurface(_square(_InstanceDataMaterial()));
      final left = MeshComponent(
        mesh: mesh,
        position: Vector3(-0.5, 0, 0),
        instanceData: Vector4(1, 0, 0.5, 1),
      );
      final right = MeshComponent(mesh: mesh, position: Vector3(0.5, 0, 0));
      // Changed after creation: the values at draw time are used.
      right.instanceData.setValues(0, 1, 0.25, 1);
      final game = FlameGame3D(
        world: World3D(children: [left, right]),
        camera: CameraComponent3D(
          projection: CameraProjection.orthographic,
          orthographicHeight: 2,
          position: Vector3(0, 0, 5),
          target: Vector3.zero(),
        ),
      );

      final pixels = await renderGame(tester, game, width: 64, height: 64);

      expect(game.renderStats.drawCalls, 1);
      expect(game.renderStats.instances, 2);
      final (r1, g1, b1, _) = pixels.at(16, 32);
      expect((r1, g1), (255, 0));
      expect(b1, closeTo(128, 1));
      final (r2, g2, b2, _) = pixels.at(48, 32);
      expect((r2, g2), (0, 255));
      expect(b2, closeTo(64, 1));
    });
  });
}
