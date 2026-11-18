import 'dart:ui';

import 'package:flame/components.dart' show RectangleComponent, World;
import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' show GlobalKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

Mesh _accentedQuad(Material material) {
  return Mesh()..addSurface(
    StylizedMaterial.buildSurface(
      positions: const [
        -0.5, -0.5, 0.0, //
        0.5, -0.5, 0.0, //
        0.5, 0.5, 0.0, //
        -0.5, 0.5, 0.0, //
      ],
      normals: const [
        0.0, 0.0, 1.0, //
        0.0, 0.0, 1.0, //
        0.0, 0.0, 1.0, //
        0.0, 0.0, 1.0, //
      ],
      indices: const [0, 1, 2, 0, 2, 3],
      accent: const [1.0, 1.0, 1.0, 1.0],
      material: material,
    ),
  );
}

Future<Pixels> _pump2DScene(
  WidgetTester tester,
  Scene3DComponent layer, {
  Color backdrop = const Color(0xFF181C24),
}) async {
  final game = FlameGame(
    world: World(
      children: [
        RectangleComponent(
          position: Vector2.all(-500),
          size: Vector2.all(1000),
          paint: Paint()..color = backdrop,
        ),
        layer,
      ],
    ),
  );
  game.camera.viewfinder.position = Vector2(64, 64);

  tester.view
    ..physicalSize = const Size(128, 128)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: GameWidget(game: game),
    ),
  );
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData();
    final out = Pixels(image.width, image.height, data!.buffer.asUint8List());
    image.dispose();
    return out;
  }))!;
}

Scene3DProjection _orthoFront() => Scene3DProjection.affine(
  origin: Vector2(64, 64),
  xAxis: Vector2(28, 0),
  yAxis: Vector2(0, -28),
  zAxis: Vector2(-8, -8),
  towardsViewer: Vector3(0, 0, 1),
  near: -40,
  far: 40,
);

