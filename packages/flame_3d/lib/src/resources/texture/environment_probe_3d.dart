import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';

/// {@template environment_probe_3d}
/// Pre-filtered Image-Based Lighting (IBL) probe storing 9-band (`L0..L2`)
/// Spherical Harmonics (`SH9`) diffuse irradiance coefficients alongside a
/// mipmapped equirectangular specular reflection [reflectionTexture].
///
/// Can be baked on the CPU from any RGBA8888 equirectangular panorama via
/// [EnvironmentProbe3D.fromEquirectangular] or synthesized procedurally from
/// sky/horizon/ground/sun parameters via [EnvironmentProbe3D.skyDome].
/// {@endtemplate}
class EnvironmentProbe3D({
  required final List<Vector3> shCoefficients,
  required final Texture reflectionTexture,
  var double intensity = 1.0,
}) {
  /// {@macro environment_probe_3d}
  this : assert(shCoefficients.length == 9, 'SH9 requires 9 coefficients');

  /// Evaluates diffuse irradiance (`RGB`, linear) for unit world [normal]
  /// using the Ramamoorthi & Hanrahan `L0..L2` cosine-lobe convolution.
  Vector3 evaluateIrradiance(Vector3 normal, {Vector3? out}) {
    final res = out ?? Vector3.zero();
    final x = normal.x;
    final y = normal.y;
    final z = normal.z;

    const c0 = 0.282095 * math.pi;
    const c1 = 0.488603 * (2.0 * math.pi / 3.0);
    const c2 = 1.092548 * (math.pi / 4.0);
    const c3 = 0.315392 * (math.pi / 4.0);
    const c4 = 0.546274 * (math.pi / 4.0);

    const b0 = c0;
    final b1 = c1 * y;
    final b2 = c1 * z;
    final b3 = c1 * x;
    final b4 = c2 * x * y;
    final b5 = c2 * y * z;
    final b6 = c3 * (3.0 * z * z - 1.0);
    final b7 = c2 * x * z;
    final b8 = c4 * (x * x - y * y);

    final c = shCoefficients;
    final r =
        c[0].x * b0 +
        c[1].x * b1 +
        c[2].x * b2 +
        c[3].x * b3 +
        c[4].x * b4 +
        c[5].x * b5 +
        c[6].x * b6 +
        c[7].x * b7 +
        c[8].x * b8;
    final g =
        c[0].y * b0 +
        c[1].y * b1 +
        c[2].y * b2 +
        c[3].y * b3 +
        c[4].y * b4 +
        c[5].y * b5 +
        c[6].y * b6 +
        c[7].y * b7 +
        c[8].y * b8;
    final b =
        c[0].z * b0 +
        c[1].z * b1 +
        c[2].z * b2 +
        c[3].z * b3 +
        c[4].z * b4 +
        c[5].z * b5 +
        c[6].z * b6 +
        c[7].z * b7 +
        c[8].z * b8;

    return res..setValues(
      math.max(0.0, r * intensity),
      math.max(0.0, g * intensity),
      math.max(0.0, b * intensity),
    );
  }

  /// Projects an RGBA8888 `2:1` equirectangular [pixels] buffer onto `SH9`
  /// radiance coefficients and builds a mipmapped specular reflection texture.
  factory EnvironmentProbe3D.fromEquirectangular(
    ByteData pixels, {
    required int width,
    required int height,
    double intensity = 1.0,
    bool srgb = true,
  }) {
    final coeffs = List.generate(9, (_) => Vector3.zero());
    final raw = pixels.buffer.asUint8List(
      pixels.offsetInBytes,
      pixels.lengthInBytes,
    );
    final dPhi = 2.0 * math.pi / width;
    final dTheta = math.pi / height;

    for (var row = 0; row < height; row++) {
      final theta = (row + 0.5) / height * math.pi;
      final sinTheta = math.sin(theta);
      final cosTheta = math.cos(theta);
      final solidAngle = sinTheta * dTheta * dPhi;
      final y = cosTheta;

      for (var col = 0; col < width; col++) {
        final phi = ((col + 0.5) / width - 0.5) * 2.0 * math.pi;
        final x = sinTheta * math.cos(phi);
        final z = sinTheta * math.sin(phi);

        final idx = (row * width + col) * 4;
        var r = raw[idx] / 255.0;
        var g = raw[idx + 1] / 255.0;
        var b = raw[idx + 2] / 255.0;
        if (srgb) {
          r = math.pow(r, 2.2).toDouble();
          g = math.pow(g, 2.2).toDouble();
          b = math.pow(b, 2.2).toDouble();
        }

        final y00 = 0.282095 * solidAngle;
        final y1m1 = 0.488603 * y * solidAngle;
        final y10 = 0.488603 * z * solidAngle;
        final y11 = 0.488603 * x * solidAngle;
        final y2m2 = 1.092548 * x * y * solidAngle;
        final y2m1 = 1.092548 * y * z * solidAngle;
        final y20 = 0.315392 * (3.0 * z * z - 1.0) * solidAngle;
        final y21 = 1.092548 * x * z * solidAngle;
        final y22 = 0.546274 * (x * x - y * y) * solidAngle;

        _accum(coeffs[0], r, g, b, y00);
        _accum(coeffs[1], r, g, b, y1m1);
        _accum(coeffs[2], r, g, b, y10);
        _accum(coeffs[3], r, g, b, y11);
        _accum(coeffs[4], r, g, b, y2m2);
        _accum(coeffs[5], r, g, b, y2m1);
        _accum(coeffs[6], r, g, b, y20);
        _accum(coeffs[7], r, g, b, y21);
        _accum(coeffs[8], r, g, b, y22);
      }
    }

    final tex = Texture(
      pixels,
      width: width,
      height: height,
      mipmaps: true,
      sampler: const TextureSampler(
        minFilter: TextureFilter.linear,
        magFilter: TextureFilter.linear,
        mipFilter: TextureFilter.linear,
        wrapU: TextureWrap.repeat,
      ),
    );
    return EnvironmentProbe3D(
      shCoefficients: coeffs,
      reflectionTexture: tex,
      intensity: intensity,
    );
  }

  /// Synthesizes a procedural atmospheric sky dome panorama (`width x height`)
  /// and bakes its exact `SH9` diffuse probe + mipmapped reflection map.
  factory EnvironmentProbe3D.skyDome({
    int width = 128,
    int height = 64,
    Color zenithColor = const Color(0xFF0A2463),
    Color horizonColor = const Color(0xFF60A5FA),
    Color groundColor = const Color(0xFF334155),
    Vector3? upAxis,
    Vector3? sunDirection,
    Color sunColor = const Color(0xFFFFFBEB),
    double sunIntensity = 1.2,
    double intensity = 1.0,
  }) {
    final up = (upAxis?.clone() ?? Vector3(0, 1, 0))..normalize();
    final toSun = ((sunDirection?.clone() ?? Vector3(-0.4, -0.8, -0.3))
      ..scale(-1.0)
      ..normalize());
    final bytes = Uint8List(width * height * 4);
    final dir = Vector3.zero();

    for (var row = 0; row < height; row++) {
      final theta = (row + 0.5) / height * math.pi;
      final sinT = math.sin(theta);
      final cosT = math.cos(theta);
      for (var col = 0; col < width; col++) {
        final phi = ((col + 0.5) / width - 0.5) * 2.0 * math.pi;
        // Note `spatial_material.frag` maps equirect `v = acos(clamp(y))/pi`.
        dir.setValues(sinT * math.cos(phi), cosT, sinT * math.sin(phi));
        final elev = dir.dot(up);
        double r;
        double g;
        double b;
        if (elev >= 0.0) {
          final t = math.pow(elev, 0.65).toDouble();
          r = _lerp(horizonColor.r, zenithColor.r, t);
          g = _lerp(horizonColor.g, zenithColor.g, t);
          b = _lerp(horizonColor.b, zenithColor.b, t);
        } else {
          final t = math.pow(-elev, 0.55).toDouble();
          r = _lerp(horizonColor.r, groundColor.r, t);
          g = _lerp(horizonColor.g, groundColor.g, t);
          b = _lerp(horizonColor.b, groundColor.b, t);
        }
        final sunCos = math.max(0.0, dir.dot(toSun));
        final glow = math.pow(sunCos, 16.0).toDouble() * 0.45 * sunIntensity;
        r = (r + sunColor.r * glow).clamp(0.0, 1.0);
        g = (g + sunColor.g * glow).clamp(0.0, 1.0);
        b = (b + sunColor.b * glow).clamp(0.0, 1.0);

        final i = (row * width + col) * 4;
        bytes
          ..[i] = (r * 255).round()
          ..[i + 1] = (g * 255).round()
          ..[i + 2] = (b * 255).round()
          ..[i + 3] = 255;
      }
    }

    return EnvironmentProbe3D.fromEquirectangular(
      ByteData.sublistView(bytes),
      width: width,
      height: height,
      intensity: intensity,
    );
  }

  static void _accum(Vector3 out, double r, double g, double b, double weight) {
    out.x += r * weight;
    out.y += g * weight;
    out.z += b * weight;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
