import 'dart:ui' show Canvas, Color, PictureRecorder;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canvas3DFallbackComponent & EnvironmentProbe3D', () {
    test(
      'renders MeshComponent, InstancedGroup3D, and ModelComponent to 2D',
      () {
        final world = World3D();
        final mat = SpatialMaterial(albedoColor: const Color(0xFF38BDF8));
        final cube = CuboidMesh(size: Vector3.all(1.0), material: mat);

        world
          ..add(
            LightComponent.directional(
              direction: Vector3(-0.4, -0.4, -0.8),
              intensity: 2.0,
            ),
          )
          ..add(MeshComponent(mesh: cube, position: Vector3(0, 0, 0.5)));

        final group = InstancedGroup3D(mesh: cube)
          ..addInstance(transform: Matrix4.translationValues(-2, 0, 0.5))
          ..addInstance(transform: Matrix4.translationValues(2, 0, 0.5));
        world.add(group);

        final modelNode = ModelNode(
          name: 'Root',
          nodeIndex: 0,
          parentNodeIndex: null,
          transform: Matrix4.translationValues(0, 0, 1.8),
          mesh: SphereMesh(radius: 0.5, segments: 6, material: mat),
          joints: const {},
        );
        world.add(
          ModelComponent(
            model: Model(nodes: {0: modelNode}, animations: const []),
          ),
        );

        final fallback = Canvas3DFallbackComponent(
          world: world,
          size: Vector2(320, 200),
          camera: CameraComponent3D(
            position: Vector3(0, 5, 8),
            target: Vector3(0, 0.8, 0),
          ),
        );

        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        fallback.render(canvas);
        final picture = recorder.endRecording();
        addTearDown(picture.dispose);

        expect(fallback.lastTrianglesSubmitted, greaterThan(20));
      },
    );

    test('EnvironmentProbe3D.skyDome evaluates directional SH9 irradiance', () {
      final probe = EnvironmentProbe3D.skyDome(
        width: 64,
        height: 32,
        zenithColor: const Color(0xFF2563EB),
        horizonColor: const Color(0xFF93C5FD),
        groundColor: const Color(0xFF1E293B),
      );
      expect(probe.shCoefficients.length, 9);
      final skyIrr = probe.evaluateIrradiance(Vector3(0, 1, 0));
      final groundIrr = probe.evaluateIrradiance(Vector3(0, -1, 0));
      expect(skyIrr.z, greaterThan(groundIrr.z));
      expect(skyIrr.length, greaterThan(0.1));
    });

    test('ShadowSettings validates 1 or 2 cascades', () {
      final single = ShadowSettings();
      expect(single.cascades, 1);
      final dual = ShadowSettings(cascades: 2, cascadeSplitRatio: 0.3);
      expect(dual.cascades, 2);
      expect(() => ShadowSettings(cascades: 3), throwsArgumentError);
    });
  });
}
