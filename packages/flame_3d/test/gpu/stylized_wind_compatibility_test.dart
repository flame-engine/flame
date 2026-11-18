import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

// StylizedMaterial's vertices carry three floats of wind (the sway weight,
// a phase and a flutter weight) where they carried one (the sway weight),
// and its wind has a flutter, gusts and a world space scaled by each object.
// These tests render a scene with the vertex stage and the vertex layout of
// before, `test/gpu/shaders/reference/stylized_sway_vertex.glsl`, and with
// today's, the new features unused, and check that every pixel is the same.

const _width = 192;
const _height = 144;

/// StylizedMaterial's own layout before the per-vertex phase and flutter: 16
/// floats per vertex, the sway weight last.
final _swayLayout = VertexLayout(const [
  VertexAttribute(VertexLayout.positionAttribute, 3),
  VertexAttribute('vertexNormal', 3),
  VertexAttribute('vertexColor', 4),
  VertexAttribute('vertexMasks', 4),
  VertexAttribute('vertexOcclusion', 1),
  VertexAttribute('vertexSway', 1),
]);

/// [_swayLayout] with joints and weights, 24 floats per vertex.
final _skinnedSwayLayout = VertexLayout([
  ..._swayLayout.attributes,
  const VertexAttribute('vertexJoints', 4),
  const VertexAttribute('vertexWeights', 4),
]);

/// A StylizedMaterial that draws surfaces in [_swayLayout] and
/// [_skinnedSwayLayout] with the vertex stage of before, whose Wind block it
/// writes as it was written then.
class _SwayReferenceMaterial({
  super.windDirection,
  super.windAmplitude,
  super.windSpace,
  super.windPhase,
  super.windTime,
}) extends StylizedMaterial {
  final Shader _rigid = VertexShader.fromAsset(
    'test/stylized_sway_reference.shaderbundle',
    slots: [RenderContext3D.cameraMatricesBlock, 'Wind'],
  );

  final Shader _skinned = VertexShader.fromAsset(
    'test/stylized_skinned_sway_reference.shaderbundle',
    slots: [
      RenderContext3D.cameraMatricesBlock,
      'Wind',
      RenderContext3D.jointMatricesBlock,
    ],
  );

  @override
  Shader vertexShaderFor(VertexLayout layout) {
    if (layout == _swayLayout) {
      return _rigid;
    }
    if (layout == _skinnedSwayLayout) {
      return _skinned;
    }
    return super.vertexShaderFor(layout);
  }

  @override
  void apply(RenderContext context) {
    super.apply(context);
    final inModelSpace = windSpace == WindSpace.model;
    final zero = Vector3.zero();
    for (final shader in [_rigid, _skinned]) {
      shader
        ..setVector3('Wind.direction', inModelSpace ? zero : windDirection)
        ..setVector3('Wind.modelDirection', inModelSpace ? windDirection : zero)
        ..setFloat('Wind.amplitude', windAmplitude)
        ..setVector3('Wind.phaseScale', windPhase)
        ..setFloat('Wind.frequency', windFrequency)
        ..setFloat('Wind.time', windTime);
    }
  }
}

/// A thin blade in the z = 0 plane, 0.12 wide and 0.6 tall along y, whose
/// sway weight grows from 0 at its foot to 1 at its tip. Skinned, its tip
/// follows joint 1 and its foot joint 0.
Surface _blade(Material material, {bool skinned = false}) {
  const segments = 6;
  final positions = <double>[];
  final normals = <double>[];
  final colors = <double>[];
  final tint = <double>[];
  final gloss = <double>[];
  final sway = <double>[];
  final joints = <double>[];
  final weights = <double>[];
  final indices = <int>[];
  for (var i = 0; i <= segments; i++) {
    final t = i / segments;
    for (final x in const [-0.06, 0.06]) {
      positions.addAll([x, -0.3 + 0.6 * t, 0]);
      normals.addAll([x * 4, 0.3, 0.95]);
      colors.addAll([0.3 + 0.5 * t, 0.7, 0.3, 1]);
      tint.add(t > 0.5 ? 1 : 0);
      gloss.add(t * 0.6);
      sway.add(t * t);
      joints.addAll([0, 1, 0, 0]);
      weights.addAll([1 - t, t, 0, 0]);
    }
    if (i < segments) {
      final a = i * 2;
      indices.addAll([a, a + 1, a + 3, a + 3, a + 2, a]);
    }
  }
  return StylizedMaterial.buildSurface(
    positions: positions,
    normals: normals,
    colors: colors,
    tint: tint,
    gloss: gloss,
    sway: sway,
    joints: skinned ? joints : null,
    weights: skinned ? weights : null,
    indices: indices,
    material: material,
  );
}

