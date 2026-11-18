import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart' show RectangleComponent, World;
import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart'
    show GlobalKey, ObjectKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

Scene3DProjection _isoProj() => Scene3DProjection.affine(
  origin: Vector2(64, 64),
  xAxis: Vector2(22, 10),
  yAxis: Vector2(-22, 10),
  zAxis: Vector2(0, -24),
  towardsViewer: Vector3(1, 1, 1),
  near: -40,
  far: 40,
);

Future<Pixels> _pump2D(
  WidgetTester tester,
  Scene3DComponent layer, {
  Color backdrop = const Color(0xFF0B101B),
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
      child: GameWidget(key: ObjectKey(game), game: game),
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

void main() {
  setUpGpu();

  group('Geometry, Water, Skybox, Billboards, Text3D & PostProcess', () {
    test(
      'CapsuleMesh, TorusMesh, TubeSplineMesh & TerrainMesh3D generate '
      'valid normals, AABBs, height queries, and 32-bit indices',
      () {
        final capsule = CapsuleMesh(radius: 0.5, height: 2.0);
        expect(capsule.aabb.min.y, closeTo(-1.0, 1e-3));
        expect(capsule.aabb.max.y, closeTo(1.0, 1e-3));

        final torus = TorusMesh(majorRadius: 1.0, minorRadius: 0.25);
        expect(torus.aabb.max.x, closeTo(1.25, 1e-2));
        expect(torus.aabb.max.y, closeTo(0.25, 1e-2));

        final spline = CatmullRomSpline3D([
          Vector3(-2, 0, 0),
          Vector3(0, 1, 0),
          Vector3(2, 0, 0),
        ]);
        expect(spline.samplePoint(0.0).x, closeTo(-2.0, 1e-5));
        expect(spline.samplePoint(1.0).x, closeTo(2.0, 1e-5));
        expect(spline.sampleTangent(0.5).length, closeTo(1.0, 1e-5));

        final tube = TubeSplineMesh(spline: spline, radius: 0.2);
        expect(tube.surfaces.single.vertexCount, greaterThan(50));

        final terrain = TerrainMesh3D.procedural(
          columns: 32,
          rows: 32,
          width: 10,
          depth: 10,
          amplitude: 1.5,
          upAxis: TerrainUpAxis.z,
        );
        final centerH = terrain.sampleHeight(0, 0);
        expect(centerH, greaterThan(0.0));
        final n = terrain.sampleNormal(0, 0);
        expect(n.length, closeTo(1.0, 1e-5));
        expect(n.z, greaterThan(0.2));

        final largeTerrain = TerrainMesh3D(
          columns: 260,
          rows: 260,
          width: 20,
          depth: 20,
          heights: Float32List(260 * 260),
        );
        expect(largeTerrain.surfaces.single.vertexCount, 67600);
        expect(largeTerrain.surfaces.single.indexType, GpuIndexType.uint32);
      },
    );

    testGpu(
      'WaterMaterial animates Gerstner waves & DecalBatch3D.addBlobShadow '
      'renders soft contact shadow',
      (tester) async {
        final waterMat = WaterMaterial(
          upAxis: Vector3(0, 0, 1),
          waveAmplitude: 0.22,
          waveFrequency: 2.2,
          opacity: 0.92,
        );
        final waterGrid = TerrainMesh3D(
          columns: 24,
          rows: 24,
          width: 5.0,
          depth: 5.0,
          upAxis: TerrainUpAxis.z,
          heights: Float32List(24 * 24),
          material: waterMat,
        );

        final layer = Scene3DComponent(projection: _isoProj());
        layer.world.addAll([
          LightComponent.hemisphere(
            up: Vector3(0, 0, 1),
            intensity: 0.8,
          ),
          LightComponent.directional(
            direction: Vector3(-0.5, -0.5, -0.8),
            intensity: 1.4,
          ),
          MeshComponent(mesh: waterGrid),
        ]);

        final pxT0 = await _pump2D(tester, layer);
        waterMat.time = 1.35;
        final pxT1 = await _pump2D(tester, layer);
        expect(differingPixels(pxT0, pxT1, tolerance: 3), greaterThan(150));

        final floorLayer = Scene3DComponent(projection: _isoProj());
        final decals = DecalBatch3D(material: DecalMaterial())
          ..addBlobShadow(
            groundPoint: Vector3.zero(),
            radius: 0.6,
            elevation: 0.2,
            baseOpacity: 0.8,
            normal: Vector3(0, 0, 1),
          );
        floorLayer.world.addAll([
          MeshComponent(
            mesh: CuboidMesh(
              size: Vector3(5, 5, 0.1),
              material: UnlitMaterial(albedoColor: const Color(0xFFE2E8F0)),
            ),
            position: Vector3(0, 0, -0.05),
          ),
          decals,
        ]);
        final blobPx = await _pump2D(tester, floorLayer);
        final underBlob = blobPx.at(64, 64);
        final outsideBlob = blobPx.at(28, 64);
        expect(outsideBlob.$1, greaterThan(underBlob.$1 + 40));
      },
    );

    testGpu(
      'SkyboxComponent3D, BillboardBatch3D & Text3DComponent render '
      'with accurate depth occlusion',
      (tester) async {
        final skyGame = FlameGame3D(
          world: World3D(
            children: [
              SkyboxComponent3D(
                material: SkyboxMaterial3D(
                  zenithColor: const Color(0xFF0A2463),
                  horizonColor: const Color(0xFF3E92CC),
                  sunDirection: Vector3(0, -0.3, 1.0),
                ),
              ),
              MeshComponent(
                mesh: SphereMesh(
                  radius: 0.6,
                  material: UnlitMaterial(albedoColor: const Color(0xFFFF2020)),
                ),
                position: Vector3(0, 0, -3.0),
              ),
            ],
          ),
          camera: CameraComponent3D(
            position: Vector3(0, 0, 1),
            target: Vector3(0, 0, -3),
          ),
        );
        final skyPx = await renderGame(tester, skyGame);
        expect(skyPx.at(64, 64).$1, greaterThan(200));
        expect(skyPx.at(64, 64).$3, lessThan(50));
        expect(skyPx.at(8, 8).$3, greaterThan(80));
        expect(skyPx.at(8, 8).$4, 255);

        final spriteTexPx = Uint8List(8 * 8 * 4);
        for (var i = 0; i < spriteTexPx.length; i += 4) {
          spriteTexPx[i] = 0;
          spriteTexPx[i + 1] = 255;
          spriteTexPx[i + 2] = 100;
          spriteTexPx[i + 3] = 255;
        }
        final spriteTex = Texture(
          ByteData.sublistView(spriteTexPx),
          width: 8,
          height: 8,
        );
        final billboards =
            BillboardBatch3D(
              material: BillboardMaterial3D(
                albedoTexture: spriteTex,
                shadeWeight: 0.0,
              ),
            )..addBillboard(
              position: Vector3(-0.8, 0.8, 0.4),
              width: 0.9,
              height: 1.1,
              upAxis: Vector3(0, 0, 1),
            );

        final textBehindWall = Text3DComponent(
          text: 'HIDDEN',
          worldHeight: 0.9,
          backgroundColor: const Color(0xFF00FF44),
          upAxis: Vector3(0, 0, 1),
          position: Vector3(0.8, -0.8, -1.5),
        );
        final occludingWall = MeshComponent(
          mesh: CuboidMesh(
            size: Vector3(1.6, 1.6, 1.6),
            material: UnlitMaterial(albedoColor: const Color(0xFFFF1050)),
          ),
          position: Vector3(0.5, -0.5, 0.4),
        );

        final bbLayer = Scene3DComponent(projection: _isoProj());
        bbLayer.world.addAll([billboards, textBehindWall, occludingWall]);
        final bbPx = await _pump2D(tester, bbLayer);
        expect(
          bbPx.count((r, g, b, a) => g > 180 && r < 40),
          greaterThan(30),
        );
        expect(
          bbPx.count((r, g, b, a) => r > 220 && g < 40),
          greaterThan(80),
        );
      },
    );

    testGpu(
      'PostProcessSettings applies ACES/AgX tone-mapping, exposure, '
      'vignette & FXAA standalone and fused with BloomSettings',
      (tester) async {
        Scene3DComponent buildPostScene({
          PostProcessSettings? post,
          BloomSettings? bloom,
        }) {
          final l = Scene3DComponent(
            projection: _isoProj(),
            postProcess: post,
            bloom: bloom,
          );
          l.world.add(
            MeshComponent(
              mesh: CuboidMesh(
                size: Vector3(8, 8, 0.2),
                material: UnlitMaterial(albedoColor: const Color(0xFFE0E0E0)),
              ),
            ),
          );
          return l;
        }

        final rawPx = await _pump2D(tester, buildPostScene());
        final vignettePx = await _pump2D(
          tester,
          buildPostScene(
            post: PostProcessSettings(
              toneMap: ToneMapMode.acesFilmic,
              exposure: 1.1,
              vignetteIntensity: 0.95,
              fxaa: true,
            ),
          ),
        );
        expect(vignettePx.at(64, 64).$1, greaterThan(150));
        expect(
          vignettePx.at(4, 4).$1,
          lessThan(rawPx.at(64, 64).$1 - 80),
        );

        final fusedPx = await _pump2D(
          tester,
          buildPostScene(
            bloom: BloomSettings(threshold: 0.5, intensity: 0.8),
            post: PostProcessSettings(
              toneMap: ToneMapMode.agx,
              exposure: 1.25,
              saturation: 1.2,
              fxaa: true,
            ),
          ),
        );
        expect(fusedPx.at(64, 64).$1, greaterThan(160));
      },
    );
  });
}
