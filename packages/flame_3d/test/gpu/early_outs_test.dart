import 'dart:math' as math;
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

// The shaders skip work that cannot change a pixel: the shadow map outside
// of it, and where the surface faces away from the sun and has no
// highlights; MatCap textures without strength; point lights of zero
// intensity. These tests render scenes that go through every such case with
// the shaders, and with the straightforward shaders of
// `test/gpu/shaders/reference/`, and check that every pixel is the same.

const _width = 220.0;
const _height = 160.0;

const _stylizedSlots = [
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

const _catcherSlots = [
  'Material',
  RenderContext3D.shadowsBlock,
  RenderContext3D.shadowMapSampler,
];

/// A lit sphere of [color] in a 32 by 32 texture, with mipmaps.
Texture _matCap(Color color) {
  const size = 32;
  final pixels = Uint8List(size * size * 4);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final nx = (x + 0.5) / size * 2 - 1;
      final ny = 1 - (y + 0.5) / size * 2;
      final light = (0.35 + 0.65 * math.max(0, 0.6 * ny - 0.3 * nx)).clamp(
        0.0,
        1.0,
      );
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
    mipmaps: true,
  );
}

/// A box of [size] in [material]'s layout whose vertices have [gloss].
Mesh _box(Material material, Vector3 size, {double gloss = 0}) {
  final positions = <double>[];
  final normals = <double>[];
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
    ),
  );
}

/// A sphere of [radius] in [material]'s layout, whose normals take every
/// direction.
Mesh _sphere(Material material, double radius) {
  const rings = 16;
  const sides = 24;
  final positions = <double>[];
  final normals = <double>[];
  final indices = <int>[];
  for (var r = 0; r <= rings; r++) {
    final polar = r / rings * math.pi;
    for (var s = 0; s <= sides; s++) {
      final azimuth = s / sides * 2 * math.pi;
      final normal = [
        math.sin(polar) * math.cos(azimuth),
        math.sin(polar) * math.sin(azimuth),
        math.cos(polar),
      ];
      positions.addAll(normal.map((c) => c * radius));
      normals.addAll(normal);
    }
  }
  for (var r = 0; r < rings; r++) {
    for (var s = 0; s < sides; s++) {
      final a = r * (sides + 1) + s;
      final b = a + sides + 1;
      indices.addAll([a, b, a + 1, a + 1, b, b + 1]);
    }
  }
  return Mesh()..addSurface(
    StylizedMaterial.buildSurface(
      positions: positions,
      normals: normals,
      indices: indices,
      material: material,
    ),
  );
}

