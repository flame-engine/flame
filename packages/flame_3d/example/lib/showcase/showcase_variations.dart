import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart'
    show Anchor, PositionComponent, TextComponent, TextPaint;
import 'package:flame_3d/audio.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/debug.dart';
import 'package:flame_3d/effects.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/input.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/navigation.dart';
import 'package:flame_3d/parser.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/physics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/showcase/showcase_meshes.dart';
import 'package:flame_3d_example/showcase/showcase_v2_builders.dart';
import 'package:flame_3d_example/showcase/showcase_v3_builders.dart';
import 'package:flutter/painting.dart' show Shadow, TextStyle;

/// Curated testbed variations exercising distinct feature matrices of
/// `package:flame_3d`.
enum ShowcasePreset(final String label, final String summary) {
  allInOne(
    '1. All-in-One',
    'Retained + ShadowCache + 16-Accent Batch + LOD + Skinned + Bloom + Fog',
  ),
  materialsAndGrading(
    '2. Materials & Ghost',
    'PBR 3x3 + Grading + Depth-Prepass Ghost + Samplers + ImageTex + Mirror',
  ),
  windSpaces(
    '3. Wind Spaces',
    'Side-by-side WindSpace.world vs model vs worldScaled + Gusts + Flutter',
  ),
  shadowsAndLights(
    '4. Shadows & 4+8 Lights',
    '3-Layer ShadowGroup + RGBA8/Float32 + View/Scene Fit + 4 Suns + 8 Pt',
  ),
  particlesAndRibbons(
    '5. Flipbook & Forces',
    '4 Billboards + 4x4 Flipbook + 5 Shapes + Attractor + Ground + Plasma',
  ),
  projectionsAndInsets(
    '6. PiP & Projections',
    'Perspective PiP + Camera/Oblique Matrix Insets + Line3D + DRS 0.5x',
  ),
  modelsAnd32BitMesh(
    '7. GLB/OBJ & 67k Mesh',
    'GLB + OBJ(.mtl) + 26-Float Skin + PlayModes + 67,600v Uint32 Mesh',
  ),
  extremeStress(
    '8. Stress 2,048+',
    '2,048 InstancedGroup + 6 Skinned Rigs + 4 Particle Systems + Ribbons',
  ),
  pbrV2AndSinglePiece(
    '9. PBR & Single-Piece',
    'Normal/ORM/Emissive/Env Maps + Cutout + Built-in Single-Piece + Dither',
  ),
  skinning64MorphIkLayers(
    '10. 64-Bone, Morph & IK',
    '32-Bone Serpent + CubicSpline + MorphTargets + Upper Layer + IK/Spring',
  ),
  waterTerrainAndHd2d(
    '11. Water, Terrain & HD-2D',
    'Gerstner Water + TerrainMesh3D + TubeSpline + Standees + Text3D + Blobs',
  ),
  spotLightsCullingAndPost(
    '12. SpotLights, BVH & ACES',
    '4 SpotLights + 32 Culled PointLights + SceneSpatialIndex3D + ACES/FXAA',
  ),
  inputEffectsAndCameraRigs(
    '13. 3D Input, Effects & Rigs',
    'Tap/Hover/Drag3D + Gizmo + Arc/Spline/Squash Effects + FixedInterp + Rigs',
  ),
  physicsCollidersKinematicAndNavMesh(
    '14. Physics, NavMesh & Audio',
    'RigidBody3D Dice + HingeJoint + Trigger + Kinematic + NavMesh + Audio3D',
  ),
  blendTreesCrowdSceneLoaderAndIsolate(
    '15. Blend, Crowd64 & Scene',
    'BlendSpace 1D/2D + Events + RootMotion + 64 Crowd + SceneLoader + Isolate',
  ),
  ssaoDofCsmPortalAndDebug3D(
    '16. SSAO, DoF, CSM & Portal',
    'DepthNormal SSAO/DoF + SoftPtcl + CSM 2x + SpotShadow + Portal + Debug3D',
  ),
}

/// Draws an overlapping multi-part mesh as a single seamless translucent piece
/// by recording a [RenderState.depthOnly] prepass right before a translucent
/// pass with [CompareFunction.lessEqual].
class DepthPrepassGhostObject3D({
  required final Mesh mesh,
  required final StylizedMaterial translucentMaterial,
  var double fade = 0.45,
  super.position,
  super.scale,
  super.rotation,
}) extends Object3D {
  this : super(castsShadows: false);

  final StylizedMaterial _prepassMaterial = StylizedMaterial()
    ..renderState = RenderState.depthOnly
    ..castsShadows = false;

  final Vector4 _instanceData = Vector4.zero();

  @override
  Aabb3? computeLocalAabb() => mesh.aabb;

  @override
  void draw(covariant RenderContext3D context) {
    if (context.isShadowPass) {
      return;
    }
    _instanceData.setValues(0, 0, 0, fade.clamp(0.0, 0.98));
    final m = worldTransformMatrix;
    for (final surface in mesh.surfaces) {
      context
        ..drawSurface(surface, transform: m, material: _prepassMaterial)
        ..drawSurface(
          surface,
          transform: m,
          material: translucentMaterial,
          instanceData: _instanceData,
        );
    }
  }
}

/// Manages the specialized components, extra layers, and per-frame animations
/// of the active [ShowcasePreset].
class ShowcaseVariationRig({required final ShowcaseAssets assets}) {
  ImageTexture? canvasBannerTexture;
  Model? parsedObjModel;
  Model? parsedGlbModel;

  /// Components added to `dynamicLayer.world` for the current preset.
  final List<Component3D> dynamicExtras = [];

  /// Components added to `staticLayer.world` for the current preset.
  final List<Component3D> staticExtras = [];

  /// Extra 2D/layer components mounted into `world` or `camera.viewport`.
  final List<PositionComponent> world2DExtras = [];
  final List<PositionComponent> viewportExtras = [];

  final ShowcaseV2Builders v2 = ShowcaseV2Builders();
  final ShowcaseV3Builders v3 = ShowcaseV3Builders();
  final AssetScope3D assetScope3D = AssetScope3D();

  Model? isolateGlbModel;
  List<PreparedSurfaceBvh3D> isolatePreparedBvhs = const [];
  LoadedScene3D? loadedExtendedScene;
  int sceneExtrasCallbackHits = 0;

  // Inspected live objects for diagnostics & interactive controls.
  DepthPrepassGhostObject3D? depthPrepassGhost;
  MeshComponent? naiveGhost;
  MeshComponent? mirroredMonument;
  MeshComponent? normalMonument;
  ModelComponent? stylized26Rig;
  MeshComponent? wave32BitTerrain;
  Scene3DComponent? skyShadowLayer;
  Scene3DComponent? perspectiveInsetLayer;
  Scene3DComponent? obliqueMatrixLayer;
  Scene3DComponent? cameraProjLayer;

  // Wave 6B Lab 9–12 live handles:
  SpatialMaterial? pbrCobbleMaterial;
  SpatialMaterial? pbrEnvMaterial;
  SpatialMaterial? pbrCutoutMaterial;
  ModelComponent? singlePieceSkinnedGhost;
  final List<MeshComponent> ditherPillars = [];

  ModelComponent? serpent32BoneRig;
  ModelComponent? morphCrystalRig;
  ModelComponent? layeredIkRig;
  TwoBoneIkConstraint3D? twoBoneIk;
  LookAtConstraint3D? lookAtHead;
  SpringBone3D? springAntenna;
  MeshComponent? ikTargetOrb;

  TerrainMesh3D? islandTerrain;
  WaterMaterial? lagoonWaterMaterial;
  BillboardBatch3D? standeeBatch;
  final List<Text3DComponent> text3DBadges = [];
  DecalBatch3D? blobShadowDecals;
  MeshComponent? splineAqueduct;

  final List<LightComponent> sweepingSpotLights = [];
  final List<LightComponent> culledStreetLamps = [];

  // Next-Gen Lab 13–16 live handles:
  PointerRouter3D? pointerRouter3D;
  InteractiveCrystalTotem3D? interactiveTotem;
  AxisGizmoSlider3D? axisGizmoSlider;
  MeshComponent? splineShuttle;
  MeshComponent? arcJumpOrb;

  PhysicsWorld3D? physicsWorld;
  final List<RigidBody3D> diceRigidBodies = [];
  HingeJoint3D? pendulumHinge;
  RigidBody3D? pendulumBobBody;
  CollisionSystem3D? collisionSystem;
  TriggerVolume3D? triggerPad;
  CollisionBeacon3D? collisionBeacon;
  int triggerEnters = 0;
  int triggerExits = 0;
  MeshComponent? kinematicActor;
  KinematicCharacterController3D? kinematicController;
  NavMesh3D? steppedNavMesh;
  CrowdSteering3D? crowdSteering;
  SkinnedHitboxRig3D? skinnedHitboxRig;
  SpatialAudioListener3D? audioListener3D;
  SpatialAudioEmitter3D? audioEmitter3D;

  ModelComponent? blend1DWalker;
  ModelComponent? blend2DWalker;
  RootMotionExtractor3D? walkerRootMotion;
  int animEventsFired = 0;
  SkinnedCrowdBatch3D? skinnedCrowd64;

  RenderTexture3D? portalRenderTexture;
  MeshComponent? portalMonitorScreen;
  LightComponent? shadowSpotLight;
  ParticleMaterial? softMistMaterial;
  WaterMaterial? shoreFoamWaterMaterial;
  DebugRenderer3D? labDebugRenderer;

  final List<StylizedMaterial> animatedWindMaterials = [];
  final List<Component3D> airships = [];
  final List<ModelComponent> extraSkinnedRigs = [];

  int attractorArrivals = 0;
  int groundBounceHits = 0;
  int onceClipCompletions = 0;
  bool crownHidden = false;

  Future<void> preloadAssets() async {
    canvasBannerTexture ??= await assets.createCanvasBannerTexture();
    if (parsedObjModel == null) {
      for (final candidate in const [
        'objects/octa_gem.obj',
        'assets/objects/octa_gem.obj',
      ]) {
        try {
          parsedObjModel = await ModelParser.parse(candidate);
          break;
          // Asset path differs depending on Flame.assets prefix configuration.
          // ignore: avoid_catches_without_on_clauses
        } catch (_) {}
      }
    }
    if (parsedGlbModel == null) {
      for (final candidate in const [
        'objects/skeleton.glb',
        'assets/objects/skeleton.glb',
      ]) {
        try {
          parsedGlbModel = await ModelParser.parse(candidate);
          break;
          // Optional external GLB asset when running in pure unit tests.
          // ignore: avoid_catches_without_on_clauses
        } catch (_) {}
      }
    }
    if (isolateGlbModel == null || loadedExtendedScene == null) {
      final glbBytes = v3.buildProceduralExtendedGlbBytes();
      isolateGlbModel ??= await AsyncModelLoader3D.parseGlbBytesAsync(
        glbBytes,
        scope: assetScope3D,
      );
      isolatePreparedBvhs = await AsyncModelLoader3D.buildSurfaceBvhsInIsolate(
        isolateGlbModel!,
      );
      sceneExtrasCallbackHits = 0;
      loadedExtendedScene = await SceneLoader3D.loadGlbBytes(
        glbBytes,
        onNodeExtras: (ctx) {
          if (ctx.extrasMap?['spawnTag'] == 'obelisk_anchor') {
            sceneExtrasCallbackHits++;
            ctx.addComponent(
              MeshComponent(
                mesh: SphereMesh(
                  radius: 0.22,
                  segments: 12,
                  material: UnlitMaterial(
                    albedoColor: const ui.Color(0xFF00F5D4),
                  )..renderState = RenderState.opaque,
                ),
                position: ctx.worldPosition + Vector3(0, 0, 1.45),
                castsShadows: false,
              ),
            );
          }
        },
      );
    }
  }

