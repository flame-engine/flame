import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/debug.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/showcase/showcase_meshes.dart';
import 'package:flutter/widgets.dart' hide Matrix4;

/// Camera rig variations tested in [PureCameraLabGame].
enum PureCameraMode(final String label) {
  perspectiveOrbit('Perspective Orbit'),
  orthographic('Orthographic (-near)'),
  thirdPerson('ThirdPersonCamera'),
  firstPerson('FirstPersonCamera'),
  orbitController3D('OrbitController3D'),
  springArm3D('SpringArmCamera3D'),
  dollyTrack3D('CameraDollyTrack3D'),
  customMirrored('Custom Mirrored Matrix'),
}

/// Pure 3D [FlameGame3D] testbed exercising [CameraComponent3D] modes
/// ([CameraProjection.perspective], [CameraProjection.orthographic],
/// [ThirdPersonCamera], [FirstPersonCamera], and mirrored
/// `customViewMatrix`/`customProjectionMatrix`), [SkyboxComponent3D],
/// [PostProcessSettings], `viewportPointToRay` picking, `worldToViewportPoint`
/// 2D HUD projection, [Line3D], [FogSettings], and [BloomSettings].
class PureCameraLabGame() extends FlameGame3D with TapCallbacks {
  this
    : super(
        world: World3D(),
        camera: CameraComponent3D(
          position: Vector3(7, 5.5, 7),
          target: Vector3(0, 0.8, 0),
          up: Vector3(0, 1, 0),
          fovY: 55,
        ),
      );

  @override
  ui.Color backgroundColor() => const ui.Color(0xFF0E1626);

  final ValueNotifier<int> hudTick = ValueNotifier<int>(0);
  final ShowcaseAssets labAssets = ShowcaseAssets();

  PureCameraMode _mode = PureCameraMode.perspectiveOrbit;
  PureCameraMode get mode => _mode;

  bool skyboxEnabled = true;
  bool bloomEnabled = true;
  bool fogEnabled = true;
  bool acesPostEnabled = true;
  bool debugOverlayEnabled = false;

  late final SkyboxComponent3D skybox;
  late final DebugRenderer3D debugRenderer;
  late final MeshComponent rover;
  late final MeshComponent beaconA;
  late final MeshComponent beaconB;
  late final MeshComponent occluderWall;
  late final ThirdPersonCamera _thirdPersonCam;
  late final FirstPersonCamera _firstPersonCam;
  late final OrbitCameraController3D orbitController;
  late final SpringArmCamera3D springArm;
  late final CameraDollyTrack3D dollyTrack;
  late final CameraShake3D cameraShake;

  Vector2 beaconAScreen = Vector2.zero();
  Vector2 beaconBScreen = Vector2.zero();
  String lastPickText = 'Tap any 3D object to pick via viewportPointToRay()';

  double _time = 0;
  double _uiTimer = 0;

  @override
  Msaa msaa() => Msaa.sample4;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    skybox = SkyboxComponent3D(
      material: SkyboxMaterial3D(
        zenithColor: const ui.Color(0xFF0A2463),
        horizonColor: const ui.Color(0xFF3E92CC),
        sunDirection: Vector3(-0.5, -0.9, -0.4),
        sunIntensity: 1.35,
      ),
    );

    syncEffects();

