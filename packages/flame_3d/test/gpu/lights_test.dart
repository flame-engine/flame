import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

/// A square facing the default camera (in the z = -5 plane, counter-clockwise
/// seen from +z) in the standard layout, whose vertices all have [normal] and
/// [color].
Surface _quad(
  Material material, {
  Vector3? normal,
  Color color = const Color(0xFFFFFFFF),
  double halfSize = 0.5,
  double x = 0,
}) {
  final n = (normal ?? Vector3(0, 0, 1)).normalized();
  final stride = VertexLayout.standard.strideInFloats;
  final vertices = Float32List(4 * stride);
  const corners = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
  for (final (i, (cx, cy)) in corners.indexed) {
    vertices
      ..setRange(i * stride, i * stride + 3, [
        x + cx * halfSize,
        cy * halfSize,
        -5,
      ])
      ..setRange(i * stride + 5, i * stride + 9, [
        color.r,
        color.g,
        color.b,
        color.a,
      ])
      ..setRange(i * stride + 9, i * stride + 12, n.storage);
  }
  return Surface.fromBuffers(
    vertices: vertices,
    indices: Uint16List.fromList([0, 1, 2, 2, 3, 0]),
    material: material,
  );
}

/// The world position of the center of the pixel ([px], [py]) on the z = -5
/// plane, seen by the default camera in a 64x64 frame.
Vector3 _worldAt(int px, int py) {
  return Vector3((px + 0.5) / 32 - 1, 1 - (py + 0.5) / 32, -5);
}

/// The `SpatialMaterial` shading, computed in Dart.
class _Spatial({
  required final Vector3 base,
  final double metallic = 0.8,
}) {
  /// The roughness of the material (the default of `SpatialMaterial`).
  static const roughness = 0.6;

  static const _epsilon = 0.0001;

  Vector3 _fresnel(double cosTheta, Vector3 f0) {
    final k = math.pow((1 - cosTheta).clamp(0.0, 1.0), 5).toDouble();
    return f0 + (Vector3.all(1) - f0) * k;
  }

  Vector3 _light(
    Vector3 l,
    Vector3 radiance,
    double specularFactor,
    Vector3 n,
    Vector3 v,
    Vector3 f0,
  ) {
    final h = (v + l)..normalize();
    const a = roughness * roughness;
    const a2 = a * a;
    final ndoth = math.max(n.dot(h), 0.0);
    final b = ndoth * ndoth * (a2 - 1) + 1;
    final ndf = a2 / (math.pi * b * b);
    const k = (roughness + 1) * (roughness + 1) / 8;
    double ggx(double x) => x / (x * (1 - k) + k);
    final ndotv = math.max(n.dot(v), 0.0);
    final ndotl = math.max(n.dot(l), 0.0);
    final g = ggx(ndotv) * ggx(ndotl);
    final f = _fresnel(math.max(h.dot(v), 0.0), f0);
    final kD = (Vector3.all(1) - f) * (1 - metallic);
    final specular = f * (ndf * g / (4 * ndotv * ndotl + _epsilon));
    final diffuse = kD.clone()..multiply(base / math.pi);
    return (diffuse + specular * specularFactor)
      ..multiply(radiance)
      ..scale(ndotl);
  }

  /// The 8-bit color of a fragment at [position] with normal [normal].
  (int, int, int) shade({
    required Vector3 position,
    required Vector3 normal,
    Vector3? ambient,
    (Vector3 sky, Vector3 ground, Vector3 up, double intensity)? hemisphere,
    List<(Vector3 toLight, Vector3 radiance, double specular)> suns = const [],
    List<(Vector3 position, Vector3 color, double intensity, double range)>
        points =
        const [],
  }) {
    final n = normal.normalized();
    final v = (-position)..normalize();
    final f0 = Vector3.all(0.04) + (base - Vector3.all(0.04)) * metallic;
    final kS = _fresnel(math.max(n.dot(v), 0.0), f0);
    final kD = (Vector3.all(1) - kS) * (1 - metallic);
    final irradiance = ambient?.clone() ?? Vector3.zero();
    if (hemisphere != null) {
      final (sky, ground, up, intensity) = hemisphere;
      final hemi = 0.5 + 0.5 * n.dot(up);
      irradiance.add((ground + (sky - ground) * hemi) * intensity);
    }
    final color = (kD.clone()..multiply(base))..multiply(irradiance);
    for (final (lightPosition, lightColor, intensity, range) in points) {
      final toLight = lightPosition - position;
      final distance = toLight.length + _epsilon;
      final falloff = math.max(1 - distance / range, 0.0);
      final attenuation = range > 0
          ? intensity * falloff * falloff
          : intensity / (distance * distance);
      color.add(
        _light(toLight.normalized(), lightColor * attenuation, 1, n, v, f0),
      );
    }
    for (final (toLight, radiance, specular) in suns) {
      color.add(_light(toLight.normalized(), radiance, specular, n, v, f0));
    }
    int channel(double c) {
      final mapped = math.pow(c / (c + 1), 1 / 2.2).toDouble();
      return (mapped.clamp(0.0, 1.0) * 255).round();
    }

    return (channel(color.x), channel(color.y), channel(color.z));
  }
}

void _expectColor(
  (int, int, int, int) pixel,
  (int, int, int) expected, {
  int tolerance = 2,
}) {
  final (r, g, b, a) = pixel;
  expect(
    [r, g, b, a],
    pairwiseCompare<int, int>(
      [expected.$1, expected.$2, expected.$3, 255],
      (actual, wanted) => (actual - wanted).abs() <= tolerance,
      'within $tolerance of',
    ),
  );
}