  void clearMounted() {
    for (final c in dynamicExtras) {
      c.removeFromParent();
    }
    for (final c in staticExtras) {
      c.removeFromParent();
    }
    for (final c in world2DExtras) {
      c.removeFromParent();
    }
    for (final c in viewportExtras) {
      c.removeFromParent();
    }
    dynamicExtras.clear();
    staticExtras.clear();
    world2DExtras.clear();
    viewportExtras.clear();
    animatedWindMaterials.clear();
    airships.clear();
    extraSkinnedRigs.clear();

    depthPrepassGhost = null;
    naiveGhost = null;
    mirroredMonument = null;
    normalMonument = null;
    stylized26Rig = null;
    wave32BitTerrain = null;
    skyShadowLayer = null;
    perspectiveInsetLayer = null;
    obliqueMatrixLayer = null;
    cameraProjLayer = null;

    pbrCobbleMaterial = null;
    pbrEnvMaterial = null;
    pbrCutoutMaterial = null;
    singlePieceSkinnedGhost = null;
    ditherPillars.clear();

    serpent32BoneRig = null;
    morphCrystalRig = null;
    layeredIkRig = null;
    twoBoneIk = null;
    lookAtHead = null;
    springAntenna = null;
    ikTargetOrb = null;

    islandTerrain = null;
    lagoonWaterMaterial = null;
    standeeBatch = null;
    text3DBadges.clear();
    blobShadowDecals = null;
    splineAqueduct = null;

    sweepingSpotLights.clear();
    culledStreetLamps.clear();

    pointerRouter3D = null;
    interactiveTotem = null;
    axisGizmoSlider = null;
    splineShuttle = null;
    arcJumpOrb = null;

    physicsWorld?.removeFromParent();
    physicsWorld = null;
    diceRigidBodies.clear();
    pendulumHinge = null;
    pendulumBobBody = null;
    collisionSystem?.removeFromParent();
    collisionSystem = null;
    triggerPad = null;
    collisionBeacon = null;
    triggerEnters = 0;
    triggerExits = 0;
    kinematicActor = null;
    kinematicController = null;
    steppedNavMesh = null;
    crowdSteering = null;
    skinnedHitboxRig?.removeFromParent();
    skinnedHitboxRig = null;
    audioListener3D = null;
    audioEmitter3D = null;

    blend1DWalker = null;
    blend2DWalker = null;
    walkerRootMotion = null;
    animEventsFired = 0;
    skinnedCrowd64 = null;

    portalRenderTexture?.dispose();
    portalRenderTexture = null;
    portalMonitorScreen = null;
    shadowSpotLight = null;
    softMistMaterial = null;
    shoreFoamWaterMaterial = null;
    labDebugRenderer = null;
  }

  void buildMaterialsAndGradingLab() {
    final upright = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);

    // 1. 3x3 SpatialMaterial PBR metallic x roughness sphere matrix.
    const metallics = [0.0, 0.5, 1.0];
    const roughnesses = [0.12, 0.48, 0.88];
    for (var mi = 0; mi < metallics.length; mi++) {
      for (var ri = 0; ri < roughnesses.length; ri++) {
        final sphere = MeshComponent(
          mesh: SphereMesh(
            radius: 0.34,
            segments: 18,
            material: SpatialMaterial(
              albedoColor: const ui.Color(0xFFF4A261),
              metallic: metallics[mi],
              roughness: roughnesses[ri],
            )..renderState = const RenderState(cullMode: CullMode.backFace),
          ),
          position: Vector3(2.2 + mi * 1.05, 2.2 + ri * 1.05, 0.55),
        );
        staticExtras.add(sphere);
      }
    }