/// Renders a 2D ground below a layer with a sun that casts soft shadows
/// onto part of a shadow catcher and onto stylized boxes with every kind of
/// MatCap, with and without highlights, lit by point lights.
///
/// With [reference], the materials draw with the shaders of
/// `test/gpu/shaders/reference/`. With [zeroLights], the scene also has
/// point lights of zero intensity, all written to the shaders when
/// [writeEveryPointLight].
Future<Pixels> _render(
  WidgetTester tester, {
  required bool reference,
  int softness = 1,
  bool zeroLights = false,
  bool writeEveryPointLight = false,
}) async {
  StylizedMaterial stylized(StylizedMaterial material) {
    if (reference) {
      material.fragmentShader = FragmentShader.fromAsset(
        'test/stylized_reference.shaderbundle',
        slots: _stylizedSlots,
      );
    }
    return material;
  }

  final coat = _matCap(const Color(0xFFE0E8F0));
  final gem = _matCap(const Color(0xFF80C0FF));
  final gold = _matCap(const Color(0xFFFFC060));
  final materials = [
    stylized(StylizedMaterial()),
    stylized(
      StylizedMaterial(matCapTexture: coat, matCapThreshold: 0.3),
    ),
    stylized(StylizedMaterial(gemMatCapTexture: gem, gemThreshold: 0.5)),
    stylized(
      StylizedMaterial(
        matCapTexture: coat,
        gemMatCapTexture: gem,
        gemThreshold: 0.9,
        matCapGlossWeight: 0.5,
      ),
    ),
    stylized(
      StylizedMaterial(
        matCapTexture: gold,
        matCapThreshold: -1,
        matCapMetallic: 1,
      ),
    ),
    // MatCap textures without strength.
    stylized(
      StylizedMaterial(
        matCapTexture: coat,
        gemMatCapTexture: gem,
        matCapStrength: 0,
        gemMatCapStrength: 0,
        matCapMetallic: 0.5,
      ),
    ),
    stylized(StylizedMaterial(translucent: true)),
  ];
  final catcher = ShadowCatcherMaterial(color: const Color(0xC0102040));
  if (reference) {
    catcher.fragmentShader = FragmentShader.fromAsset(
      'test/shadow_catcher_reference.shaderbundle',
      slots: _catcherSlots,
    );
  }

  final layer = Scene3DComponent(
    projection: Scene3DProjection.affine(
      origin: Vector2(0, -18),
      xAxis: Vector2(44, 22),
      yAxis: Vector2(-44, 22),
      zAxis: Vector2(0, -53.889),
      towardsViewer: Vector3(0.6124, 0.6124, 0.5),
      near: -100,
      far: 100,
    ),
    priority: 1,
  );
  layer.world.addAll([
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
        softness: softness,
        color: const Color(0xFF1E2A55),
        strength: 0.8,
        // Only part of the ground receives shadows: the rest is outside of
        // the map.
        bounds: Aabb3.minMax(Vector3(-1, -1, -1), Vector3(5, 4, 3)),
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
    if (zeroLights)
      for (var i = 0; i < 3; i++)
        LightComponent.point(
          position: Vector3(1.0 + i, 1.5, 0.5 + i * 0.3),
          color: const Color(0xFFFFE0C0),
          intensity: 0,
          range: i == 1 ? null : 2,
        ),
    MeshComponent(
      mesh: PlaneMesh(size: Vector2.all(12), material: catcher),
      position: Vector3(3, 3, 0),
      rotation: Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2),
    ),
    // Spheres in the shadow of a tall box: their surfaces turn away from
    // the sun gradually.
    MeshComponent(
      mesh: _box(materials[0], Vector3(0.6, 0.6, 2.4), gloss: 0.5),
      position: Vector3(2.6, 3.4, 1.2),
    ),
    for (final (index, material) in [materials[0], materials[3]].indexed)
      MeshComponent(
        mesh: _sphere(material, 0.35),
        position: Vector3(3.4 + index * 0.6, 2.85 - index * 0.4, 0.36),
      ),
    for (final (index, material) in materials.indexed)
      for (final (gloss, offset) in const [(0.0, 0.0), (1.0, 0.55)])
        MeshComponent(
          mesh: _box(material, Vector3(0.45, 0.45, 0.8), gloss: gloss),
          position: Vector3(
            0.4 + (index % 4) * 1.3 + offset,
            0.6 + (index ~/ 4) * 1.9 + offset,
            0.4 + offset * 0.4,
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
  game.camera.viewfinder
    ..position = layer.positionOf(layer.scenePointToLocal(Vector3(3, 2.5, 0)))
    ..zoom = 0.6;

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
  if (writeEveryPointLight) {
    layer.context.registerPassUniform(
      RenderContext3D.lightsBlock,
      _writeEveryPointLight,
    );
  }
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

/// Writes the point lights of the scene as before zero-intensity lights
/// were left out: the first eight, whatever their intensity.
void _writeEveryPointLight(RenderContext3D context, UniformBlock block) {
  var count = 0;
  for (final light in context.lights) {
    final source = light.source;
    if (source is! PointLight || count == RenderContext3D.maxPointLights) {
      continue;
    }
    final range = source.range;
    block
      ..setVector3('positions', light.position, index: count)
      ..setColor('colors', source.color, index: count)
      ..setFloat('intensities', source.intensity, index: count)
      ..setFloat(
        'ranges',
        range != null && range > 0 ? range : 0,
        index: count,
      );
    count++;
  }
  block.setFloat('numLights', count.toDouble());
}

void main() {
  setUpGpu();

  setUpAll(() async {
    if (gpuAvailable) {
      await registerTestShaders([
        'stylized_reference',
        'shadow_catcher_reference',
      ]);
    }
  });

  group('Shader early-outs', () {
    for (final softness in [0, 1, 2]) {
      testGpu('render the same pixels, shadow softness $softness', (
        tester,
      ) async {
        final reference = await _render(
          tester,
          reference: true,
          softness: softness,
        );
        final pixels = await _render(
          tester,
          reference: false,
          softness: softness,
        );

        // The scene has shadows on the ground, and lit and shaded boxes.
        expect(
          reference.count((r, g, b, a) => b > r + 8 && b < 120),
          greaterThan(200),
        );
        expect(differingPixels(pixels, reference, tolerance: 0), 0);
      });
    }

    testGpu('leaving out point lights of zero intensity keeps the pixels', (
      tester,
    ) async {
      final everyLight = await _render(
        tester,
        reference: true,
        zeroLights: true,
        writeEveryPointLight: true,
      );
      final pixels = await _render(tester, reference: false, zeroLights: true);

      expect(differingPixels(pixels, everyLight, tolerance: 0), 0);
    });
  });
}