    final floorMat = StylizedMaterial(
      matCapTexture: labAssets.coatMatCap,
      matCapThreshold: 0.35,
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    final goldMat = StylizedMaterial(
      matCapTexture: labAssets.goldMatCap,
      matCapThreshold: -1,
      matCapGlossWeight: 0,
      matCapMetallic: 1.0,
    )..renderState = const RenderState(cullMode: CullMode.backFace);

    rover = MeshComponent(
      mesh: CuboidMesh(
        size: Vector3(0.7, 0.45, 1.1),
        material: UnlitMaterial(albedoColor: const ui.Color(0xFF38BDF8))
          ..renderState = RenderState.opaque,
      ),
      position: Vector3(2.5, 0.35, 0),
    );

    beaconA = MeshComponent(
      mesh: SphereMesh(
        radius: 0.42,
        segments: 18,
        material: goldMat,
      ),
      position: Vector3(-2.4, 0.85, -1.8),
      color: const ui.Color(0xFFFFD166),
    );

    beaconB = MeshComponent(
      mesh: ConeMesh(
        radius: 0.45,
        height: 1.3,
        segments: 16,
        material: SpatialMaterial(
          albedoColor: const ui.Color(0xFFF43F5E),
          metallic: 0.35,
          roughness: 0.28,
        )..renderState = const RenderState(cullMode: CullMode.backFace),
      ),
      position: Vector3(2.2, 0.65, 2.1),
    );

    final axisRed = UnlitMaterial(albedoColor: const ui.Color(0xFFEF4444))
      ..renderState = RenderState.opaque;
    final axisGreen = UnlitMaterial(albedoColor: const ui.Color(0xFF22C55E))
      ..renderState = RenderState.opaque;
    final axisBlue = UnlitMaterial(albedoColor: const ui.Color(0xFF3B82F6))
      ..renderState = RenderState.opaque;

    world.addAll([
      skybox,
      LightComponent.hemisphere(
        skyColor: const ui.Color(0xFFA5C8FF),
        groundColor: const ui.Color(0xFF475569),
        intensity: 0.6,
      ),
      LightComponent.directional(
        direction: Vector3(-0.5, -0.9, -0.4),
        intensity: 1.8,
        shadows: ShadowSettings(
          maxDistance: 24,
          color: const ui.Color(0xFF1E293B),
        ),
      ),
      LightComponent.point(
        position: Vector3(0, 2.2, 0),
        color: const ui.Color(0xFF67E8F9),
        intensity: 3.5,
        range: 9,
      ),
      MeshComponent(
        mesh: PlaneMesh(size: Vector2.all(12), material: floorMat),
        color: const ui.Color(0xFF334155),
      ),
      Line3D.generate(
        start: Vector3(0, 0.05, 0),
        end: Vector3(2.5, 0.05, 0),
        radius: 0.035,
        material: axisRed,
      ),
      Line3D.generate(
        start: Vector3(0, 0.05, 0),
        end: Vector3(0, 2.5, 0),
        radius: 0.035,
        material: axisGreen,
      ),
      Line3D.generate(
        start: Vector3(0, 0.05, 0),
        end: Vector3(0, 0.05, 2.5),
        radius: 0.035,
        material: axisBlue,
      ),
      rover,
      beaconA,
      beaconB,
    ]);

    occluderWall = MeshComponent(
      mesh: CuboidMesh(
        size: Vector3(2.8, 2.2, 0.32),
        material: SpatialMaterial(
          albedoColor: const ui.Color(0xFF475569),
          roughness: 0.65,
        )..renderState = const RenderState(cullMode: CullMode.backFace),
      ),
      position: Vector3(0, 1.1, 4.4),
    );
    debugRenderer = DebugRenderer3D(enabled: debugOverlayEnabled);
    world.addAll([occluderWall, debugRenderer]);

    _thirdPersonCam = ThirdPersonCamera(
      following: rover.position,
      followDamping: 8.0,
      fovY: 58,
    )..distance = 4.6;
    _firstPersonCam = FirstPersonCamera(
      following: Vector3(2.5, 0.85, 0),
      fovY: 68,
    );
    orbitController = OrbitCameraController3D(
      camera: camera,
      target: Vector3(0, 0.7, 0),
      yaw: 0.6,
      pitch: 0.42,
      distance: 8.2,
      damping: 10.0,
    );
    springArm = SpringArmCamera3D(
      camera: camera,
      world: world,
      targetComponent: rover,
      socketOffset: Vector3(0, 0.65, 0),
      armLength: 5.2,
      collisionFilter: (obj) => !identical(obj, rover),
    );
    dollyTrack = CameraDollyTrack3D(
      camera: camera,
      eyeSpline: CatmullRomSpline3D([
        Vector3(-6.5, 3.8, 6.0),
        Vector3(0.0, 5.2, 7.2),
        Vector3(6.8, 3.6, 4.5),
        Vector3(5.5, 2.8, -5.5),
      ]),
      lookAtTarget: Vector3(0, 0.75, 0),
      duration: 6.0,
      loop: true,
    );
    cameraShake = CameraShake3D(
      camera: camera,
      maxPositionOffset: 0.42,
      maxAngleRad: 0.065,
    );
  }

