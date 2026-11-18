import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart' show RectangleComponent, World;
import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/debug.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart'
    show GlobalKey, ObjectKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

Scene3DProjection _isoProj() => Scene3DProjection.affine(
  origin: Vector2(64, 64),
  xAxis: Vector2(20, 10),
  yAxis: Vector2(-20, 10),
  zAxis: Vector2(0, -22),
  towardsViewer: Vector3(1, 1, 1),
  near: -40,
  far: 40,
);

Future<Pixels> _pumpLayer(
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

  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: GameWidget(key: ObjectKey(game), game: game),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = boundary.toImageSync();
  addTearDown(image.dispose);
  late final ByteData? bytes;
  await tester.runAsync(() async {
    bytes = await image.toByteData();
  });
  return Pixels(image.width, image.height, bytes!.buffer.asUint8List());
}

int _countNonBackdrop(Pixels px, Color bg) {
  final r0 = (bg.r * 255).round();
  final g0 = (bg.g * 255).round();
  final b0 = (bg.b * 255).round();
  return px.count(
    (r, g, b, _) =>
        (r - r0).abs() > 6 || (g - g0).abs() > 6 || (b - b0).abs() > 6,
  );
}

void main() {
  setUpGpu();

  testGpu(
    'DepthNormalPrepass drives SSAO, 3D DoF, Soft Particles, and Shore Water',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(128, 128));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final world = World3D(
        depthPrepassEnabled: true,
        postProcess: PostProcessSettings(
          toneMap: ToneMapMode.acesFilmic,
          ssaoIntensity: 0.75,
          ssaoRadius: 1.8,
          dofFocusDepth: 0.48,
          dofFocusRange: 0.12,
          dofBlurStrength: 0.65,
        ),
      );

      final probe = EnvironmentProbe3D.skyDome(width: 32, height: 16);
      final floorMat = SpatialMaterial(
        albedoColor: const Color(0xFFE2E8F0),
        roughness: 0.5,
        metallic: 0.1,
        environmentProbe: probe,
      );
      world.addAll([
        LightComponent.hemisphere(intensity: 0.6),
        LightComponent.directional(
          direction: Vector3(-0.4, -0.5, -0.9),
          intensity: 2.8,
        ),
        MeshComponent(
          mesh: CuboidMesh(size: Vector3(5.0, 5.0, 0.3), material: floorMat),
          position: Vector3(0, 0, -0.15),
        ),
        MeshComponent(
          mesh: CuboidMesh(size: Vector3(1.1, 1.1, 2.0), material: floorMat),
          position: Vector3(-0.4, -0.4, 1.0),
        ),
        MeshComponent(
          mesh: TerrainMesh3D(
            columns: 12,
            rows: 12,
            width: 4.2,
            depth: 4.2,
            upAxis: TerrainUpAxis.z,
            heights: Float32List(144),
            material: WaterMaterial(
              upAxis: Vector3(0, 0, 1),
              shoreFoamDepth: 0.08,
            ),
          ),
          position: Vector3(0, 0, 0.25),
          castsShadows: false,
        ),
      ]);

      final softSmoke = ParticleSystem3D(
        capacity: 24,
        material: ParticleMaterial(
          sprite: ParticleSprite.softBlob,
          color: const Color(0xCC94A3B8),
          softDepthFade: 0.12,
        ),
        emitters: [
          ParticleEmitter3D(
            bursts: const [EmitterBurst(0, 16)],
            lifespan: (2.0, 3.0),
            speed: (0.05, 0.15),
            size: (0.7, 1.0),
          ),
        ],
      )..position.setValues(0.4, 0.4, 0.35);
      world.add(softSmoke);

      final layer = Scene3DComponent(projection: _isoProj(), world: world);
      final px = await _pumpLayer(tester, layer);
      expect(_countNonBackdrop(px, const Color(0xFF0B101B)), greaterThan(600));
      // 1 depth-normal prepass + 1 scene pass + 1 post-process composite pass.
      expect(layer.renderStats.renderPasses, 3);
    },
  );

  testGpu(
    '2-Cascade CSM shadow atlas and perspective SpotLight shadows render',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(128, 128));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Part A: 2-Cascade Directional Shadow Atlas (`cascades: 2`).
      final csmWorld = World3D();
      final mat = StylizedMaterial(albedoColor: const Color(0xFFF1F5F9));
      csmWorld.addAll([
        LightComponent.hemisphere(intensity: 0.35),
        LightComponent.directional(
          direction: Vector3(-0.45, -0.35, -0.82),
          intensity: 1.4,
          shadows: ShadowSettings(
            resolution: 512,
            cascades: 2,
            cascadeSplitRatio: 0.35,
          ),
        ),
        MeshComponent(
          mesh: CuboidMesh(size: Vector3(6.0, 6.0, 0.2), material: mat),
          position: Vector3(0, 0, -0.1),
        ),
        MeshComponent(
          mesh: CuboidMesh(size: Vector3(0.9, 0.9, 2.2), material: mat),
          position: Vector3(0.4, 0.4, 1.1),
        ),
      ]);
      final csmLayer = Scene3DComponent(
        projection: _isoProj(),
        world: csmWorld,
      );
      final csmPx = await _pumpLayer(tester, csmLayer);
      expect(
        _countNonBackdrop(csmPx, const Color(0xFF0B101B)),
        greaterThan(500),
      );
      expect(csmLayer.renderStats.shadowPasses, 2);

      // Part B: Perspective `SpotLight(shadows: ShadowSettings(...))`.
      final spotWorld = World3D();
      final pbrMat = SpatialMaterial(
        albedoColor: const Color(0xFFE2E8F0),
        roughness: 0.65,
        metallic: 0.05,
      );
      spotWorld.addAll([
        LightComponent.ambient(intensity: 0.12),
        LightComponent.spot(
          position: Vector3(2.2, 2.2, 3.6),
          direction: Vector3(-0.5, -0.5, -0.85),
          intensity: 18.0,
          range: 14.0,
          innerConeAngle: math.pi / 9,
          outerConeAngle: math.pi / 3.2,
          shadows: ShadowSettings(resolution: 512),
        ),
        MeshComponent(
          mesh: CuboidMesh(size: Vector3(5.5, 5.5, 0.2), material: pbrMat),
          position: Vector3(0, 0, -0.1),
        ),
        MeshComponent(
          mesh: SphereMesh(radius: 0.65, segments: 12, material: pbrMat),
          position: Vector3(0.3, 0.3, 0.8),
        ),
      ]);
      final spotLayer = Scene3DComponent(
        projection: _isoProj(),
        world: spotWorld,
      );
      final spotPx = await _pumpLayer(tester, spotLayer);
      expect(
        _countNonBackdrop(spotPx, const Color(0xFF0B101B)),
        greaterThan(450),
      );
      expect(spotLayer.renderStats.shadowPasses, 1);
    },
  );

  testGpu(
    'RenderTexture3D portal, cameraMask/lightMask, warmupMaterial & Debug3D',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(128, 128));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final portal = RenderTexture3D(
        width: 128,
        height: 128,
        clearValue: const Color(0xFF1D4ED8),
      );
      addTearDown(portal.dispose);

      final world = World3D();
      final portalScreenMat = UnlitMaterial(
        albedoTexture: portal.texture,
      )..renderState = RenderState.opaque;

      final modelNode0 = ModelNode(
        name: 'Hip',
        nodeIndex: 0,
        parentNodeIndex: null,
        transform: Matrix4.identity(),
        mesh: CuboidMesh(
          size: Vector3.all(0.5),
          material: StylizedMaterial(albedoColor: const Color(0xFFF59E0B)),
        ),
        joints: const {},
      );
      final modelNode1 = ModelNode(
        name: 'Chest',
        nodeIndex: 1,
        parentNodeIndex: 0,
        transform: Matrix4.translationValues(0, 0, 0.9),
        mesh: null,
        joints: const {},
      );

      final debug3d = DebugRenderer3D(xray: true)
        ..drawAxes(Matrix4.identity(), size: 1.2);

      // Hidden object on mask bit `0x02` (not visible to cameraMask `0x01`).
      final hiddenOnlyMask2 = MeshComponent(
        mesh: CuboidMesh(
          size: Vector3.all(3.0),
          material: UnlitMaterial(albedoColor: const Color(0xFFEF4444))
            ..renderState = RenderState.opaque,
        ),
        cameraMask: 0x02,
      );

      world.addAll([
        LightComponent.ambient(intensity: 0.5, lightMask: 0x01),
        LightComponent.spot(
          position: Vector3(0, 0, 3),
          direction: Vector3(0, 0, -1),
          range: 4.0,
          intensity: 4.0,
          lightMask: 0x01,
        ),
        ModelComponent(
          model: Model(
            nodes: {0: modelNode0, 1: modelNode1},
            animations: const [],
          ),
        )..cameraMask = 0x01,
        MeshComponent(
          mesh: CuboidMesh(
            size: Vector3(2.2, 0.2, 1.8),
            material: portalScreenMat,
          ),
          position: Vector3(-1.0, 0.8, 0.9),
          cameraMask: 0x01,
        ),
        hiddenOnlyMask2,
        debug3d,
      ]);

      final layer = Scene3DComponent(
        projection: _isoProj(),
        world: world,
        cameraMask: 0x01,
      );

      // Render first frame to initialize layer device, then capture portal &
      // warmup a material pipeline!
      await _pumpLayer(tester, layer);

      final view = Matrix4.identity()
        ..setAsViewMatrix(
          Vector3(4, 4, 3),
          Vector3.zero(),
          Vector3(0, 0, 1),
        );
      final proj = Matrix4.identity()..setAsPerspective(55, 1.0, 0.1, 30.0);
      final ok = portal.renderWorld(
        world,
        view: view,
        projection: proj,
        cameraMask: 0x01,
      );
      expect(ok, isTrue);
      expect(portal.renderCount, 1);

      final device = layer.device;
      device.warmupMaterial(SpatialMaterial());
      expect(device.cachedPipelineCount, greaterThan(0));
      expect(device.estimatedTargetVramBytes, greaterThan(0));

      final px = await _pumpLayer(tester, layer);
      expect(_countNonBackdrop(px, const Color(0xFF0B101B)), greaterThan(200));
      expect(debug3d.lastSegmentCount, greaterThan(20));
    },
  );
}
