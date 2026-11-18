import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SceneSpatialIndex3D broadphase AABB BVH', () {
    Future<(FlameGame, World3D, List<MeshComponent>)> buildGridScene({
      required bool spatialIndexEnabled,
      int gridSide = 20,
    }) async {
      final world = World3D(spatialIndex3DEnabled: spatialIndexEnabled);
      final game = FlameGame(world: world);
      final sharedBox = CuboidMesh(size: Vector3.all(0.8));
      final items = <MeshComponent>[];
      for (var r = 0; r < gridSide; r++) {
        for (var c = 0; c < gridSide; c++) {
          final comp = MeshComponent(
            mesh: sharedBox,
            position: Vector3(c * 3.0, 0.0, r * 3.0),
          );
          items.add(comp);
        }
      }
      world.addAll(items);
      game
        ..onGameResize(Vector2.all(128))
        ..start();
      await game.ready();
      return (game, world, items);
    }

    test(
      'queryAabb and queryFrustum return exact overlapping objects',
      () async {
        final (_, world, items) = await buildGridScene(
          spatialIndexEnabled: true,
        );
        final index = world.spatialIndex3D..ensureBuilt(world);

        expect(index.indexedObjectCount, items.length);

        final queryBox = Aabb3.minMax(
          Vector3(-0.5, -1.0, -0.5),
          Vector3(3.5, 1.0, 3.5),
        );
        final aabbHits = index.queryAabb(world, queryBox);
        expect(aabbHits, hasLength(4));

        final vp = makeOrthographicMatrix(-1, 4, -2, 2, 0.5, 6.0)
          ..multiply(Matrix4.translationValues(0, 0, -4.5));
        final frustum = Frustum()..setFromMatrix(vp);
        final frustumHits = index.queryFrustum(world, frustum);
        expect(frustumHits, isNotEmpty);
        expect(frustumHits.length, lessThan(20));
      },
    );

    test(
      'World3D raycast & raycastAll match brute-force with O(log N) '
      'candidates tested',
      () async {
        final (_, worldIndexed, _) = await buildGridScene(
          spatialIndexEnabled: true,
        );
        final (_, worldBrute, _) = await buildGridScene(
          spatialIndexEnabled: false,
        );

        final ray = Ray.originDirection(
          Vector3(-2.0, 0.0, -2.0),
          Vector3(1.0, 0.0, 1.0)..normalize(),
        );

        final hitIndexed = worldIndexed.raycast(ray);
        final hitBrute = worldBrute.raycast(ray);
        expect(hitIndexed, isNotNull);
        expect(hitBrute, isNotNull);
        expect(hitIndexed!.distance, closeTo(hitBrute!.distance, 1e-5));
        expect(
          worldIndexed.spatialIndex3D.lastRaycastCandidatesTested,
          lessThan(25),
        );

        final allIndexed = worldIndexed.raycastAll(ray);
        final allBrute = worldBrute.raycastAll(ray);
        expect(allIndexed.length, 20);
        expect(allIndexed.length, allBrute.length);
        for (var i = 0; i < allIndexed.length; i++) {
          expect(allIndexed[i].distance, closeTo(allBrute[i].distance, 1e-5));
        }
        expect(
          worldIndexed.spatialIndex3D.lastRaycastCandidatesTested,
          lessThan(80),
        );
      },
    );

    test(
      'moving or removing an Object3D invalidates the BVH cleanly',
      () async {
        final (game, world, items) = await buildGridScene(
          spatialIndexEnabled: true,
          gridSide: 6,
        );

        final targetRay = Ray.originDirection(
          Vector3(100, 0, 5),
          Vector3(0, 0, -1),
        );
        expect(world.raycast(targetRay), isNull);

        items.first.position.setValues(100, 0, 0);
        final hitAfterMove = world.raycast(targetRay);
        expect(hitAfterMove, isNotNull);
        expect(hitAfterMove!.object, same(items.first));

        items.first.removeFromParent();
        game.update(0.016);
        expect(world.raycast(targetRay), isNull);
      },
    );
  });
}