  /// Switches the active 3D camera / projection mode.
  void setCameraMode(PureCameraMode next) {
    _mode = next;
    camera
      ..customViewMatrix = null
      ..customProjectionMatrix = null;

    switch (next) {
      case PureCameraMode.perspectiveOrbit:
        camera
          ..projection = CameraProjection.perspective
          ..fovY = 55
          ..near = 0.1
          ..far = 100
          ..up.setValues(0, 1, 0);
      case PureCameraMode.orthographic:
        camera
          ..projection = CameraProjection.orthographic
          ..orthographicHeight = 7.5
          ..near = -25
          ..far = 60
          ..position.setValues(7.5, 6.5, 7.5)
          ..target.setValues(0, 0.6, 0)
          ..up.setValues(0, 1, 0);
      case PureCameraMode.thirdPerson:
      case PureCameraMode.firstPerson:
      case PureCameraMode.orbitController3D:
      case PureCameraMode.springArm3D:
      case PureCameraMode.dollyTrack3D:
        camera
          ..projection = CameraProjection.perspective
          ..fovY = next == PureCameraMode.firstPerson ? 68 : 56
          ..near = 0.1
          ..far = 100
          ..up.setValues(0, 1, 0);
      case PureCameraMode.customMirrored:
        final swapXZ = Matrix4.identity()
          ..setEntry(0, 0, 0)
          ..setEntry(0, 2, 1)
          ..setEntry(2, 0, 1)
          ..setEntry(2, 2, 0);
        final view = Matrix4.zero()
          ..setAsViewMatrix(
            Vector3(8, 6.5, 8),
            Vector3(0, 0.5, 0),
            Vector3(0, 1, 0),
          )
          ..multiply(swapXZ);
        final aspect = hasLayout && canvasSize.y > 0
            ? canvasSize.x / canvasSize.y
            : 1.6;
        final proj = Matrix4.zero()
          ..setAsOrthographicOffCenter(
            -4.2 * aspect,
            4.2 * aspect,
            -4.2,
            4.2,
            -30,
            60,
          );
        camera
          ..customViewMatrix = view
          ..customProjectionMatrix = proj;
    }
    hudTick.value++;
  }

  void syncEffects() {
    world
      ..fog = fogEnabled
          ? FogSettings(
              color: const ui.Color(0xFF1B2A4A),
              start: 8,
              end: 34,
              heightFalloff: 0.35,
            )
          : null
      ..bloom = bloomEnabled
          ? BloomSettings(threshold: 0.65, intensity: 0.75, radius: 1.4)
          : null
      ..postProcess = acesPostEnabled
          ? PostProcessSettings(
              toneMap: ToneMapMode.acesFilmic,
              exposure: 1.05,
              vignetteIntensity: 0.22,
              fxaa: true,
            )
          : null;
    if (isLoaded) {
      debugRenderer.enabled = debugOverlayEnabled;
      if (skyboxEnabled && !skybox.isMounted) {
        world.add(skybox);
      } else if (!skyboxEnabled && skybox.isMounted) {
        skybox.removeFromParent();
      }
    }
    hudTick.value++;
  }

  /// Adds a 6-DOF trauma shake impulse to [cameraShake].
  void triggerTraumaShake([double amount = 0.78]) {
    cameraShake.addTrauma(amount);
    hudTick.value++;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt <= 0 || !isLoaded) {
      return;
    }
    _time += dt;

    final ang = _time * 0.9;
    const trackR = 2.8;
    final rx = math.cos(ang) * trackR;
    final rz = math.sin(ang) * trackR;
    rover.position.setValues(rx, 0.32, rz);
    final yaw = -ang;
    rover.rotation.setAxisAngle(Vector3(0, 1, 0), yaw);

    switch (_mode) {
      case PureCameraMode.perspectiveOrbit:
        final camAng = _time * 0.35;
        camera
          ..position.setValues(
            math.cos(camAng) * 7.8,
            4.8 + math.sin(_time * 0.7) * 0.8,
            math.sin(camAng) * 7.8,
          )
          ..target.setValues(0, 0.6, 0);
      case PureCameraMode.orthographic:
      case PureCameraMode.customMirrored:
        break;
      case PureCameraMode.thirdPerson:
        _thirdPersonCam
          ..following.setFrom(rover.position)
          ..rotation.setAxisAngle(Vector3(0, 1, 0), yaw - 0.35)
          ..update(dt);
        camera
          ..position.setFrom(_thirdPersonCam.position)
          ..target.setFrom(_thirdPersonCam.target);
      case PureCameraMode.firstPerson:
        _firstPersonCam
          ..following.setValues(rx, 0.85, rz)
          ..rotation.setAxisAngle(Vector3(0, 1, 0), yaw)
          ..update(dt);
        camera
          ..position.setFrom(_firstPersonCam.position)
          ..target.setFrom(_firstPersonCam.target);
      case PureCameraMode.orbitController3D:
        orbitController
          ..yaw += dt * 0.45
          ..update(dt);
      case PureCameraMode.springArm3D:
        springArm
          ..yaw = yaw + math.pi
          ..pitch = 0.28
          ..update(dt);
      case PureCameraMode.dollyTrack3D:
        dollyTrack.update(dt);
    }
    if (_mode != PureCameraMode.customMirrored) {
      cameraShake.update(dt);
    }

    camera.worldToViewportPoint(
      beaconA.position + Vector3(0, 0.65, 0),
      output: beaconAScreen,
    );
    camera.worldToViewportPoint(
      beaconB.position + Vector3(0, 0.85, 0),
      output: beaconBScreen,
    );