/// [surface], in StylizedMaterial's layout of today, laid out as before the
/// per-vertex phase and flutter (their two floats dropped), drawn with
/// [material].
Surface _inSwayLayout(Surface surface, Material material) {
  final skinned = surface.layout == StylizedMaterial.skinnedVertexLayout;
  final from = surface.layout.strideInFloats;
  final to = from - 2;
  final source = surface.vertexData;
  final data = Float32List(surface.vertexCount * to);
  for (var v = 0; v < surface.vertexCount; v++) {
    for (var i = 0; i < 16; i++) {
      data[v * to + i] = source[v * from + i];
    }
    for (var i = 18; i < from; i++) {
      data[v * to + i - 2] = source[v * from + i];
    }
  }
  return Surface.fromBuffers(
    vertices: data,
    indices: surface.indices,
    layout: skinned ? _skinnedSwayLayout : _swayLayout,
    material: material,
  );
}

List<Light> _lights() => [
  Light(
    position: Vector3.zero(),
    source: HemisphereLight(
      skyColor: const Color(0xFFB4CCF0),
      groundColor: const Color(0xFF6E7A50),
      intensity: 0.6,
    ),
  ),
  Light(
    position: Vector3.zero(),
    source: DirectionalLight(
      direction: Vector3(0.4, -0.5, -0.8),
      intensity: 0.8,
    ),
  ),
];

/// Renders rows of blades swaying in a world-space and a model-space wind,
/// turned and scaled, with various wind strengths, skinned blades, and a
/// cube in the standard layout.
///
/// With [reference], the materials are [_SwayReferenceMaterial]s and the
/// blades are laid out as before. Otherwise [create] (by default a
/// StylizedMaterial with just these settings) builds the materials of today
/// from their wind settings.
Future<Pixels> _render({
  required bool reference,
  StylizedMaterial Function({
    required Vector3 windDirection,
    required double windAmplitude,
    required WindSpace windSpace,
    required Vector3 windPhase,
    required double windTime,
  })?
  create,
}) async {
  StylizedMaterial material({
    required Vector3 windDirection,
    required double windAmplitude,
    required WindSpace windSpace,
    required Vector3 windPhase,
  }) {
    const windTime = 1.3;
    if (reference) {
      return _SwayReferenceMaterial(
        windDirection: windDirection,
        windAmplitude: windAmplitude,
        windSpace: windSpace,
        windPhase: windPhase,
        windTime: windTime,
      );
    }
    return (create ?? _plain)(
      windDirection: windDirection,
      windAmplitude: windAmplitude,
      windSpace: windSpace,
      windPhase: windPhase,
      windTime: windTime,
    );
  }

  final world = material(
    windDirection: Vector3(1, 0.2, 0),
    windAmplitude: 0.08,
    windSpace: WindSpace.world,
    windPhase: Vector3(0.7, 0, 0.5),
  );
  final model = material(
    windDirection: Vector3(1, -0.55, 0),
    windAmplitude: 0.12,
    windSpace: WindSpace.model,
    windPhase: Vector3(2.7, 1.5, 0),
  );
  Surface blade(Material material, {bool skinned = false}) {
    final surface = _blade(material, skinned: skinned);
    return reference ? _inSwayLayout(surface, material) : surface;
  }

  final worldBlade = blade(world);
  final modelBlade = blade(model);
  final skinnedBlade = blade(model, skinned: true);
  final cube = CuboidMesh(size: Vector3.all(0.25), material: world);
  final bend = Matrix4.identity()..rotateZ(-0.4);

  final frame = await renderFrame(
    width: _width,
    height: _height,
    lights: _lights(),
    draw: (context) {
      for (var i = 0; i < 7; i++) {
        final x = -0.85 + i * 0.28;
        context
          ..drawSurface(
            worldBlade,
            transform: Matrix4.translationValues(x, 0.45, -5)
              ..rotateZ(0.25 * (i - 3))
              ..scaleByDouble(1 + 0.15 * i, 1.4 - 0.1 * i, 1, 1),
            color: const Color(0xFFE08040),
            instanceData: Vector4(0, 0, (i - 3) / 3, 0),
          )
          ..drawSurface(
            modelBlade,
            transform: Matrix4.translationValues(x, -0.2, -5)
              ..rotateZ(0.3 * (3 - i))
              ..rotateX(0.2 * i)
              ..scaleByDouble(1.2, 0.8 + 0.12 * i, 1, 1),
            color: const Color(0xFF40A0E0),
            instanceData: Vector4(0, 0, (3 - i) / 4, 0),
          );
      }
      for (final (index, x) in const [-0.5, 0.1, 0.6].indexed) {
        context.drawSurface(
          skinnedBlade,
          transform: Matrix4.translationValues(x, -0.72, -5)
            ..rotateZ(0.2 * index),
          jointTransforms: [Matrix4.identity(), bend],
        );
      }
      context.drawMesh(
        cube,
        transform: Matrix4.translationValues(0.85, -0.75, -5)
          ..rotateX(0.6)
          ..rotateY(0.5),
      );
    },
  );
  return frame.pixels;
}