Vector3 _rgb(Color color) => Vector3(color.r, color.g, color.b);

void main() {
  setUpGpu();

  group('SpatialMaterial lights', () {
    const albedo = Color(0xFFD08040);
    final spatial = _Spatial(base: _rgb(albedo), metallic: 0.1);
    final (cx, cy) = pixelAt(0, 0);
    final center = _worldAt(cx, cy);

    SpatialMaterial newMaterial() =>
        SpatialMaterial(albedoColor: albedo, metallic: 0.1);

    testGpuEngine(
      'a directional light lights the faces turned to it',
      () async {
        final surface = _quad(newMaterial());
        for (final specular in [0.0, 1.0]) {
          final frame = await renderFrame(
            draw: (context) => context.drawSurface(surface),
            lights: [
              Light(
                position: Vector3.zero(),
                source: AmbientLight(intensity: 0.1),
              ),
              Light(
                position: Vector3(100, 100, 100),
                source: DirectionalLight(
                  color: const Color(0xFFFFF0E0),
                  intensity: 2.5,
                  direction: Vector3(0, -0.5, -1),
                  specular: specular,
                ),
              ),
            ],
          );

          _expectColor(
            frame.pixels.at(cx, cy),
            spatial.shade(
              position: center,
              normal: Vector3(0, 0, 1),
              ambient: Vector3.all(0.1),
              suns: [
                (
                  Vector3(0, 0.5, 1),
                  _rgb(const Color(0xFFFFF0E0)) * 2.5,
                  specular,
                ),
              ],
            ),
          );
        }
      },
    );

    testGpuEngine('a directional light from behind adds nothing', () async {
      final surface = _quad(newMaterial());
      final frame = await renderFrame(
        draw: (context) => context.drawSurface(surface),
        lights: [
          Light(
            position: Vector3.zero(),
            source: DirectionalLight(intensity: 5, direction: Vector3(0, 0, 1)),
          ),
        ],
      );

      _expectColor(
        frame.pixels.at(cx, cy),
        spatial.shade(
          position: center,
          normal: Vector3(0, 0, 1),
          ambient: Vector3.all(0.2),
        ),
      );
    });

    testGpuEngine('a hemisphere light blends sky and ground', () async {
      final up = Vector3(0, 0.6, 0.8);
      final down = Vector3(0, -0.6, 0.8);
      const sky = Color(0xFF6090FF);
      const ground = Color(0xFF805020);
      final material = newMaterial();
      final upper = _quad(material, normal: up, halfSize: 0.3, x: -0.5);
      final lower = _quad(material, normal: down, halfSize: 0.3, x: 0.5);

      final frame = await renderFrame(
        draw: (context) => context
          ..drawSurface(upper)
          ..drawSurface(lower),
        lights: [
          Light(
            position: Vector3.zero(),
            source: HemisphereLight(
              skyColor: sky,
              groundColor: ground,
              intensity: 1.5,
            ),
          ),
        ],
      );

      final hemisphere = (_rgb(sky), _rgb(ground), Vector3(0, 1, 0), 1.5);
      for (final (x, normal) in [(-0.5, up), (0.5, down)]) {
        final (px, py) = pixelAt(x, 0);
        // Without ambient light, the hemisphere replaces the default one.
        _expectColor(
          frame.pixels.at(px, py),
          spatial.shade(
            position: _worldAt(px, py),
            normal: normal,
            hemisphere: hemisphere,
          ),
        );
      }
    });

    testGpuEngine('a point light with a range fades out at it', () async {
      final surface = _quad(newMaterial());
      const color = Color(0xFFFFFFFF);
      for (final range in [null, 3.0, 0.5]) {
        final frame = await renderFrame(
          draw: (context) => context.drawSurface(surface),
          lights: [
            Light(
              position: Vector3(0, 0, -4),
              source: PointLight(color: color, intensity: 2, range: range),
            ),
          ],
        );

        _expectColor(
          frame.pixels.at(cx, cy),
          spatial.shade(
            position: center,
            normal: Vector3(0, 0, 1),
            ambient: Vector3.all(0.2),
            points: [(Vector3(0, 0, -4), _rgb(color), 2, range ?? 0)],
          ),
        );
      }
    });

    testGpuEngine('the vertex color multiplies the base color', () async {
      const vertexColor = Color(0xFF80FF40);
      final surface = _quad(newMaterial(), color: vertexColor);
      final frame = await renderFrame(
        draw: (context) => context.drawSurface(surface),
      );

      final tinted = _Spatial(
        base: _rgb(albedo)..multiply(_rgb(vertexColor)),
        metallic: 0.1,
      );
      _expectColor(
        frame.pixels.at(cx, cy),
        tinted.shade(
          position: center,
          normal: Vector3(0, 0, 1),
          ambient: Vector3.all(0.2),
        ),
      );
    });
  });

  testGpuEngine('UnlitMaterial multiplies by the vertex color', () async {
    final surface = _quad(
      opaqueUnlit(const Color(0xFFFF8040)),
      color: const Color(0xFF80FF80),
    );
    final frame = await renderFrame(
      draw: (context) => context.drawSurface(surface),
    );

    final (cx, cy) = pixelAt(0, 0);
    _expectColor(frame.pixels.at(cx, cy), (128, 128, 32));
  });
}
