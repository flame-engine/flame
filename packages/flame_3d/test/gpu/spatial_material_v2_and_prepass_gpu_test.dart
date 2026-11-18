import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart' show RectangleComponent, World;
import 'package:flame/game.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart'
    show GlobalKey, ObjectKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

Scene3DProjection _orthoFront() => Scene3DProjection.affine(
  origin: Vector2(64, 64),
  xAxis: Vector2(36, 0),
  yAxis: Vector2(0, -36),
  zAxis: Vector2.zero(),
  towardsViewer: Vector3(0, 0, 1),
  near: -40,
  far: 40,
);

Future<Pixels> _pumpScene(
  WidgetTester tester,
  Scene3DComponent layer, {
  Color backdrop = const Color(0xFF0A0E17),
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

Surface _xyQuad(Material material, {double z = 0, double halfSize = 0.85}) {
  final s = halfSize;
  return Surface.fromBuffers(
    vertices: Float32List.fromList([
      -s, -s, z, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, //
      s, -s, z, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, //
      s, s, z, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, //
      -s, s, z, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, //
    ]),
    indices: Uint16List.fromList(const [0, 1, 2, 0, 2, 3]),
    material: material,
  );
}

Texture _solidTexture(int r, int g, int b, [int a = 255]) {
  final px = Uint8List(4 * 4 * 4);
  for (var i = 0; i < px.length; i += 4) {
    px[i] = r;
    px[i + 1] = g;
    px[i + 2] = b;
    px[i + 3] = a;
  }
  return Texture(ByteData.sublistView(px), width: 4, height: 4);
}

void main() {
  setUpGpu();

  group('SpatialMaterial maps, SpotLight GPU & single-piece prepass', () {
    testGpu(
      'SpatialMaterial receives SpotLight cone, directional shadows '
      'and FogSettings',
      (tester) async {
        final pbrMat = SpatialMaterial(
          metallic: 0.1,
          roughness: 0.7,
        );

        final spotLayer = Scene3DComponent(projection: _orthoFront());
        spotLayer.world.addAll([
          LightComponent.ambient(intensity: 0.02),
          LightComponent.spot(
            position: Vector3(0, 0, 2.0),
            direction: Vector3(0, 0, -1),
            color: const Color(0xFF00FF66),
            intensity: 10.0,
            innerConeAngle: 0.08,
            outerConeAngle: 0.28,
          ),
          MeshComponent(
            mesh: Mesh()..addSurface(_xyQuad(pbrMat, halfSize: 1.4)),
          ),
        ]);
        final spotPx = await _pumpScene(tester, spotLayer);
        final centerSpot = spotPx.at(64, 64);
        final edgeSpot = spotPx.at(25, 25);
        expect(centerSpot.$2, greaterThan(edgeSpot.$2 + 60));

        // Slanted directional PCF shadow darkens shadowed side of PBR quad!
        final slantedLayer = Scene3DComponent(projection: _orthoFront());
        slantedLayer.world.addAll([
          LightComponent.ambient(intensity: 0.08),
          LightComponent.directional(
            direction: Vector3(-0.8, 0, -1.0),
            intensity: 2.8,
            shadows: ShadowSettings(resolution: 256),
          ),
          MeshComponent(
            mesh: Mesh()..addSurface(_xyQuad(pbrMat, halfSize: 1.5)),
          ),
          MeshComponent(
            mesh: CuboidMesh(
              size: Vector3(0.45, 1.2, 0.5),
              material: SpatialMaterial(albedoColor: const Color(0xFF222222)),
            ),
            position: Vector3(0.6, 0, 0.8),
          ),
        ]);
        final shPx = await _pumpScene(tester, slantedLayer);
        final shadowed = shPx.at(58, 64);
        final sunlit = shPx.at(28, 64);
        expect(sunlit.$1, greaterThan(shadowed.$1 + 35));

        // FogSettings blends SpatialMaterial towards fog color!
        final fogLayer = Scene3DComponent(projection: _orthoFront());
        fogLayer.world
          ..fog = FogSettings(
            color: const Color(0xFFFF00AA),
            end: 1.0,
          )
          ..addAll([
            LightComponent.ambient(),
            MeshComponent(
              mesh: Mesh()..addSurface(_xyQuad(pbrMat, z: -5.0, halfSize: 1.2)),
            ),
          ]);
        final fogPx = await _pumpScene(tester, fogLayer);
        final fc = fogPx.at(64, 64);
        expect(fc.$1, greaterThan(150));
        expect(fc.$2, lessThan(60));
      },
    );

    testGpu(
      'SpatialMaterial normal/ORM/emissive/env maps & ditherFade '
      'change shaded pixels',
      (tester) async {
        final tiltedNormalMap = _solidTexture(242, 128, 165);
        final flatMat = SpatialMaterial(
          albedoColor: const Color(0xFFCCCCCC),
          metallic: 0.0,
          roughness: 0.5,
        );
        final normalMappedMat = SpatialMaterial(
          albedoColor: const Color(0xFFCCCCCC),
          metallic: 0.0,
          roughness: 0.5,
          normalTexture: tiltedNormalMap,
          normalScale: 1.5,
        );

        Scene3DComponent buildLit(Material m) {
          final l = Scene3DComponent(projection: _orthoFront());
          l.world.addAll([
            LightComponent.ambient(intensity: 0.02),
            LightComponent.directional(
              direction: Vector3(-1.0, 0.0, -0.1),
              intensity: 3.0,
            ),
            MeshComponent(mesh: Mesh()..addSurface(_xyQuad(m))),
          ]);
          return l;
        }

        final flatPx = await _pumpScene(tester, buildLit(flatMat));
        final normPx = await _pumpScene(tester, buildLit(normalMappedMat));
        expect(
          (normPx.at(64, 64).$1 - flatPx.at(64, 64).$1).abs(),
          greaterThan(35),
        );

        final envTex = _solidTexture(20, 220, 255);
        final envMat = SpatialMaterial(
          metallic: 1.0,
          roughness: 0.08,
          environmentTexture: envTex,
          environmentIntensity: 1.5,
          emissiveColor: const Color(0xFFFF2000),
          emissiveStrength: 0.5,
        );
        final envLayer = Scene3DComponent(projection: _orthoFront());
        envLayer.world.addAll([
          LightComponent.ambient(intensity: 0.0),
          MeshComponent(mesh: Mesh()..addSurface(_xyQuad(envMat))),
        ]);
        final envPx = await _pumpScene(tester, envLayer);
        final ec = envPx.at(64, 64);
        expect(ec.$1, greaterThan(80));
        expect(ec.$3, greaterThan(120));

        final ditherMat = SpatialMaterial(
          albedoColor: const Color(0xFF00FF44),
          ditherFade: true,
        );
        final ditherLayer = Scene3DComponent(projection: _orthoFront());
        ditherLayer.world.addAll([
          LightComponent.ambient(intensity: 2.0),
          MeshComponent(
            mesh: Mesh()..addSurface(_xyQuad(ditherMat, halfSize: 1.2)),
            instanceData: Vector4(0, 0, 0, 0.5),
          ),
        ]);
        final ditherPx = await _pumpScene(
          tester,
          ditherLayer,
          backdrop: const Color(0xFF000000),
        );
        var litCount = 0;
        var bgCount = 0;
        for (var y = 48; y < 80; y++) {
          for (var x = 48; x < 80; x++) {
            if (ditherPx.at(x, y).$2 > 60) {
              litCount++;
            } else {
              bgCount++;
            }
          }
        }
        expect(litCount, greaterThan(350));
        expect(bgCount, greaterThan(350));
      },
    );

    testGpu(
      'singlePieceTranslucent eliminates internal overlap seams on '
      'both multi-surface MeshComponent and multi-node ModelComponent',
      (tester) async {
        Mesh buildFrontRedRearBlue({required bool singlePiece}) {
          final redMat = StylizedMaterial(
            albedoColor: const Color(0xFFFF0000),
            ambientBase: const Color(0xFFFFFFFF),
            rimStrength: 0,
            specularStrength: 0,
            translucent: true,
            singlePieceTranslucent: singlePiece,
          );
          final blueMat = StylizedMaterial(
            albedoColor: const Color(0xFF0000FF),
            ambientBase: const Color(0xFFFFFFFF),
            rimStrength: 0,
            specularStrength: 0,
            translucent: true,
            singlePieceTranslucent: singlePiece,
          );
          return Mesh()
            ..addSurface(_xyQuad(blueMat, z: -1.0))
            ..addSurface(_xyQuad(redMat, z: 1.0));
        }

        Scene3DComponent meshScene({required bool singlePiece}) {
          final l = Scene3DComponent(projection: _orthoFront());
          l.world.addAll([
            LightComponent.ambient(intensity: 1.0),
            MeshComponent(
              mesh: buildFrontRedRearBlue(singlePiece: singlePiece),
              instanceData: Vector4(0, 0, 0, 0.45),
            ),
          ]);
          return l;
        }

        final naiveMeshPx = await _pumpScene(
          tester,
          meshScene(singlePiece: false),
          backdrop: const Color(0xFF000000),
        );
        final prepassMeshPx = await _pumpScene(
          tester,
          meshScene(singlePiece: true),
          backdrop: const Color(0xFF000000),
        );

        expect(naiveMeshPx.at(64, 64).$3, greaterThan(40));
        expect(prepassMeshPx.at(64, 64).$3, lessThanOrEqualTo(3));
        expect(prepassMeshPx.at(64, 64).$1, greaterThan(100));

        final nodeBlueMat = StylizedMaterial(
          albedoColor: const Color(0xFF0000FF),
          ambientBase: const Color(0xFFFFFFFF),
          rimStrength: 0,
          specularStrength: 0,
          translucent: true,
          singlePieceTranslucent: true,
        );
        final nodeRedMat = StylizedMaterial(
          albedoColor: const Color(0xFFFF0000),
          ambientBase: const Color(0xFFFFFFFF),
          rimStrength: 0,
          specularStrength: 0,
          translucent: true,
          singlePieceTranslucent: true,
        );
        final multiNodeModel = Model(
          nodes: {
            0: ModelNode(
              name: 'RearBlue',
              nodeIndex: 0,
              parentNodeIndex: null,
              transform: Matrix4.translationValues(0, 0, -1.0),
              mesh: Mesh()..addSurface(_xyQuad(nodeBlueMat)),
              joints: const {},
            ),
            1: ModelNode(
              name: 'FrontRed',
              nodeIndex: 1,
              parentNodeIndex: null,
              transform: Matrix4.translationValues(0, 0, 1.0),
              mesh: Mesh()..addSurface(_xyQuad(nodeRedMat)),
              joints: const {},
            ),
          },
          animations: const [],
        );
        final modelLayer = Scene3DComponent(projection: _orthoFront());
        modelLayer.world.addAll([
          LightComponent.ambient(intensity: 1.0),
          ModelComponent(
            model: multiNodeModel,
            instanceData: Vector4(0, 0, 0, 0.45),
          ),
        ]);
        final modelPx = await _pumpScene(
          tester,
          modelLayer,
          backdrop: const Color(0xFF000000),
        );
        expect(modelPx.at(64, 64).$3, lessThanOrEqualTo(3));
        expect(modelPx.at(64, 64).$1, greaterThan(100));
      },
    );
  });
}