    _uiTimer += dt;
    if (_uiTimer >= 0.08) {
      _uiTimer = 0;
      hudTick.value++;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    final ray = camera.viewportPointToRay(event.canvasPosition);
    final hit = world.raycast(ray);
    if (hit == null) {
      lastPickText = 'Miss (background)';
    } else {
      final tag = identical(hit.object, beaconA)
          ? 'Gold Sphere'
          : identical(hit.object, beaconB)
          ? 'PBR Cone'
          : identical(hit.object, rover)
          ? 'Rover'
          : 'Floor';
      lastPickText =
          'Picked $tag at d=${hit.distance.toStringAsFixed(2)} '
          '(tri=${hit.triangleIndex})';
    }
    hudTick.value++;
  }
}

/// Interactive host widget for [PureCameraLabGame] with 2D viewport-projected
/// world pins (`worldToViewportPoint`) and camera-mode selector pills.
class const PureCameraLabView({
  final PureCameraLabGame? game,
  super.key,
}) extends StatefulWidget {
  @override
  State<PureCameraLabView> createState() => _PureCameraLabViewState();
}

class _PureCameraLabViewState() extends State<PureCameraLabView> {
  late final PureCameraLabGame _game = widget.game ?? PureCameraLabGame();

  @override
  void dispose() {
    if (widget.game == null) {
      _game.hudTick.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _game.hudTick,
      builder: (context, _, _) {
        final stats = _game.renderStats;
        return Stack(
          fit: StackFit.expand,
          children: [
            GameWidget(game: _game),
            if (_game.isLoaded &&
                _game.beaconAScreen.x.isFinite &&
                _game.beaconAScreen.y.isFinite)
              Positioned(
                left: _game.beaconAScreen.x - 38,
                top: _game.beaconAScreen.y - 24,
                child: const _PinTag(
                  label: 'Gold MatCap',
                  color: Color(0xFFFFD166),
                ),
              ),
            if (_game.isLoaded &&
                _game.beaconBScreen.x.isFinite &&
                _game.beaconBScreen.y.isFinite)
              Positioned(
                left: _game.beaconBScreen.x - 32,
                top: _game.beaconBScreen.y - 24,
                child: const _PinTag(
                  label: 'PBR Cone',
                  color: Color(0xFFFB7185),
                ),
              ),
            Positioned(
              left: 10,
              top: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xD90B111E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x3838BDF8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'FlameGame3D • ${_game.mode.label} • '
                    'mirrored=${_game.context.isMirrored}\n'
                    'passes ${stats.renderPasses} (sh ${stats.shadowPasses}) • '
                    'draws ${stats.drawCalls} • tris ${stats.triangles}\n'
                    '${_game.lastPickText}',
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xD90B111E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x2E94A3B8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final m in PureCameraMode.values)
                        GestureDetector(
                          onTap: () => _game.setCameraMode(m),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _game.mode == m
                                  ? const Color(0xFF0E7490)
                                  : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _game.mode == m
                                    ? const Color(0xFF67E8F9)
                                    : const Color(0xFF475569),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                m.label,
                                style: const TextStyle(
                                  color: Color(0xFFF8FAFC),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          _game
                            ..skyboxEnabled = !_game.skyboxEnabled
                            ..syncEffects();
                        },
                        child: _ToggleBadge(
                          label: 'Skybox',
                          on: _game.skyboxEnabled,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _game
                            ..bloomEnabled = !_game.bloomEnabled
                            ..syncEffects();
                        },
                        child: _ToggleBadge(
                          label: 'Bloom',
                          on: _game.bloomEnabled,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _game
                            ..fogEnabled = !_game.fogEnabled
                            ..syncEffects();
                        },
                        child: _ToggleBadge(label: 'Fog', on: _game.fogEnabled),
                      ),
                      GestureDetector(
                        onTap: () {
                          _game
                            ..acesPostEnabled = !_game.acesPostEnabled
                            ..syncEffects();
                        },
                        child: _ToggleBadge(
                          label: 'ACES+FXAA',
                          on: _game.acesPostEnabled,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _game
                            ..debugOverlayEnabled = !_game.debugOverlayEnabled
                            ..syncEffects();
                        },
                        child: _ToggleBadge(
                          label: 'Debug3D',
                          on: _game.debugOverlayEnabled,
                        ),
                      ),
                      GestureDetector(
                        onTap: _game.triggerTraumaShake,
                        child: const _ToggleBadge(
                          label: '⚡ Shake 6-DOF',
                          on: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class const _PinTag({
  required final String label,
  required final Color color,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCC0F172A),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class const _ToggleBadge({
  required final String label,
  required final bool on,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: on ? const Color(0xFF065F46) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: on ? const Color(0xFF34D399) : const Color(0xFF475569),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 11),
        ),
      ),
    );
  }
}
