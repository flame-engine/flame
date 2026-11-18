import 'dart:async' show unawaited;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/debug.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/houses/board_grid.dart';
import 'package:flame_3d_example/showcase/showcase_meshes.dart';
import 'package:flame_3d_example/showcase/showcase_variations.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

/// Interactive feature flags and live telemetry state of [ShowcaseGame].
class ShowcaseController() extends ChangeNotifier {
  ShowcasePreset preset = ShowcasePreset.allInOne;

  bool retainedStaticLayer = true;
  bool staticShadowCache = true;
  bool sharedShadowGroup = false;
  bool bloom = true;
  bool fog = true;
  bool outlines = true;
  bool wind = false;
  bool particles = true;
  bool ribbonsAndDecals = true;
  bool msaa4x = true;
  bool autoOrbitCamera = false;
  bool stressInstances = false;
  bool spatialIndex3D = true;
  bool prioritizeNearestLights = true;
  bool fxaa = false;
  bool vignette = false;
  bool ssao = false;
  bool dof = false;
  bool csm2Cascades = false;
  bool debug3D = false;

  ToneMapMode toneMap = ToneMapMode.none;
  ShadowMapEncoding shadowEncoding = ShadowMapEncoding.auto;
  ShadowFit shadowFit = ShadowFit.scene;
  int shadowSoftness = 1;
  double renderScale = 1.0;
  AnimationPlayMode playMode = AnimationPlayMode.loop;
  double animSpeed = 1.0;

  String activeClip = 'Idle';
  String lastHitSummary = 'Tap any 3D object to raycast its triangle BVH';
  ui.Image? snapshotImage;

  double fps = 60;
  double frameMsP50 = 16.6;
  double frameMsP95 = 16.6;

  void notifyChanged() => notifyListeners();

  @override
  void dispose() {
    snapshotImage?.dispose();
    snapshotImage = null;
    super.dispose();
  }
}