void main() {
  setUpGpu();

  group('New flame_3d GPU materials, batches, LOD, Fog & Bloom', () {
    testGpu(
      'StylizedMaterial accentPalette batches distinct accents in 1 draw',
      (tester) async {
        final material = StylizedMaterial(
          accentPalette: const [Color(0xFFFF1010), Color(0xFF1040FF)],
          rimStrength: 0,
          specularStrength: 0,
        );
        final mesh = _accentedQuad(material);

        final layer = Scene3DComponent(projection: _orthoFront());
        layer.world.addAll([
          LightComponent.ambient(intensity: 1.0),
          MeshComponent(
            mesh: mesh,
            position: Vector3(-0.9, 0, 0),
            instanceData: Vector4(
              0,
              0,
              0,
              StylizedMaterial.packAccentAndFade(0),
            ),
          ),
          MeshComponent(
            mesh: mesh,
            position: Vector3(0.9, 0, 0),
            instanceData: Vector4(
              0,
              0,
              0,
              StylizedMaterial.packAccentAndFade(1),
            ),
          ),
        ]);

        final pixels = await _pump2DScene(tester, layer);
        expect(layer.renderStats.drawCalls, 1);
        expect(layer.renderStats.instances, 2);
        expect(
          pixels.count((r, g, b, a) => r > 200 && b < 40),
          greaterThan(150),
        );
        expect(
          pixels.count((r, g, b, a) => b > 200 && r < 40),
          greaterThan(150),
        );
      },
    );

    testGpu(
      'FogSettings blends distant StylizedMaterial objects to fog color',
      (
        tester,
      ) async {
        final mat = StylizedMaterial(
          albedoColor: const Color(0xFFFF2020),
          rimStrength: 0,
          specularStrength: 0,
        );
        final box = Mesh()
          ..addSurface(
            StylizedMaterial.buildSurface(
              positions: const [
                -0.6,
                -0.6,
                0,
                0.6,
                -0.6,
                0,
                0.6,
                0.6,
                0,
                -0.6,
                0.6,
                0,
              ],
              normals: const [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1],
              indices: const [0, 1, 2, 0, 2, 3],
              material: mat,
            ),
          );

        final game = FlameGame3D(
          world: World3D(
            fog: FogSettings(
              color: const Color(0xFF20E0FF),
              start: 2,
              end: 10,
            ),
            children: [
              LightComponent.ambient(intensity: 1.0),
              MeshComponent(mesh: box, position: Vector3(-0.9, 0, -2)),
              MeshComponent(mesh: box, position: Vector3(1.8, 0, -12)),
            ],
          ),
          camera: CameraComponent3D(
            position: Vector3(0, 0, 0),
            target: Vector3(0, 0, -5),
          ),
        );

        final pixels = await renderGame(tester, game);
        // Near quad stays bright red; far quad is fogged cyan.
        expect(
          pixels.count((r, g, b, a) => r > 200 && b < 50),
          greaterThan(80),
        );
        expect(
          pixels.count((r, g, b, a) => b > 180 && r < 60),
          greaterThan(20),
        );
      },
    );

    testGpu(
      'OutlineMaterial draws inverted-hull silhouette rim without hiding face',
      (tester) async {
        final fill = UnlitMaterial();
        final outline = OutlineMaterial(
          color: const Color(0xFF00FF40),
          thickness: 0.12,
          screenSpace: true,
        );
        final fillSphere = SphereMesh(
          radius: 0.7,
          segments: 16,
          material: fill,
        );
        final outlineSphere = SphereMesh(
          radius: 0.7,
          segments: 16,
          material: outline,
        );

        final layer = Scene3DComponent(projection: _orthoFront());
        layer.world.addAll([
          MeshComponent(mesh: fillSphere),
          MeshComponent(mesh: outlineSphere),
        ]);

        final pixels = await _pump2DScene(tester, layer);
        // Interior stays white, outer border is bright green!
        final center = pixels.at(64, 64);
        expect(center.$1, greaterThan(240));
        expect(center.$3, greaterThan(240));
        expect(
          pixels.count((r, g, b, a) => g > 200 && r < 40 && b < 100),
          greaterThan(80),
        );
      },
    );

    testGpu('DecalBatch3D and StrokeBatch3D render in 1 instanced draw each', (
      tester,
    ) async {
      final decals =
          DecalBatch3D(
            material: DecalMaterial(softness: 0.1, innerRadius: 0.45),
          )..addFlatDecal(
            center: Vector3(-0.9, 0, 0),
            width: 1.2,
            height: 1.2,
            normal: Vector3(0, 0, 1),
            color: const Color(0xFFFFD020),
          );

      final strokes =
          StrokeBatch3D(
            material: RibbonMaterial3D(edgeSoftness: 0.2),
          )..addPolyline(
            [Vector3(0.2, -0.8, 0), Vector3(0.9, 0.0, 0), Vector3(1.5, 0.8, 0)],
            width: 0.35,
            endWidth: 0.15,
            color: const Color(0xFF30D0FF),
            endOpacity: 0.8,
          );

      final layer = Scene3DComponent(projection: _orthoFront());
      layer.world.addAll([decals, strokes]);

      final pixels = await _pump2DScene(tester, layer);
      expect(layer.renderStats.drawCalls, 2);
      // Gold ring decal on left + cyan stroke on right.
      expect(
        pixels.count((r, g, b, a) => r > 180 && g > 140 && b < 80),
        greaterThan(40),
      );
      expect(
        pixels.count((r, g, b, a) => b > 180 && g > 140 && r < 80),
        greaterThan(60),
      );
    });

    testGpu('RibbonTrail3D tracks a moving object and draws a tapered trail', (
      tester,
    ) async {
      final trail = RibbonTrail3D(
        position: Vector3(-1.2, -0.5, 0),
        width: 0.35,
        lifetime: 1.0,
        minVertexDistance: 0.05,
        color: const Color(0xFFFF40C0),
      );

      final layer = Scene3DComponent(projection: _orthoFront());
      layer.world.add(trail);

      final game = FlameGame(
        world: World(
          children: [
            RectangleComponent(
              position: Vector2.all(-500),
              size: Vector2.all(1000),
              paint: Paint()..color = const Color(0xFF10141C),
            ),
            layer,
          ],
        ),
      );
      game.camera.viewfinder.position = Vector2(64, 64);

      tester.view
        ..physicalSize = const Size(128, 128)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: GameWidget(game: game),
        ),
      );
      for (var step = 0; step < 6; step++) {
        trail.position.setValues(-1.2 + step * 0.45, -0.5 + step * 0.2, 0);
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(trail.pointCount, greaterThanOrEqualTo(5));
      expect(layer.renderStats.drawCalls, 1);

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final pixels = (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData();
        final out = Pixels(
          image.width,
          image.height,
          data!.buffer.asUint8List(),
        );
        image.dispose();
        return out;
      }))!;
      expect(
        pixels.count((r, g, b, a) => r > 180 && b > 140 && g < 120),
        greaterThan(60),
      );
    });

    testGpu('LodMeshComponent selects tier by distance and uses shadowMesh', (
      tester,
    ) async {
      final nearMesh = CuboidMesh(
        size: Vector3.all(1),
        material: UnlitMaterial(albedoColor: const Color(0xFF20FF40)),
      );
      final farMesh = CuboidMesh(
        size: Vector3.all(1),
        material: UnlitMaterial(albedoColor: const Color(0xFFFF2080)),
      );
      final lod = LodMeshComponent(
        levels: [
          MeshLodLevel(mesh: nearMesh, maxDistance: 5),
          MeshLodLevel(mesh: farMesh),
        ],
        position: Vector3(0, 0, -12),
      );

      final game = FlameGame3D(
        world: World3D(children: [lod]),
        camera: CameraComponent3D(
          position: Vector3.zero(),
          target: Vector3(0, 0, -12),
        ),
      );
      await renderGame(tester, game);
      expect(lod.lastSelectedLevel, 1);

      lod.position.z = -3;
      await tester.pump(const Duration(milliseconds: 16));
      expect(lod.lastSelectedLevel, 0);
    });

    testGpu(
      'BloomSettings adds a soft halo onto the 2D backdrop around bright quads',
      (tester) async {
        Scene3DComponent buildLayer({required bool withBloom}) {
          final layer = Scene3DComponent(
            projection: _orthoFront(),
            bloom: withBloom
                ? BloomSettings(
                    threshold: 0.5,
                    intensity: 1.4,
                    radius: 2.0,
                    passes: 3,
                  )
                : null,
          );
          layer.world.add(
            MeshComponent(
              mesh: CuboidMesh(
                size: Vector3.all(0.7),
                material: UnlitMaterial(albedoColor: const Color(0xFFFFE040)),
              ),
            ),
          );
          return layer;
        }

        const backdrop = Color(0xFF101018);
        final unbloomed = await _pump2DScene(
          tester,
          buildLayer(withBloom: false),
          backdrop: backdrop,
        );
        final bloomed = await _pump2DScene(
          tester,
          buildLayer(withBloom: true),
          backdrop: backdrop,
        );

        // With bloom enabled, surrounding backdrop pixels outside the quad
        // are brightened by the additive glow halo!
        final litWithout = unbloomed.count((r, g, b, a) => r > 20);
        final litWith = bloomed.count((r, g, b, a) => r > 20);
        expect(litWith, greaterThan(litWithout + 30));
      },
    );
  });
}
