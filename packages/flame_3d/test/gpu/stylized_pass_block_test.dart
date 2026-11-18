import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart' show RectangleComponent, World;
import 'package:flame/game.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' show GlobalKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

// StylizedMaterial's fragment shader reads the camera, the lights and the
// shadows of the pass from one uniform block
// (RenderContext3D.stylizedPassBlock) where it read six, so that each draw
// binds fewer resources. These tests render scenes with every kind of light,
// shadows, the three vertex stages (its own layout, skinned, the standard
// layout) and perspective, parallel and mirroring projections with the
// fragment shader of before,
// `test/gpu/shaders/reference/stylized_pass_blocks_fragment.glsl`, and with
// today's, and check that every pixel is the same.

const _width = 200.0;
const _height = 150.0;

/// The slots of the fragment shader of before.
const _sixBlockSlots = [
  'matCapTexture',
  'gemMatCapTexture',
  'Material',
  RenderContext3D.ambientLightBlock,
  RenderContext3D.lightsBlock,
  RenderContext3D.directionalLightsBlock,
  RenderContext3D.hemisphereLightBlock,
  RenderContext3D.cameraBlock,
  RenderContext3D.shadowsBlock,
  RenderContext3D.shadowMapSampler,
];

/// A lit sphere of [color] in a 16 by 16 texture.
Texture _matCap(Color color) {
  const size = 16;
  final pixels = Uint8List(size * size * 4);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final light = 0.4 + 0.6 * (1 - y / size) * (0.5 + 0.5 * x / size);
      final i = (y * size + x) * 4;
      pixels
        ..[i] = (color.r * light * 255).round()
        ..[i + 1] = (color.g * light * 255).round()
        ..[i + 2] = (color.b * light * 255).round()
        ..[i + 3] = 255;
    }
  }
  return Texture(
    ByteData.sublistView(pixels),
    width: size,
    height: size,
    sampler: TextureSampler.linear,
  );
}

/// A box of [size] in StylizedMaterial's layout, with [gloss], tinted
/// everywhere; skinned (its top following joint 1) with [skinned].
Mesh _box(
  Material material,
  Vector3 size, {
  double gloss = 0,
  bool skinned = false,
}) {
  final positions = <double>[];
  final normals = <double>[];
  final joints = <double>[];
  final weights = <double>[];
  final indices = <int>[];
  const faces = [
    ([1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]),
    ([-1.0, 0.0, 0.0], [0.0, 0.0, 1.0], [0.0, 1.0, 0.0]),
    ([0.0, 1.0, 0.0], [0.0, 0.0, 1.0], [1.0, 0.0, 0.0]),
    ([0.0, -1.0, 0.0], [1.0, 0.0, 0.0], [0.0, 0.0, 1.0]),
    ([0.0, 0.0, 1.0], [1.0, 0.0, 0.0], [0.0, 1.0, 0.0]),
    ([0.0, 0.0, -1.0], [0.0, 1.0, 0.0], [1.0, 0.0, 0.0]),
  ];
  final half = [size.x / 2, size.y / 2, size.z / 2];
  for (final (normal, u, v) in faces) {
    final base = positions.length ~/ 3;
    for (final (fu, fv) in const [(-1, -1), (1, -1), (1, 1), (-1, 1)]) {
      for (var c = 0; c < 3; c++) {
        positions.add(half[c] * (normal[c] + u[c] * fu + v[c] * fv));
      }
      normals.addAll(normal);
      final top = positions.last > 0 ? 1.0 : 0.0;
      joints.addAll([0, 1, 0, 0]);
      weights.addAll([1 - top, top, 0, 0]);
    }
    indices.addAll([base, base + 1, base + 2, base + 2, base + 3, base]);
  }
  final count = positions.length ~/ 3;
  return Mesh()..addSurface(
    StylizedMaterial.buildSurface(
      positions: positions,
      normals: normals,
      indices: indices,
      material: material,
      gloss: List.filled(count, gloss),
      tint: List.filled(count, 1),
      joints: skinned ? joints : null,
      weights: skinned ? weights : null,
    ),
  );
}

