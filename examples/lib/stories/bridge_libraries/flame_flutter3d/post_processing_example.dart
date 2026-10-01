import 'dart:math' as math;

import 'package:examples/stories/bridge_libraries/flame_flutter3d/story_host.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d/flutter3d.dart' hide Material;

class PostProcessingExample extends FlameGame with HasFlutter3d {
  static const String description = '''
    A lit 3D scene drawn by flutter3d under a Flame HUD, with the
    post-processing of the frame switched on and off from the panel: bloom,
    ambient occlusion, screen-space reflections, depth of field, motion
    blur, volumetric fog with light shafts, the tone mapping curve, exposure
    and temporal anti-aliasing.

    The ring of cubes is turned by a Flame effect, so motion blur has
    something to smear. On the web the frame is drawn through WebGL2, or
    through WebGPU in a build made with
    `--dart-define=FLUTTER3D_WEBGPU=true`; the HUD says which.
  ''';

  /// What the panel switches; read for every frame.
  final PostProcessingOptions options = PostProcessingOptions();

  static final Vector3 _focus = Vector3(0, 0.8, 0);

  @override
  CameraNode createCamera3d() =>
      CameraNode(
          name: 'camera',
          projection: const PerspectiveProjection(fovYRadians: 0.8, far: 200),
        )
        ..setPosition(0, 3.2, 8.5)
        ..lookAt(_focus);

  @override
  RenderSettings renderSettings() => options.settings(
    focusDistance: camera3d.readWorldPosition().distanceTo(_focus),
  );

  @override
  void onOpen3d() {
    clearColor.setValues(0.02, 0.025, 0.04, 1);

    MeshNode mesh(Shape shape, engine.Material material) =>
        MeshNode(DeviceMesh.upload(device, shape.build()), material);

    scene
      ..add(
        mesh(
          const PlaneShape(width: 200, depth: 200),
          engine.Material(
            name: 'floor',
            baseColor: Vector4(0.18, 0.19, 0.22, 1),
            metallic: 0.2,
            roughness: 0.25,
          ),
        ),
      )
      ..add(
        LightNode(intensity: 2.2, color: Vector3(1, 0.92, 0.8))
          ..setLocalForward(Vector3(-0.5, -0.6, -0.8)),
      )
      ..add(
        LightNode(
          type: LightType.point,
          intensity: 30,
          range: 12,
          color: Vector3(0.3, 0.6, 1),
        )..setPosition(-3, 2.5, 1),
      );

    // A row of spheres from rough plastic to polished metal.
    for (var i = 0; i < 5; i++) {
      final t = i / 4;
      scene.add(
        mesh(
          const SphereShape(radius: 0.55),
          engine.Material(
            name: 'sphere $i',
            baseColor: Vector4(0.9, 0.55 + 0.3 * t, 0.3, 1),
            metallic: t,
            roughness: 0.85 - 0.75 * t,
          ),
        )..setPosition(-3 + 1.5 * i, 0.55, -1.5),
      );
    }

    // Glowing shapes, far brighter than white, for the bloom to catch.
    scene
      ..add(
        mesh(
          const TorusShape(radius: 0.7, tubeRadius: 0.12),
          engine.Material(
            name: 'ring light',
            baseColor: Vector4(0.1, 0.1, 0.1, 1),
            emissive: Vector3(1, 0.35, 0.1),
            emissiveStrength: 12,
          ),
        )..setPosition(0, 1.6, -3.5),
      )
      ..add(
        mesh(
          CuboidShape(size: Vector3(0.3, 1.6, 0.3)),
          engine.Material(
            name: 'pillar light',
            baseColor: Vector4(0.1, 0.1, 0.1, 1),
            emissive: Vector3(0.2, 0.7, 1),
            emissiveStrength: 8,
          ),
        )..setPosition(3.5, 0.8, -3),
      );

    // A ring of cubes on a node Flame turns, through its own effects.
    final ring = SceneNode(name: 'ring');
    final cube = DeviceMesh.upload(
      device,
      CuboidShape(size: Vector3.all(0.45)).build(),
    );
    final cubeMaterial = engine.Material(
      name: 'cube',
      baseColor: Vector4(0.85, 0.85, 0.9, 1),
      metallic: 0.6,
      roughness: 0.3,
    );
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      ring.add(
        MeshNode(cube, cubeMaterial)
          ..setPosition(1.6 * math.cos(angle), 0, 1.6 * math.sin(angle)),
      );
    }
    add(
      Node3dComponent(
        node: ring,
        scene: scene,
        position: Vector3(0, 0.45, 1.2),
      )..add(
        Rotate3dEffect.by(
          Vector3(0, 1, 0),
          2 * math.pi,
          EffectController(duration: 2.5, infinite: true),
        ),
      ),
    );