    // 2. StylizedMaterial color-grading pedestals: petrified, vivid, overlay.
    final petrified = StylizedMaterial(
      saturation: 0.0,
      matCapTexture: assets.coatMatCap,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    final vivid = StylizedMaterial(
      saturation: 1.65,
      accentColor: const ui.Color(0xFF00F5D4),
      matCapTexture: assets.gemMatCap,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    final shielded = StylizedMaterial(
      overlayColor: const ui.Color(0x6638BDF8),
      matCapTexture: assets.coatMatCap,
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    for (final (idx, mat) in [petrified, vivid, shielded].indexed) {
      staticExtras.add(
        MeshComponent(
          mesh: assets.buildCrystalTowerLodMesh(
            mat,
            segments: 14,
            crystalTint: const ui.Color(0xFFFF70A6),
          ),
          position: Vector3(8.5 + idx * 1.35, 2.6, 0),
        ),
      );
    }

    // 3. Side-by-side Depth-Prepass Ghost vs Naive Translucent Ghost.
    final ghostMat =
        StylizedMaterial(
            translucent: true,
            matCapTexture: assets.coatMatCap,
            matCapStrength: 0.55,
          )
          ..renderState = StylizedMaterial.translucentRenderState.copyWith(
            depthCompare: CompareFunction.lessEqual,
            cullMode: CullMode.backFace,
          );
    final naiveMat =
        StylizedMaterial(
            translucent: true,
            matCapTexture: assets.coatMatCap,
            matCapStrength: 0.55,
          )
          ..renderState = StylizedMaterial.translucentRenderState.copyWith(
            cullMode: CullMode.backFace,
          );
    final ghostMesh = assets.buildOverlappingGhostMesh(ghostMat);
    final naiveMesh = assets.buildOverlappingGhostMesh(naiveMat);

    depthPrepassGhost = DepthPrepassGhostObject3D(
      mesh: ghostMesh,
      translucentMaterial: ghostMat,
      position: Vector3(5.8, 9.8, 0.1),
    );
    naiveGhost = MeshComponent(
      mesh: naiveMesh,
      position: Vector3(8.2, 9.8, 0.1),
      instanceData: Vector4(0, 0, 0, 0.45),
      castsShadows: false,
    );
    dynamicExtras.addAll([depthPrepassGhost!, naiveGhost!]);

    // 4. TextureSampler (`repeat`, `mirror`, `clamp`) + zero-copy ImageTexture.
    Surface uvQuad(Material mat, {double uvMax = 2.5}) {
      return Surface.fromBuffers(
        vertices: Float32List.fromList([
          -0.48, -0.48, 0, -0.5, uvMax, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0,
          0, 0, //
          0.48, -0.48, 0, uvMax, uvMax, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0,
          0, 0, //
          0.48, 0.48, 0, uvMax, -0.5, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
          0, //
          -0.48, 0.48, 0, -0.5, -0.5, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
          0, //
        ]),
        indices: Uint16List.fromList(const [0, 1, 2, 0, 2, 3]),
        material: mat,
      );
    }

    const wraps = [TextureWrap.repeat, TextureWrap.mirror, TextureWrap.clamp];
    for (var i = 0; i < wraps.length; i++) {
      final tex = assets.buildCheckerTexture(
        sampler: TextureSampler(
          minFilter: i == 0 ? TextureFilter.nearest : TextureFilter.linear,
          magFilter: i == 0 ? TextureFilter.nearest : TextureFilter.linear,
          mipFilter: TextureFilter.linear,
          wrapU: wraps[i],
          wrapV: wraps[i],
        ),
      );
      final mat = UnlitMaterial(albedoTexture: tex)
        ..renderState = RenderState.opaque;
      staticExtras.add(
        MeshComponent(
          mesh: Mesh()..addSurface(uvQuad(mat)),
          position: Vector3(2.4 + i * 1.25, 6.8, 0.65),
        ),
      );
    }

    if (canvasBannerTexture case final bannerTex?) {
      final bannerMat = UnlitMaterial(albedoTexture: bannerTex)
        ..renderState = RenderState.opaque;
      staticExtras.add(
        MeshComponent(
          mesh: PlaneMesh(size: Vector2(2.1, 1.05), material: bannerMat),
          position: Vector3(10.2, 6.8, 1.05),
          rotation: upright,
        ),
      );
    }

    // 5. Normal (`+1`) vs Mirrored Negative-Scale (`-1`) asymmetric monuments.
    final monMat = StylizedMaterial(
      accentColor: const ui.Color(0xFFFFBE0B),
      matCapTexture: assets.coatMatCap,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    final monMesh = assets.buildAsymmetricMonumentMesh(monMat);
    normalMonument = MeshComponent(
      mesh: monMesh,
      position: Vector3(3.0, 10.6, 0),
    );
    mirroredMonument = MeshComponent(
      mesh: monMesh,
      position: Vector3(4.5, 10.6, 0),
      scale: Vector3(-1, 1, 1),
    );
    staticExtras.addAll([normalMonument!, mirroredMonument!]);
  }

  void buildWindSpacesLab() {
    // 3 rows: WindSpace.world, WindSpace.model, WindSpace.worldScaled across
    // different yaws & heights so the difference is crystal clear!
    final modes = [
      (WindSpace.world, const ui.Color(0xFF60A5FA)),
      (WindSpace.model, const ui.Color(0xFFF472B6)),
      (WindSpace.worldScaled, const ui.Color(0xFF34D399)),
    ];
    const scales = [0.65, 1.0, 1.55, 2.0];
    for (var row = 0; row < modes.length; row++) {
      final (space, tint) = modes[row];
      final mat = StylizedMaterial(
        albedoColor: tint,
        windSpace: space,
        windDirection: Vector3(1, 0.25, 0),
        windUpAxis: Vector3(0, 0, 1),
        windAmplitude: 0.085,
        windFrequency: 2.8,
        windPhase: Vector3(0.7, 0.4, 0),
        windFlutterAmplitude: 0.022,
        windFlutterFrequency: 13.0,
        windGustAmplitude: 0.55,
        windGustFrequency: 1.1,
        windGustDirection: Vector3(1, 0.25, 0),
      )..renderState = const RenderState(cullMode: CullMode.backFace);
      animatedWindMaterials.add(mat);

      final treeMesh = assets.buildWindTreeMesh(mat);
      for (var col = 0; col < scales.length; col++) {
        final hScale = scales[col];
        dynamicExtras.add(
          MeshComponent(
            mesh: treeMesh,
            position: Vector3(3.0 + col * 2.4, 3.2 + row * 3.5, 0),
            scale: Vector3(0.95, 0.95, hScale),
            rotation: Quaternion.axisAngle(Vector3(0, 0, 1), col * 1.25),
          ),
        );
      }
    }
  }

  void buildShadowsAndLightsLab({
    required Scene3DProjection projection,
    required ShadowGroup shadowGroup,
    required Msaa msaa,
  }) {
    // Up to 4 DirectionalLights + 8 PointLights (including finite `range` and
    // zero-intensity culled slots).
    const ptColors = [
      ui.Color(0xFFFF595E),
      ui.Color(0xFFFFCA3A),
      ui.Color(0xFF8AC926),
      ui.Color(0xFF1982C4),
      ui.Color(0xFF6A4C93),
      ui.Color(0xFF00F5D4),
      ui.Color(0xFFFF70A6),
      ui.Color(0xFFFFFFFF),
    ];
    for (var i = 0; i < 3; i++) {
      final ang = (i + 1) * 1.8;
      dynamicExtras.add(
        LightComponent.directional(
          direction: Vector3(math.cos(ang), math.sin(ang), -0.7),
          color: ptColors[i],
          intensity: 0.18,
          specular: i == 0 ? 1.0 : 0.25,
        ),
      );
    }
    for (var i = 0; i < 7; i++) {
      final a = (i / 7) * math.pi * 2;
      dynamicExtras.add(
        LightComponent.point(
          position: Vector3(
            7.0 + math.cos(a) * 4.2,
            7.0 + math.sin(a) * 4.2,
            1.1,
          ),
          color: ptColors[i],
          // Slot 3 & 6 intentionally have 0 intensity to exercise shader skip!
          intensity: (i == 3 || i == 6) ? 0.0 : 2.8,
          range: i.isEven ? 3.8 : null,
        ),
      );
    }

    // 2D world banner sandwiched at priority 3 BELOW `skyShadowLayer` (4) and
    // ABOVE `staticLayer` (1) & `dynamicLayer` (2)!
    final label2D = TextComponent(
      text: '2D LAYER SANDWICHED UNDER 3D AIRSHIPS',
      position: projection.scenePointToLocal(Vector3(7, 7, 0.2)),
      anchor: Anchor.center,
      priority: 3,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: ui.Color(0xCCBAE6FD),
          fontSize: 13,
          fontWeight: ui.FontWeight.w700,
          shadows: [Shadow(blurRadius: 3)],
        ),
      ),
    );
    world2DExtras.add(label2D);

    // 3rd Scene3DComponent sharing `shadowGroup`: flying airships cast shadows
    // onto lower 3D buildings and 2D ground!
    final skyLayer = Scene3DComponent(
      projection: projection,
      msaa: msaa,
      priority: 4,
    );
    skyLayer.world.shadowGroup = shadowGroup;
    skyLayer.world.addAll([
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
        shadows: ShadowSettings(
          fit: ShadowFit.scene,
          bounds: Aabb3.minMax(Vector3(-2, -2, -1), Vector3(16, 16, 6)),
        ),
      ),
    ]);

    final hullMat = StylizedMaterial(
      accentColor: const ui.Color(0xFFF59E0B),
      matCapTexture: assets.goldMatCap,
      matCapMetallic: 0.85,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    final hullMesh = CuboidMesh(
      size: Vector3(1.1, 0.42, 0.42),
      material: hullMat,
    );
    for (var i = 0; i < 3; i++) {
      final ship = MeshComponent(
        mesh: hullMesh,
        position: Vector3(7, 7, 2.8 + i * 0.45),
        color: ptColors[i * 2],
      );
      airships.add(ship);
      skyLayer.world.add(ship);
    }
    skyShadowLayer = skyLayer;
    world2DExtras.add(skyLayer);
  }

  void buildParticlesAndRibbonsLab({required DecalBatch3D impactDecals}) {
    attractorArrivals = 0;
    groundBounceHits = 0;
    final upRot = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);

    // 1. Spherical 4x4 animated fire flipbook (`frameBlending: true`).
    final fireFlipbook = ParticleSystem3D(
      capacity: 192,
      rotation: upRot,
      position: Vector3(3.2, 3.5, 0.25),
      material: ParticleMaterial(
        sprite: ParticleSprite.texture,
        texture: assets.flipbookFireTexture,
        flipbookColumns: 4,
        flipbookRows: 4,
        frameBlending: true,
        renderState: RenderState.additive,
      ),
      flipbook: const ParticleFlipbook3D(
        cycles: 1.5,
        randomStart: true,
      ),
      emitters: [
        ParticleEmitter3D(
          rate: 36,
          shape: const SphereEmitterShape3D(
            0.28,
            surface: true,
            hemisphere: true,
          ),
          speed: (0.8, 1.8),
          lifespan: (0.7, 1.2),
          size: (0.45, 0.75),
        ),
      ],
      sizeOverLife: ParticleCurve(0.7, 1.35),
      opacityOverLife: ParticleCurve(1.0, 0.0),
    )..prewarm(1.2);

    // 2. Cylindrical locked-axis plasma column (`BoxEmitterShape3D`).
    final cylindricalPlasma = ParticleSystem3D(
      capacity: 128,
      rotation: upRot,
      position: Vector3(10.8, 3.5, 0.2),
      material: ParticleMaterial(
        billboard: ParticleBillboard.cylindrical,
        axis: Vector3(0, 0, 1),
        color: const ui.Color(0xFF00F5D4),
        softness: 0.65,
        renderState: RenderState.additive,
      ),
      emitters: [
        ParticleEmitter3D(
          rate: 32,
          shape: const BoxEmitterShape3D(0.6, 0.2, 0.6),
          speed: (1.2, 2.4),
          lifespan: (0.6, 1.0),
          size: (0.18, 0.28),
          aspect: (2.8, 4.2),
        ),
      ],
      opacityOverLife: ParticleCurve(1, 0),
    )..prewarm(1.0);

    // 3. Flat ground shockwave rings (`DiscEmitterShape3D` radial + `Point`).
    final flatShockwaves = ParticleSystem3D(
      capacity: 96,
      rotation: upRot,
      position: Vector3(3.2, 10.5, 0.06),
      overflow: ParticleOverflow.recycle,
      material: ParticleMaterial(
        billboard: ParticleBillboard.flat,
        axis: Vector3(0, 0, 1),
        softness: 0.35,
        color: const ui.Color(0xFFA855F7),
      ),
      emitters: [
        ParticleEmitter3D(
          rate: 18,
          shape: const DiscEmitterShape3D(0.8, innerRadius: 0.35),
          speed: (0.4, 0.9),
          lifespan: (0.8, 1.3),
          size: (0.35, 0.55),
        ),
        ParticleEmitter3D(
          rate: 8,
          speed: (0.1, 0.3),
          lifespan: (0.6, 0.9),
          size: (0.5, 0.8),
        ),
      ],
      sizeOverLife: ParticleCurve(0.5, 1.8),
      opacityOverLife: ParticleCurve(0.9, 0.0),
    )..prewarm(1.0);

    // 4. Attractor portal (`consumeOnArrival: true`), ground-bounce decal
    //    spawner, and opaque cut-out (`alphaCutoff: 0.35`) local-space motes.
    final attractorSystem = ParticleSystem3D(
      capacity: 160,
      position: Vector3(9.5, 10.2, 0.8),
      material: ParticleMaterial(
        color: const ui.Color(0xFFFFBE0B),
        renderState: RenderState.additive,
      ),
      emitters: [
        ParticleEmitter3D(
          rate: 56,
          shape: const SphereEmitterShape3D(1.1, surface: true),
          speed: (0.2, 0.5),
          lifespan: (1.5, 2.5),
          size: (0.12, 0.2),
        ),
      ],
      attractors: [
        ParticleAttractor3D(
          target: Vector3(9.5, 10.2, 1.5),
          strength: 24,
          arrivalRadius: 0.45,
          onArrived: (n) => attractorArrivals += n,
        ),
      ],
    )..prewarm(0.8);

    final bounceDecalSparks = ParticleSystem3D(
      capacity: 128,
      rotation: upRot,
      position: Vector3(7.0, 10.5, 0.55),
      material: ParticleMaterial(
        billboard: ParticleBillboard.velocity,
        alphaCutoff: 0.35,
        softness: 0.25,
        renderState: RenderState.opaque,
      ),
      emitters: [
        ParticleEmitter3D(
          rate: 36,
          shape: const ConeEmitterShape3D(angle: 0.65),
          speed: (0.4, 1.0),
          lifespan: (0.9, 1.4),
          size: (0.1, 0.16),
          colors: const [ui.Color(0xFF38BDF8), ui.Color(0xFFF43F5E)],
        ),
      ],
      gravity: Vector3(0, 0, -9.5),
      ground: ParticleGround3D(
        normal: Vector3(0, 0, 1),
        height: 0.05,
        restitution: 0.5,
      ),
      onGroundHit: (pos, _) {
        groundBounceHits++;
        if (impactDecals.length < 48) {
          impactDecals.addFlatDecal(
            center: Vector3(pos.x, pos.y, 0.03),
            width: 0.45,
            height: 0.45,
            normal: Vector3(0, 0, 1),
            color: const ui.Color(0x9938BDF8),
          );
        }
      },
    )..prewarm(0.8);

    final localOrbitMotes = ParticleSystem3D(
      capacity: 48,
      space: ParticleSpace.local,
      position: Vector3(7.0, 7.0, 2.4),
      material: ParticleMaterial(
        sprite: ParticleSprite.softBlob,
        lumpiness: 0.85,
        color: const ui.Color(0xFF80FFDB),
      ),
      emitters: [
        ParticleEmitter3D(
          rate: 20,
          shape: const SphereEmitterShape3D(0.55),
          speed: (0.1, 0.3),
          lifespan: (0.8, 1.2),
          size: (0.2, 0.32),
        ),
      ],
    )..prewarm(0.8);

    // 5. Textured `RibbonMaterial3D` across additive, premultiplied, and alpha!
    final blendModes = [
      (RenderState.additive, const ui.Color(0xFF38BDF8), 5.2),
      (RenderState.premultipliedAlphaBlend, const ui.Color(0xFFF472B6), 7.0),
      (RenderState.alphaBlend, const ui.Color(0xFFFACC15), 8.8),
    ];
    for (final (state, col, yCoord) in blendModes) {
      final batch =
          StrokeBatch3D(
            material: RibbonMaterial3D(
              texture: assets.ribbonPlasmaTexture,
              edgeSoftness: 0.25,
              alphaCutoff: 0.02,
              renderState: state,
            ),
          )..addPolyline(
            [
              for (var s = 0; s <= 12; s++)
                Vector3(
                  3.5 + s * 0.58,
                  yCoord + math.sin(s * 0.7) * 0.35,
                  1.1 + math.sin((s / 12) * math.pi) * 0.9,
                ),
            ],
            width: 0.34,
            endWidth: 0.14,
            color: col,
            endOpacity: 0.65,
          );
      dynamicExtras.add(batch);
    }

    dynamicExtras.addAll([
      fireFlipbook,
      cylindricalPlasma,
      flatShockwaves,
      attractorSystem,
      bounceDecalSparks,
      localOrbitMotes,
    ]);
  }