/// The projections the scenes are rendered with.
enum _View() {
  perspective,
  parallel,
  mirrored,
}

/// Renders, under [view], a 2D ground below a layer of stylized boxes (with
/// and without highlights, MatCaps, a metal, a translucent one, a skinned
/// one) and standard-layout meshes on a stylized ground, lit either by an
/// ambient light, two suns (one casting shadows) and two point lights, or by
/// a hemisphere light, a sun casting soft shadows and a point light of zero
/// intensity ([hemisphere]).
///
/// With [reference], the materials draw with the fragment shader of before.
Future<Pixels> _render(
  WidgetTester tester, {
  required bool reference,
  required _View view,
  bool hemisphere = false,
}) async {
  StylizedMaterial stylized(StylizedMaterial material) {
    if (reference) {
      material.fragmentShader = FragmentShader.fromAsset(
        'test/stylized_pass_blocks_reference.shaderbundle',
        slots: _sixBlockSlots,
      );
    }
    return material;
  }

  final materials = [
    stylized(StylizedMaterial()),
    stylized(
      StylizedMaterial(
        matCapTexture: _matCap(const Color(0xFFE0E8F0)),
        matCapThreshold: 0.3,
      ),
    ),
    stylized(
      StylizedMaterial(
        matCapTexture: _matCap(const Color(0xFFFFC060)),
        matCapThreshold: -1,
        matCapMetallic: 1,
      ),
    ),
    stylized(StylizedMaterial(translucent: true)),
  ];
  final ground = stylized(StylizedMaterial());

  final projection = switch (view) {
    _View.perspective => Scene3DProjection.perspective(
      eye: Vector3(3, -3.5, 4),
      target: Vector3(2, 1.5, 0),
      rect: const Rect.fromLTWH(-100, -75, 200, 150),
      fovY: 55,
    ),
    _View.parallel || _View.mirrored => Scene3DProjection.affine(
      origin: Vector2(0, -18),
      xAxis: Vector2(view == _View.mirrored ? -44 : 44, 22),
      yAxis: Vector2(view == _View.mirrored ? 44 : -44, 22),
      zAxis: Vector2(0, -53.889),
      towardsViewer: Vector3(0.6124, 0.6124, 0.5),
      near: -100,
      far: 100,
    ),
  };
  final layer = Scene3DComponent(projection: projection, priority: 1);
  layer.world.addAll([
    if (hemisphere) ...[
      LightComponent.hemisphere(
        skyColor: const Color(0xFFB4CCF0),
        groundColor: const Color(0xFF6E7A50),
        intensity: 0.45,
        up: Vector3(0, 0, 1),
      ),
      LightComponent.directional(
        direction: Vector3(0.6, -0.4, -0.7),
        intensity: 0.8,
        shadows: ShadowSettings(
          softness: 2,
          color: const Color(0xFF1E2A55),
          strength: 0.8,
        ),
      ),
      LightComponent.point(
        position: Vector3(2, 2, 1),
        intensity: 0,
        range: 2,
      ),
    ] else ...[
      LightComponent.ambient(
        color: const Color(0xFFFFF0E0),
        intensity: 0.35,
      ),
      LightComponent.directional(
        direction: Vector3(-0.3, 0.5, -0.8),
        color: const Color(0xFFFFE0C0),
        intensity: 0.5,
        specular: 0.5,
      ),
      LightComponent.directional(
        direction: Vector3(0.6, -0.4, -0.7),
        intensity: 0.7,
        shadows: ShadowSettings(
          color: const Color(0xFF203050),
          strength: 0.7,
        ),
      ),
      LightComponent.point(
        position: Vector3(1, 3, 1.2),
        color: const Color(0xFFFFB060),
        intensity: 2,
        range: 3,
      ),
      LightComponent.point(
        position: Vector3(4, 1, 0.8),
        color: const Color(0xFF60B0FF),
        intensity: 1.5,
      ),
    ],
    MeshComponent(
      mesh: _box(ground, Vector3(7, 6, 0.1)),
      position: Vector3(2.5, 2, -0.05),
      color: const Color(0xFFB0C090),
    ),
    for (final (index, material) in materials.indexed)
      for (final (gloss, offset) in const [(0.0, 0.0), (1.0, 0.6)])
        MeshComponent(
          mesh: _box(material, Vector3(0.45, 0.45, 0.8), gloss: gloss),
          position: Vector3(
            0.4 + index * 1.2 + offset,
            0.6 + offset,
            0.4 + offset * 0.3,
          ),
          rotation: Quaternion.axisAngle(Vector3(0, 0, 1), 0.3 * index),
          color: const Color(0xFFFFE0C0),
          instanceData: Vector4(
            0,
            0,
            0,
            material.renderState.translucent ? 0.4 : 0,
          ),
        ),
    MeshComponent(
      mesh: _box(
        materials[1],
        Vector3(0.4, 0.4, 1.2),
        gloss: 0.8,
        skinned: true,
      ),
      position: Vector3(1.2, 2.6, 0.6),
      jointTransforms: {
        0: [
          Matrix4.identity(),
          Matrix4.translationValues(0.15, -0.1, 0)..rotateX(0.3),
        ],
      },
    ),
    MeshComponent(
      mesh: SphereMesh(radius: 0.4, segments: 24, material: materials[0]),
      position: Vector3(3, 2.8, 0.4),
      color: const Color(0xFF80C0FF),
    ),
    MeshComponent(
      mesh: CuboidMesh(size: Vector3.all(0.5), material: materials[2]),
      position: Vector3(4.2, 2.4, 0.25),
      rotation: Quaternion.axisAngle(Vector3(0, 0, 1), 0.5),
    ),
  ]);
  final game = FlameGame(
    world: World(
      children: [
        RectangleComponent(
          position: Vector2.all(-5000),
          size: Vector2.all(10000),
          paint: Paint()..color = const Color(0xFF808080),
        ),
        layer,
      ],
    ),
  );
  if (view != _View.perspective) {
    game.camera.viewfinder
      ..position = layer.positionOf(layer.scenePointToLocal(Vector3(2.5, 2, 0)))
      ..zoom = 0.6;
  }

  tester.view
    ..physicalSize = const Size(_width * 2, _height * 2)
    ..devicePixelRatio = 2;
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
    final image = await boundary.toImage(pixelRatio: 2);
    final pixels = await readImage(image);
    image.dispose();
    return pixels;
  }))!;
}

void main() {
  setUpGpu();

  setUpAll(() async {
    if (gpuAvailable) {
      await registerTestShaders(['stylized_pass_blocks_reference']);
    }
  });

  group('StylizedMaterial pass block', () {
    for (final view in _View.values) {
      for (final hemisphere in [false, true]) {
        final lights = hemisphere ? 'a hemisphere light' : 'an ambient light';
        testGpu('renders the same pixels as six blocks, ${view.name} view, '
            '$lights', (tester) async {
          final reference = await _render(
            tester,
            reference: true,
            view: view,
            hemisphere: hemisphere,
          );
          final pixels = await _render(
            tester,
            reference: false,
            view: view,
            hemisphere: hemisphere,
          );

          // The layer is drawn: most pixels are not the grey 2D ground.
          expect(
            reference.count((r, g, b, a) => r != g || g != b),
            greaterThan(_width * _height),
          );
          // Shadows on the stylized ground: blue-ish dark pixels.
          expect(
            reference.count((r, g, b, a) => b > r + 8 && r < 120),
            greaterThan(100),
          );
          expect(differingPixels(pixels, reference, tolerance: 0), 0);
        });
      }
    }
  });
}
