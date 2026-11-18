import 'dart:math' as math;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SurfaceBvh & World3D raycasting', () {
    test('raycasts multi-triangle SphereMesh accurately in O(log T)', () {
      final sphere = SphereMesh(radius: 2, segments: 16);
      final surface = sphere.surfaces.first;
      final bvh = surface.bvh;

      expect(bvh.triangleCount, greaterThan(100));
      expect(bvh.nodeCount, greaterThan(1));

      final ray = Ray.originDirection(Vector3(0, 0, 5), Vector3(0, 0, -1));
      final hit = bvh.raycast(ray);
      expect(hit, isNotNull);
      expect(hit!.distance, closeTo(3.0, 0.05));
      expect(hit.point.z, closeTo(2.0, 0.05));
      expect(hit.normal.z, greaterThan(0.95));
    });

    test('honors CullMode.backFace and CullMode.frontFace', () {
      final surface = Surface(
        vertices: [
          Vertex(
            position: Vector3(-1, -1, 0),
            texCoord: Vector2.zero(),
            normal: Vector3(0, 0, 1),
          ),
          Vertex(
            position: Vector3(1, -1, 0),
            texCoord: Vector2.zero(),
            normal: Vector3(0, 0, 1),
          ),
          Vertex(
            position: Vector3(0, 1, 0),
            texCoord: Vector2.zero(),
            normal: Vector3(0, 0, 1),
          ),
        ],
        indices: [0, 1, 2],
      );

      final fromFront = Ray.originDirection(
        Vector3(0, 0, 3),
        Vector3(0, 0, -1),
      );
      final fromBack = Ray.originDirection(
        Vector3(0, 0, -3),
        Vector3(0, 0, 1),
      );

      expect(
        surface.bvh.raycast(fromFront, cullMode: CullMode.backFace),
        isNotNull,
      );
      expect(
        surface.bvh.raycast(fromFront, cullMode: CullMode.frontFace),
        isNull,
      );
      expect(
        surface.bvh.raycast(fromBack, cullMode: CullMode.backFace),
        isNull,
      );
      expect(
        surface.bvh.raycast(fromBack, cullMode: CullMode.frontFace),
        isNotNull,
      );
    });

    test(
      'World3D.raycast handles rotation, non-uniform and negative scale',
      () {
        final cube = CuboidMesh(size: Vector3.all(2));
        final nearObj = MeshComponent(
          mesh: cube,
          position: Vector3(0, 0, 2),
          scale: Vector3(-1, 2, 0.5),
        );
        final farObj = MeshComponent(
          mesh: cube,
          position: Vector3(0, 0, -4),
          rotation: Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 4),
        );
        final world = World3D(children: [farObj, nearObj]);

        final ray = Ray.originDirection(Vector3(0, 1.5, 10), Vector3(0, 0, -1));
        final hit = world.raycast(ray, cullMode: CullMode.backFace);
        expect(hit, isNotNull);
        expect(hit!.object, same(nearObj));
        // Half-depth along Z is `1 * 0.5 = 0.5`, so top face sits at `z = 2.5`.
        expect(hit.distance, closeTo(7.5, 1e-4));
        expect(hit.worldPoint.z, closeTo(2.5, 1e-4));
        expect(hit.worldNormal.z, closeTo(1.0, 1e-4));

        final all = world.raycastAll(
          Ray.originDirection(Vector3(0, 0, 10), Vector3(0, 0, -1)),
          cullMode: CullMode.backFace,
        );
        expect(all.map((h) => h.object), [nearObj, farObj]);
      },
    );

    test('Scene3DComponent.raycastLocal picks InstancedGroup3D instances', () {
      final group = InstancedGroup3D(mesh: CuboidMesh(size: Vector3.all(1)));
      group
        ..addInstance(transform: Matrix4.translationValues(0, 0, 0))
        ..addInstance(transform: Matrix4.translationValues(3, 0, 0));

      final layer = Scene3DComponent(
        projection: Scene3DProjection.affine(
          origin: Vector2.zero(),
          xAxis: Vector2(40, 20),
          yAxis: Vector2(-40, 20),
          zAxis: Vector2(0, -40),
          towardsViewer: Vector3(1, 1, 1),
          near: -50,
          far: 50,
        ),
      );
      layer.world.add(group);

      final target2D = layer.scenePointToLocal(Vector3(3, 0, 0));
      final hit = layer.raycastLocal(target2D, cullMode: CullMode.none);
      expect(hit, isNotNull);
      expect(hit!.object, same(group));
      expect(hit.surfaceIndex, 1);
    });
  });
}