StylizedMaterial _plain({
  required Vector3 windDirection,
  required double windAmplitude,
  required WindSpace windSpace,
  required Vector3 windPhase,
  required double windTime,
}) {
  return StylizedMaterial(
    windDirection: windDirection,
    windAmplitude: windAmplitude,
    windSpace: windSpace,
    windPhase: windPhase,
    windTime: windTime,
  );
}

void main() {
  setUpGpu();

  setUpAll(() async {
    if (gpuAvailable) {
      await registerTestShaders([
        'stylized_sway_reference',
        'stylized_skinned_sway_reference',
      ]);
    }
  });

  group('StylizedMaterial wind', () {
    testGpuEngine('renders the same pixels as before without the new '
        'features', () async {
      final reference = await _render(reference: true);
      final pixels = await _render(reference: false);

      // The blades are drawn, and sway: the scene differs from one without
      // wind.
      expect(reference.count((r, g, b, a) => a > 0), greaterThan(2000));
      final still = await _render(
        reference: false,
        create:
            ({
              required windDirection,
              required windAmplitude,
              required windSpace,
              required windPhase,
              required windTime,
            }) => _plain(
              windDirection: windDirection,
              windAmplitude: 0,
              windSpace: windSpace,
              windPhase: windPhase,
              windTime: windTime,
            ),
      );
      expect(differingPixels(still, reference, tolerance: 0), greaterThan(50));

      expect(differingPixels(pixels, reference, tolerance: 0), 0);
    });

    testGpuEngine('renders the same pixels with flutter and gust settings '
        'whose amplitude or weight is zero', () async {
      final reference = await _render(reference: true);
      final pixels = await _render(
        reference: false,
        create:
            ({
              required windDirection,
              required windAmplitude,
              required windSpace,
              required windPhase,
              required windTime,
            }) => StylizedMaterial(
              windDirection: windDirection,
              windAmplitude: windAmplitude,
              windSpace: windSpace,
              windPhase: windPhase,
              windTime: windTime,
              // The vertices have no flutter weight.
              windFlutterAmplitude: 0.3,
              windFlutterFrequency: 17,
              windGustFrequency: 1.7,
              windGustDirection: Vector3(0.3, 1, 0),
              windGustPhaseScale: 3,
              windUpAxis: Vector3(0, 0, 1),
            ),
      );

      expect(differingPixels(pixels, reference, tolerance: 0), 0);
    });
  });
}