/// Comprehensive `flame_3d` testbed exercising all major engine subsystems in
/// two layered [Scene3DComponent]s over a 2D world:
///
/// - `staticLayer`: [Scene3DCacheMode.retained] +
///   [ShadowSettings.cacheWhenStatic], [ShadowCatcherMaterial] on 2D ground,
///   [InstancedGroup3D] with 16-color [StylizedMaterial.accentPalette],
///   [LodMeshComponent] towers, `WindSpace.worldScaled` foliage, two-tier
///   metallic/gem MatCaps, PBR [SpatialMaterial] maps, [TerrainMesh3D], and
///   [TubeSplineMesh];
/// - `dynamicLayer`: [BloomSettings] + fused [PostProcessSettings] (ACES/AgX,
///   vignette, FXAA), [FogSettings], 64-bone skinning, morph targets, animation
///   layers, procedural IK/LookAt/SpringBone, [WaterMaterial],
///   [BillboardBatch3D], [Text3DComponent], [SpotLight]s + 32-lamp culling,
///   [SceneSpatialIndex3D], [OutlineMaterial], [DecalBatch3D], [StrokeBatch3D],
///   [RibbonTrail3D], and [ParticleSystem3D];
/// - Interactive `Surface.bvh` + `SceneSpatialIndex3D` raycasting on tap and
///   offscreen `World3D.renderToImage` thumbnail snapshots.
class ShowcaseGame({ShowcaseController? controller})
    extends FlameGame
    with TapCallbacks, DragCallbacks, ScrollCallbacks, ScaleCallbacks {
  /// Controller driving feature toggles and HUD readouts.
  final ShowcaseController controller = controller ?? ShowcaseController();

  static const int boardCells = 14;
  static const double minZoom = 0.35;
  static const double maxZoom = 2.6;

  /// Dimetric board projection (cells of `88x44` logical px, `+Z` up).
  static final Scene3DProjection projection = Scene3DProjection.affine(
    origin: Vector2(0, -18),
    xAxis: Vector2(44, 22),
    yAxis: Vector2(-44, 22),
    zAxis: Vector2(0, -53.889),
    towardsViewer: Vector3(0.6124, 0.6124, 0.5),
    near: -45,
    far: 45,
  );

  static const List<String> animationClips = ['Idle', 'Swing', 'Spin'];

  final ShowcaseAssets showcaseAssets = ShowcaseAssets();
  late final ShowcaseVariationRig variationRig = ShowcaseVariationRig(
    assets: showcaseAssets,
  );
  final ShadowGroup shadowGroup = ShadowGroup();

  late final Scene3DComponent staticLayer;
  late final Scene3DComponent dynamicLayer;

  late final StylizedMaterial tileMaterial;
  late final StylizedMaterial windTreeMaterial;
  late final StylizedMaterial crystalMaterial;
  late final StylizedMaterial metalPedestalMaterial;
  late final StylizedMaterial automatonMaterial;
  late final OutlineMaterial staticOutlineMaterial;
  late final OutlineMaterial skinnedOutlineMaterial;

  late final InstancedGroup3D tileInstances;
  final List<LodMeshComponent> lodTowers = [];
  final List<MeshComponent> windTrees = [];

  late final ModelComponent automaton;
  late final ModelComponent automatonOutline;
  late final BoneSocket3D armTipSocket;
  late final LightComponent socketPointLight;
  late final RibbonTrail3D socketRibbon;

  late final MeshComponent orbitingSentinel;
  late final MeshComponent orbitingSentinelOutline;
  late final RibbonTrail3D sentinelRibbon;

  late final DecalBatch3D ringDecals;
  late final DecalBatch3D atlasDecals;
  late final StrokeBatch3D energyStrokes;

  late final ParticleSystem3D sparkParticles;
  late final ParticleSystem3D smokeParticles;
  late final ParticleSystem3D coinMeshParticles;

  late final ShadowSettings _staticShadows;
  late final ShadowSettings _dynamicShadows;
  late final FogSettings _fogSettings;
  late final BloomSettings _bloomSettings;
  late final PostProcessSettings _postProcessSettings;
  late final DebugRenderer3D globalDebugRenderer;

  final Matrix4 _portalView = Matrix4.identity();
  final Matrix4 _portalProj = Matrix4.identity();

  double _time = 0;
  double _burstTimer = 0;
  double _startZoom = 1.0;
  int _clipIndex = 0;
  int? _highlightedInstance;

  Vector3? _lastHitPoint;
  Vector3? _lastHitNormal;

  final List<double> _frameDurationsMs = List<double>.filled(90, 16.6);
  int _frameRingCursor = 0;
  int _frameSamples = 0;
  double _hudRefreshTimer = 0;

  @override
  ui.Color backgroundColor() => const ui.Color(0xFF101722);

  @override
  Future<void> onLoad() async {
    _staticShadows = ShadowSettings(
      fit: ShadowFit.scene,
      strength: 0.78,
      color: const ui.Color(0xFF1A2548),
      cacheWhenStatic: controller.staticShadowCache,
      bounds: Aabb3.minMax(
        Vector3(-2, -2, -1),
        Vector3(boardCells + 2.0, boardCells + 2.0, 5),
      ),
    );
    _dynamicShadows = ShadowSettings(
      fit: ShadowFit.scene,
      strength: 0.78,
      color: const ui.Color(0xFF1A2548),
      bounds: Aabb3.minMax(
        Vector3(-2, -2, -1),
        Vector3(boardCells + 2.0, boardCells + 2.0, 5),
      ),
    );
    _fogSettings = FogSettings(
      color: const ui.Color(0xFF283C5E),
      start: 28,
      end: 95,
      baseHeight: 0.15,
      heightFalloff: 0.9,
      up: Vector3(0, 0, 1),
    );
    _bloomSettings = BloomSettings(
      threshold: 0.68,
      softKnee: 0.45,
      intensity: 0.85,
      radius: 1.5,
    );
    _postProcessSettings = PostProcessSettings();

    staticLayer = Scene3DComponent(
      projection: projection,
      msaa: controller.msaa4x ? Msaa.sample4 : Msaa.off,
      cacheMode: controller.retainedStaticLayer
          ? Scene3DCacheMode.retained
          : Scene3DCacheMode.none,
      priority: 1,
    );
    dynamicLayer = Scene3DComponent(
      projection: projection,
      msaa: controller.msaa4x ? Msaa.sample4 : Msaa.off,
      bloom: controller.bloom ? _bloomSettings : null,
      priority: 2,
    );

    world.addAll([
      BoardGrid(cells: boardCells, projection: projection),
      staticLayer,
      dynamicLayer,
    ]);

    _buildMaterials();
    _populateStaticLayer();
    _populateDynamicLayer();
    globalDebugRenderer = DebugRenderer3D(enabled: false);
    dynamicLayer.world.add(globalDebugRenderer);
    syncControllerState();

    camera.viewfinder.position = staticLayer.scenePointToLocal(
      Vector3(boardCells / 2, boardCells / 2, 0.5),
    );
  }

  void _buildMaterials() {
    tileMaterial = StylizedMaterial(
      accentPalette: ShowcaseAssets.accentPalette,
      matCapTexture: showcaseAssets.coatMatCap,
      matCapStrength: 0.45,
      matCapThreshold: 0.4,
      matCapGlossWeight: 0,
      gemMatCapTexture: showcaseAssets.gemMatCap,
      gemMatCapStrength: 0.85,
      gemThreshold: 1.3,
      emissiveColor: const ui.Color(0xFF90E8FF),
      emissiveBoostColor: const ui.Color(0xFFFFE066),
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    windTreeMaterial = StylizedMaterial(
      windSpace: WindSpace.worldScaled,
      windDirection: Vector3(1, 0.35, 0),
      windUpAxis: Vector3(0, 0, 1),
      windAmplitude: 0.055,
      windFrequency: 2.4,
      windPhase: Vector3(0.65, 0.45, 0),
      windFlutterAmplitude: 0.014,
      windFlutterFrequency: 11.5,
      windGustAmplitude: 0.45,
      windGustFrequency: 0.9,
      windGustDirection: Vector3(1, 0.35, 0),
      windGustPhaseScale: 0.45,
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    crystalMaterial = StylizedMaterial(
      matCapTexture: showcaseAssets.coatMatCap,
      matCapThreshold: 0.25,
      gemMatCapTexture: showcaseAssets.gemMatCap,
      emissiveColor: const ui.Color(0xFF5CE1E6),
      emissiveBoostColor: const ui.Color(0xFFFF70C8),
      emissiveStrength: 0.85,
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    metalPedestalMaterial = StylizedMaterial(
      matCapTexture: showcaseAssets.goldMatCap,
      matCapThreshold: -1,
      matCapGlossWeight: 0,
      matCapMetallic: 1.0,
      specularStrength: 0.15,
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    automatonMaterial = StylizedMaterial(
      matCapTexture: showcaseAssets.coatMatCap,
      matCapThreshold: 0.2,
      matCapStrength: 0.55,
      rimColor: const ui.Color(0xFF38BDF8),
      rimStrength: 0.28,
    );

    staticOutlineMaterial = OutlineMaterial(
      color: const ui.Color(0xFF00F5D4),
      thickness: 0.055,
      screenSpace: true,
    );
    skinnedOutlineMaterial = OutlineMaterial(
      color: const ui.Color(0xFFFFBE0B),
      thickness: 0.045,
      screenSpace: true,
    );
  }

  void _populateStaticLayer() {
    final upright = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);
    final sunDirection = Vector3(-0.48, -0.62, -0.92);

    staticLayer.world.addAll([
      LightComponent.hemisphere(
        skyColor: const ui.Color(0xFFB8D4F8),
        groundColor: const ui.Color(0xFF5D6B4D),
        intensity: 0.58,
        up: Vector3(0, 0, 1),
      ),
      LightComponent.directional(
        direction: sunDirection,
        color: const ui.Color(0xFFFFF4DC),
        intensity: 0.82,
        shadows: _staticShadows,
      ),
      MeshComponent(
        mesh: PlaneMesh(
          size: Vector2.all(boardCells + 2.0),
          material: ShadowCatcherMaterial(color: const ui.Color(0xA6141D38)),
        ),
        position: Vector3(boardCells / 2, boardCells / 2, 0),
        rotation: upright,
      ),
    ]);

    final tileMesh = showcaseAssets.buildAccentTileMesh(tileMaterial);
    tileInstances = InstancedGroup3D(mesh: tileMesh, initialCapacity: 2048);
    _rebuildTileInstances(mode: _desiredTileMode());
    staticLayer.world.add(tileInstances);

    final highCrystal = showcaseAssets.buildCrystalTowerLodMesh(
      crystalMaterial,
      segments: 20,
      crystalTint: const ui.Color(0xFF48CAE4),
    );
    final midCrystal = showcaseAssets.buildCrystalTowerLodMesh(
      crystalMaterial,
      segments: 10,
      crystalTint: const ui.Color(0xFF48CAE4),
    );
    final lowCrystal = showcaseAssets.buildCrystalTowerLodMesh(
      crystalMaterial,
      segments: 5,
      crystalTint: const ui.Color(0xFF48CAE4),
    );
    final shadowCrystal = showcaseAssets.buildCrystalTowerLodMesh(
      crystalMaterial,
      segments: 4,
      crystalTint: const ui.Color(0xFFFFFFFF),
    );

    const towerCoords = [
      (2.5, 2.5),
      (11.5, 2.5),
      (2.5, 11.5),
      (11.5, 11.5),
      (7.0, 1.8),
      (7.0, 12.2),
      (1.8, 7.0),
      (12.2, 7.0),
    ];
    for (final (tx, ty) in towerCoords) {
      final tower = LodMeshComponent(
        position: Vector3(tx, ty, 0),
        shadowMesh: shadowCrystal,
        levels: [
          MeshLodLevel(mesh: highCrystal, minScreenHeightRatio: 0.32),
          MeshLodLevel(mesh: midCrystal, minScreenHeightRatio: 0.1),
          MeshLodLevel(mesh: lowCrystal),
        ],
      );
      lodTowers.add(tower);
      staticLayer.world.add(tower);
    }

    final treeMesh = showcaseAssets.buildWindTreeMesh(windTreeMaterial);
    final rng = math.Random(42);
    for (var i = 0; i < 16; i++) {
      final angle = (i / 16) * math.pi * 2;
      final radius = 4.8 + (i.isEven ? 0.55 : -0.35);
      final heightScale = 0.8 + rng.nextDouble() * 0.55;
      final tree = MeshComponent(
        mesh: treeMesh,
        position: Vector3(
          boardCells / 2 + math.cos(angle) * radius,
          boardCells / 2 + math.sin(angle) * radius,
          0,
        ),
        scale: Vector3(
          0.9 + rng.nextDouble() * 0.25,
          0.9 + rng.nextDouble() * 0.25,
          heightScale,
        ),
        rotation: Quaternion.axisAngle(
          Vector3(0, 0, 1),
          rng.nextDouble() * math.pi * 2,
        ),
      );
      windTrees.add(tree);
      staticLayer.world.add(tree);
    }

    final goldSphere = SphereMesh(
      radius: 0.42,
      segments: 20,
      material: metalPedestalMaterial,
    );
    final pbrSphere = SphereMesh(
      radius: 0.42,
      segments: 20,
      material: SpatialMaterial(
        albedoColor: const ui.Color(0xFFE07A5F),
        metallic: 0.75,
        roughness: 0.25,
      )..renderState = const RenderState(cullMode: CullMode.backFace),
    );
    staticLayer.world.addAll([
      MeshComponent(
        mesh: goldSphere,
        position: Vector3(5.2, 5.2, 0.45),
        color: const ui.Color(0xFFFFD166),
      ),
      MeshComponent(
        mesh: pbrSphere,
        position: Vector3(8.8, 5.2, 0.45),
      ),
    ]);
  }

  int _desiredTileMode() {
    if (controller.preset == ShowcasePreset.extremeStress) {
      return 2048;
    }
    if (controller.stressInstances) {
      return 1024;
    }
    if (controller.preset == ShowcasePreset.allInOne ||
        controller.preset == ShowcasePreset.spotLightsCullingAndPost) {
      return 144;
    }
    return 44;
  }

  void _rebuildTileInstances({required int mode}) {
    tileInstances.clear();
    final m = Matrix4.identity();
    const paletteLen = 16;
    if (mode == 2048) {
      for (var ix = 0; ix < 64; ix++) {
        for (var iy = 0; iy < 32; iy++) {
          final cx = 0.35 + ix * (boardCells - 0.7) / 63;
          final cy = 0.35 + iy * (boardCells - 0.7) / 31;
          final zScale = 0.3 + 0.55 * ((ix * 5 + iy * 3) % 5) / 4;
          m
            ..setIdentity()
            ..setTranslationRaw(cx, cy, 0)
            ..scaleByDouble(0.22, 0.38, zScale, 1);
          final paletteIdx = (ix + iy) % paletteLen;
          tileInstances.addInstance(
            transform: m,
            color: const ui.Color(0xFFE2E8F0),
            instanceData: Vector4(
              (ix * iy) % 13 == 0 ? 0.65 : 0.0,
              0.0,
              0.0,
              StylizedMaterial.packAccentAndFade(paletteIdx),
            ),
          );
        }
      }
    } else if (mode == 1024) {
      for (var ix = 0; ix < 32; ix++) {
        for (var iy = 0; iy < 32; iy++) {
          final cx = 0.4 + ix * (boardCells - 0.8) / 31;
          final cy = 0.4 + iy * (boardCells - 0.8) / 31;
          final zScale = 0.35 + 0.55 * ((ix * 7 + iy * 3) % 5) / 4;
          m
            ..setIdentity()
            ..setTranslationRaw(cx, cy, 0)
            ..scaleByDouble(0.38, 0.38, zScale, 1);
          final paletteIdx = (ix + iy) % paletteLen;
          tileInstances.addInstance(
            transform: m,
            color: const ui.Color(0xFFE2E8F0),
            instanceData: Vector4(
              (ix * iy) % 11 == 0 ? 0.6 : 0.0,
              0.0,
              0.0,
              StylizedMaterial.packAccentAndFade(paletteIdx),
            ),
          );
        }
      }
    } else {
      final perimeterOnly = mode == 44;
      for (var ix = 0; ix < 12; ix++) {
        for (var iy = 0; iy < 12; iy++) {
          if (perimeterOnly && ix > 0 && ix < 11 && iy > 0 && iy < 11) {
            continue;
          }
          final cx = 1.5 + ix;
          final cy = 1.5 + iy;
          final dist = math.sqrt(
            (cx - boardCells / 2) * (cx - boardCells / 2) +
                (cy - boardCells / 2) * (cy - boardCells / 2),
          );
          final zScale = dist < 2.2 ? 0.28 : (0.45 + 0.35 * ((ix + iy) % 3));
          m
            ..setIdentity()
            ..setTranslationRaw(cx, cy, 0)
            ..scaleByDouble(0.85, 0.85, zScale, 1);
          final paletteIdx = (ix * 3 + iy * 5) % paletteLen;
          tileInstances.addInstance(
            transform: m,
            color: dist < 2.2
                ? const ui.Color(0xFFCBD5E1)
                : const ui.Color(0xFFE2E8F0),
            instanceData: Vector4(
              (ix + iy) % 7 == 0 ? 0.45 : 0.0,
              0.0,
              0.0,
              StylizedMaterial.packAccentAndFade(paletteIdx),
            ),
          );
        }
      }
    }
    _highlightedInstance = null;
  }

  void _populateDynamicLayer() {
    dynamicLayer.world.addAll([
      LightComponent.hemisphere(
        skyColor: const ui.Color(0xFFB8D4F8),
        groundColor: const ui.Color(0xFF5D6B4D),
        intensity: 0.58,
        up: Vector3(0, 0, 1),
      ),
      LightComponent.directional(
        direction: Vector3(-0.48, -0.62, -0.92),
        color: const ui.Color(0xFFFFF4DC),
        intensity: 0.82,
        shadows: _dynamicShadows,
      ),
    ]);

    final models = showcaseAssets.buildArticulatedModels(
      bodyMaterial: automatonMaterial,
      outlineMaterial: skinnedOutlineMaterial,
    );
    final centerPos = Vector3(boardCells / 2, boardCells / 2, 0.18);
    final socketOrb = MeshComponent(
      mesh: SphereMesh(
        radius: 0.16,
        segments: 12,
        material: UnlitMaterial(albedoColor: const ui.Color(0xFF90F6FF))
          ..renderState = RenderState.opaque,
      ),
      castsShadows: false,
    );
    armTipSocket = BoneSocket3D.byName(
      'ArmTip',
      children: [socketOrb],
    );
    automaton = ModelComponent(
      model: models.shaded,
      position: centerPos.clone(),
      children: [armTipSocket],
    )..playAnimationByName('Idle');

    automatonOutline = ModelComponent(
      model: models.outlined,
      position: centerPos.clone(),
      castsShadows: false,
    )..playAnimationByName('Idle');

    socketPointLight = LightComponent.point(
      color: const ui.Color(0xFF38BDF8),
      intensity: 3.5,
      range: 4.5,
    );
    socketRibbon = RibbonTrail3D(
      target: armTipSocket,
      lifetime: 0.55,
      width: 0.22,
      minVertexDistance: 0.03,
      color: const ui.Color(0xFF38BDF8),
    );

    final sentinelPos = Vector3(boardCells / 2 + 2.6, boardCells / 2, 1.35);
    orbitingSentinel = MeshComponent(
      mesh: SphereMesh(
        radius: 0.32,
        segments: 18,
        material: UnlitMaterial(albedoColor: const ui.Color(0xFFFF5D8F))
          ..renderState = RenderState.opaque,
      ),
      position: sentinelPos.clone(),
    );
    orbitingSentinelOutline = MeshComponent(
      mesh: SphereMesh(
        radius: 0.32,
        segments: 18,
        material: staticOutlineMaterial,
      ),
      position: sentinelPos.clone(),
      castsShadows: false,
    );
    sentinelRibbon = RibbonTrail3D(
      target: orbitingSentinel,
      lifetime: 0.75,
      width: 0.28,
      color: const ui.Color(0xFFFF5D8F),
    );

    ringDecals = DecalBatch3D(
      material: DecalMaterial(
        innerRadius: 0.68,
        softness: 0.1,
        depthBias: 0.001,
      ),
    );
    atlasDecals = DecalBatch3D(
      material: DecalMaterial(
        texture: showcaseAssets.decalAtlas,
        softness: 0.05,
        depthBias: 0.0012,
      ),
    );
    _populateBaseDecals();

    energyStrokes = StrokeBatch3D(
      material: RibbonMaterial3D(depthBias: 0.0005),
    );
    _rebuildEnergyStrokes(0);

    sparkParticles = ParticleSystem3D(
      capacity: 384,
      material: ParticleMaterial(
        billboard: ParticleBillboard.velocity,
        renderState: RenderState.additive,
      ),
      emitters: [
        ParticleEmitter3D(
          rate: 55,
          shape: const ConeEmitterShape3D(angle: 0.45),
          speed: (2.2, 4.4),
          lifespan: (0.55, 1.0),
          size: (0.06, 0.11),
          colors: const [
            ui.Color(0xFFFFD166),
            ui.Color(0xFFFF7B54),
            ui.Color(0xFF72EFDD),
          ],
        ),
      ],
      position: Vector3(5.2, 8.8, 0.35),
      rotation: Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2),
      gravity: Vector3(0, 0, -7.5),
      turbulence: const ParticleTurbulence3D(strength: 1.4, frequency: 0.9),
      ground: ParticleGround3D(
        normal: Vector3(0, 0, 1),
        height: 0.12,
        restitution: 0.45,
      ),
      velocityStretch: 0.06,
      opacityOverLife: ParticleCurve(1, 0),
    );

    smokeParticles =
        ParticlePresets3D.smoke(
            up: Vector3(0, 0, 1),
            scale: 0.75,
            rate: 10,
          )
          ..position = Vector3(8.8, 8.8, 0.35)
          ..prewarm(2.0);

    final coinMesh = CylinderMesh(
      radius: 0.5,
      height: 0.16,
      segments: 10,
      material: metalPedestalMaterial,
    );
    coinMeshParticles = ParticleSystem3D(
      capacity: 96,
      mesh: coinMesh,
      emitters: [
        ParticleEmitter3D(
          shape: const ConeEmitterShape3D(angle: 0.5),
          speed: (2.6, 4.2),
          lifespan: (1.4, 2.0),
          size: (0.16, 0.22),
          rotation: (0, math.pi * 2),
          spin: (-12, 12),
          colors: const [ui.Color(0xFFFFD166), ui.Color(0xFFFFE699)],
        ),
      ],
      position: Vector3(boardCells / 2, 4.2, 0.3),
      rotation: Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2),
      gravity: Vector3(0, 0, -9.2),
      ground: ParticleGround3D(
        normal: Vector3(0, 0, 1),
        height: 0.14,
        restitution: 0.42,
        settleRotation: true,
      ),
    )..burst(14);

    dynamicLayer.world.addAll([
      socketPointLight,
      automaton,
      automatonOutline,
      orbitingSentinel,
      orbitingSentinelOutline,
      ringDecals,
      atlasDecals,
      energyStrokes,
      socketRibbon,
      sentinelRibbon,
      sparkParticles,
      smokeParticles,
      coinMeshParticles,
    ]);
  }

  void _populateBaseDecals() {
    ringDecals.clear();
    atlasDecals.clear();
    final upZ = Vector3(0, 0, 1);

    ringDecals.addFlatDecal(
      center: Vector3(boardCells / 2, boardCells / 2, 0.02),
      width: 3.4,
      height: 3.4,
      normal: upZ,
      color: const ui.Color(0xCC38BDF8),
    );
    if (_lastHitPoint case final hp?) {
      ringDecals.addFlatDecal(
        center: Vector3(hp.x, hp.y, hp.z + 0.02),
        width: 1.15,
        height: 1.15,
        normal: _lastHitNormal ?? upZ,
        color: const ui.Color(0xFFFFBE0B),
      );
    }

    const atlasRects = [
      ui.Rect.fromLTWH(0.0, 0.0, 0.5, 0.5),
      ui.Rect.fromLTWH(0.5, 0.0, 0.5, 0.5),
      ui.Rect.fromLTWH(0.0, 0.5, 0.5, 0.5),
      ui.Rect.fromLTWH(0.5, 0.5, 0.5, 0.5),
    ];
    const runePositions = [
      (4.2, 4.2, ui.Color(0xD972EFDD)),
      (9.8, 4.2, ui.Color(0xD9FF70A6)),
      (4.2, 9.8, ui.Color(0xD9FFD166)),
      (9.8, 9.8, ui.Color(0xD9A855F7)),
    ];
    for (var i = 0; i < runePositions.length; i++) {
      final (rx, ry, rc) = runePositions[i];
      atlasDecals.addFlatDecal(
        center: Vector3(rx, ry, 0.025),
        width: 1.35,
        height: 1.35,
        angle: _time * 0.4 * (i.isEven ? 1 : -1),
        normal: upZ,
        color: rc,
        uvRect: atlasRects[i],
      );
    }
  }

  void _rebuildEnergyStrokes(double t) {
    energyStrokes.clear();
    if (!controller.ribbonsAndDecals) {
      return;
    }

    energyStrokes.beginStroke(color: const ui.Color(0xFF48CAE4));
    const arcSteps = 14;
    for (var i = 0; i <= arcSteps; i++) {
      final u = i / arcSteps;
      final x = 2.5 + (11.5 - 2.5) * u;
      final y = 2.5 + math.sin(u * math.pi) * 1.4;
      final z =
          2.15 +
          math.sin(u * math.pi) * 1.65 +
          0.12 * math.sin(t * 4.0 + u * 8.0);
      final pulse = 0.65 + 0.35 * math.sin(u * math.pi);
      energyStrokes.addPoint(
        x,
        y,
        z,
        halfWidth: 0.09 * pulse,
        opacity: 0.85 * pulse,
      );
    }
    energyStrokes.endStroke();

    if (_lastHitPoint != null && _lastHitNormal != null) {
      final p0 = _lastHitPoint!;
      final p1 = p0 + _lastHitNormal! * 1.35;
      energyStrokes.addPolyline(
        [p0, p1],
        width: 0.14,
        endWidth: 0.02,
        color: const ui.Color(0xFFFFBE0B),
        endOpacity: 0.25,
      );
    }
  }

  /// Preloads optional async testbed assets (`ImageTexture` from `Picture`,
  /// `.obj`+`.mtl` and `.glb` models via `ModelParser`).
  Future<void> preloadVariationAssets() => variationRig.preloadAssets();

  /// Asynchronously preloads any external variation assets and switches to
  /// [next].
  Future<void> selectPreset(ShowcasePreset next) async {
    await preloadVariationAssets();
    if (isLoaded) {
      applyPreset(next);
    }
  }

  /// Synchronously switches the active [ShowcasePreset] lab.
  void applyPreset(ShowcasePreset next) {
    controller.preset = next;
    variationRig.clearMounted();

    switch (next) {
      case ShowcasePreset.allInOne:
        controller
          ..retainedStaticLayer = true
          ..staticShadowCache = true
          ..sharedShadowGroup = false
          ..stressInstances = false
          ..toneMap = ToneMapMode.none
          ..fxaa = false
          ..vignette = false
          ..ssao = false
          ..dof = false
          ..csm2Cascades = false
          ..debug3D = false
          ..renderScale = 1.0;
      case ShowcasePreset.materialsAndGrading:
        controller
          ..retainedStaticLayer = false
          ..staticShadowCache = true
          ..sharedShadowGroup = false
          ..stressInstances = false;
        variationRig.buildMaterialsAndGradingLab();
      case ShowcasePreset.windSpaces:
        controller
          ..retainedStaticLayer = false
          ..wind = true
          ..stressInstances = false;
        variationRig.buildWindSpacesLab();
      case ShowcasePreset.shadowsAndLights:
        controller
          ..retainedStaticLayer = false
          ..staticShadowCache = false
          ..sharedShadowGroup = true
          ..stressInstances = false;
        variationRig.buildShadowsAndLightsLab(
          projection: projection,
          shadowGroup: shadowGroup,
          msaa: controller.msaa4x ? Msaa.sample4 : Msaa.off,
        );
      case ShowcasePreset.particlesAndRibbons:
        controller
          ..retainedStaticLayer = true
          ..particles = true
          ..ribbonsAndDecals = true
          ..stressInstances = false;
        variationRig.buildParticlesAndRibbonsLab(impactDecals: ringDecals);
      case ShowcasePreset.projectionsAndInsets:
        controller
          ..retainedStaticLayer = true
          ..stressInstances = false;
        variationRig.buildProjectionsAndInsetsLab(gemMat: crystalMaterial);
      case ShowcasePreset.modelsAnd32BitMesh:
        controller
          ..retainedStaticLayer = false
          ..stressInstances = false;
        variationRig.buildModelsAnd32BitMeshLab();
      case ShowcasePreset.extremeStress:
        controller
          ..retainedStaticLayer = false
          ..staticShadowCache = true
          ..wind = true
          ..particles = true
          ..ribbonsAndDecals = true;
        variationRig.buildExtremeStressLab(rigMat: automatonMaterial);
      case ShowcasePreset.pbrV2AndSinglePiece:
        controller
          ..retainedStaticLayer = false
          ..staticShadowCache = true
          ..stressInstances = false;
        variationRig.buildPbrV2AndSinglePieceLab();
      case ShowcasePreset.skinning64MorphIkLayers:
        controller
          ..retainedStaticLayer = true
          ..staticShadowCache = true
          ..stressInstances = false;
        variationRig.buildSkinning64MorphIkLayersLab();
      case ShowcasePreset.waterTerrainAndHd2d:
        controller
          ..retainedStaticLayer = false
          ..staticShadowCache = true
          ..stressInstances = false;
        variationRig.buildWaterTerrainAndHd2dLab();
      case ShowcasePreset.spotLightsCullingAndPost:
        controller
          ..retainedStaticLayer = false
          ..staticShadowCache = true
          ..prioritizeNearestLights = true
          ..spatialIndex3D = true
          ..toneMap = ToneMapMode.acesFilmic
          ..fxaa = true
          ..vignette = true
          ..stressInstances = false;
        variationRig.buildSpotLightsCullingAndPostLab();
      case ShowcasePreset.inputEffectsAndCameraRigs:
        controller
          ..retainedStaticLayer = true
          ..staticShadowCache = true
          ..stressInstances = false;
        variationRig.buildInputEffectsAndCameraRigsLab(
          dynamicLayer: dynamicLayer,
          gemMat: crystalMaterial,
        );
      case ShowcasePreset.physicsCollidersKinematicAndNavMesh:
        controller
          ..retainedStaticLayer = false
          ..staticShadowCache = true
          ..stressInstances = false;
        variationRig.buildPhysicsCollidersKinematicAndNavMeshLab(
          dynamicWorld: dynamicLayer.world,
          automaton: automaton,
        );
      case ShowcasePreset.blendTreesCrowdSceneLoaderAndIsolate:
        controller
          ..retainedStaticLayer = true
          ..staticShadowCache = true
          ..stressInstances = false;
        variationRig.buildBlendTreesCrowdSceneLoaderAndIsolateLab(
          crowdModel: automaton.model,
        );
      case ShowcasePreset.ssaoDofCsmPortalAndDebug3D:
        controller
          ..retainedStaticLayer = false
          ..staticShadowCache = false
          ..ssao = true
          ..dof = true
          ..csm2Cascades = true
          ..debug3D = true
          ..toneMap = ToneMapMode.acesFilmic
          ..fxaa = true
          ..stressInstances = false;
        variationRig.buildSsaoDofCsmPortalAndDebug3DLab(
          debugEnabled: controller.debug3D,
        );
    }

    if (variationRig.staticExtras.isNotEmpty) {
      staticLayer.world.addAll(variationRig.staticExtras);
    }
    if (variationRig.dynamicExtras.isNotEmpty) {
      dynamicLayer.world.addAll(variationRig.dynamicExtras);
    }
    if (variationRig.world2DExtras.isNotEmpty) {
      world.addAll(variationRig.world2DExtras);
    }
    if (variationRig.viewportExtras.isNotEmpty) {
      camera.viewport.addAll(variationRig.viewportExtras);
    }
    syncControllerState();
  }

  /// Cycles `ToneMapMode` (`none` -> `acesFilmic` -> `agx` -> `reinhard`).
  void cycleToneMap() {
    const order = [
      ToneMapMode.none,
      ToneMapMode.acesFilmic,
      ToneMapMode.agx,
      ToneMapMode.reinhard,
    ];
    final idx = order.indexOf(controller.toneMap);
    controller.toneMap = order[(idx + 1) % order.length];
    syncControllerState();
  }

  /// Cycles `ShadowMapEncoding` (`auto` -> `float32` -> `rgba8`).
  void cycleShadowEncoding() {
    const vals = ShadowMapEncoding.values;
    controller.shadowEncoding =
        vals[(controller.shadowEncoding.index + 1) % vals.length];
    syncControllerState();
  }

  /// Toggles `ShadowFit` between `scene` and `view`.
  void toggleShadowFit() {
    controller.shadowFit = controller.shadowFit == ShadowFit.scene
        ? ShadowFit.view
        : ShadowFit.scene;
    syncControllerState();
  }

  /// Cycles PCF shadow filter softness (`0` -> `1` -> `2` -> `3`).
  void cycleShadowSoftness() {
    controller.shadowSoftness = (controller.shadowSoftness + 1) % 4;
    syncControllerState();
  }

  /// Toggles dynamic resolution scaling (`renderScale`: `1.0` vs `0.5`).
  void toggleRenderScale() {
    controller.renderScale = controller.renderScale == 1.0 ? 0.5 : 1.0;
    syncControllerState();
  }

  /// Cycles `AnimationPlayMode` (`loop` -> `once` -> `pingPong`) and triggers
  /// the current clip with that mode.
  void cyclePlayMode() {
    const modes = AnimationPlayMode.values;
    final next = modes[(controller.playMode.index + 1) % modes.length];
    controller.playMode = next;
    final clipName = animationClips[_clipIndex];
    automaton.playAnimationByName(
      clipName,
      mode: next,
      onComplete: () => variationRig.onceClipCompletions++,
    );
    automatonOutline.playAnimationByName(clipName, mode: next);
    controller.notifyChanged();
  }

  /// Cycles skeletal animation playback speed (`1.0x` -> `2.0x` -> `0.5x`).
  void cycleAnimSpeed() {
    final next = controller.animSpeed == 1.0
        ? 2.0
        : controller.animSpeed == 2.0
        ? 0.5
        : 1.0;
    controller.animSpeed = next;
    syncControllerState();
  }

  /// Toggles visibility of the `Crown` sub-node on the 26-float stylized rig
  /// (`ModelComponent.hideNodeByName`).
  void toggleCrownNode() {
    if (variationRig.stylized26Rig == null) {
      unawaited(
        selectPreset(ShowcasePreset.modelsAnd32BitMesh).then((_) {
          variationRig.crownHidden = !variationRig.crownHidden;
          variationRig.stylized26Rig?.hideNodeByName(
            'Crown',
            hidden: variationRig.crownHidden,
          );
          controller.notifyChanged();
        }),
      );
      return;
    }
    variationRig.crownHidden = !variationRig.crownHidden;
    variationRig.stylized26Rig?.hideNodeByName(
      'Crown',
      hidden: variationRig.crownHidden,
    );
    controller.notifyChanged();
  }

  /// Applies all toggle states from [controller] to the live 3D layers.
  void syncControllerState() {
    if (!isLoaded) {
      return;
    }
    final msaa = controller.msaa4x ? Msaa.sample4 : Msaa.off;
    _postProcessSettings
      ..toneMap = controller.toneMap
      ..exposure = controller.toneMap == ToneMapMode.none ? 1.0 : 1.08
      ..vignetteIntensity = controller.vignette ? 0.35 : 0.0
      ..fxaa = controller.fxaa
      ..ssaoIntensity = controller.ssao ? 0.72 : 0.0
      ..ssaoRadius = 0.032
      ..dofBlurStrength = controller.dof ? 0.45 : 0.0
      ..dofFocusDepth = 0.5
      ..dofFocusRange = 0.16;

    final needDepthPrepass =
        controller.ssao ||
        controller.dof ||
        controller.preset == ShowcasePreset.ssaoDofCsmPortalAndDebug3D;

    staticLayer
      ..msaa = msaa
      ..renderScale = controller.renderScale
      ..cacheMode = controller.retainedStaticLayer
          ? Scene3DCacheMode.retained
          : Scene3DCacheMode.none;
    staticLayer.world
      ..spatialIndex3DEnabled = controller.spatialIndex3D
      ..prioritizeNearestLights = controller.prioritizeNearestLights;

    dynamicLayer
      ..msaa = msaa
      ..renderScale = controller.renderScale
      ..bloom = controller.bloom ? _bloomSettings : null
      ..postProcess = _postProcessSettings.isActive
          ? _postProcessSettings
          : null;
    dynamicLayer.world
      ..depthPrepassEnabled = needDepthPrepass
      ..spatialIndex3DEnabled = controller.spatialIndex3D
      ..prioritizeNearestLights = controller.prioritizeNearestLights;

    final desiredCascades = controller.csm2Cascades ? 2 : 1;
    _staticShadows
      ..cacheWhenStatic = controller.staticShadowCache
      ..encoding = controller.shadowEncoding
      ..fit = controller.shadowFit
      ..softness = controller.shadowSoftness
      ..cascades = desiredCascades;
    _dynamicShadows
      ..encoding = controller.shadowEncoding
      ..fit = controller.shadowFit
      ..softness = controller.shadowSoftness
      ..cascades = desiredCascades;

    if (variationRig.labDebugRenderer case final labDbg?) {
      labDbg.enabled = controller.debug3D;
      globalDebugRenderer.enabled = false;
    } else {
      globalDebugRenderer.enabled = controller.debug3D;
    }

    if (controller.sharedShadowGroup) {
      staticLayer.world.shadowGroup = shadowGroup;
      dynamicLayer.world.shadowGroup = shadowGroup;
      variationRig.skyShadowLayer?.world.shadowGroup = shadowGroup;
    } else {
      staticLayer.world.shadowGroup = null;
      dynamicLayer.world.shadowGroup = null;
    }

    dynamicLayer.world.fog = controller.fog ? _fogSettings : null;

    automaton.animationState.speed = controller.animSpeed;
    automatonOutline.animationState.speed = controller.animSpeed;
    variationRig.stylized26Rig?.animationState.speed = controller.animSpeed;
    variationRig.serpent32BoneRig?.animationState.speed = controller.animSpeed;

    final outlineScale = controller.outlines ? 1.0 : 0.0;
    automatonOutline.scale.setValues(outlineScale, outlineScale, outlineScale);
    orbitingSentinelOutline.scale.setValues(
      outlineScale,
      outlineScale,
      outlineScale,
    );

    sparkParticles.paused = !controller.particles;
    smokeParticles.paused = !controller.particles;
    coinMeshParticles.paused = !controller.particles;

    socketRibbon.emitting = controller.ribbonsAndDecals;
    sentinelRibbon.emitting = controller.ribbonsAndDecals;
    if (!controller.ribbonsAndDecals) {
      socketRibbon.reset();
      sentinelRibbon.reset();
      ringDecals.clear();
      atlasDecals.clear();
      energyStrokes.clear();
    } else {
      _populateBaseDecals();
      _rebuildEnergyStrokes(_time);
    }

    final expectedInstances = _desiredTileMode();
    if (tileInstances.length != expectedInstances) {
      _rebuildTileInstances(mode: expectedInstances);
    }

    staticLayer.markDirty();
    dynamicLayer.world.markSceneDirty(shadows: false);
    controller.notifyChanged();
  }

  /// Crossfades the articulated automaton to the next animation clip (`Idle` ->
  /// `Swing` -> `Spin`), supporting custom [mode] and [duration].
  void crossFadeNextClip({
    AnimationPlayMode mode = AnimationPlayMode.loop,
    double duration = 0.3,
  }) {
    _clipIndex = (_clipIndex + 1) % animationClips.length;
    final clipName = animationClips[_clipIndex];
    automaton.crossFadeToByName(clipName, duration: duration, mode: mode);
    automatonOutline.crossFadeToByName(
      clipName,
      duration: duration,
      mode: mode,
    );
    controller
      ..activeClip = clipName
      ..notifyChanged();
  }

  /// Renders an offscreen `128x128` close-up perspective snapshot of the
  /// dynamic world via `World3D.renderToImage` and stores it in
  /// [ShowcaseController.snapshotImage].
  ui.Image captureOffscreenSnapshot({ui.Size size = const ui.Size(128, 128)}) {
    final view = Matrix4.identity()
      ..setAsViewMatrix(
        Vector3(boardCells / 2 + 4.0, boardCells / 2 + 4.0, 3.2),
        Vector3(boardCells / 2, boardCells / 2, 1.0),
        Vector3(0, 0, 1),
      );
    final proj = Matrix4.identity()
      ..setAsPerspective(48, size.width / size.height, 0.2, 60);
    final img = dynamicLayer.world.renderToImage(
      size,
      view: view,
      projection: proj,
      clearValue: const ui.Color(0xFF162033),
    );
    controller.snapshotImage?.dispose();
    controller
      ..snapshotImage = img
      ..notifyChanged();
    return img;
  }

  /// Performs a triangle-accurate BVH raycast at [localPoint] (in layer local
  /// coordinates), highlighting any hit instance and placing a 3D hit decal +
  /// normal indicator.
  RayHit3D? pickAtLocalPoint(Vector2 localPoint) {
    final dynHit = dynamicLayer.raycastLocal(localPoint);
    final statHit = staticLayer.raycastLocal(localPoint);
    final RayHit3D? hit;
    if (dynHit != null && statHit != null) {
      hit = dynHit.distance <= statHit.distance ? dynHit : statHit;
    } else {
      hit = dynHit ?? statHit;
    }

    if (_highlightedInstance case final prev?
        when prev < tileInstances.length) {
      final paletteIdx = prev % ShowcaseAssets.accentPalette.length;
      tileInstances.setInstance(
        prev,
        instanceData: Vector4(
          0,
          0,
          0,
          StylizedMaterial.packAccentAndFade(paletteIdx),
        ),
      );
      _highlightedInstance = null;
    }

    if (hit == null) {
      _lastHitPoint = null;
      _lastHitNormal = null;
      controller.lastHitSummary = 'Miss (sky / background)';
    } else {
      _lastHitPoint = hit.worldPoint.clone();
      _lastHitNormal = hit.worldNormal.clone();
      final compName = hit.object.runtimeType.toString();
      final isTileInst = identical(hit.object, tileInstances);
      final instSuffix = isTileInst ? ' #${hit.surfaceIndex}' : '';
      controller.lastHitSummary =
          'Hit $compName$instSuffix (tri=${hit.triangleIndex}, '
          'd=${hit.distance.toStringAsFixed(1)})';

      if (isTileInst && hit.surfaceIndex < tileInstances.length) {
        final idx = hit.surfaceIndex;
        _highlightedInstance = idx;
        final paletteIdx = idx % ShowcaseAssets.accentPalette.length;
        tileInstances.setInstance(
          idx,
          instanceData: Vector4(
            0.85,
            0.38,
            0,
            StylizedMaterial.packAccentAndFade(paletteIdx),
          ),
        );
      }
    }

    if (controller.ribbonsAndDecals) {
      _populateBaseDecals();
      _rebuildEnergyStrokes(_time);
    }
    controller.notifyChanged();
    return hit;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt <= 0) {
      return;
    }
    _time += dt;

    final dtMs = dt * 1000.0;
    _frameDurationsMs[_frameRingCursor] = dtMs;
    _frameRingCursor = (_frameRingCursor + 1) % _frameDurationsMs.length;
    if (_frameSamples < _frameDurationsMs.length) {
      _frameSamples++;
    }

    if (controller.wind) {
      windTreeMaterial.windTime = _time;
      staticLayer.markDirty();
    }

    if (controller.autoOrbitCamera) {
      final center = staticLayer.scenePointToLocal(
        Vector3(boardCells / 2, boardCells / 2, 0.5),
      );
      camera.viewfinder
        ..position =
            center +
            Vector2(math.sin(_time * 0.65) * 55, math.cos(_time * 0.5) * 32)
        ..zoom = 1.0 + 0.14 * math.sin(_time * 0.45);
    }

    final orbAngle = _time * 1.45;
    final sx = boardCells / 2 + math.cos(orbAngle) * 2.75;
    final sy = boardCells / 2 + math.sin(orbAngle) * 2.75;
    final sz = 1.25 + 0.35 * math.sin(_time * 2.6);
    orbitingSentinel.position.setValues(sx, sy, sz);
    orbitingSentinelOutline.position.setValues(sx, sy, sz);

    final tip = armTipSocket.worldTransformMatrix.storage;
    socketPointLight.position.setValues(tip[12], tip[13], tip[14]);

    if (controller.particles) {
      _burstTimer += dt;
      if (_burstTimer >= 2.2) {
        _burstTimer = 0;
        coinMeshParticles.burst(12);
      }
    }

    if (controller.ribbonsAndDecals) {
      _rebuildEnergyStrokes(_time);
    }

    variationRig.update(_time, dt);

    if (variationRig.portalRenderTexture case final portal?) {
      _portalView.setAsViewMatrix(
        Vector3(
          boardCells / 2 + math.cos(_time * 0.6) * 4.5,
          boardCells / 2 + math.sin(_time * 0.6) * 4.5,
          3.4,
        ),
        Vector3(boardCells / 2, boardCells / 2, 0.9),
        Vector3(0, 0, 1),
      );
      _portalProj.setAsPerspective(52, 1.0, 0.25, 40.0);
      portal.renderWorld(
        dynamicLayer.world,
        view: _portalView,
        projection: _portalProj,
        cameraMask: 0x01,
      );
      if (variationRig.portalMonitorScreen case final screen?) {
        final mat = screen.mesh.surfaces.first.material;
        if (mat is UnlitMaterial &&
            !identical(mat.albedoTexture, portal.texture)) {
          mat.albedoTexture = portal.texture;
        }
      }
    }

    _hudRefreshTimer += dt;
    if (_hudRefreshTimer >= 0.25) {
      _hudRefreshTimer = 0;
      _publishTelemetry();
    }
  }

  void _publishTelemetry() {
    if (_frameSamples == 0) {
      return;
    }
    final sorted = _frameDurationsMs.sublist(0, _frameSamples)..sort();
    final p50 = sorted[(sorted.length * 0.5).floor()];
    final p95Index = math.min(
      sorted.length - 1,
      (sorted.length * 0.95).floor(),
    );
    final p95 = sorted[p95Index];
    final mean = sorted.fold<double>(0, (a, b) => a + b) / sorted.length;
    controller
      ..fps = mean > 0 ? 1000.0 / mean : 60.0
      ..frameMsP50 = p50
      ..frameMsP95 = p95
      ..notifyChanged();
  }

  @override
  void onTapUp(TapUpEvent event) {
    final local = staticLayer.absoluteToLocal(
      camera.globalToLocal(event.canvasPosition),
    );
    pickAtLocalPoint(local);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (controller.autoOrbitCamera || isScaling) {
      return;
    }
    camera.viewfinder.position -= event.localDelta / camera.viewfinder.zoom;
  }

  @override
  void onScroll(ScrollEvent event) {
    final factor = math.exp(-event.scrollDelta.y * 0.002);
    camera.viewfinder.zoom = (camera.viewfinder.zoom * factor).clamp(
      minZoom,
      maxZoom,
    );
  }

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    _startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    camera.viewfinder.zoom = (_startZoom * event.scale).clamp(minZoom, maxZoom);
  }
}