  void buildProjectionsAndInsetsLab({required StylizedMaterial gemMat}) {
    // 1. Live `Scene3DProjection.perspective` Picture-in-Picture inset mounted
    //    in the 2D viewport!
    const pipRect = ui.Rect.fromLTWH(0, 0, 170, 120);
    final pipLayer = Scene3DComponent(
      position: Vector2(14, 152),
      size: Vector2(170, 120),
      projection: Scene3DProjection.perspective(
        eye: Vector3(2.4, 2.4, 1.8),
        target: Vector3(0, 0, 0.7),
        rect: pipRect,
        fovY: 50,
      ),
    );
    pipLayer.world.addAll([
      LightComponent.hemisphere(
        skyColor: const ui.Color(0xFFBAE6FD),
        groundColor: const ui.Color(0xFF334155),
        intensity: 0.7,
        up: Vector3(0, 0, 1),
      ),
      LightComponent.directional(
        direction: Vector3(-0.5, -0.7, -1.0),
        intensity: 1.1,
      ),
      MeshComponent(
        mesh: assets.buildCrystalTowerLodMesh(
          gemMat,
          segments: 16,
          crystalTint: const ui.Color(0xFF38BDF8),
        ),
        scale: Vector3.all(0.65),
      ),
    ]);
    perspectiveInsetLayer = pipLayer;
    viewportExtras.add(pipLayer);

    // 2. `Scene3DProjection.camera` inset right next to it!
    final camView = Matrix4.zero()
      ..setAsViewMatrix(
        Vector3(0, -3.2, 2.0),
        Vector3(0, 0, 0.4),
        Vector3(0, 0, 1),
      );
    final camProj = Matrix4.zero()..setAsPerspective(45, 130 / 120, 0.2, 30);
    final camLayer = Scene3DComponent(
      position: Vector2(192, 152),
      size: Vector2(130, 120),
      projection: Scene3DProjection.camera(
        viewMatrix: camView,
        projectionMatrix: camProj,
        rect: const ui.Rect.fromLTWH(0, 0, 130, 120),
      ),
    );
    camLayer.world.addAll([
      LightComponent.ambient(intensity: 0.8),
      LightComponent.directional(
        direction: Vector3(0.4, 0.6, -0.9),
        intensity: 1.5,
      ),
      MeshComponent(
        mesh: SphereMesh(
          radius: 0.55,
          segments: 16,
          material: SpatialMaterial(
            albedoColor: const ui.Color(0xFFA855F7),
            metallic: 0.6,
            roughness: 0.22,
          )..renderState = const RenderState(cullMode: CullMode.backFace),
        ),
        position: Vector3(0, 0, 0.4),
      ),
    ]);
    cameraProjLayer = camLayer;
    viewportExtras.add(camLayer);

    // 3. `Scene3DProjection.matrix` (Cabinet oblique 4x4 projection) inset!
    final obliqueMat = Matrix4.zero()
      ..setEntry(0, 0, 32)
      ..setEntry(0, 1, 14)
      ..setEntry(0, 3, 65)
      ..setEntry(1, 1, 14)
      ..setEntry(1, 2, -32)
      ..setEntry(1, 3, 78)
      ..setEntry(2, 0, -0.01)
      ..setEntry(2, 1, -0.02)
      ..setEntry(2, 2, -0.01)
      ..setEntry(2, 3, 0.5)
      ..setEntry(3, 3, 1.0);
    final obliqueLayer = Scene3DComponent(
      position: Vector2(330, 152),
      size: Vector2(130, 120),
      projection: Scene3DProjection.matrix(obliqueMat),
    );
    obliqueLayer.world.addAll([
      LightComponent.ambient(intensity: 0.9),
      MeshComponent(
        mesh: CuboidMesh(
          size: Vector3.all(1.1),
          material: UnlitMaterial(albedoColor: const ui.Color(0xFF34D399))
            ..renderState = RenderState.opaque,
        ),
        position: Vector3(0, 0, 0.55),
      ),
    ]);
    obliqueMatrixLayer = obliqueLayer;
    viewportExtras.add(obliqueLayer);

    // 4. `Line3D.generate` RGB XYZ coordinate gizmo in main 3D scene!
    final red = UnlitMaterial(albedoColor: const ui.Color(0xFFEF4444))
      ..renderState = RenderState.opaque;
    final green = UnlitMaterial(albedoColor: const ui.Color(0xFF22C55E))
      ..renderState = RenderState.opaque;
    final blue = UnlitMaterial(albedoColor: const ui.Color(0xFF3B82F6))
      ..renderState = RenderState.opaque;
    final origin = Vector3(3.2, 3.2, 0.25);
    dynamicExtras.addAll([
      Line3D.generate(
        start: origin,
        end: origin + Vector3(2.2, 0, 0),
        radius: 0.045,
        material: red,
      ),
      Line3D.generate(
        start: origin,
        end: origin + Vector3(0, 2.2, 0),
        radius: 0.045,
        material: green,
      ),
      Line3D.generate(
        start: origin,
        end: origin + Vector3(0, 0, 2.2),
        radius: 0.045,
        material: blue,
      ),
    ]);
  }

  void buildModelsAnd32BitMeshLab() {
    onceClipCompletions = 0;

    // 1. 26-float `StylizedMaterial.skinnedVertexLayout` rig + Crown toggle.
    final skin26Mat = StylizedMaterial(
      accentColor: const ui.Color(0xFFFF70A6),
      emissiveColor: const ui.Color(0xFF72EFDD),
      matCapTexture: assets.coatMatCap,
      gemMatCapTexture: assets.gemMatCap,
      gemThreshold: 1.2,
      windAmplitude: 0.04,
    );
    animatedWindMaterials.add(skin26Mat);
    stylized26Rig = ModelComponent(
      model: assets.buildStylized26SkinnedModel(skin26Mat),
      position: Vector3(4.2, 4.2, 0.15),
      color: const ui.Color(0xFF38BDF8),
    )..playAnimationByName('Wave');
    dynamicExtras.add(stylized26Rig!);

    // 2. Parsed Wavefront `.obj` + `.mtl` two-material gem!
    if (parsedObjModel case final objModel?) {
      dynamicExtras.add(
        ModelComponent(
          model: objModel,
          position: Vector3(9.8, 4.2, 1.1),
        ),
      );
    }

    // 3. Parsed binary `.glb` (`skeleton.glb`) when available in bundle!
    if (parsedGlbModel case final glb?) {
      final skel = ModelComponent(
        model: glb,
        position: Vector3(4.2, 9.8, 0.1),
        rotation: Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2),
        scale: Vector3.all(0.85),
      );
      if (glb.animationNames.contains('Cheer')) {
        skel.playAnimationByName('Cheer');
      } else if (glb.animations.isNotEmpty) {
        skel.playAnimationByIndex(0);
      }
      dynamicExtras.add(skel);
    }

    // 4. `260 x 260 = 67,600`-vertex (`> 65,535`) 32-bit `Uint32List` wave!
    final waveMat = SpatialMaterial(
      metallic: 0.45,
      roughness: 0.28,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    wave32BitTerrain = MeshComponent(
      mesh: assets.buildHighPoly32BitWaveMesh(waveMat),
      position: Vector3(9.6, 9.6, 0.42),
      castsShadows: false,
    );
    staticExtras.add(wave32BitTerrain!);
  }

  void buildExtremeStressLab({required StylizedMaterial rigMat}) {
    final models = assets.buildArticulatedModels(
      bodyMaterial: rigMat,
      outlineMaterial: OutlineMaterial(
        color: const ui.Color(0xFF00F5D4),
        thickness: 0.04,
        screenSpace: true,
      ),
    );
    for (var i = 0; i < 6; i++) {
      final a = (i / 6) * math.pi * 2;
      final rig = ModelComponent(
        model: models.shaded,
        position: Vector3(
          7.0 + math.cos(a) * 3.8,
          7.0 + math.sin(a) * 3.8,
          0.2,
        ),
        color: ShowcaseAssets.accentPalette[(i * 3) % 16],
      )..playAnimationByName(i.isEven ? 'Swing' : 'Spin');
      extraSkinnedRigs.add(rig);
      dynamicExtras.add(rig);
    }
  }

  void buildPbrV2AndSinglePieceLab() {
    final upright = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);

