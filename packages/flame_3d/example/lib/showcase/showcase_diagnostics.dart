import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/showcase/pure_camera_lab_game.dart';
import 'package:flame_3d_example/showcase/showcase_game.dart';
import 'package:flame_3d_example/showcase/showcase_variations.dart';

/// Result of a single subsystem check executed by [ShowcaseDiagnostics].
class DiagnosticCheckResult({
  required final String id,
  required final String title,
  required final bool passed,
  required final String detail,
}) {
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'passed': passed,
    'detail': detail,
  };
}

/// Complete report returned by [ShowcaseDiagnostics.runAllChecks].
class ShowcaseDiagnosticReport({
  required final List<DiagnosticCheckResult> results,
  required final Duration elapsed,
}) {
  int get passedCount => results.where((r) => r.passed).length;
  int get totalCount => results.length;
  bool get allPassed => passedCount == totalCount;

  Map<String, Object?> toJson() => {
    'all_passed': allPassed,
    'passed_count': passedCount,
    'total_count': totalCount,
    'elapsed_ms': elapsed.inMicroseconds / 1000.0,
    'checks': [for (final r in results) r.toJson()],
  };
}

/// Automated 48-point functional & rendering health suite for
/// `package:flame_3d`.
///
/// Exercises all 16 [ShowcasePreset] feature labs plus [PureCameraLabGame],
/// both interactively on desktop/mobile and headlessly under
/// `flutter test --enable-impeller --enable-flutter-gpu`.
class ShowcaseDiagnostics() {
  static Future<ShowcaseDiagnosticReport> runAllChecks(
    ShowcaseGame game, {
    required Future<void> Function() pumpFrame,
    Future<ByteData?> Function(ui.Image image)? readImageBytes,
    Future<T?> Function<T>(Future<T> Function() task)? runAsyncHost,
  }) async {
    final sw = Stopwatch()..start();
    final results = <DiagnosticCheckResult>[];

    final ctrl = game.controller;
    final rig = game.variationRig;

    final savedPreset = ctrl.preset;
    final savedOrbit = ctrl.autoOrbitCamera;
    final savedWind = ctrl.wind;
    final savedRetained = ctrl.retainedStaticLayer;
    final savedShadowCache = ctrl.staticShadowCache;
    final savedSharedShadow = ctrl.sharedShadowGroup;
    final savedBloom = ctrl.bloom;
    final savedFog = ctrl.fog;
    final savedOutlines = ctrl.outlines;
    final savedParticles = ctrl.particles;
    final savedRibbons = ctrl.ribbonsAndDecals;
    final savedStress = ctrl.stressInstances;
    final savedSpatialIdx = ctrl.spatialIndex3D;
    final savedLightCull = ctrl.prioritizeNearestLights;
    final savedToneMap = ctrl.toneMap;
    final savedFxaa = ctrl.fxaa;
    final savedVignette = ctrl.vignette;
    final savedSsao = ctrl.ssao;
    final savedDof = ctrl.dof;
    final savedCsm2 = ctrl.csm2Cascades;
    final savedDebug3D = ctrl.debug3D;
    final savedEncoding = ctrl.shadowEncoding;
    final savedFit = ctrl.shadowFit;
    final savedSoftness = ctrl.shadowSoftness;
    final savedScale = ctrl.renderScale;
    final savedPlayMode = ctrl.playMode;
    final savedSpeed = ctrl.animSpeed;
    final savedZoom = game.camera.viewfinder.zoom;
    final savedPos = game.camera.viewfinder.position.clone();

    void record(
      String id,
      String title, {
      required bool ok,
      required String detail,
    }) {
      results.add(
        DiagnosticCheckResult(
          id: id,
          title: title,
          passed: ok,
          detail: detail,
        ),
      );
    }

    void renderPureLab(PureCameraLabGame lab) {
      final rec = ui.PictureRecorder();
      lab.render(ui.Canvas(rec));
      rec.endRecording().dispose();
    }

    try {
      if (runAsyncHost != null) {
        await runAsyncHost(game.preloadVariationAssets);
      } else {
        await game.preloadVariationAssets();
      }

      // 1. GPU backend & shader library readiness.
      final gpuReady = GpuBackend.isAvailable && game.isLoaded;
      record(
        'gpu_backend',
        'Flutter GPU Backend & Shaders',
        ok: gpuReady,
        detail:
            'isAvailable=${GpuBackend.isAvailable}, isLoaded=${game.isLoaded}',
      );

      // --- LAB 1: All-in-One ---
      game.applyPreset(ShowcasePreset.allInOne);
      ctrl
        ..autoOrbitCamera = false
        ..wind = false
        ..retainedStaticLayer = false
        ..staticShadowCache = true
        ..sharedShadowGroup = false
        ..bloom = true
        ..fog = true
        ..outlines = true
        ..particles = true
        ..ribbonsAndDecals = true
        ..stressInstances = false
        ..shadowEncoding = ShadowMapEncoding.auto
        ..shadowFit = ShadowFit.scene
        ..shadowSoftness = 1
        ..renderScale = 1.0
        ..animSpeed = 1.0;
      const halfBoard = ShowcaseGame.boardCells / 2;
      game.camera.viewfinder
        ..zoom = 1.0
        ..position = game.staticLayer.scenePointToLocal(
          Vector3(halfBoard, halfBoard, 0.5),
        );
      game.syncControllerState();
      await pumpFrame();
      await pumpFrame();

      // 2. InstancedGroup3D + 16-color accentPalette batching.
      final statStats = game.staticLayer.renderStats;
      final instCount = game.tileInstances.length;
      final batchedOk =
          instCount == 144 &&
          statStats.instances >= 144 &&
          statStats.drawCalls <= 16;
      record(
        'instanced_palette_batching',
        'InstancedGroup3D + 16-Accent Palette Batch',
        ok: batchedOk,
        detail:
            'tileInstances=$instCount, staticDraws=${statStats.drawCalls}, '
            'staticInstances=${statStats.instances}',
      );

      // 3. Static Shadow Map Caching (`ShadowSettings.cacheWhenStatic`).
      final shadowCachedOk =
          statStats.renderPasses == 1 &&
          statStats.shadowPasses == 0 &&
          game.staticLayer.context.hasActiveShadows;
      record(
        'static_shadow_cache',
        'ShadowSettings.cacheWhenStatic (0 Shadow Passes)',
        ok: shadowCachedOk,
        detail:
            'renderPasses=${statStats.renderPasses}, '
            'shadowPasses=${statStats.shadowPasses}, '
            'hasActiveShadows=${game.staticLayer.context.hasActiveShadows}',
      );

      // 4. Retained 3D Layer Caching (`Scene3DCacheMode.retained`).
      ctrl.retainedStaticLayer = true;
      game.syncControllerState();
      final hitsBefore = game.staticLayer.cacheHitCount;
      await pumpFrame();
      await pumpFrame();
      await pumpFrame();
      final hitsDelta = game.staticLayer.cacheHitCount - hitsBefore;
      final retainedPasses = game.staticLayer.renderStats.renderPasses;
      record(
        'retained_layer_cache',
        'Scene3DCacheMode.retained (0 GPU Passes on Clean Frame)',
        ok: hitsDelta >= 2 && retainedPasses == 0,
        detail: 'cacheHitsDelta=$hitsDelta, staticRenderPasses=$retainedPasses',
      );

      // 5. `LodMeshComponent` tier switching across camera zoom.
      final tower = game.lodTowers.first;
      game.camera.viewfinder
        ..position = game.staticLayer.scenePointToLocal(tower.position)
        ..zoom = 2.4;
      ctrl.retainedStaticLayer = false;
      game.syncControllerState();
      await pumpFrame();
      final nearLod = tower.lastSelectedLevel;

      game.camera.viewfinder.zoom = 0.35;
      await pumpFrame();
      final farLod = tower.lastSelectedLevel;
      game.camera.viewfinder
        ..zoom = 1.0
        ..position = game.staticLayer.scenePointToLocal(
          Vector3(halfBoard, halfBoard, 0.5),
        );
      record(
        'lod_switching',
        'LodMeshComponent Distance / Screen-Coverage Tiers',
        ok: farLod > nearLod,
        detail: 'nearZoomLod=$nearLod -> farZoomLod=$farLod',
      );

      // 6. Skeletal `AnimationPlayMode`, Crossfade & `BoneSocket3D`.
      final tipBefore = Vector3(
        game.armTipSocket.worldTransformMatrix.storage[12],
        game.armTipSocket.worldTransformMatrix.storage[13],
        game.armTipSocket.worldTransformMatrix.storage[14],
      );
      game.crossFadeNextClip(duration: 0.25);
      final crossFadingStarted = game.automaton.animationState.isCrossFading;
      for (var i = 0; i < 6; i++) {
        await pumpFrame();
      }
      final tipAfter = Vector3(
        game.armTipSocket.worldTransformMatrix.storage[12],
        game.armTipSocket.worldTransformMatrix.storage[13],
        game.armTipSocket.worldTransformMatrix.storage[14],
      );
      final tipMoved = tipAfter.distanceTo(tipBefore) > 1e-3;

      var onceCompleted = false;
      ctrl.animSpeed = 24.0;
      game.syncControllerState();
      game.automaton.playAnimationByName(
        'Spin',
        mode: AnimationPlayMode.once,
        onComplete: () => onceCompleted = true,
      );
      for (var i = 0; i < 6; i++) {
        await pumpFrame();
      }
      game.automaton.playAnimationByName(
        'Swing',
        mode: AnimationPlayMode.pingPong,
      );
      final pingPongOk =
          game.automaton.animationState.mode == AnimationPlayMode.pingPong;
      ctrl.animSpeed = 1.0;
      game.automaton.playAnimationByName('Idle');
      game.syncControllerState();
      record(
        'animation_modes_crossfade_socket',
        'AnimationPlayMode (once/pingPong/loop), Crossfade & BoneSocket3D',
        ok: crossFadingStarted && tipMoved && onceCompleted && pingPongOk,
        detail:
            'crossFade=$crossFadingStarted, tipMoved=$tipMoved, '
            'onceDone=$onceCompleted, pingPong=$pingPongOk',
      );

      // 7. Static & Skinned `OutlineMaterial` inverted-hull silhouettes.
      await pumpFrame();
      final dynStatsAllInOne = game.dynamicLayer.renderStats;
      final outlinesOk =
          ctrl.outlines &&
          game.automatonOutline.scale.x > 0.9 &&
          game.orbitingSentinelOutline.scale.x > 0.9 &&
          dynStatsAllInOne.drawCalls >= 4;
      record(
        'outlines_static_and_skinned',
        'OutlineMaterial (Static + Skinned)',
        ok: outlinesOk,
        detail:
            'dynamicDraws=${dynStatsAllInOne.drawCalls}, '
            'dynamicTris=${dynStatsAllInOne.triangles}',
      );

      // --- LAB 2: Materials, Grading, Depth-Prepass Ghost & Mirror Scale ---
      game.applyPreset(ShowcasePreset.materialsAndGrading);
      await pumpFrame();
      await pumpFrame();

      // 8. Flat `SurfaceBvh` raycasting + Negative Mirror Scale (`-1, 1, 1`).
      final normHit = rig.normalMonument?.raycast(
        Ray.originDirection(Vector3(3.45, 10.6, 2.5), Vector3(0, 0, -1)),
      );
      final mirrorHit = rig.mirroredMonument?.raycast(
        Ray.originDirection(Vector3(4.05, 10.6, 2.5), Vector3(0, 0, -1)),
      );
      final mirrorMiss = rig.mirroredMonument?.raycast(
        Ray.originDirection(Vector3(4.95, 10.6, 2.5), Vector3(0, 0, -1)),
      );
      final sceneHit = game.pickAtLocalPoint(
        game.staticLayer.scenePointToLocal(Vector3(3.3, 10.6, 1.0)),
      );
      final bvhMirrorOk =
          normHit != null &&
          mirrorHit != null &&
          mirrorMiss == null &&
          (mirrorHit.worldNormal.z - 1.0).abs() < 1e-2 &&
          sceneHit != null;
      record(
        'bvh_raycasting_and_mirror_scale',
        'SurfaceBvh Narrowphase & Negative Mirror Scale (-1, 1, 1)',
        ok: bvhMirrorOk,
        detail:
            'normHit=${normHit != null}, mirrorHit=${mirrorHit != null}, '
            'mirrorMiss=${mirrorMiss == null}, sceneHit=${sceneHit != null}',
      );

      // 9. Depth-Prepass single-piece translucent fade vs naive ghost.
      final ghostOk =
          rig.depthPrepassGhost != null &&
          rig.naiveGhost != null &&
          rig.depthPrepassGhost!.isMounted &&
          game.dynamicLayer.renderStats.drawCalls >= 4;
      record(
        'depth_prepass_translucent_fade',
        'RenderState.depthOnly Prepass + Seamless Translucent Fade',
        ok: ghostOk,
        detail:
            'ghostFade=${rig.depthPrepassGhost?.fade.toStringAsFixed(2)}, '
            'dynamicDraws=${game.dynamicLayer.renderStats.drawCalls}',
      );

      // 10. StylizedMaterial color grading.
      final matStats = game.staticLayer.renderStats;
      final gradingOk = matStats.drawCalls >= 12 && matStats.triangles >= 1000;
      record(
        'stylized_color_grading_and_metallic',
        'StylizedMaterial Color Grading (Saturation/Overlay/Metallic)',
        ok: gradingOk,
        detail:
            'staticDraws=${matStats.drawCalls}, '
            'staticTris=${matStats.triangles}',
      );

      // 11. SpatialMaterial 3x3 PBR grid + TextureSampler wrap/filter modes.
      final samplersOk =
          rig.staticExtras.length >= 17 && matStats.renderPasses >= 1;
      record(
        'spatial_pbr_and_samplers',
        'SpatialMaterial 3x3 PBR & Samplers (repeat/mirror/clamp)',
        ok: samplersOk,
        detail:
            'staticExtras=${rig.staticExtras.length}, '
            'passes=${matStats.renderPasses}',
      );

      // 12. Zero-copy `ImageTexture.create` from `ui.PictureRecorder` Canvas.
      final bannerTex = rig.canvasBannerTexture;
      final imgTexOk =
          bannerTex != null && bannerTex.width == 128 && bannerTex.height == 64;
      record(
        'zero_copy_image_texture',
        'Canvas Picture -> Zero-Copy ImageTexture.create',
        ok: imgTexOk,
        detail:
            'width=${bannerTex?.width ?? 0}, height=${bannerTex?.height ?? 0}',
      );

      // --- LAB 3: Wind Spaces ---
      game.applyPreset(ShowcasePreset.windSpaces);
      await pumpFrame();
      await pumpFrame();

      // 13. Wind (`WindSpace.world` vs `model` vs `worldScaled` + gusts).
      final spaces = {for (final m in rig.animatedWindMaterials) m.windSpace};
      final windOk =
          spaces.containsAll(WindSpace.values) &&
          rig.animatedWindMaterials.every((m) => m.windTime > 0) &&
          game.dynamicLayer.renderStats.instances >= 12;
      record(
        'wind_spaces_v2',
        'WindSpace (world / model / worldScaled) + Gusts & Flutter',
        ok: windOk,
        detail:
            'spaces=${spaces.length}/3, '
            'dynInstances=${game.dynamicLayer.renderStats.instances}',
      );

      // --- LAB 4: Shadows, 3-Layer ShadowGroup & 4+8 Lights ---
      game.applyPreset(ShowcasePreset.shadowsAndLights);
      ctrl
        ..retainedStaticLayer = false
        ..staticShadowCache = false
        ..sharedShadowGroup = true;
      game.syncControllerState();
      await pumpFrame();
      await pumpFrame();

      // 14. Multi-light limits: 4 DirectionalLights + 8 PointLights.
      final lights = game.dynamicLayer.world.children
          .whereType<LightComponent>()
          .toList();
      final dirCount = lights.where((l) => l.source is DirectionalLight).length;
      final ptCount = lights.where((l) => l.source is PointLight).length;
      record(
        'multi_lights_4dir_8point',
        '4 DirectionalLights + 8 PointLights (Range & Zero-Skip)',
        ok:
            dirCount == 4 &&
            ptCount == 8 &&
            game.dynamicLayer.renderStats.renderPasses >= 1,
        detail: 'directional=$dirCount, point=$ptCount',
      );

      // 15. 3-Layer `ShadowGroup` + sandwiched 2D layer (1 shared shadow pass).
      final sky = rig.skyShadowLayer;
      final totalShPasses =
          game.staticLayer.renderStats.shadowPasses +
          game.dynamicLayer.renderStats.shadowPasses +
          (sky?.renderStats.shadowPasses ?? 99);
      final groupOk =
          sky != null &&
          sky.renderStats.renderPasses >= 1 &&
          totalShPasses == 1 &&
          game.staticLayer.context.hasActiveShadows &&
          game.dynamicLayer.context.hasActiveShadows &&
          sky.context.hasActiveShadows;
      record(
        'shadow_group_3_layers',
        '3-Layer ShadowGroup + 2D Sandwich (1 Shared Shadow Pass)',
        ok: groupOk,
        detail:
            'totalShadowPasses=$totalShPasses, '
            'skyPasses=${sky?.renderStats.renderPasses ?? 0}',
      );

      // 16. `ShadowMapEncoding.rgba8` + `ShadowFit.view` + PCF `softness: 2`.
      ctrl
        ..sharedShadowGroup = false
        ..shadowEncoding = ShadowMapEncoding.rgba8
        ..shadowFit = ShadowFit.view
        ..shadowSoftness = 2;
      game.syncControllerState();
      await pumpFrame();
      await pumpFrame();
      final rgba8Ok =
          game.staticLayer.renderStats.shadowPasses == 1 &&
          game.dynamicLayer.renderStats.shadowPasses == 1 &&
          game.dynamicLayer.context.hasActiveShadows;
      record(
        'shadow_rgba8_and_view_fit',
        'ShadowMapEncoding.rgba8 + ShadowFit.view + PCF Softness 2',
        ok: rgba8Ok,
        detail:
            'statSh=${game.staticLayer.renderStats.shadowPasses}, '
            'dynSh=${game.dynamicLayer.renderStats.shadowPasses}',
      );
      ctrl
        ..shadowEncoding = ShadowMapEncoding.auto
        ..shadowFit = ShadowFit.scene
        ..shadowSoftness = 1;

      // --- LAB 5: Flipbook, 4 Billboards, 5 Shapes, Attractor & Ribbons ---
      game.applyPreset(ShowcasePreset.particlesAndRibbons);
      for (var i = 0; i < 6; i++) {
        await pumpFrame();
      }

      // 17. `DecalBatch3D` (ring + 2x2 UV atlas) & textured `RibbonMaterial3D`.
      final ribbonBatches = rig.dynamicExtras.whereType<StrokeBatch3D>().length;
      final decalsAndStrokesOk =
          game.ringDecals.length >= 1 &&
          game.atlasDecals.length == 4 &&
          game.energyStrokes.segmentCount >= 10 &&
          ribbonBatches == 3;
      record(
        'decals_and_textured_strokes',
        'DecalBatch3D & Textured RibbonMaterial3D (3 Blend Modes)',
        ok: decalsAndStrokesOk,
        detail:
            'rings=${game.ringDecals.length}, atlas=${game.atlasDecals.length},'
            ' plasmaBatches=$ribbonBatches',
      );

      // 18. All 4 `ParticleBillboard` modes + 4x4 `ParticleFlipbook3D`.
      final pSystems = rig.dynamicExtras.whereType<ParticleSystem3D>().toList();
      final billboards = {
        for (final ps in pSystems) ?ps.material?.billboard,
      };
      final hasFlipbook = pSystems.any(
        (ps) => ps.flipbook != null && (ps.material?.frameBlending ?? false),
      );
      final ptclBillboardOk =
          billboards.containsAll(ParticleBillboard.values) &&
          hasFlipbook &&
          game.dynamicLayer.renderStats.particles >= 100;
      record(
        'particle_billboards_and_flipbook',
        '4 ParticleBillboards + 4x4 Flipbook FrameBlending',
        ok: ptclBillboardOk,
        detail:
            'billboards=${billboards.length}/4, flipbook=$hasFlipbook, '
            'particles=${game.dynamicLayer.renderStats.particles}',
      );

      // 19. 5 `EmitterShape3D`s + `ParticleAttractor3D` + `onGroundHit`.
      final forcesOk =
          rig.attractorArrivals > 0 &&
          rig.groundBounceHits > 0 &&
          game.sentinelRibbon.pointCount >= 3;
      record(
        'particle_shapes_attractor_ground',
        '5 EmitterShapes + Attractor Consumption + Ground Hit Decals',
        ok: forcesOk,
        detail:
            'arrivals=${rig.attractorArrivals}, '
            'groundHits=${rig.groundBounceHits}',
      );

      // --- LAB 6: Projections, PiP Insets & DRS 0.5x ---
      game.applyPreset(ShowcasePreset.projectionsAndInsets);
      ctrl.renderScale = 0.5;
      game.syncControllerState();
      await pumpFrame();
      await pumpFrame();

      // 20. `Scene3DProjection` (`.perspective`, `.camera`, `.matrix`) + DRS.
      final pipDraws = rig.perspectiveInsetLayer?.renderStats.drawCalls ?? 0;
      final camDraws = rig.cameraProjLayer?.renderStats.drawCalls ?? 0;
      final oblDraws = rig.obliqueMatrixLayer?.renderStats.drawCalls ?? 0;
      final projOk =
          pipDraws >= 1 &&
          camDraws >= 1 &&
          oblDraws >= 1 &&
          game.dynamicLayer.renderScale == 0.5;
      record(
        'projections_perspective_camera_matrix_drs',
        'Scene3DProjection (.perspective / .camera / .matrix) + DRS 0.5x',
        ok: projOk,
        detail:
            'pipDraws=$pipDraws, camDraws=$camDraws, oblDraws=$oblDraws, '
            'scale=${game.dynamicLayer.renderScale}',
      );
      ctrl.renderScale = 1.0;

      // 21. Pure 3D `FlameGame3D` (`PureCameraLabGame` 5 camera modes + pick).
      final lab = PureCameraLabGame()..onGameResize(Vector2(320, 200));
      await lab.start();
      lab.update(0.05);
      renderPureLab(lab);
      final perspDraws = lab.renderStats.drawCalls;
      final perspNotMirrored = !lab.context.isMirrored;
      final skyboxInPureLabOk =
          lab.skybox.isMounted && lab.world.postProcess != null;

      final beaconScreen = lab.camera.worldToViewportPoint(
        lab.beaconA.position,
      );
      final pickRay = lab.camera.viewportPointToRay(beaconScreen);
      final beaconHit = lab.world.raycast(pickRay);
      final purePickOk = identical(beaconHit?.object, lab.beaconA);

      lab.setCameraMode(PureCameraMode.orthographic);
      renderPureLab(lab);
      final orthoDraws = lab.renderStats.drawCalls;

      lab
        ..setCameraMode(PureCameraMode.thirdPerson)
        ..update(0.05);
      renderPureLab(lab);
      final thirdOk = lab.camera.position.distanceTo(lab.rover.position) > 1.0;

      lab
        ..setCameraMode(PureCameraMode.firstPerson)
        ..update(0.05);
      renderPureLab(lab);
      final firstOk =
          (lab.camera.position.x - lab.rover.position.x).abs() < 0.05;

      lab.setCameraMode(PureCameraMode.customMirrored);
      renderPureLab(lab);
      final mirroredOk =
          lab.context.isMirrored && lab.renderStats.drawCalls >= 6;

      // Also test the 4 production 3D camera rigs inside `PureCameraLabGame`:
      // OrbitCameraController3D, SpringArmCamera3D, CameraDollyTrack3D,
      // CameraShake3D.
      lab.setCameraMode(PureCameraMode.orbitController3D);
      lab.orbitController.fitAabb(
        Aabb3.minMax(Vector3(-3, 0, -3), Vector3(3, 2, 3)),
      );
      lab.update(0.05);
      renderPureLab(lab);
      final orbitRigOk = lab.orbitController.distance > 1.0;

      lab.setCameraMode(PureCameraMode.springArm3D);
      // Place rover at `(0, 0.35, 2.2)` so the spring-arm boom (`yaw = 0`,
      // `+Z` toward `z = 7.4`) intersects `occluderWall` at `z = 4.4`.
      lab.rover.position.setValues(0, 0.35, 2.2);
      lab.springArm
        ..yaw = 0.0
        ..pitch = 0.12
        ..update(0.05);
      final springOccludedOk =
          lab.springArm.isOccluded &&
          lab.springArm.currentArmLength < lab.springArm.armLength;

      lab
        ..setCameraMode(PureCameraMode.dollyTrack3D)
        ..update(0.25);
      final dollyOk = lab.dollyTrack.progress > 0.0;

      lab.triggerTraumaShake(0.85);
      final traumaBefore = lab.cameraShake.trauma;
      lab.update(0.05);
      renderPureLab(lab);
      final shakeOk =
          traumaBefore >= 0.8 && lab.cameraShake.trauma < traumaBefore;

      lab.onRemove();
      lab.hudTick.dispose();

      record(
        'pure_3d_cameras_and_line3d',
        'FlameGame3D (Perspective/Ortho/3rd/1st/Mirrored + Pick + Pins)',
        ok:
            perspDraws >= 6 &&
            perspNotMirrored &&
            purePickOk &&
            orthoDraws >= 6 &&
            thirdOk &&
            firstOk &&
            mirroredOk,
        detail:
            'perspDraws=$perspDraws, orthoDraws=$orthoDraws, '
            'pick=$purePickOk, mirrored=$mirroredOk',
      );

      // --- LAB 7: 26-Float Skinning, GLB/OBJ Parsers & 67,600v 32-Bit Mesh ---
      game.applyPreset(ShowcasePreset.modelsAnd32BitMesh);
      await pumpFrame();
      await pumpFrame();

      // 22. 26-Float `StylizedMaterial.skinnedVertexLayout` + `hideNodeByName`.
      final rig26 = rig.stylized26Rig;
      var skin26Stride = 0;
      var crownHideOk = false;
      if (rig26 != null) {
        final bodyNode = rig26.model.nodes[3];
        skin26Stride =
            bodyNode?.mesh?.surfaces.first.layout.strideInFloats ?? 0;
        rig26
          ..stopAnimation()
          ..hideNodeByName('Crown', hidden: false);
        final crownRay = Ray.originDirection(
          Vector3(4.2, 4.2, 3.0),
          Vector3(0, 0, -1),
        );
        final hitWithCrown = rig26.raycast(crownRay);
        rig26.hideNodeByName('Crown');
        final hitWithoutCrown = rig26.raycast(crownRay);
        crownHideOk =
            hitWithCrown != null &&
            hitWithCrown.worldPoint.z > 1.95 &&
            (hitWithoutCrown == null || hitWithoutCrown.worldPoint.z < 1.9);
        rig26
          ..hideNodeByName('Crown', hidden: false)
          ..playAnimationByName('Wave');
      }
      record(
        'stylized_26float_skinning_and_hide_node',
        'StylizedMaterial 26-Float Skinned Layout & hideNodeByName',
        ok: skin26Stride == 26 && crownHideOk,
        detail: 'strideFloats=$skin26Stride, crownToggleRaycast=$crownHideOk',
      );

      // 23. `67,600`-vertex (`> 65,535`) `Uint32List` surface + `OBJ` & `GLB`.
      final waveSurf = rig.wave32BitTerrain?.mesh.surfaces.first;
      final uint32Ok =
          waveSurf != null &&
          waveSurf.vertexCount == 67600 &&
          waveSurf.indexType == GpuIndexType.uint32 &&
          game.staticLayer.renderStats.triangles >= 134000;
      final objOk =
          rig.parsedObjModel != null && rig.parsedObjModel!.nodes.isNotEmpty;
      final glbOk =
          rig.parsedGlbModel != null &&
          rig.parsedGlbModel!.animations.isNotEmpty;
      record(
        'large_32bit_surface_and_parsers',
        '67,600v Uint32 Surface + ModelParser (OBJ/.mtl & GLB)',
        ok: uint32Ok && objOk && glbOk,
        detail:
            'verts=${waveSurf?.vertexCount ?? 0} '
            '(${waveSurf?.indexType.name}), obj=$objOk, glb=$glbOk',
      );

      // --- LAB 9: PBR Maps, Single-Piece Skinned Prepass & Dither Fade ---
      game.applyPreset(ShowcasePreset.pbrV2AndSinglePiece);
      await pumpFrame();
      await pumpFrame();

      // 24. `SpatialMaterial` v2 (normal, ORM, AO, emissive, env, cutout).
      final cobble = rig.pbrCobbleMaterial;
      final envMat = rig.pbrEnvMaterial;
      final cutMat = rig.pbrCutoutMaterial;
      final pbrV2Ok =
          cobble != null &&
          cobble.normalTexture != null &&
          cobble.metallicRoughnessTexture != null &&
          cobble.occlusionTexture != null &&
          cobble.emissiveTexture != null &&
          envMat?.environmentTexture != null &&
          (cutMat?.alphaCutoff ?? 0) > 0.4 &&
          (cutMat?.doubleSided ?? false) &&
          game.staticLayer.renderStats.drawCalls >= 6;
      record(
        'pbr_v2_maps_and_env',
        'SpatialMaterial (Normal/ORM/AO/Emissive/Env/Cutout)',
        ok: pbrV2Ok,
        detail:
            'staticDraws=${game.staticLayer.renderStats.drawCalls}, '
            'env=${envMat?.environmentTexture != null}, '
            'cutout=${cutMat?.alphaCutoff}',
      );

      // 25. Built-in `singlePieceTranslucent` (`RenderState.depthPrepass`) on
      //     multi-node skinned rig + Bayer 4x4 `ditherFade`.
      final spGhost = rig.singlePieceSkinnedGhost;
      final spMat = spGhost?.model.nodes[3]?.mesh?.surfaces.first.material;
      final prepassAndDitherOk =
          spGhost != null &&
          spGhost.isMounted &&
          (spMat?.renderState.depthPrepass ?? false) &&
          rig.ditherPillars.length == 2 &&
          game.dynamicLayer.renderStats.drawCalls >= 6;
      record(
        'builtin_single_piece_prepass_and_dither',
        'Built-in RenderState.depthPrepass (Skinned) & Bayer ditherFade',
        ok: prepassAndDitherOk,
        detail:
            'depthPrepass=${spMat?.renderState.depthPrepass}, '
            'ditherPillars=${rig.ditherPillars.length}',
      );

      // --- LAB 10: 64-Bone Skinning, Morph Targets, Layers & IK/Spring ---
      game.applyPreset(ShowcasePreset.skinning64MorphIkLayers);
      for (var i = 0; i < 4; i++) {
        await pumpFrame();
      }

      // 26. 32-Joint (`> 16`, `maxJoints = 64`) skinned serpent + CubicSpline.
      final serpent = rig.serpent32BoneRig;
      final serpentJoints =
          serpent
              ?.evaluatePose()
              .nodesByIndex[32]
              ?.jointTransforms[0]
              ?.length ??
          0;
      final skin64Ok =
          StylizedMaterial.maxJoints == 64 &&
          serpentJoints == 32 &&
          game.dynamicLayer.renderStats.drawCalls >= 4;
      record(
        'skinning_32_to_64_joints_and_cubicspline',
        '64-Bone Skinning Capacity (32-Joint CubicSpline Serpent)',
        ok: skin64Ok,
        detail:
            'activeJoints=$serpentJoints/64, '
            'dynDraws=${game.dynamicLayer.renderStats.drawCalls}',
      );

      // 27. `MorphTargetData` + `MorphWeightsChannel` + `setMorphWeights`.
      final morphRig = rig.morphCrystalRig;
      final morphSurf = morphRig?.model.nodes[0]?.mesh?.surfaces.first;
      var morphOk = false;
      var maxMorphDelta = 0.0;
      if (morphRig != null && morphSurf != null) {
        morphRig.setMorphWeights(const [0.0, 0.0]);
        final restSnapshot = List<double>.of(morphSurf.vertexData);
        morphRig.setMorphWeights(const [1.0, 1.0]);
        final morphed = morphSurf.vertexData;
        for (var i = 0; i < morphed.length; i++) {
          final d = (morphed[i] - restSnapshot[i]).abs();
          if (d > maxMorphDelta) {
            maxMorphDelta = d;
          }
        }
        morphOk =
            morphSurf.morphTargets.length == 2 &&
            maxMorphDelta > 0.1 &&
            morphSurf.hasResource;
      }
      record(
        'morph_targets_and_dynamic_vertices',
        'MorphTargetData + MorphWeightsChannel + Dynamic Vertex Upload',
        ok: morphOk,
        detail:
            'targets=${morphSurf?.morphTargets.length ?? 0}, '
            'maxDelta=${maxMorphDelta.toStringAsFixed(3)}',
      );

      // 28. `AnimationLayer3D` upper-body mask + `TwoBoneIkConstraint3D` +
      //     `LookAtConstraint3D` + `SpringBone3D`.
      final ikRig = rig.layeredIkRig;
      var ikDist = 99.0;
      var hasOverlay = false;
      var springMoved = false;
      if (ikRig != null && rig.twoBoneIk != null && rig.springAntenna != null) {
        hasOverlay = ikRig.animationState.layers.length == 1;
        final pose = ikRig.evaluatePose();
        final handModel = pose.nodesByIndex[6]!.combinedTransform
            .getTranslation();
        final handWorld = ikRig.worldTransformMatrix.transformed3(handModel);
        ikDist = handWorld.distanceTo(rig.twoBoneIk!.targetWorld);
        springMoved = rig.springAntenna!.currentTipWorld.length2 > 0.1;
      }
      record(
        'animation_layers_and_procedural_ik',
        'AnimationLayer3D Mask + TwoBoneIK + LookAt + SpringBone3D',
        ok: hasOverlay && ikDist < 0.08 && springMoved,
        detail:
            'layers=${ikRig?.animationState.layers.length ?? 0}, '
            'ikErr=${ikDist.toStringAsFixed(4)}, spring=$springMoved',
      );

      // --- LAB 11: Water, Terrain, Spline, Standees, Text3D & Blob Shadows ---
      game.applyPreset(ShowcasePreset.waterTerrainAndHd2d);
      for (var i = 0; i < 4; i++) {
        await pumpFrame();
      }

      // 29. `TerrainMesh3D` (`sampleHeight` / `sampleNormal`) + `CapsuleMesh`,
      //     `TorusMesh`, & `TubeSplineMesh` (`CatmullRomSpline3D`).
      final terrain = rig.islandTerrain;
      final terrainH = terrain?.sampleHeight(0, 0) ?? 0.0;
      final terrainN = terrain?.sampleNormal(0, 0);
      final splineVerts =
          rig.splineAqueduct?.mesh.surfaces.first.vertexCount ?? 0;
      final terrainAndPrimitivesOk =
          terrain != null &&
          terrainH > 0.1 &&
          terrainN != null &&
          terrainN.z > 0.3 &&
          splineVerts > 100;
      record(
        'terrain_mesh_and_procedural_primitives',
        'TerrainMesh3D (Height/Normal) + Capsule/Torus + TubeSplineMesh',
        ok: terrainAndPrimitivesOk,
        detail:
            'centerH=${terrainH.toStringAsFixed(2)}, splineVerts=$splineVerts',
      );

      // 30. Animated Gerstner `WaterMaterial` + `DecalBatch3D.addBlobShadow`.
      final water = rig.lagoonWaterMaterial;
      final blobs = rig.blobShadowDecals;
      final waterAndBlobsOk =
          water != null &&
          water.time > 0 &&
          blobs != null &&
          blobs.length == 2 &&
          game.dynamicLayer.renderStats.drawCalls >= 4;
      record(
        'water_material_and_blob_shadows',
        'Animated 4-Wave Gerstner WaterMaterial & Blob Drop Shadows',
        ok: waterAndBlobsOk,
        detail:
            'waterTime=${water?.time.toStringAsFixed(2)}, '
            'blobCount=${blobs?.length ?? 0}',
      );

      // 31. `BillboardBatch3D` HD-2D cylindrical standees + `Text3DComponent`.
      final standees = rig.standeeBatch;
      final badges = rig.text3DBadges;
      final hd2dOk =
          standees != null &&
          standees.length == 4 &&
          badges.length == 4 &&
          badges.first.worldWidth > 0.2;
      record(
        'hd2d_billboard_batch_and_text3d',
        'BillboardBatch3D HD-2D Standees & Depth-Occluded Text3DComponent',
        ok: hd2dOk,
        detail:
            'standees=${standees?.length ?? 0}, textBadges=${badges.length}',
      );

      // 32. `SkyboxComponent3D` + `PostProcessSettings` in `PureCameraLabGame`.
      record(
        'skybox_3d_in_pure_camera_lab',
        'SkyboxComponent3D (Clip Depth 1.0) & Pure 3D ACES PostProcess',
        ok: skyboxInPureLabOk,
        detail: 'skyboxMountedAndPostActive=$skyboxInPureLabOk',
      );

      // --- LAB 12: 4 SpotLights, 32 Culled Lamps, BVH3D & ACES/AgX/FXAA ---
      game.applyPreset(ShowcasePreset.spotLightsCullingAndPost);
      await pumpFrame();
      await pumpFrame();

      // 33. 4 sweeping `SpotLight`s + 32 `PointLight`s culled to nearest 8!
      final spotCount = rig.sweepingSpotLights.length;
      final lampCount = rig.culledStreetLamps.length;
      final cullingOk =
          spotCount == 4 &&
          lampCount >= 32 &&
          game.dynamicLayer.world.prioritizeNearestLights &&
          game.dynamicLayer.renderStats.renderPasses >= 4;
      record(
        'spot_lights_and_32_point_light_culling',
        '4 Sweeping SpotLights + 32-Lamp Priority Light Culling',
        ok: cullingOk,
        detail: 'spotLights=$spotCount, streetLamps=$lampCount (top-8 active)',
      );

      // 34. `SceneSpatialIndex3D` broadphase AABB BVH (queryAabb & raycast).
      final sWorld = game.staticLayer.world;
      final bvh3d = sWorld.spatialIndex3D..ensureBuilt(sWorld);
      final boxHits = bvh3d.queryAabb(
        sWorld,
        Aabb3.minMax(Vector3(1, 1, -1), Vector3(4, 4, 3)),
      );
      final bvhHit = sWorld.raycast(
        Ray.originDirection(Vector3(2.5, 2.5, 6.0), Vector3(0, 0, -1)),
      );
      final bvhCandidates = bvh3d.lastRaycastCandidatesTested;
      final sceneBvhOk =
          sWorld.spatialIndex3DEnabled &&
          bvh3d.indexedObjectCount >= 30 &&
          boxHits.isNotEmpty &&
          bvhHit != null &&
          bvhCandidates < bvh3d.indexedObjectCount;
      record(
        'scene_spatial_index_3d_bvh',
        'SceneSpatialIndex3D Broadphase AABB BVH (Query & O(log N) Raycast)',
        ok: sceneBvhOk,
        detail:
            'indexed=${bvh3d.indexedObjectCount}, '
            'candidatesTested=$bvhCandidates',
      );

      // 35. Fused `PostProcessSettings` (`acesFilmic`, `agx`, `vignette`,
      //     `fxaa`) + standalone post-process without bloom.
      final fusedPasses = game.dynamicLayer.renderStats.renderPasses;
      ctrl
        ..bloom = false
        ..toneMap = ToneMapMode.agx
        ..fxaa = true
        ..vignette = true;
      game.syncControllerState();
      await pumpFrame();
      final standalonePostPasses = game.dynamicLayer.renderStats.renderPasses;
      final postOk =
          standalonePostPasses >= 2 &&
          standalonePostPasses <= 3 &&
          fusedPasses == standalonePostPasses + 3 &&
          game.dynamicLayer.postProcess?.toneMap == ToneMapMode.agx;
      record(
        'fused_post_process_aces_agx_fxaa',
        'PostProcessSettings (ACES/AgX ToneMap + Vignette + FXAA)',
        ok: postOk,
        detail:
            'fusedWithBloomPasses=$fusedPasses, '
            'standalonePostPasses=$standalonePostPasses',
      );
      ctrl.bloom = true;

      // --- Restore All-in-One & Verify Fog + Bloom + Offscreen Snapshot ---
      game.applyPreset(ShowcasePreset.allInOne);
      await pumpFrame();
      await pumpFrame();

      // 36. `FogSettings` + `BloomSettings` + `World3D.renderToImage`.
      final dynPasses = game.dynamicLayer.renderStats.renderPasses;
      final fogAndBloomOk =
          game.dynamicLayer.world.fog != null &&
          game.dynamicLayer.bloom != null &&
          dynPasses >= 4;
      final snapshot = game.captureOffscreenSnapshot(
        size: const ui.Size(64, 64),
      );
      var nonBgPixels = -1;
      final reader =
          readImageBytes ??
          (runAsyncHost != null
              ? (ui.Image img) => runAsyncHost<ByteData?>(img.toByteData)
              : (ui.Image img) => img.toByteData());
      final bytes = await reader(snapshot);
      if (bytes != null) {
        nonBgPixels = 0;
        final raw = bytes.buffer.asUint8List(
          bytes.offsetInBytes,
          bytes.lengthInBytes,
        );
        for (var i = 0; i + 3 < raw.length; i += 4) {
          if ((raw[i] - 22).abs() > 6 ||
              (raw[i + 1] - 32).abs() > 6 ||
              (raw[i + 2] - 51).abs() > 6) {
            nonBgPixels++;
          }
        }
      }
      final snapshotOk =
          fogAndBloomOk &&
          snapshot.width == 64 &&
          snapshot.height == 64 &&
          nonBgPixels > 20;
      record(
        'fog_bloom_and_offscreen_snapshot',
        'FogSettings + Kawase Bloom + World3D.renderToImage',
        ok: snapshotOk,
        detail:
            'passes=$dynPasses, size=${snapshot.width}x${snapshot.height}, '
            'litPixels=$nonBgPixels',
      );

      // --- LAB 13: 3D Input, 3D Effects, Fixed Interpolation & Camera Rigs ---
      game.applyPreset(ShowcasePreset.inputEffectsAndCameraRigs);
      await pumpFrame();
      await pumpFrame();

      // 37. `PointerRouter3D` (`TapCallbacks3D`, `HoverCallbacks3D`,
      //     ray-plane `DragCallbacks3D`, and 1D `dragAxisConstraint` gizmo).
      final router = rig.pointerRouter3D;
      final totem = rig.interactiveTotem;
      final slider = rig.axisGizmoSlider;
      var input3DOk = false;
      if (router != null && totem != null && slider != null) {
        final totemPt = game.dynamicLayer.scenePointToLocal(
          totem.position + Vector3(0, 0, 0.6),
        );
        final totemDragTo = game.dynamicLayer.scenePointToLocal(
          totem.position + Vector3(0.9, 0.7, 0.6),
        );
        final startTotemPos = totem.position.clone();
        router
          ..dispatchHover(totemPt)
          ..dispatchTapDown(totemPt)
          ..dispatchTapUp(totemPt)
          ..dispatchDragStart(totemPt, pointerId: 2)
          ..dispatchDragUpdate(totemDragTo, pointerId: 2)
          ..dispatchDragEnd(pointerId: 2, point: totemDragTo);

        final sliderPt = game.dynamicLayer.scenePointToLocal(slider.position);
        final sliderDragTo = game.dynamicLayer.scenePointToLocal(
          slider.position + Vector3(1.4, 1.8, 0.0),
        );
        final sliderYBefore = slider.position.y;
        final sliderXBefore = slider.position.x;
        router
          ..dispatchDragStart(sliderPt, pointerId: 3)
          ..dispatchDragUpdate(sliderDragTo, pointerId: 3)
          ..dispatchDragEnd(pointerId: 3, point: sliderDragTo);

        input3DOk =
            totem.hoverEnterCount >= 1 &&
            totem.tapCount >= 1 &&
            totem.dragUpdateCount >= 1 &&
            totem.position.distanceTo(startTotemPos) > 0.2 &&
            slider.dragMoves >= 1 &&
            (slider.position.x - sliderXBefore).abs() > 0.2 &&
            (slider.position.y - sliderYBefore).abs() < 1e-5;
      }
      record(
        'input_3d_tap_hover_drag_and_gizmo',
        'PointerRouter3D (Tap/Hover/Plane-Drag & 1D Axis Gizmo)',
        ok: input3DOk,
        detail:
            'taps=${totem?.tapCount ?? 0}, '
            'drags=${totem?.dragUpdateCount ?? 0}, '
            'gizmoMoves=${slider?.dragMoves ?? 0}',
      );

      // 38. `SplinePathEffect3D`, `ArcMoveEffect3D`, `InstanceDataEffect3D`,
      //     `SquashStretchEffect3D`, and `FixedTransformInterpolation3D`.
      final shuttleStart = rig.splineShuttle?.position.clone();
      for (var i = 0; i < 6; i++) {
        await pumpFrame();
      }
      final shuttleMoved =
          shuttleStart != null &&
          (rig.splineShuttle?.position.distanceTo(shuttleStart) ?? 0) > 0.05;
      final arcLifted = (rig.arcJumpOrb?.position.z ?? 0) > 0.46;
      var interpOk = false;
      if (totem != null) {
        final wasInterp = totem.isInterpolated;
        totem.restoreSimulatedState();
        interpOk = wasInterp && !totem.isInterpolated;
      }
      record(
        'effects_3d_and_fixed_interpolation',
        '3D Effects (Spline/Arc/Squash/Color/InstanceData) & FixedInterp3D',
        ok: shuttleMoved && arcLifted && interpOk,
        detail:
            'shuttleMoved=$shuttleMoved, arcLifted=$arcLifted, '
            'fixedInterp=$interpOk',
      );

      // 39. Production 3D Camera Rigs (`OrbitCameraController3D`,
      //     `SpringArmCamera3D`, `CameraDollyTrack3D`, `CameraShake3D`).
      record(
        'camera_rigs_orbit_spring_dolly_shake',
        'Camera Rigs (Orbit fitAabb, Occluded SpringArm, Dolly, 6-DOF Shake)',
        ok: orbitRigOk && springOccludedOk && dollyOk && shakeOk,
        detail:
            'orbit=$orbitRigOk, springOccluded=$springOccludedOk, '
            'dolly=$dollyOk, shake=$shakeOk',
      );

      // --- LAB 14: PhysicsWorld3D, Colliders, Kinematic, NavMesh & Audio3D ---
      game.applyPreset(ShowcasePreset.physicsCollidersKinematicAndNavMesh);
      for (var i = 0; i < 20; i++) {
        await pumpFrame();
      }

      // 40. `PhysicsWorld3D` (`RigidBody3D` `throwDice3D` + `HingeJoint3D`).
      final diceOk =
          rig.diceRigidBodies.length == 4 &&
          rig.diceRigidBodies.every(
            (b) => b.bodyPosition.z > 0.1 && b.bodyPosition.z < 5.0,
          );
      final hingeAngle = rig.pendulumHinge?.jointAngle ?? 99.0;
      final hingeOk =
          rig.pendulumHinge != null &&
          hingeAngle.isFinite &&
          hingeAngle.abs() <= 1.45;
      record(
        'rigid_body_3d_dice_and_hinge_joint',
        'PhysicsWorld3D (Seeded 3D Dice Throw & HingeJoint3D Pendulum)',
        ok: diceOk && hingeOk,
        detail:
            'dice=${rig.diceRigidBodies.length}, '
            'hingeAngle=${hingeAngle.toStringAsFixed(2)} rad',
      );

      // 41. `CollisionSystem3D`, `TriggerVolume3D`, `ShapeCast3D` &
      //     `KinematicCharacterController3D` stair step-up!
      final sweepHit = ShapeCast3D.sphereCast(
        origin: Vector3(8.2, 11.4, 0.15),
        radius: 0.25,
        delta: Vector3(1.2, 0.0, 0.0),
        collisionSystem: rig.collisionSystem,
      );
      // Drive the kinematic character straight up the 2-step staircase into
      // `triggerPad` & `collisionBeacon` at `x = 10.15`.
      final kcc = rig.kinematicController;
      final actor = rig.kinematicActor;
      if (kcc != null && actor != null) {
        actor.position.setValues(8.3, 11.4, 0.0);
        for (var i = 0; i < 15; i++) {
          kcc.moveAndSlide(
            Vector3(4.5, 0.0, -4.0),
            1.0 / 30.0,
            collisionSystem: rig.collisionSystem,
          );
          rig.collisionSystem?.step();
        }
      }
      final climbedStairs = (actor?.position.z ?? 0) > 0.35;
      final triggersOk =
          rig.triggerEnters >= 1 &&
          (rig.collisionBeacon?.collisionStarts ?? 0) >= 1;
      record(
        'colliders_trigger_shapecast_and_kinematic',
        'CollisionSystem3D + TriggerVolume3D + ShapeCast3D + Kinematic Step-Up',
        ok:
            sweepHit != null &&
            sweepHit.toi < 1.0 &&
            climbedStairs &&
            triggersOk,
        detail:
            'toi=${sweepHit?.toi.toStringAsFixed(2)}, '
            'actorZ=${actor?.position.z.toStringAsFixed(2)}, '
            'triggers=${rig.triggerEnters}',
      );

      // 42. `NavMesh3D` funnel path + `CrowdSteering3D` + `SkinnedHitboxRig3D`
      //     + `SpatialAudio3D`!
      final navPath =
          rig.steppedNavMesh?.findPath(
            Vector3(2.8, 5.0, 0.05),
            Vector3(11.2, 5.0, 0.65),
          ) ??
          const [];
      final navOk = navPath.length >= 2 && navPath.last.z > 0.55;
      final crowdOk =
          (rig.crowdSteering?.agents.length ?? 0) == 4 &&
          rig.crowdSteering!.agents.every((a) => a.position.x > 2.9);

      BoneRayHit3D? boneHit;
      if (rig.skinnedHitboxRig case final sRig?) {
        sRig.syncTransforms();
        final tipBox = sRig.hitboxes.last;
        final tipCenter = tipBox.worldMatrix.getTranslation();
        boneHit = sRig.raycast(
          Ray.originDirection(
            tipCenter + Vector3(0, 0, 2.0),
            Vector3(0, 0, -1),
          ),
        );
      }
      final mix = rig.audioEmitter3D?.lastMix;
      final audioOk =
          mix != null && mix.volume > 0.05 && mix.pan >= -1.0 && mix.pan <= 1.0;
      record(
        'navmesh_crowd_bone_hitbox_and_audio3d',
        'NavMesh3D Funnel + CrowdSteering3D + BoneHitbox3D + SpatialAudio3D',
        ok: navOk && crowdOk && boneHit != null && audioOk,
        detail:
            'navPts=${navPath.length}, bone=${boneHit?.boneName}, '
            'vol=${mix?.volume.toStringAsFixed(2)}',
      );

      // --- LAB 15: BlendSpaces, Crowd64, SceneLoader3D & Isolate Streaming ---
      game.applyPreset(ShowcasePreset.blendTreesCrowdSceneLoaderAndIsolate);
      for (var i = 0; i < 18; i++) {
        await pumpFrame();
      }

      // 43. `BlendSpace1D` / `BlendSpace2D`, `AnimationEvent3D`,
      //     `RootMotionExtractor3D`, and `OffscreenAnimationPolicy`.
      final w1 = rig.blend1DWalker;
      final w2 = rig.blend2DWalker;
      var offscreenDeferredOk = false;
      if (w2 != null) {
        w2.resetPoseEvaluationsCount();
        w2.update(0.05);
        // `tickOnlyEvaluateWhenVisible` defers pose evaluation until draw!
        final evalsDuringUpdate = w2.poseEvaluationsCount;
        w2.evaluatePose();
        offscreenDeferredOk =
            evalsDuringUpdate == 0 && w2.poseEvaluationsCount == 1;
      }
      final blendAndEventsOk =
          w1 != null &&
          w1.animationState.activeBlendSpace1D != null &&
          w2?.animationState.activeBlendSpace2D != null &&
          rig.animEventsFired >= 1 &&
          offscreenDeferredOk;
      record(
        'blend_spaces_events_rootmotion_offscreen',
        'BlendSpace 1D/2D + AnimationEvent3D + RootMotion + OffscreenPolicy',
        ok: blendAndEventsOk,
        detail:
            'events=${rig.animEventsFired}, '
            'deferredOffscreen=$offscreenDeferredOk',
      );

      // 44. `SkinnedCrowdBatch3D` (64 agents) + `AsyncModelLoader3D` Isolate +
      //     `AssetScope3D`.
      final crowd64 = rig.skinnedCrowd64;
      final crowd64Ok =
          crowd64 != null &&
          crowd64.length == 64 &&
          (crowd64.lastSkinnedNodeDraws >= 64 ||
              crowd64.lastInstancedSubNodeDraws >= 1);
      final isolateOk =
          rig.isolateGlbModel != null &&
          rig.isolatePreparedBvhs.isNotEmpty &&
          rig.assetScope3D.refCountOf(rig.isolateGlbModel!) >= 1;
      record(
        'skinned_crowd_64_and_isolate_streaming',
        'SkinnedCrowdBatch3D (64 Agents) + Isolate GLB/BVH + AssetScope3D',
        ok: crowd64Ok && isolateOk,
        detail:
            'crowd=${crowd64?.length ?? 0}, '
            'bvhs=${rig.isolatePreparedBvhs.length}',
      );

      // 45. `SceneLoader3D` + 6 glTF Extensions + `onNodeExtras`.
      final extScene = rig.loadedExtendedScene;
      final extSceneOk =
          extScene != null &&
          extScene.lights.length == 2 &&
          extScene.instancedGroups.length == 1 &&
          extScene.instancedGroups.first.length == 8 &&
          extScene.staticMeshes.isNotEmpty &&
          rig.sceneExtrasCallbackHits >= 1;
      record(
        'gltf_extensions_and_scene_loader_3d',
        'SceneLoader3D (KHR_lights/unlit/emissive/quant + EXT_instancing)',
        ok: extSceneOk,
        detail:
            'lights=${extScene?.lights.length ?? 0}, '
            'instanced=${extScene?.instancedGroups.firstOrNull?.length ?? 0}, '
            'extras=${rig.sceneExtrasCallbackHits}',
      );

      // --- LAB 16: SSAO, 3D DoF, Soft Particles, 2-Cascade CSM & Portal ---
      game.applyPreset(ShowcasePreset.ssaoDofCsmPortalAndDebug3D);
      await pumpFrame();
      await pumpFrame();

      // 46. Half-res `DepthNormalPrepass` (`SSAO` + `3D DoF` + Soft Particles
      //     + Shoreline Water Foam).
      final hasDepthNorm =
          game.dynamicLayer.context.activeDepthNormalTexture != null;
      final depthNormOk =
          game.dynamicLayer.world.depthPrepassEnabled &&
          hasDepthNorm &&
          (game.dynamicLayer.postProcess?.ssaoIntensity ?? 0) > 0.5 &&
          (game.dynamicLayer.postProcess?.dofBlurStrength ?? 0) > 0.3 &&
          (rig.softMistMaterial?.softDepthFade ?? 0) > 0.05 &&
          (rig.shoreFoamWaterMaterial?.shoreFoamDepth ?? 0) > 0.05;
      record(
        'depth_normal_ssao_dof_soft_particles_foam',
        'DepthNormalPrepass (SSAO + 3D DoF + Soft Particles + Shore Foam)',
        ok: depthNormOk,
        detail:
            'prepass=$hasDepthNorm, '
            'ssao=${game.dynamicLayer.postProcess?.ssaoIntensity}',
      );

      // 47. 2-Cascade Directional Shadow Atlas + Shadowing `SpotLight` +
      //     `EnvironmentProbe3D` `SH9` IBL + `cameraMask`/`lightMask`.
      final dynCsmPasses = game.dynamicLayer.renderStats.shadowPasses;
      final statCsmPasses = game.staticLayer.renderStats.shadowPasses;
      // Mask out directional sun for 1 frame (`lightMask = 0`) so `_ShadowPass`
      // renders the perspective `SpotLight` shadow map.
      final dynSun = game.dynamicLayer.world.children
          .whereType<LightComponent>()
          .firstWhere((l) => l.source is DirectionalLight);
      dynSun.lightMask = 0;
      await pumpFrame();
      final spotShPasses = game.dynamicLayer.renderStats.shadowPasses;
      final spotShadowActive = game.dynamicLayer.context.hasActiveShadows;
      dynSun.lightMask = 0xFFFFFFFF;
      await pumpFrame();

      final probe = rig.v3.skyDomeProbe;
      final skyIrr = probe.evaluateIrradiance(Vector3(0, 0, 1));
      final gndIrr = probe.evaluateIrradiance(Vector3(0, 0, -1));
      final csmSpotIblOk =
          statCsmPasses == 2 &&
          dynCsmPasses == 2 &&
          spotShPasses == 1 &&
          spotShadowActive &&
          skyIrr.z > gndIrr.z;
      record(
        'csm_2_cascades_spot_shadows_and_sh9_ibl',
        '2-Cascade CSM Atlas + SpotLight Shadows + SH9 IBL + Layer Masks',
        ok: csmSpotIblOk,
        detail:
            'csmPasses=$statCsmPasses/$dynCsmPasses, '
            'spotShPasses=$spotShPasses, sh9=${skyIrr.z > gndIrr.z}',
      );

      // 48. Live GPU `RenderTexture3D` Portal + `DebugRenderer3D` +
      //     `GraphicsDevice.warmupMaterial`/VRAM + `Canvas3DFallbackComponent`.
      final portal = rig.portalRenderTexture;
      final dbgSegs = rig.labDebugRenderer?.lastSegmentCount ?? 0;
      final warmedPipe = game.dynamicLayer.device.warmupMaterial(
        UnlitMaterial(),
      );
      final vramBytes = game.dynamicLayer.device.estimatedTargetVramBytes;

      final fbWorld = World3D()
        ..add(
          MeshComponent(
            mesh: CuboidMesh(
              size: Vector3.all(1),
              material: UnlitMaterial(albedoColor: const ui.Color(0xFF38BDF8)),
            ),
          ),
        );
      final fbComp = Canvas3DFallbackComponent(
        world: fbWorld,
        size: Vector2(120, 90),
        cullBackFaces: false,
      );
      final fbRec = ui.PictureRecorder();
      fbComp.render(ui.Canvas(fbRec));
      fbRec.endRecording().dispose();
      final fallbackTris = fbComp.lastTrianglesSubmitted;

      final portalDbgOk =
          portal != null &&
          portal.renderCount >= 1 &&
          dbgSegs >= 20 &&
          warmedPipe.id >= 0 &&
          vramBytes > 0 &&
          fallbackTris == 12;
      record(
        'render_texture_portal_debug3d_and_fallback',
        'RenderTexture3D Portal + DebugRenderer3D + Warmup + Canvas3D Fallback',
        ok: portalDbgOk,
        detail:
            'portalFrames=${portal?.renderCount ?? 0}, dbgSegs=$dbgSegs, '
            'vramKB=${vramBytes ~/ 1024}, fbTris=$fallbackTris',
      );
    } finally {
      game.applyPreset(savedPreset);
      ctrl
        ..autoOrbitCamera = savedOrbit
        ..wind = savedWind
        ..retainedStaticLayer = savedRetained
        ..staticShadowCache = savedShadowCache
        ..sharedShadowGroup = savedSharedShadow
        ..bloom = savedBloom
        ..fog = savedFog
        ..outlines = savedOutlines
        ..particles = savedParticles
        ..ribbonsAndDecals = savedRibbons
        ..stressInstances = savedStress
        ..spatialIndex3D = savedSpatialIdx
        ..prioritizeNearestLights = savedLightCull
        ..toneMap = savedToneMap
        ..fxaa = savedFxaa
        ..vignette = savedVignette
        ..ssao = savedSsao
        ..dof = savedDof
        ..csm2Cascades = savedCsm2
        ..debug3D = savedDebug3D
        ..shadowEncoding = savedEncoding
        ..shadowFit = savedFit
        ..shadowSoftness = savedSoftness
        ..renderScale = savedScale
        ..playMode = savedPlayMode
        ..animSpeed = savedSpeed;
      game.camera.viewfinder
        ..zoom = savedZoom
        ..position = savedPos;
      game.syncControllerState();
    }

    sw.stop();
    return ShowcaseDiagnosticReport(results: results, elapsed: sw.elapsed);
  }
}