    add(
      TextComponent(
        text: 'Drawn with ${backendName(device)}',
        position: Vector2.all(16),
      ),
    );
  }

  /// The panel of switches over the game.
  static Widget panel(BuildContext context, PostProcessingExample game) =>
      _Panel(options: game.options);
}

/// The switches of [PostProcessingExample], read into a [RenderSettings]
/// each frame.
class PostProcessingOptions {
  bool bloom = true;
  bool ambientOcclusion = true;
  bool groundTruthOcclusion = false;
  bool reflections = true;
  bool depthOfField = false;
  bool motionBlur = false;
  bool volumetricFog = false;
  bool autoExposure = false;
  bool temporalAntiAlias = true;
  double exposure = RenderSettings.defaultExposure;
  TonemapCurve tonemapCurve = TonemapCurve.aces;

  static const List<TonemapCurve> curves = [
    TonemapCurve.neutral,
    TonemapCurve.aces,
    TonemapCurve.agx,
    TonemapCurve.reinhard,
  ];

  RenderSettings settings({required double focusDistance}) => RenderSettings(
    exposure: exposure,
    tonemapCurve: tonemapCurve,
    bloom: BloomSettings(enabled: bloom, intensity: 0.08),
    ambientOcclusion: AmbientOcclusionSettings(
      enabled: ambientOcclusion,
      method: groundTruthOcclusion
          ? AmbientOcclusionMethod.gtao
          : AmbientOcclusionMethod.ssao,
    ),
    reflections: ReflectionSettings(enabled: reflections),
    depthOfField: DepthOfFieldSettings(
      enabled: depthOfField,
      focusDistance: focusDistance,
      aperture: 2,
    ),
    motionBlur: MotionBlurSettings(enabled: motionBlur),
    volumetricFog: VolumetricFogSettings(
      enabled: volumetricFog,
      density: 0.06,
    ),
    lightShafts: LightShaftSettings(enabled: volumetricFog),
    autoExposure: AutoExposureSettings(enabled: autoExposure),
    antiAlias: AntiAliasSettings(
      enabled: temporalAntiAlias,
      temporal: TemporalSettings(enabled: temporalAntiAlias),
    ),
  );
}

class _Panel extends StatefulWidget {
  const _Panel({required this.options});

  final PostProcessingOptions options;

  @override
  State<_Panel> createState() => _PanelState();
}

class _PanelState extends State<_Panel> {
  PostProcessingOptions get _options => widget.options;

  /// Each switch: its label, whether it is on, and how it is set.
  List<(String, bool, ValueChanged<bool>)> get _switches => [
    ('Bloom', _options.bloom, (on) => _options.bloom = on),
    (
      'Ambient occlusion',
      _options.ambientOcclusion,
      (on) => _options.ambientOcclusion = on,
    ),
    (
      'GTAO',
      _options.groundTruthOcclusion,
      (on) => _options.groundTruthOcclusion = on,
    ),
    ('Reflections', _options.reflections, (on) => _options.reflections = on),
    (
      'Depth of field',
      _options.depthOfField,
      (on) => _options.depthOfField = on,
    ),
    ('Motion blur', _options.motionBlur, (on) => _options.motionBlur = on),
    (
      'Fog and light shafts',
      _options.volumetricFog,
      (on) => _options.volumetricFog = on,
    ),
    (
      'Auto exposure',
      _options.autoExposure,
      (on) => _options.autoExposure = on,
    ),
    (
      'Temporal AA',
      _options.temporalAntiAlias,
      (on) => _options.temporalAntiAlias = on,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: const Color(0xCC101318),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (label, value, set) in _switches)
                  FilterChip(
                    label: Text(label),
                    selected: value,
                    onSelected: (on) => setState(() => set(on)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final curve in PostProcessingOptions.curves)
                  ChoiceChip(
                    label: Text(curve.name),
                    selected: _options.tonemapCurve == curve,
                    onSelected: (_) =>
                        setState(() => _options.tonemapCurve = curve),
                  ),
              ],
            ),
            Row(
              children: [
                const Text('Exposure', style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    value: _options.exposure,
                    min: 0.25,
                    max: 4,
                    onChanged: _options.autoExposure
                        ? null
                        : (value) => setState(() => _options.exposure = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