    // 1. SpatialMaterial with normal, ORM, occlusion, and emissive maps +
    //    directional shadow & fog reception.
    pbrCobbleMaterial = SpatialMaterial(
      albedoColor: const ui.Color(0xFFCBD5E1),
      metallic: 1.0,
      roughness: 1.0,
      normalTexture: v2.cobbleNormalTexture,
      normalScale: 1.55,
      metallicRoughnessTexture: v2.cobbleOrmTexture,
      occlusionTexture: v2.cobbleOrmTexture,
      occlusionStrength: 0.85,
      emissiveTexture: v2.cobbleEmissiveTexture,
      emissiveColor: const ui.Color(0xFF38BDF8),
      emissiveStrength: 1.4,
      uvScale: Vector2.all(2.0),
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    staticExtras.addAll([
      MeshComponent(
        mesh: CuboidMesh(
          size: Vector3(2.4, 2.4, 0.35),
          material: pbrCobbleMaterial,
        ),
        position: Vector3(3.6, 3.6, 0.18),
      ),
      MeshComponent(
        mesh: SphereMesh(
          radius: 0.58,
          segments: 22,
          material: pbrCobbleMaterial,
        ),
        position: Vector3(3.6, 3.6, 0.95),
      ),
    ]);

    // 2. Equirectangular `environmentTexture` chrome reflection orb!
    pbrEnvMaterial = SpatialMaterial(
      metallic: 1.0,
      roughness: 0.06,
      environmentTexture: v2.equirectEnvTexture,
      environmentIntensity: 1.45,
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    staticExtras.add(
      MeshComponent(
        mesh: SphereMesh(radius: 0.68, segments: 24, material: pbrEnvMaterial),
        position: Vector3(9.8, 3.6, 0.85),
      ),
    );

    // 3. `alphaCutoff` + `doubleSided` perforated PBR lattice panel!
    pbrCutoutMaterial = SpatialMaterial(
      albedoTexture: v2.perforatedCutoutTexture,
      metallic: 0.65,
      roughness: 0.32,
      alphaCutoff: 0.45,
      doubleSided: true,
    );
    staticExtras.add(
      MeshComponent(
        mesh: PlaneMesh(size: Vector2(2.2, 1.5), material: pbrCutoutMaterial),
        position: Vector3(10.2, 7.2, 0.9),
        rotation: upright,
      ),
    );

    // 4. Built-in `singlePieceTranslucent: true` (`RenderState.depthPrepass`)
    //    on a multi-node SKINNED `ModelComponent`!
    final ghostSkinMat = StylizedMaterial(
      albedoColor: const ui.Color(0xFF67E8F9),
      accentColor: const ui.Color(0xFFF472B6),
      matCapTexture: assets.coatMatCap,
      matCapStrength: 0.6,
      translucent: true,
      singlePieceTranslucent: true,
    );
    singlePieceSkinnedGhost = ModelComponent(
      model: assets.buildStylized26SkinnedModel(ghostSkinMat),
      position: Vector3(4.2, 9.8, 0.15),
      instanceData: Vector4(0, 0, 0, 0.45),
      castsShadows: false,
    )..playAnimationByName('Wave');
    dynamicExtras.add(singlePieceSkinnedGhost!);

    // 5. Bayer 4x4 `ditherFade: true` opaque dissolve pillars (0 overdraw!).
    final ditherStylized = StylizedMaterial(
      accentColor: const ui.Color(0xFFFBBF24),
      matCapTexture: assets.goldMatCap,
      ditherFade: true,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    final ditherPbr = SpatialMaterial(
      albedoColor: const ui.Color(0xFFA855F7),
      metallic: 0.5,
      roughness: 0.3,
      ditherFade: true,
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    final pillarA = MeshComponent(
      mesh: assets.buildCrystalTowerLodMesh(
        ditherStylized,
        segments: 12,
        crystalTint: const ui.Color(0xFF38BDF8),
      ),
      position: Vector3(8.2, 10.2, 0),
      instanceData: Vector4(0, 0, 0, 0.35),
    );
    final pillarB = MeshComponent(
      mesh: CapsuleMesh(radius: 0.38, height: 1.7, material: ditherPbr),
      position: Vector3(10.4, 10.2, 0.9),
      rotation: upright,
      instanceData: Vector4(0, 0, 0, 0.55),
    );
    ditherPillars.addAll([pillarA, pillarB]);
    dynamicExtras.addAll(ditherPillars);
  }

  void buildSkinning64MorphIkLayersLab() {
    // 1. 32-joint (`> 16`, up to `64`) `CubicSpline` undulating serpent!
    final serpentMat = StylizedMaterial(
      accentColor: const ui.Color(0xFF00F5D4),
      matCapTexture: assets.coatMatCap,
      gemMatCapTexture: assets.gemMatCap,
    );
    serpent32BoneRig = ModelComponent(
      model: v2.buildSerpent32BoneModel(serpentMat),
      position: Vector3(3.2, 3.6, 0.65),
    )..playAnimationByName('Slither');

    // 2. Morph-target crystal (`MorphTargetData` + `MorphWeightsChannel`)!
    final morphMat = SpatialMaterial(
      albedoColor: const ui.Color(0xFFF472B6),
      metallic: 0.35,
      roughness: 0.18,
      environmentTexture: v2.equirectEnvTexture,
      environmentIntensity: 0.95,
      emissiveColor: const ui.Color(0xFF38BDF8),
      emissiveStrength: 0.35,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    morphCrystalRig = ModelComponent(
      model: v2.buildMorphCrystalModel(morphMat),
      position: Vector3(10.2, 9.6, 0.95),
    )..playAnimationByName('Breathe');

    // 3. Dual-layer character (`Bounce` base + `UpperWave` overlay layer) +
    //    `TwoBoneIkConstraint3D` + `LookAtConstraint3D` + `SpringBone3D`!
    final charMat = SpatialMaterial(
      albedoColor: const ui.Color(0xFF60A5FA),
      metallic: 0.4,
      roughness: 0.35,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    final charModel = v2.buildLayeredIkCharacterModel(charMat);
    final upperClip = charModel.animations.firstWhere(
      (a) => a.name == 'UpperWave',
    );

    final targetPos = Vector3(5.2, 9.6, 1.35);
    ikTargetOrb = MeshComponent(
      mesh: SphereMesh(
        radius: 0.18,
        segments: 12,
        material: UnlitMaterial(albedoColor: const ui.Color(0xFFFACC15))
          ..renderState = RenderState.opaque,
      ),
      position: targetPos.clone(),
      castsShadows: false,
    );

    twoBoneIk = TwoBoneIkConstraint3D(
      rootNodeName: 'Shoulder',
      midNodeName: 'Elbow',
      tipNodeName: 'Hand',
      targetWorld: targetPos,
      poleWorld: Vector3(4.2, 11.2, 1.8),
    );
    lookAtHead = LookAtConstraint3D(
      nodeName: 'Head',
      targetWorld: targetPos,
      forwardAxis: Vector3(0, 0, 1),
      maxAngle: 1.2,
    );
    springAntenna = SpringBone3D(
      nodeName: 'Antenna',
      localTipOffset: Vector3(0, 0.6, 0),
      stiffness: 18.0,
      damping: 4.5,
      gravity: Vector3(0, 0, -2.5),
    );

    layeredIkRig = ModelComponent(
      model: charModel,
      position: Vector3(4.2, 9.8, 0.1),
    )..playAnimationByName('Bounce');
    layeredIkRig!
        .addOverlayLayer(boneNames: const {'WaveArm'}, weight: 0.85)
        .state
        .startAnimation(upperClip);
    layeredIkRig!.boneModifiers.addAll([
      twoBoneIk!,
      lookAtHead!,
      springAntenna!,
    ]);

    dynamicExtras.addAll([
      serpent32BoneRig!,
      morphCrystalRig!,
      layeredIkRig!,
      ikTargetOrb!,
    ]);
  }

  void buildWaterTerrainAndHd2dLab() {
    final upright = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);

    // 1. `TerrainMesh3D.procedural` (`TerrainUpAxis.z`) island with height &
    //    slope color splatting!
    final terrainMat = SpatialMaterial(
      metallic: 0.08,
      roughness: 0.78,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    islandTerrain = TerrainMesh3D.procedural(
      columns: 44,
      rows: 44,
      width: 8.4,
      depth: 8.4,
      amplitude: 1.35,
      frequency: 0.55,
      upAxis: TerrainUpAxis.z,
      material: terrainMat,
      colorRamp: (h, slope) {
        if (h < 0.22) {
          return const ui.Color(0xFFE9C46A); // Sandy shore
        }
        if (slope > 0.3) {
          return const ui.Color(0xFF64748B); // Cliff rock
        }
        return h > 0.85
            ? const ui.Color(0xFFF1F5F9) // Snow peak
            : const ui.Color(0xFF2A9D8F); // Lush meadow
      },
    );
    staticExtras.add(
      MeshComponent(
        mesh: islandTerrain!,
        position: Vector3(7.0, 7.0, 0.05),
      ),
    );

    // 2. Animated 4-wave Gerstner `WaterMaterial` lagoon!
    lagoonWaterMaterial = WaterMaterial(
      upAxis: Vector3(0, 0, 1),
      waveAmplitude: 0.075,
      waveFrequency: 1.9,
      waveSpeed: 2.1,
      steepness: 0.48,
    );
    final waterMesh = TerrainMesh3D(
      columns: 36,
      rows: 36,
      width: 11.6,
      depth: 11.6,
      upAxis: TerrainUpAxis.z,
      heights: Float32List(36 * 36),
      material: lagoonWaterMaterial,
    );
    dynamicExtras.add(
      MeshComponent(
        mesh: waterMesh,
        position: Vector3(7.0, 7.0, 0.26),
        castsShadows: false,
      ),
    );

    // 3. Smooth arched `TubeSplineMesh` (`CatmullRomSpline3D`) bridge +
    //    `CapsuleMesh` & `TorusMesh` monuments + `DecalBatch3D.addBlobShadow`!
    final spline = CatmullRomSpline3D([
      Vector3(2.2, 3.2, 0.35),
      Vector3(4.8, 4.6, 1.55),
      Vector3(9.2, 9.4, 1.55),
      Vector3(11.8, 10.8, 0.35),
    ]);
    splineAqueduct = MeshComponent(
      mesh: TubeSplineMesh(
        spline: spline,
        radius: 0.16,
        crossSectionAspect: 1.8,
        color: const ui.Color(0xFF90E0EF),
        material: SpatialMaterial(
          metallic: 0.55,
          roughness: 0.25,
          environmentTexture: v2.equirectEnvTexture,
          environmentIntensity: 0.55,
        )..renderState = const RenderState(cullMode: CullMode.backFace),
      ),
    );
    staticExtras.add(splineAqueduct!);

    final ringMat = SpatialMaterial(
      albedoColor: const ui.Color(0xFFFFBE0B),
      metallic: 0.85,
      roughness: 0.2,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    blobShadowDecals = DecalBatch3D(material: DecalMaterial(softness: 0.45));

    const propOffsets = [(-1.8, -1.6), (1.8, -1.6), (-1.6, 1.9), (1.7, 1.7)];
    for (var i = 0; i < propOffsets.length; i++) {
      final (lx, ly) = propOffsets[i];
      final wx = 7.0 + lx;
      final wy = 7.0 + ly;
      final groundZ = 0.05 + islandTerrain!.sampleHeight(lx, ly);
      final groundN = islandTerrain!.sampleNormal(lx, ly);
      if (i.isEven) {
        staticExtras.add(
          MeshComponent(
            mesh: CapsuleMesh(radius: 0.2, height: 0.78, material: ringMat),
            position: Vector3(wx, wy, groundZ + 0.39),
            rotation: upright,
          ),
        );
      } else {
        staticExtras.add(
          MeshComponent(
            mesh: TorusMesh(
              majorRadius: 0.36,
              minorRadius: 0.1,
              material: ringMat,
            ),
            position: Vector3(wx, wy, groundZ + 0.85),
            rotation: upright,
          ),
        );
        blobShadowDecals!.addBlobShadow(
          groundPoint: Vector3(wx, wy, math.max(0.28, groundZ + 0.03)),
          radius: 0.52,
          elevation: 0.85,
          normal: groundN,
        );
      }
    }
    dynamicExtras.add(blobShadowDecals!);

    // 4. `BillboardBatch3D` HD-2D cylindrical standees + `Text3DComponent`!
    standeeBatch = BillboardBatch3D(
      material: BillboardMaterial3D(
        albedoTexture: v2.standeeAtlasTexture,
        shadeWeight: 0.55,
      ),
    );
    const atlasCells = [
      ui.Rect.fromLTWH(0.0, 0.0, 0.5, 0.5),
      ui.Rect.fromLTWH(0.5, 0.0, 0.5, 0.5),
      ui.Rect.fromLTWH(0.0, 0.5, 0.5, 0.5),
      ui.Rect.fromLTWH(0.5, 0.5, 0.5, 0.5),
    ];
    const partyCoords = [
      (-0.7, -0.5, 'KNIGHT'),
      (0.7, -0.4, 'MAGE'),
      (-0.5, 0.8, 'RANGER'),
      (0.6, 0.7, 'PALADIN'),
    ];
    for (var i = 0; i < partyCoords.length; i++) {
      final (px, py, role) = partyCoords[i];
      final gz = math.max(0.28, 0.05 + islandTerrain!.sampleHeight(px, py));
      standeeBatch!.addBillboard(
        position: Vector3(7.0 + px, 7.0 + py, gz),
        width: 0.72,
        height: 0.92,
        upAxis: Vector3(0, 0, 1),
        tiltRadians: 0.14,
        uvRect: atlasCells[i],
      );
      final badge = Text3DComponent(
        text: role,
        worldHeight: 0.28,
        upAxis: Vector3(0, 0, 1),
        position: Vector3(7.0 + px, 7.0 + py, gz + 1.12),
      );
      text3DBadges.add(badge);
      dynamicExtras.add(badge);
    }
    dynamicExtras.add(standeeBatch!);
  }

  void buildSpotLightsCullingAndPostLab() {
    // 1. 4 sweeping colored `SpotLight` searchlights!
    const spotColors = [
      ui.Color(0xFF38BDF8),
      ui.Color(0xFFF472B6),
      ui.Color(0xFF34D399),
      ui.Color(0xFFFBBF24),
    ];
    const corners = [(2.2, 2.2), (11.8, 2.2), (2.2, 11.8), (11.8, 11.8)];
    for (var i = 0; i < 4; i++) {
      final (cx, cy) = corners[i];
      final spot = LightComponent.spot(
        position: Vector3(cx, cy, 3.6),
        direction: Vector3(7.0 - cx, 7.0 - cy, -3.4),
        color: spotColors[i],
        intensity: 14.0,
        range: 14.0,
        innerConeAngle: 0.16,
        outerConeAngle: 0.46,
      );
      sweepingSpotLights.add(spot);
      dynamicExtras.add(spot);
    }

    // 2. 32 `PointLight` streetlamps across the 14x14 arena (culled to the 8
    //    nearest active lights by `World3D.prioritizeNearestLights`)!
    for (var i = 0; i < 32; i++) {
      final row = i ~/ 8;
      final col = i % 8;
      final lx = 1.6 + col * 1.54;
      final ly = 2.0 + row * 3.3;
      final lampColor = ShowcaseAssets.accentPalette[i % 16];
      final lamp = LightComponent.point(
        position: Vector3(lx, ly, 0.95),
        color: lampColor,
        intensity: 2.2,
        range: 3.2,
      );
      culledStreetLamps.add(lamp);
      dynamicExtras.add(lamp);

      staticExtras.add(
        MeshComponent(
          mesh: SphereMesh(
            radius: 0.11,
            segments: 8,
            material: UnlitMaterial(albedoColor: lampColor)
              ..renderState = RenderState.opaque,
          ),
          position: Vector3(lx, ly, 0.95),
          castsShadows: false,
        ),
      );
    }
  }

  /// Lab 13: 3D Input (`TapCallbacks3D`, `HoverCallbacks3D`, `DragCallbacks3D`,
  /// 1D axis gizmo), 3D Effects (`ArcMoveEffect3D`, `SplinePathEffect3D`,
  /// `SquashStretchEffect3D`, `RotateAroundEffect3D`, `InstanceDataEffect3D`),
  /// and `FixedTransformInterpolation3D`.
  void buildInputEffectsAndCameraRigsLab({
    required Scene3DComponent dynamicLayer,
    required StylizedMaterial gemMat,
  }) {
    final upright = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);

    pointerRouter3D = PointerRouter3D.forScene(
      dynamicLayer,
      defaultDragNormal: Vector3(0, 0, 1),
      priority: 10,
    );
    world2DExtras.add(pointerRouter3D!);

    // 1. Free ray-plane draggable + tap + hover + FixedTransformInterpolation3D
    //    crystal totem.
    final totemMat = StylizedMaterial(
      matCapTexture: assets.coatMatCap,
      gemMatCapTexture: assets.gemMatCap,
      emissiveColor: const ui.Color(0xFF38BDF8),
      emissiveBoostColor: const ui.Color(0xFFFFBE0B),
      emissiveStrength: 1.1,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    interactiveTotem = InteractiveCrystalTotem3D(
      mesh: assets.buildCrystalTowerLodMesh(
        totemMat,
        segments: 16,
        crystalTint: const ui.Color(0xFF67E8F9),
      ),
      position: Vector3(4.2, 8.8, 0.05),
    )..instanceData.x = 0.25;
    dynamicExtras.add(interactiveTotem!);

    // 2. 1D X-axis gizmo slider (`dragAxisConstraint = Vector3(1, 0, 0)`) on a
    //    rail.
    staticExtras.add(
      MeshComponent(
        mesh: CuboidMesh(
          size: Vector3(6.6, 0.1, 0.08),
          material: SpatialMaterial(
            albedoColor: const ui.Color(0xFF64748B),
            metallic: 0.7,
            roughness: 0.3,
          )..renderState = const RenderState(cullMode: CullMode.backFace),
        ),
        position: Vector3(7.0, 10.8, 0.45),
      ),
    );
    axisGizmoSlider = AxisGizmoSlider3D(
      mesh: CuboidMesh(
        size: Vector3(0.75, 0.55, 0.55),
        material: SpatialMaterial(
          albedoColor: const ui.Color(0xFFF59E0B),
          metallic: 0.4,
          roughness: 0.25,
        )..renderState = const RenderState(cullMode: CullMode.backFace),
      ),
      position: Vector3(7.0, 10.8, 0.55),
    );
    dynamicExtras.add(axisGizmoSlider!);

    // 3. `SplinePathEffect3D(orientToTangent: true)` gliding shuttle.
    final flightSpline = CatmullRomSpline3D([
      Vector3(2.8, 3.2, 1.35),
      Vector3(6.8, 2.2, 2.25),
      Vector3(11.2, 4.8, 1.55),
      Vector3(9.6, 8.6, 2.35),
      Vector3(2.8, 3.2, 1.35),
    ]);
    splineShuttle =
        MeshComponent(
          mesh: ConeMesh(
            radius: 0.28,
            height: 0.85,
            segments: 14,
            material: gemMat,
          ),
          position: Vector3(2.8, 3.2, 1.35),
          color: const ui.Color(0xFFA78BFA),
        )..add(
          SplinePathEffect3D(
            flightSpline,
            EffectController(duration: 4.5, infinite: true),
            orientToTangent: true,
            upAxis: Vector3(0, 0, 1),
          ),
        );
    dynamicExtras.add(splineShuttle!);

    // 4. `ArcMoveEffect3D` + `RotateAroundEffect3D` + `InstanceDataEffect3D`.
    arcJumpOrb =
        MeshComponent(
          mesh: SphereMesh(
            radius: 0.34,
            segments: 16,
            material: gemMat,
          ),
          position: Vector3(3.2, 4.6, 0.45),
          color: const ui.Color(0xFF34D399),
        )..addAll([
          ArcMoveEffect3D(
            Vector3(6.2, 4.6, 0.45),
            EffectController(duration: 1.25, alternate: true, infinite: true),
            arcHeight: 1.65,
            upAxis: Vector3(0, 0, 1),
          ),
          InstanceDataEffect3D(
            Vector4(0.95, 0.5, 0.0, 0.0),
            EffectController(duration: 0.9, alternate: true, infinite: true),
          ),
        ]);
    final moonOrb =
        MeshComponent(
          mesh: CapsuleMesh(
            radius: 0.16,
            height: 0.52,
            material: SpatialMaterial(
              albedoColor: const ui.Color(0xFFF472B6),
              metallic: 0.65,
              roughness: 0.2,
            )..renderState = const RenderState(cullMode: CullMode.backFace),
          ),
          position: Vector3(10.6, 5.2, 1.15),
          rotation: upright,
        )..add(
          RotateAroundEffect3D(
            axis: Vector3(0, 0, 1),
            radians: math.pi * 2.0,
            pivot: Vector3(9.6, 5.2, 1.15),
            controller: EffectController(duration: 2.8, infinite: true),
          ),
        );
    dynamicExtras.addAll([arcJumpOrb!, moonOrb]);
  }

  /// Lab 14: `PhysicsWorld3D` (`RigidBody3D`, `throwDice3D`, `HingeJoint3D`),
  /// `CollisionSystem3D` + `TriggerVolume3D`, `KinematicCharacterController3D`,
  /// `NavMesh3D` + `CrowdSteering3D`, `SkinnedHitboxRig3D`, and
  /// `SpatialAudio3D`.
  void buildPhysicsCollidersKinematicAndNavMeshLab({
    required World3D dynamicWorld,
    required ModelComponent automaton,
  }) {
    final upright = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);

    // 1. Sequential Impulse `PhysicsWorld3D` (`+Z` up -> gravity `(0,0,-9.81)`)
    //    with tumbling dice & a hinged pendulum!
    physicsWorld = PhysicsWorld3D(gravity: Vector3(0, 0, -9.81));
    dynamicWorld.add(physicsWorld!);

    final arenaFloorBody = RigidBody3D(
      shape: BoxShape3D(halfExtents: Vector3(7.0, 7.0, 0.25)),
      bodyType: BodyType3D.static,
      restitution: 0.42,
      friction: 0.6,
      syncParent: false,
      position: Vector3(7.0, 7.0, -0.25),
    );
    dynamicExtras.add(arenaFloorBody);

    final dieColors = [
      const ui.Color(0xFFEF4444),
      const ui.Color(0xFF3B82F6),
      const ui.Color(0xFF10B981),
      const ui.Color(0xFFF59E0B),
    ];
    for (var i = 0; i < 4; i++) {
      final body = RigidBody3D(
        shape: BoxShape3D(halfExtents: Vector3.all(0.28)),
        restitution: 0.46,
        friction: 0.55,
      );
      final dieMesh = MeshComponent(
        mesh: CuboidMesh(
          size: Vector3.all(0.56),
          material: SpatialMaterial(
            albedoColor: dieColors[i],
            metallic: 0.2,
            roughness: 0.32,
          )..renderState = const RenderState(cullMode: CullMode.backFace),
        ),
        position: Vector3(5.6 + i * 0.85, 9.8, 2.4),
        children: [body],
      );
      diceRigidBodies.add(body);
      dynamicExtras.add(dieMesh);
    }
    physicsWorld!.throwDice3D(
      diceRigidBodies,
      seed: 2026,
      origin: Vector3(6.8, 9.8, 2.8),
      throwVelocity: Vector3(0.35, -0.55, -2.4),
    );

    // Hinged pendulum at `(2.8, 10.6, 2.8)`
    final hingeAnchor = RigidBody3D(
      shape: SphereShape3D(radius: 0.12),
      bodyType: BodyType3D.static,
      syncParent: false,
      position: Vector3(2.8, 10.6, 2.8),
    );
    pendulumBobBody = RigidBody3D(
      shape: SphereShape3D(radius: 0.3),
      mass: 1.5,
      linearDamping: 0.02,
      angularDamping: 0.02,
    );
    final pendulumBob = MeshComponent(
      mesh: SphereMesh(
        radius: 0.3,
        segments: 14,
        material: SpatialMaterial(
          albedoColor: const ui.Color(0xFFEAB308),
          metallic: 0.85,
          roughness: 0.2,
        )..renderState = const RenderState(cullMode: CullMode.backFace),
      ),
      position: Vector3(3.75, 10.6, 2.05),
      children: [pendulumBobBody!],
    );
    pendulumHinge = HingeJoint3D(
      bodyA: hingeAnchor,
      bodyB: pendulumBobBody!,
      localAnchorB: Vector3(-0.95, 0.0, 0.75),
      localAxisA: Vector3(0, 1, 0),
      minAngle: -1.35,
      maxAngle: 1.35,
    );
    physicsWorld!.addJoint(pendulumHinge!);
    dynamicExtras.addAll([hingeAnchor, pendulumBob]);

    // 2. `CollisionSystem3D` + `TriggerVolume3D` + `CollisionBeacon3D` +
    //    `KinematicCharacterController3D` climbing a 2-step staircase!
    collisionSystem = CollisionSystem3D();
    dynamicWorld.add(collisionSystem!);

    // Ground & 2 walkable steps (`z = 0.0..0.22`, `0.22..0.44`) inside
    // `dynamicWorld` so `collisionSystem` indexes them!
    final stepMat = SpatialMaterial(
      albedoColor: const ui.Color(0xFF64748B),
      roughness: 0.62,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    dynamicExtras.add(
      Collider3D(
        shape: BoxShape3D(halfExtents: Vector3(7.0, 7.0, 0.25)),
        isStatic: true,
        position: Vector3(7.0, 7.0, -0.25),
      ),
    );
    for (var s = 0; s < 2; s++) {
      final topZ = (s + 1) * 0.22;
      final widthX = s == 1 ? 1.55 : 0.95;
      final cx = s == 1 ? 10.45 : 9.2;
      dynamicExtras.add(
        MeshComponent(
          mesh: CuboidMesh(
            size: Vector3(widthX, 1.4, topZ),
            material: stepMat,
          ),
          position: Vector3(cx, 11.4, topZ * 0.5),
          children: [
            Collider3D(
              shape: BoxShape3D(
                halfExtents: Vector3(widthX * 0.5, 0.7, topZ * 0.5),
              ),
              isStatic: true,
            ),
          ],
        ),
      );
    }

    triggerPad = TriggerVolume3D(
      shape: BoxShape3D(halfExtents: Vector3(0.65, 0.65, 0.55)),
      position: Vector3(10.35, 11.4, 0.75),
      onEnter3D: (_, _) => triggerEnters++,
      onExit3D: (_) => triggerExits++,
    );
    collisionBeacon = CollisionBeacon3D(
      mesh: TorusMesh(
        majorRadius: 0.45,
        minorRadius: 0.07,
        material: UnlitMaterial()..renderState = RenderState.opaque,
      ),
      colliderShape: SphereShape3D(radius: 0.35),
      position: Vector3(10.65, 11.4, 0.82),
      color: const ui.Color(0xFF38BDF8),
    )..rotation.setFrom(upright);

    kinematicController = KinematicCharacterController3D(
      radius: 0.26,
      height: 0.86,
      upAxis: Axis3D.z,
      stepOffset: 0.28,
      capsuleOffset: Vector3(0, 0, 0.43),
    );
    kinematicActor = MeshComponent(
      mesh: CapsuleMesh(
        radius: 0.26,
        height: 0.86,
        material: SpatialMaterial(
          albedoColor: const ui.Color(0xFFEC4899),
          metallic: 0.35,
          roughness: 0.3,
        )..renderState = const RenderState(cullMode: CullMode.backFace),
      ),
      position: Vector3(8.1, 11.4, 0.0),
      rotation: upright,
      children: [
        kinematicController!,
        Collider3D(
          shape: SphereShape3D(radius: 0.28),
          localOffset: Vector3(0, 0.43, 0),
        ),
      ],
    );
    dynamicExtras.addAll([triggerPad!, collisionBeacon!, kinematicActor!]);

    // 3. `NavMesh3D.fromMesh` + `CrowdSteering3D` (4 RVO agents crossing ramp).
    final navTerrainMesh = v3.buildSteppedPlazaNavMesh(
      SpatialMaterial(
        albedoColor: const ui.Color(0xFF1E3A5F),
        roughness: 0.55,
      )..renderState = RenderState.opaque,
    );
    staticExtras.add(MeshComponent(mesh: navTerrainMesh));
    steppedNavMesh = NavMesh3D.fromMesh(
      navTerrainMesh,
      upAxis: Vector3(0, 0, 1),
    );
    crowdSteering = CrowdSteering3D(
      navMesh: steppedNavMesh,
      upAxis: Vector3(0, 0, 1),
    );
    const agentStarts = [
      (2.8, 3.6, 11.2, 6.2),
      (2.8, 6.4, 11.2, 4.6),
      (11.2, 4.6, 2.8, 6.4),
      (11.2, 6.2, 2.8, 3.6),
    ];
    for (var i = 0; i < agentStarts.length; i++) {
      final (sx, sy, gx, gy) = agentStarts[i];
      final sz = steppedNavMesh!.sampleHeightAt(Vector3(sx, sy, 0.5)) ?? 0.05;
      final gz = steppedNavMesh!.sampleHeightAt(Vector3(gx, gy, 0.8)) ?? 0.65;
      final marker = MeshComponent(
        mesh: ConeMesh(
          radius: 0.22,
          height: 0.62,
          segments: 12,
          material: SpatialMaterial(
            albedoColor: ShowcaseAssets.accentPalette[(i * 3) % 16],
            roughness: 0.35,
          )..renderState = const RenderState(cullMode: CullMode.backFace),
        ),
        position: Vector3(sx, sy, sz + 0.31),
        rotation: upright,
      );
      dynamicExtras.add(marker);
      final agent = CrowdAgent3D(
        position: Vector3(sx, sy, sz),
        radius: 0.28,
        maxSpeed: 2.4,
        targetComponent: marker,
      )..setDestination(Vector3(gx, gy, gz), steppedNavMesh!);
      crowdSteering!.addAgent(agent);
    }

    // 4. `SkinnedHitboxRig3D` (`BoneHitbox3D`) on the articulated `automaton`!
    skinnedHitboxRig = SkinnedHitboxRig3D(
      model: automaton,
      hitboxes: [
        BoneHitbox3D.byName(
          'Base',
          shape: SphereShape3D(radius: 0.42),
        ),
        BoneHitbox3D.byName(
          'ArmTip',
          shape: SphereShape3D(radius: 0.36),
          damageMultiplier: 2.0,
        ),
      ],
    );
    automaton.add(skinnedHitboxRig!);

    // 5. `SpatialAudioListener3D` + orbiting `SpatialAudioEmitter3D`!
    audioListener3D = SpatialAudioListener3D(
      position: Vector3(7.0, 7.0, 1.5),
    );
    audioEmitter3D = SpatialAudioEmitter3D(
      minDistance: 1.2,
      maxDistance: 18.0,
      enableOcclusion: true,
      position: Vector3(10.0, 7.0, 1.5),
    );
    dynamicExtras.addAll([audioListener3D!, audioEmitter3D!]);
  }

  /// Lab 15: `BlendSpace1D` & `BlendSpace2D`, `AnimationEvent3D`,
  /// `RootMotionExtractor3D`, `OffscreenAnimationPolicy`, 64-agent
  /// `SkinnedCrowdBatch3D`, `SceneLoader3D` (6 glTF extensions + `extras`),
  /// and `AsyncModelLoader3D` + `AssetScope3D`.
  void buildBlendTreesCrowdSceneLoaderAndIsolateLab({
    required Model crowdModel,
  }) {
    final locoMat = SpatialMaterial(
      albedoColor: const ui.Color(0xFF38BDF8),
      metallic: 0.35,
      roughness: 0.32,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    final locoModel = v3.buildLocomotionBlendModel(locoMat);
    final clips = {for (final a in locoModel.animations) a.name!: a};

    // 1. `BlendSpace1D` (`Idle` @ 0, `Walk` @ 2, `Run` @ 5) +
    //    `AnimationEvent3D` + `RootMotionExtractor3D`.
    final space1D = BlendSpace1D(
      samples: [
        BlendSample1D(animation: clips['Idle']!, position: 0.0),
        BlendSample1D(animation: clips['Walk']!, position: 2.0),
        BlendSample1D(animation: clips['Run']!, position: 5.0),
      ],
    );
    walkerRootMotion = RootMotionExtractor3D(
      rootNodeName: 'Hips',
      horizontalPlane: RootMotionPlane3D.xy,
    );
    blend1DWalker = ModelComponent(
      model: locoModel,
      position: Vector3(3.2, 9.6, 0.05),
      color: const ui.Color(0xFF38BDF8),
      rootMotion: walkerRootMotion,
      onAnimationEvent: (_) => animEventsFired++,
    )..playBlendSpace1D(space1D, initialValue: 3.2);

    // 2. `BlendSpace2D` (`Idle`, `Walk`, `StrafeL`, `StrafeR`) +
    //    `OffscreenAnimationPolicy.tickOnlyEvaluateWhenVisible`.
    final space2D = BlendSpace2D(
      samples: [
        BlendSample2D(animation: clips['Idle']!, point: Vector2(0, 0)),
        BlendSample2D(animation: clips['Walk']!, point: Vector2(0, 1)),
        BlendSample2D(animation: clips['StrafeL']!, point: Vector2(-1, 0)),
        BlendSample2D(animation: clips['StrafeR']!, point: Vector2(1, 0)),
      ],
    );
    blend2DWalker = ModelComponent(
      model: locoModel,
      position: Vector3(4.8, 9.6, 0.05),
      color: const ui.Color(0xFFF472B6),
      offscreenPolicy: OffscreenAnimationPolicy.tickOnlyEvaluateWhenVisible,
    )..playBlendSpace2D(space2D, initialValue: Vector2(0.55, 0.65));
    dynamicExtras.addAll([blend1DWalker!, blend2DWalker!]);

    // 3. `SkinnedCrowdBatch3D`: **64** animated instanced agents in an 8x8
    //    formation with baked pose-bank lookups!
    skinnedCrowd64 = SkinnedCrowdBatch3D(
      model: crowdModel,
      bakedFps: 24.0,
    );
    for (var i = 0; i < 64; i++) {
      final row = i ~/ 8;
      final col = i % 8;
      skinnedCrowd64!.addAgent(
        position: Vector3(1.6 + col * 0.72, 1.8 + row * 0.72, 0.02),
        scale: Vector3.all(0.42),
        clipIndex: i % crowdModel.animations.length,
        initialClock: (i * 0.13) % 1.2,
        speed: 0.85 + (i % 5) * 0.12,
        color: ShowcaseAssets.accentPalette[i % 16],
      );
    }
    dynamicExtras.add(skinnedCrowd64!);

    // 4. `SceneLoader3D` extended `.glb` scene (`KHR_lights_punctual`,
    //    `EXT_mesh_gpu_instancing`, `KHR_materials_unlit`,
    //    `KHR_materials_emissive_strength`, `KHR_mesh_quantization`, `extras`).
    if (loadedExtendedScene case final scene?) {
      for (final comp in scene.allComponents) {
        if (comp is Component3D) {
          dynamicExtras.add(comp);
        }
      }
    }
  }

  /// Lab 16: Half-res `DepthNormalPrepass` (`SSAO`, `3D DoF`, Soft Particles,
  /// Shoreline Water Foam), **2-Cascade CSM** + Shadowing `SpotLight`,
  /// `EnvironmentProbe3D.skyDome` `SH9` IBL, live GPU `RenderTexture3D` portal,
  /// `cameraMask` & `lightMask` isolation, and `DebugRenderer3D`.
  void buildSsaoDofCsmPortalAndDebug3DLab({required bool debugEnabled}) {
    final upright = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);

    // 1. Stepped architectural stone crease blocks showcasing SSAO contact
    //    occlusion + 2-Cascade Directional Shadows + SpotLight Shadows!
    final stoneMat = SpatialMaterial(
      albedoColor: const ui.Color(0xFFCBD5E1),
      roughness: 0.72,
      metallic: 0.05,
    )..renderState = const RenderState(cullMode: CullMode.backFace);
    for (var i = 0; i < 5; i++) {
      final w = 3.4 - i * 0.55;
      staticExtras.add(
        MeshComponent(
          mesh: CuboidMesh(
            size: Vector3(w, w, 0.28),
            material: stoneMat,
          ),
          position: Vector3(4.2, 4.2, 0.14 + i * 0.28),
        ),
      );
    }

    // 2. Shadow-casting `SpotLight` illuminating the stepped shrine +
    //    `lightMask` selective accent lamp (`lightMask: 0x02`).
    shadowSpotLight = LightComponent.spot(
      position: Vector3(1.6, 1.6, 4.2),
      direction: Vector3(2.6, 2.6, -3.2),
      color: const ui.Color(0xFFFFD166),
      intensity: 18.0,
      range: 12.0,
      innerConeAngle: 0.18,
      outerConeAngle: 0.55,
      shadows: ShadowSettings(
        resolution: 512,
        maxDistance: 12.0,
        color: const ui.Color(0xFF0F172A),
      ),
    );
    final maskedMagentaLight = LightComponent.point(
      position: Vector3(9.8, 4.2, 1.3),
      color: const ui.Color(0xFFFF00FF),
      intensity: 8.0,
      range: 4.0,
      lightMask: 0x02,
    );
    final maskedTargetCrystal = MeshComponent(
      mesh: SphereMesh(
        radius: 0.42,
        segments: 18,
        material: SpatialMaterial(
          albedoColor: const ui.Color(0xFFE2E8F0),
          roughness: 0.35,
        )..renderState = const RenderState(cullMode: CullMode.backFace),
      ),
      position: Vector3(9.8, 3.5, 0.55),
      cameraMask: 0x03, // receives both layer 0x01 camera & 0x02 lightMask!
    );
    dynamicExtras.addAll([
      shadowSpotLight!,
      maskedMagentaLight,
      maskedTargetCrystal,
    ]);

    // 3. `EnvironmentProbe3D.skyDome` (`SH9` diffuse irradiance + mipmapped
    //    specular reflection) on 3 metallic/roughness PBR spheres!
    for (var i = 0; i < 3; i++) {
      staticExtras.add(
        MeshComponent(
          mesh: SphereMesh(
            radius: 0.4,
            segments: 20,
            material: SpatialMaterial(
              albedoColor: const ui.Color(0xFFF8FAFC),
              metallic: i * 0.5,
              roughness: 0.14 + i * 0.34,
              environmentProbe: v3.skyDomeProbe,
            )..renderState = const RenderState(cullMode: CullMode.backFace),
          ),
          position: Vector3(3.4 + i * 1.15, 10.4, 0.52),
        ),
      );
    }

    // 4. Shoreline Intersection Foam (`shoreFoamDepth: 0.12`) + Soft Particles
    //    (`softDepthFade: 0.14`)!
    shoreFoamWaterMaterial = WaterMaterial(
      shallowColor: const ui.Color(0xBF38BDF8),
      deepColor: const ui.Color(0xDF0F294A),
      waveAmplitude: 0.05,
      shoreFoamDepth: 0.12,
      foamColor: const ui.Color(0xFFF8FAFC),
    );
    final basinWater = MeshComponent(
      mesh: TerrainMesh3D(
        columns: 20,
        rows: 20,
        width: 3.6,
        depth: 3.6,
        upAxis: TerrainUpAxis.z,
        heights: Float32List(20 * 20),
        material: shoreFoamWaterMaterial,
      ),
      position: Vector3(4.2, 4.2, 0.34),
      castsShadows: false,
    );
    softMistMaterial = ParticleMaterial(
      color: const ui.Color(0x88BAE6FD),
      softness: 0.65,
      softDepthFade: 0.14,
    );
    final softMist = ParticleSystem3D(
      capacity: 96,
      position: Vector3(4.2, 4.2, 0.45),
      material: softMistMaterial,
      emitters: [
        ParticleEmitter3D(
          rate: 28,
          shape: const BoxEmitterShape3D(1.2, 1.2, 0.25),
          speed: (0.12, 0.35),
          lifespan: (1.2, 2.0),
          size: (0.65, 1.15),
        ),
      ],
      opacityOverLife: ParticleCurve(0.85, 0.0),
    )..prewarm(1.0);
    dynamicExtras.addAll([basinWater, softMist]);

    // 5. Live GPU `RenderTexture3D` security monitor portal (`cameraMask: 0x04`
    //    excluded from portal capture `0x01`!).
    portalRenderTexture = RenderTexture3D(
      width: 160,
      height: 160,
      clearValue: const ui.Color(0xFF0F172A),
    );
    portalMonitorScreen = MeshComponent(
      mesh: PlaneMesh(
        size: Vector2(2.4, 2.4),
        material: UnlitMaterial(albedoTexture: portalRenderTexture!.texture)
          ..renderState = RenderState.opaque,
      ),
      position: Vector3(10.4, 9.8, 1.55),
      rotation:
          Quaternion.axisAngle(Vector3(0, 0, 1), -math.pi * 0.25) * upright,
      // Visible to main layer (`0xFFFFFFFF`), excluded from portal (`0x01`).
      cameraMask: 0x04,
      castsShadows: false,
    );
    dynamicExtras.add(portalMonitorScreen!);

    // 6. Batched 1-draw-call `DebugRenderer3D` wireframe overlay!
    labDebugRenderer = DebugRenderer3D(
      enabled: debugEnabled,
      lineThickness: 0.024,
    )..drawAxes(Matrix4.translationValues(7.0, 7.0, 0.15), size: 1.4);
    dynamicExtras.add(labDebugRenderer!);
  }

  void update(double time, double dt) {
    for (final mat in animatedWindMaterials) {
      mat.windTime = time;
    }
    if (depthPrepassGhost case final ghost?) {
      final fade = 0.42 + 0.3 * math.sin(time * 2.2);
      ghost.fade = fade;
      naiveGhost?.instanceData.w = fade;
    }
    if (singlePieceSkinnedGhost case final spGhost?) {
      spGhost.instanceData.w = 0.38 + 0.28 * math.sin(time * 2.0);
    }
    for (var i = 0; i < ditherPillars.length; i++) {
      ditherPillars[i].instanceData.w =
          0.42 + 0.32 * math.sin(time * 1.8 + i * 1.6);
    }
    if (ikTargetOrb case final orb?) {
      final tx = 4.9 + 0.45 * math.cos(time * 2.1);
      final ty = 9.8 + 0.55 * math.sin(time * 1.7);
      final tz = 1.15 + 0.3 * math.sin(time * 2.8);
      orb.position.setValues(tx, ty, tz);
      twoBoneIk?.targetWorld.setValues(tx, ty, tz);
      lookAtHead?.targetWorld.setValues(tx, ty, tz);
      layeredIkRig?.position.x = 4.2 + 0.28 * math.sin(time * 2.6);
    }
    if (lagoonWaterMaterial case final water?) {
      water.time = time;
    }
    for (var i = 0; i < sweepingSpotLights.length; i++) {
      final sp = sweepingSpotLights[i];
      final a = time * 1.1 + i * (math.pi * 0.5);
      final aimX = 7.0 + math.cos(a) * 2.8;
      final aimY = 7.0 + math.sin(a) * 2.8;
      final src = sp.source as SpotLight;
      src.direction?.setValues(
        aimX - sp.position.x,
        aimY - sp.position.y,
        -3.5,
      );
      if (sp.parent case final World3D w) {
        w.markSceneDirty(shadows: false);
      }
    }
    for (var i = 0; i < airships.length; i++) {
      final ang = time * (0.7 + i * 0.2) + i * 2.1;
      final r = 2.6 + i * 0.9;
      airships[i]
        ..position.setValues(
          7.0 + math.cos(ang) * r,
          7.0 + math.sin(ang) * r,
          2.6 + i * 0.45,
        )
        ..rotation.setAxisAngle(Vector3(0, 0, 1), ang + math.pi / 2);
    }
    if (interactiveTotem case final totem?) {
      totem
        ..captureFixedState()
        ..rotation.setAxisAngle(Vector3(0, 0, 1), time * 1.1)
        ..commitFixedState()
        ..applyInterpolationAlpha(0.5);
    }
    if (kinematicController case final kcc?) {
      final dirX = math.sin(time * 0.95) >= 0 ? 1.55 : -1.55;
      kcc.moveAndSlide(
        Vector3(dirX, 0, -4.5),
        dt,
        collisionSystem: collisionSystem,
      );
    }
    if (crowdSteering case final crowd?) {
      crowd.update(dt);
      for (var i = 0; i < crowd.agents.length; i++) {
        final ag = crowd.agents[i];
        if (ag.hasReachedGoal && steppedNavMesh != null) {
          final toEast = ag.position.x < 7.0;
          final gx = toEast ? 11.2 : 2.8;
          final gy = i.isEven ? 4.6 : 6.2;
          final gz =
              steppedNavMesh!.sampleHeightAt(Vector3(gx, gy, 0.8)) ?? 0.35;
          ag.setDestination(Vector3(gx, gy, gz), steppedNavMesh!);
        }
      }
    }
    if (audioEmitter3D case final emitter?) {
      final a = time * 1.6;
      emitter.position.setValues(
        7.0 + math.cos(a) * 3.2,
        7.0 + math.sin(a) * 3.2,
        1.5,
      );
    }
    if (blend1DWalker case final w1?) {
      w1.blendParameter1D = 2.5 + 2.3 * math.sin(time * 1.2);
    }
    if (blend2DWalker case final w2?) {
      w2.blendParameter2D = Vector2(
        math.cos(time * 1.1),
        math.sin(time * 1.1),
      );
    }
    if (shoreFoamWaterMaterial case final wMat?) {
      wMat.time = time;
    }
  }
}
