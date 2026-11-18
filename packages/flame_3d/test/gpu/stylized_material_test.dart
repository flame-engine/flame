import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

/// The per-vertex data of a test square, constant over the square.
class _Vertex({
  required final Vector3 normal,
  final Color color = const Color(0xFFFFFFFF),
  final double occlusion = 1,
  final double tint = 0,
  final double accent = 0,
  final double emissive = 0,
  final double gloss = 0,
  final double sway = 0,
  final double windPhase = 0,
  final double flutter = 0,
});

/// A square of side `2 * halfSize` centered on ([x], [y]) at z = -5, facing
/// the default camera, in the stylized layout, whose vertices all have the
/// data of [vertex].
Surface _square(
  Material material,
  _Vertex vertex, {
  double x = 0,
  double y = 0,
  double halfSize = 0.2,
}) {
  final n = vertex.normal.normalized();
  final c = vertex.color;
  const corners = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
  return StylizedMaterial.buildSurface(
    positions: [
      for (final (cx, cy) in corners) ...[
        x + cx * halfSize,
        y + cy * halfSize,
        -5,
      ],
    ],
    normals: [for (var i = 0; i < 4; i++) ...n.storage],
    colors: [
      for (var i = 0; i < 4; i++) ...[c.r, c.g, c.b, c.a],
    ],
    occlusion: List.filled(4, vertex.occlusion),
    tint: List.filled(4, vertex.tint),
    accent: List.filled(4, vertex.accent),
    emissive: List.filled(4, vertex.emissive),
    gloss: List.filled(4, vertex.gloss),
    sway: List.filled(4, vertex.sway),
    windPhase: List.filled(4, vertex.windPhase),
    windFlutter: List.filled(4, vertex.flutter),
    indices: [0, 1, 2, 2, 3, 0],
    material: material,
  );
}

/// The world position of the center of the pixel ([px], [py]) on the z = -5
/// plane, seen by the default camera in a 64x64 frame.
Vector3 _worldAt(int px, int py) {
  return Vector3((px + 0.5) / 32 - 1, 1 - (py + 0.5) / 32, -5);
}

Vector3 _rgb(Color color) => Vector3(color.r, color.g, color.b);

/// The look to reproduce, written as specified (not as the shader computes
/// it), for one fragment.
///
/// ```text
/// lit = ambientStrength * ao * (0.65 + 0.35 * skyColor * hemi
///                               + 0.10 * groundColor * groundBounce)
///     + max(0, n·l) * sunStrength * sunColor
///     + Σ point: intensity * color * (1 - d/r)^2 * max(0.18, n·l)
/// spec = (n·h)^8 * gloss * 0.28 (0.52 for gem vertices), when gloss > 0.12
/// rim = (1 - n·v)^3 * rimStrength * skyColor
/// out = color * lit + spec + rim, or the emissive color on emissive vertices
/// ```
class _Look({
  required final double ambientStrength,
  required final Vector3 sky,
  required final Vector3 ground,
  required final Vector3 toSun,
  required final double sunStrength,
  required final Vector3 sunColor,
  required final Vector3 pointPosition,
  required final Vector3 pointColor,
  required final double pointIntensity,
  required final double pointRange,
  required final double rimStrength,
  required final Vector3 accentColor,
  required final Vector3 emissiveColor,
}) {
  (int, int, int) shade({
    required Vector3 position,
    required Vector3 normal,
    required Vector3 vertexColor,
    double ao = 1,
    Vector3? tint,
    bool accent = false,
    double gloss = 0,
    bool gem = false,
    double emissiveStrength = 0,
    Vector3? matCap,
    Vector3? cap,
    Vector3? viewer,
    Vector3? skyFill,
    Vector3? emissive,
    Vector3? highlight,
    Vector3? reflected,
    double metallic = 1,
  }) {
    final color = shadeColor(
      position: position,
      normal: normal,
      vertexColor: vertexColor,
      ao: ao,
      tint: tint,
      accent: accent,
      gloss: gloss,
      gem: gem,
      emissiveStrength: emissiveStrength,
      matCap: matCap,
      cap: cap,
      viewer: viewer,
      skyFill: skyFill,
      emissive: emissive,
      highlight: highlight,
      reflected: reflected,
      metallic: metallic,
    );
    int channel(double c) => (c * 255).round();
    return (channel(color.x), channel(color.y), channel(color.z));
  }

  /// The color of [shade], from 0 to 1.
  ///
  /// [matCap] is added in proportion to the gloss, [cap] as it is;
  /// [skyFill] weighs the sky color per channel (0.35 by default);
  /// [emissive] replaces the emissive color; [highlight] is added before the
  /// emission. With [reflected] the material is metallic by [metallic]: the
  /// lit surface, at most 1, scales [reflected] instead of [cap] being added
  /// to it.
  Vector3 shadeColor({
    required Vector3 position,
    required Vector3 normal,
    required Vector3 vertexColor,
    double ao = 1,
    Vector3? tint,
    bool accent = false,
    double gloss = 0,
    bool gem = false,
    double emissiveStrength = 0,
    Vector3? matCap,
    Vector3? cap,
    Vector3? viewer,
    Vector3? skyFill,
    Vector3? emissive,
    Vector3? highlight,
    Vector3? reflected,
    double metallic = 1,
  }) {
    final n = normal.normalized();
    // Orthographic cameras look down -z; perspective ones from [viewer].
    final v = viewer == null
        ? Vector3(0, 0, 1)
        : (viewer - position).normalized();
    final l = toSun.normalized();
    final nUp = n.y;
    final hemi = 0.5 + 0.5 * nUp;
    final groundBounce = math.max(0.0, -nUp);

    var color = vertexColor.clone();
    if (tint != null) {
      color.multiply(tint);
    }
    if (accent) {
      color.multiply(accentColor);
    }

    final skyWeight = skyFill ?? Vector3.all(0.35);
    final lit =
        (Vector3.all(0.65) +
              (sky.clone()..multiply(skyWeight)) * hemi +
              ground * (0.1 * groundBounce))
          ..scale(ambientStrength * ao);
    lit.add(sunColor * (math.max(0.0, n.dot(l)) * sunStrength));
    final toPoint = pointPosition - position;
    final d = toPoint.length;
    final fade = math.max(0.0, 1 - d / pointRange);
    lit.add(
      pointColor *
          (pointIntensity *
              fade *
              fade *
              math.max(0.18, n.dot(toPoint.normalized()))),
    );

    var spec = 0.0;
    if (gloss > 0.12 || gem) {
      final h = (l + v)..normalize();
      final ndoth = math.max(0.0, n.dot(h));
      spec = math.pow(ndoth, 8) * (gem ? 0.52 : gloss * 0.28);
    }
    final rim = sky * (math.pow(1 - n.dot(v).clamp(0.0, 1.0), 3) * rimStrength);

    final surface = (color..multiply(lit)) + rim;
    if (reflected != null) {
      final sheen = surface + (cap ?? Vector3.zero());
      final metal = Vector3(
        math.min(surface.x, 1),
        math.min(surface.y, 1),
        math.min(surface.z, 1),
      )..multiply(reflected);
      color = sheen + (metal - sheen) * metallic + Vector3.all(spec);
    } else {
      color = surface + Vector3.all(spec);
      if (matCap != null) {
        color.add(matCap * gloss);
      }
      if (cap != null) {
        color.add(cap);
      }
    }
    if (highlight != null) {
      color.add(highlight);
    }
    color = color + ((emissive ?? emissiveColor) - color) * emissiveStrength;
    return color..clamp(Vector3.zero(), Vector3.all(1));
  }
}

/// The largest difference between the channels of [pixel] and [expected].
int _difference((int, int, int, int) pixel, (int, int, int) expected) {
  return [
    (pixel.$1 - expected.$1).abs(),
    (pixel.$2 - expected.$2).abs(),
    (pixel.$3 - expected.$3).abs(),
  ].reduce(math.max);
}

void main() {
  setUpGpu();

  const sky = Color(0xFF8CB3F2);
  const ground = Color(0xFF73664D);
  const sunColor = Color(0xFFFFF2D9);
  const pointColor = Color(0xFFFF9933);
  const accentColor = Color(0xFF40C0A0);
  const emissiveColor = Color(0xFFFFE385);
  final toSun = Vector3(0.5, 0.6, 0.62);
  final pointPosition = Vector3(0.1, 0, -4.5);

  final look = _Look(
    ambientStrength: 0.44,
    sky: _rgb(sky),
    ground: _rgb(ground),
    toSun: toSun,
    sunStrength: 0.7,
    sunColor: _rgb(sunColor),
    pointPosition: pointPosition,
    pointColor: _rgb(pointColor),
    pointIntensity: 0.6,
    pointRange: 1.6,
    rimStrength: 0.4,
    accentColor: _rgb(accentColor),
    emissiveColor: _rgb(emissiveColor),
  );

  List<Light> lights() => [
    Light(
      position: Vector3.zero(),
      source: HemisphereLight(
        skyColor: sky,
        groundColor: ground,
        intensity: 0.44,
      ),
    ),
    Light(
      position: Vector3.zero(),
      source: DirectionalLight(
        color: sunColor,
        intensity: 0.7,
        direction: -toSun,
      ),
    ),
    Light(
      position: pointPosition,
      source: PointLight(color: pointColor, intensity: 0.6, range: 1.6),
    ),
  ];

  StylizedMaterial newMaterial() => StylizedMaterial(
    accentColor: accentColor,
    emissiveColor: emissiveColor,
    emissiveStrength: 0.5,
    rimStrength: 0.4,
  );

  group('StylizedMaterial', () {
    testGpuEngine('reproduces the stylized look', () async {
      final material = newMaterial();
      final h = (toSun.normalized() + Vector3(0, 0, 1))..normalize();
      const tintColor = Color(0xFFE04040);
      // Each square: its center, its vertices and the expected color there.
      final squares = <(double, double, _Vertex, Color?)>[
        (
          -0.6,
          0.5,
          _Vertex(
            normal: Vector3(0, 0, 1),
            color: const Color(0xFFB08060),
            occlusion: 0.8,
            gloss: 0.5,
          ),
          null,
        ),
        (
          0,
          0.5,
          _Vertex(
            normal: Vector3(0, 0.6, 0.8),
            color: const Color(0xFFC0C0C0),
            tint: 1,
          ),
          tintColor,
        ),
        (
          0.6,
          0.5,
          _Vertex(
            normal: Vector3(0, -0.6, 0.8),
            color: const Color(0xFFD0D0D0),
            occlusion: 0.6,
            accent: 1,
          ),
          null,
        ),
        // A gem facing the half vector, for the brightest highlight.
        (
          -0.6,
          -0.5,
          _Vertex(
            normal: h,
            color: const Color(0xFF302040),
            gloss: 0.52 / 0.28,
          ),
          null,
        ),
        // Facing away from the sun, at a grazing angle: lit by the wrapped
        // point light, with a strong rim.
        (
          0,
          -0.5,
          _Vertex(
            normal: Vector3(-0.9, -0.2, 0.39),
            color: const Color(0xFFA0A0A0),
            gloss: 0.1,
          ),
          null,
        ),
        // An emissive vertex, half way to the emissive color.
        (
          0.6,
          -0.5,
          _Vertex(
            normal: Vector3(0.3, 0.3, 0.9),
            color: const Color(0xFF406080),
            emissive: 1,
          ),
          null,
        ),
      ];

      final frame = await renderFrame(
        draw: (context) {
          for (final (x, y, vertex, tint) in squares) {
            context.drawSurface(
              _square(material, vertex, x: x, y: y),
              color: tint ?? const Color(0xFFFFFFFF),
            );
          }
        },
        lights: lights(),
      );

      var largest = 0;
      for (final (i, (x, y, vertex, tint)) in squares.indexed) {
        final (px, py) = pixelAt(x, y);
        final expected = look.shade(
          position: _worldAt(px, py),
          normal: vertex.normal,
          vertexColor: _rgb(vertex.color),
          ao: vertex.occlusion,
          tint: tint == null ? null : _rgb(tint),
          accent: vertex.accent == 1,
          gloss: vertex.gloss,
          gem: i == 3,
          emissiveStrength: vertex.emissive * 0.5,
        );
        final difference = _difference(frame.pixels.at(px, py), expected);
        largest = math.max(largest, difference);
        expect(
          difference,
          lessThanOrEqualTo(1),
          reason: 'square $i: ${frame.pixels.at(px, py)} vs $expected',
        );
      }
      // ignore: avoid_print
      print('Largest difference from the reference look: $largest / 255');
    });

    testGpuEngine(
      'lights towards the viewer of a perspective camera',
      () async {
        final material = newMaterial();
        final vertex = _Vertex(
          normal: Vector3(0.2, 0.3, 0.9),
          color: const Color(0xFF9070A0),
          gloss: 1,
        );
        // A 90 degree field of view: the z = -5 plane spans [-5, 5].
        final projection = Matrix4.zero()..setAsPerspective(90, 1, 1, 100);

        final frame = await renderFrame(
          draw: (context) => context.drawSurface(
            _square(material, vertex, halfSize: 1.5),
            transform: Matrix4.translationValues(3, 1, 0),
          ),
          projection: projection,
          lights: lights(),
        );

        for (final (px, py) in [(51, 22), (44, 29), (57, 16)]) {
          final position = Vector3(
            ((px + 0.5) / 32 - 1) * 5,
            (1 - (py + 0.5) / 32) * 5,
            -5,
          );
          final expected = look.shade(
            position: position,
            normal: vertex.normal,
            vertexColor: _rgb(vertex.color),
            gloss: 1,
            viewer: Vector3.zero(),
          );
          expect(
            _difference(frame.pixels.at(px, py), expected),
            lessThan(2),
            reason: '${frame.pixels.at(px, py)} vs $expected',
          );
        }
      },
    );

    testGpuEngine(
      'adds the MatCap texture where vertices have gloss',
      () async {
        const matCapColor = Color(0xFF204060);
        final material = newMaterial()
          ..matCapTexture = ColorTexture(matCapColor)
          ..matCapStrength = 0.5;
        final vertex = _Vertex(
          normal: Vector3(0, 0, 1),
          color: const Color(0xFF808080),
          gloss: 0.6,
        );

        final frame = await renderFrame(
          draw: (context) => context.drawSurface(_square(material, vertex)),
          lights: lights(),
        );

        final (px, py) = pixelAt(0, 0);
        final expected = look.shade(
          position: _worldAt(px, py),
          normal: vertex.normal,
          vertexColor: _rgb(vertex.color),
          gloss: 0.6,
          matCap: _rgb(matCapColor) * 0.5,
        );
        expect(_difference(frame.pixels.at(px, py), expected), lessThan(2));
      },
    );

    testGpuEngine('draws standard surfaces with neutral masks', () async {
      final material = newMaterial();
      const vertexColor = Color(0xFF90A0B0);
      const tint = Color(0xFFFFC080);
      final stride = VertexLayout.standard.strideInFloats;
      final vertices = Float32List(4 * stride);
      const corners = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
      for (final (i, (x, y)) in corners.indexed) {
        vertices
          ..setRange(i * stride, i * stride + 3, [x * 0.3, y * 0.3, -5])
          ..setRange(i * stride + 5, i * stride + 9, [
            vertexColor.r,
            vertexColor.g,
            vertexColor.b,
            1,
          ])
          ..setRange(i * stride + 9, i * stride + 12, [0, 0, 1]);
      }
      final surface = Surface.fromBuffers(
        vertices: vertices,
        indices: Uint16List.fromList([0, 1, 2, 2, 3, 0]),
        material: material,
      );

      final frame = await renderFrame(
        draw: (context) => context.drawSurface(surface, color: tint),
        lights: lights(),
      );

      final (px, py) = pixelAt(0, 0);
      // Unoccluded, tinted by the instance color, no gloss nor emission.
      final expected = look.shade(
        position: _worldAt(px, py),
        normal: Vector3(0, 0, 1),
        vertexColor: _rgb(vertexColor),
        tint: _rgb(tint),
      );
      expect(_difference(frame.pixels.at(px, py), expected), lessThan(2));
    });

    testGpuEngine('batches instances with their own tint', () async {
      final material = newMaterial();
      final surface = _square(
        material,
        _Vertex(normal: Vector3(0, 0, 1), tint: 1),
        halfSize: 0.15,
      );
      const tints = [Color(0xFFFF0000), Color(0xFF00FF00), Color(0xFF0000FF)];

      final frame = await renderFrame(
        draw: (context) {
          for (final (i, tint) in tints.indexed) {
            context.drawSurface(
              surface,
              transform: Matrix4.translationValues(-0.6 + i * 0.6, 0, 0),
              color: tint,
            );
          }
        },
        lights: lights(),
      );

      expect(frame.stats.drawCalls, 1);
      expect(frame.stats.instances, 3);
      for (final (i, tint) in tints.indexed) {
        final (px, py) = pixelAt(-0.6 + i * 0.6, 0);
        final position = _worldAt(px, py);
        // The squares are drawn translated: the point light is relative to
        // their world position, which _worldAt gives.
        final expected = look.shade(
          position: position,
          normal: Vector3(0, 0, 1),
          vertexColor: Vector3.all(1),
          tint: _rgb(tint),
        );
        expect(_difference(frame.pixels.at(px, py), expected), lessThan(2));
      }
    });

    testGpuEngine('sways vertices with a sway weight in the wind', () async {
      Future<int> leftEdge(double sway, double time) async {
        final material = newMaterial()
          ..windAmplitude = 0.25
          ..windTime = time;
        final surface = _square(
          material,
          _Vertex(normal: Vector3(0, 0, 1), sway: sway),
          halfSize: 0.5,
        );
        final frame = await renderFrame(
          draw: (context) => context.drawSurface(surface),
          lights: lights(),
        );
        for (var x = 0; x < 64; x++) {
          if (!frame.pixels.isClear(x, 32)) {
            return x;
          }
        }
        return 64;
      }

      // The square sits at the origin, so the phase is time * 2.3.
      const time = 0.5;
      final offset = math.sin(time * 2.3) * 0.25;
      // The left edge at x = -0.5 is pixel 16, and moves by 32 pixels per
      // unit.
      expect(await leftEdge(0, time), 16);
      expect(await leftEdge(1, time), closeTo(16 + offset * 32, 1));
      expect(await leftEdge(0.5, time), closeTo(16 + offset * 16, 1));
    });

    testGpuEngine(
      'boosts the glow and highlights each instance of one draw',
      () async {
        const boostColor = Color(0xFF3060FF);
        const highlightColor = Color(0xFF406020);
        final material = newMaterial()
          ..emissiveStrength = 0.3
          ..emissiveBoostColor = boostColor
          ..highlightColor = highlightColor;
        final surface = _square(
          material,
          _Vertex(
            normal: Vector3(0.2, 0.3, 0.9),
            color: const Color(0xFF8090A0),
            emissive: 0.5,
          ),
          halfSize: 0.15,
        );
        // (x, boost, highlight)
        const instances = [
          (-0.6, 0.0, 0.0),
          (-0.2, 0.4, 0.0),
          (0.2, 1.0, 0.0),
          (0.6, 0.0, 0.3),
        ];

        final frame = await renderFrame(
          draw: (context) {
            for (final (x, boost, highlight) in instances) {
              context.drawSurface(
                surface,
                transform: Matrix4.translationValues(x, 0, 0),
                instanceData: Vector4(boost, highlight, 0, 0),
              );
            }
          },
          lights: lights(),
        );

        expect(frame.stats.drawCalls, 1);
        expect(frame.stats.instances, 4);
        for (final (x, boost, highlight) in instances) {
          final (px, py) = pixelAt(x, 0);
          final expected = look.shade(
            position: _worldAt(px, py),
            normal: Vector3(0.2, 0.3, 0.9),
            vertexColor: _rgb(const Color(0xFF8090A0)),
            emissiveStrength: (0.5 * (0.3 + boost)).clamp(0.0, 1.0),
            emissive:
                _rgb(emissiveColor) +
                (_rgb(boostColor) - _rgb(emissiveColor)) *
                    boost.clamp(0.0, 1.0),
            highlight: _rgb(highlightColor) * highlight,
          );
          expect(
            _difference(frame.pixels.at(px, py), expected),
            lessThan(2),
            reason: 'instance at $x: ${frame.pixels.at(px, py)} vs $expected',
          );
        }
      },
    );

    testGpuEngine('fades translucent instances over the scene', () async {
      const background = Color(0xFF2040C0);
      final ghost = StylizedMaterial(
        accentColor: accentColor,
        emissiveColor: emissiveColor,
        emissiveStrength: 0.5,
        rimStrength: 0.4,
        translucent: true,
      );
      expect(ghost.renderState.translucent, isTrue);
      expect(ghost.renderState.depthWrite, isFalse);
      final vertex = _Vertex(
        normal: Vector3(0, 0, 1),
        color: const Color(0xFFE0C0A0),
      );
      final surface = _square(ghost, vertex, halfSize: 0.15);
      // (x, fade)
      const instances = [(-0.5, 0.6), (0.0, 0.0), (0.5, 1.0)];

      final frame = await renderFrame(
        draw: (context) {
          for (final (x, fade) in instances) {
            context.drawSurface(
              surface,
              transform: Matrix4.translationValues(x, 0, 0),
              instanceData: Vector4(0, 0, 0, fade),
            );
          }
          // Recorded last, drawn first: it is opaque.
          context.drawSurface(
            quad(opaqueUnlit(background), halfSize: 1),
            transform: Matrix4.translationValues(0, 0, -8),
          );
        },
        lights: lights(),
      );

      // The background, then the ghosts in one draw.
      expect(frame.stats.drawCalls, 2);
      for (final (x, fade) in instances) {
        final (px, py) = pixelAt(x, 0);
        final color = look.shadeColor(
          position: _worldAt(px, py),
          normal: vertex.normal,
          vertexColor: _rgb(vertex.color),
        );
        // Premultiplied blending over the opaque background.
        final alpha = 1 - fade;
        final expected = color * alpha + _rgb(background) * (1 - alpha);
        int channel(double c) => (c * 255).round();
        final pixel = frame.pixels.at(px, py);
        expect(
          _difference(pixel, (
            channel(expected.x),
            channel(expected.y),
            channel(expected.z),
          )),
          lessThan(2),
          reason: 'fade $fade: $pixel vs $expected',
        );
        expect(pixel.$4, 255);
      }
    });

    /// The first non-clear pixel of row [y] from the left.
    int leftEdgeOf(Pixels pixels, int y) {
      for (var x = 0; x < pixels.width; x++) {
        if (!pixels.isClear(x, y)) {
          return x;
        }
      }
      return pixels.width;
    }

    /// The last non-clear pixel of column [x] from the top.
    int bottomEdgeOf(Pixels pixels, int x) {
      for (var y = pixels.height - 1; y >= 0; y--) {
        if (!pixels.isClear(x, y)) {
          return y;
        }
      }
      return -1;
    }

    testGpuEngine('sways each instance by its wind strength', () async {
      const time = 0.5;
      final material = newMaterial()
        ..windAmplitude = 0.1
        ..windPhase = Vector3.zero()
        ..windTime = time;
      final surface = _square(
        material,
        _Vertex(normal: Vector3(0, 0, 1), sway: 1),
        halfSize: 0.15,
      );
      // (x, strength offset)
      const instances = [(-0.6, -1.0), (0.0, 0.0), (0.6, 1.0)];

      final frame = await renderFrame(
        draw: (context) {
          for (final (x, wind) in instances) {
            context.drawSurface(
              surface,
              transform: Matrix4.translationValues(x, 0, 0),
              instanceData: Vector4(0, 0, wind, 0),
            );
          }
        },
        lights: lights(),
      );

      expect(frame.stats.drawCalls, 1);
      // The left edges of the three squares along the middle row.
      final edges = [
        for (var px = 0; px < 64; px++)
          if (!frame.pixels.isClear(px, 32) &&
              (px == 0 || frame.pixels.isClear(px - 1, 32)))
            px,
      ];
      expect(edges, hasLength(3));
      final sway = math.sin(time * 2.3) * 0.1;
      for (final (i, (x, wind)) in instances.indexed) {
        expect(
          edges[i],
          closeTo((x - 0.15 + sway * (1 + wind) + 1) * 32, 1),
          reason: 'instance at $x',
        );
      }
    });

    testGpuEngine(
      'sways in model space, turned and scaled with each instance',
      () async {
        const time = 0.5;
        final material = newMaterial()
          ..windSpace = WindSpace.model
          ..windDirection = Vector3(1, 0, 0)
          ..windAmplitude = 0.1
          ..windPhase = Vector3.zero()
          ..windTime = time;
        final surface = _square(
          material,
          _Vertex(normal: Vector3(0, 0, 1), sway: 1),
        );
        // One instance as modeled, one turned a quarter turn about z and
        // scaled twice in x and y: its model x axis is the world y axis.
        final turned = Matrix4.translationValues(0.5, 0, 0)
          ..rotateZ(math.pi / 2)
          ..scaleByDouble(2, 2, 1, 1);

        final frame = await renderFrame(
          draw: (context) => context
            ..drawSurface(
              surface,
              transform: Matrix4.translationValues(-0.5, 0, 0),
            )
            ..drawSurface(surface, transform: turned),
          lights: lights(),
        );

        expect(frame.stats.drawCalls, 1);
        final sway = math.sin(time * 2.3) * 0.1;
        // The first instance moves right by the amplitude.
        final left = (-0.5 - 0.2 + sway + 1) * 32;
        expect(leftEdgeOf(frame.pixels, 32), closeTo(left, 1));
        // The second moves up by twice the amplitude: its bottom edge, at
        // y = -0.4 at rest.
        final bottom = (1 - (-0.4 + 2 * sway)) * 32;
        expect(bottomEdgeOf(frame.pixels, 48), closeTo(bottom, 1));
      },
    );

    testGpuEngine(
      'sways in world space scaled along the up axis of each instance',
      () async {
        const time = 0.5;
        final material = newMaterial()
          ..windSpace = WindSpace.worldScaled
          ..windDirection = Vector3(1, 0, 0)
          ..windUpAxis = Vector3(0, 0, 1)
          ..windAmplitude = 0.1
          ..windPhase = Vector3.zero()
          ..windTime = time;
        final surface = _square(
          material,
          _Vertex(normal: Vector3(0, 0, 1), sway: 1),
        );
        // One instance as modeled; one turned a quarter turn about its up
        // axis (z, towards the camera), scaled 1.5 times across it and twice
        // along it (and moved back to z = -5).
        final turned = Matrix4.translationValues(0.5, 0, 5)
          ..rotateZ(math.pi / 2)
          ..scaleByDouble(1.5, 1.5, 2, 1);

        final frame = await renderFrame(
          draw: (context) => context
            ..drawSurface(
              surface,
              transform: Matrix4.translationValues(-0.5, 0, 0),
            )
            ..drawSurface(surface, transform: turned),
          lights: lights(),
        );

        expect(frame.stats.drawCalls, 1);
        final sway = math.sin(time * 2.3) * 0.1;
        // Both move right, along the world x axis whatever their turn: the
        // first by the amplitude, the second by twice the amplitude (its
        // scale along its up axis). Its left edge is at x = 0.5 - 0.3 at
        // rest.
        final edges = [
          for (var px = 0; px < 64; px++)
            if (!frame.pixels.isClear(px, 32) &&
                (px == 0 || frame.pixels.isClear(px - 1, 32)))
              px,
        ];
        expect(edges, hasLength(2));
        expect(edges[0], closeTo((-0.5 - 0.2 + sway + 1) * 32, 1));
        expect(edges[1], closeTo((0.5 - 0.3 + 2 * sway + 1) * 32, 1));
        // It does not move along the world y axis, as it would in model
        // space: its bottom edge stays at y = -0.3.
        expect(bottomEdgeOf(frame.pixels, 48), closeTo((1 + 0.3) * 32, 1));
      },
    );

    testGpuEngine('shifts the sway of each vertex by its phase', () async {
      const time = 0.5;
      final material = newMaterial()
        ..windAmplitude = 0.25
        ..windPhase = Vector3.zero()
        ..windTime = time;
      // (y, phase in turns)
      const squares = [(0.5, 0.0), (0.0, 0.25), (-0.5, 0.5)];

      final frame = await renderFrame(
        draw: (context) {
          for (final (y, phase) in squares) {
            context.drawSurface(
              _square(
                material,
                _Vertex(normal: Vector3(0, 0, 1), sway: 1, windPhase: phase),
                y: y,
                halfSize: 0.15,
              ),
            );
          }
        },
        lights: lights(),
      );

      for (final (y, phase) in squares) {
        final offset = math.sin(time * 2.3 + phase * 2 * math.pi) * 0.25;
        final (_, py) = pixelAt(0, y);
        expect(
          leftEdgeOf(frame.pixels, py),
          closeTo((-0.15 + offset + 1) * 32, 1),
          reason: 'phase $phase',
        );
      }
    });

    testGpuEngine('flutters the vertices with a flutter weight', () async {
      const time = 0.5;
      final material = newMaterial()
        ..windAmplitude = 0
        ..windPhase = Vector3.zero()
        ..windFlutterAmplitude = 0.2
        ..windFlutterFrequency = 9
        ..windTime = time;
      // (y, flutter weight, phase in turns)
      const squares = [(0.5, 0.0, 0.0), (0.0, 1.0, 0.0), (-0.5, 0.5, 0.1)];

      final frame = await renderFrame(
        draw: (context) {
          for (final (y, flutter, phase) in squares) {
            context.drawSurface(
              _square(
                material,
                _Vertex(
                  normal: Vector3(0, 0, 1),
                  flutter: flutter,
                  windPhase: phase,
                ),
                y: y,
                halfSize: 0.15,
              ),
            );
          }
        },
        lights: lights(),
      );

      for (final (y, flutter, phase) in squares) {
        final offset = math.sin(time * 9 + phase * 2 * math.pi) * 0.2 * flutter;
        final (_, py) = pixelAt(0, y);
        expect(
          leftEdgeOf(frame.pixels, py),
          closeTo((-0.15 + offset + 1) * 32, 1),
          reason: 'flutter $flutter, phase $phase',
        );
      }
      // Without a sway weight, the vertices do not sway: the first square
      // stays where it is.
      expect(leftEdgeOf(frame.pixels, pixelAt(0, 0.5).$2), 27);
    });

    testGpuEngine('strengthens and weakens the wind with gusts', () async {
      const time = 0.5;
      final material = newMaterial()
        ..windAmplitude = 0.25
        ..windPhase = Vector3.zero()
        ..windGustAmplitude = 0.6
        ..windGustFrequency = 1
        ..windGustDirection = Vector3(2, 0, 0)
        ..windGustPhaseScale = 2
        ..windTime = time;
      final surface = _square(
        material,
        _Vertex(normal: Vector3(0, 0, 1), sway: 1),
        halfSize: 0.15,
      );
      // (x, y, wind strength offset)
      const instances = [(-0.5, 0.5, 0.0), (0.5, 0.0, 0.0), (0.5, -0.5, 1.0)];

      final frame = await renderFrame(
        draw: (context) {
          for (final (x, y, strength) in instances) {
            context.drawSurface(
              surface,
              transform: Matrix4.translationValues(x, y, 0),
              instanceData: Vector4(0, 0, strength, 0),
            );
          }
        },
        lights: lights(),
      );

      final sway = math.sin(time * 2.3) * 0.25;
      for (final (x, y, strength) in instances) {
        // The gust wave travels along +x, half a unit per unit of time.
        final gust = 1 + 0.6 * math.sin(time * 1 - x * 2);
        final (_, py) = pixelAt(x, y);
        expect(
          leftEdgeOf(frame.pixels, py),
          closeTo((x - 0.15 + sway * gust * (1 + strength) + 1) * 32, 1),
          reason: 'instance at ($x, $y)',
        );
      }
    });

    testGpuEngine('weighs the sky fill per channel', () async {
      final material = newMaterial()
        ..skyFill = 1
        ..skyFillWeight = Vector3(0.35, 0.35, 0.32);
      final vertex = _Vertex(
        normal: Vector3(0, 0.9, 0.44),
        color: const Color(0xFFD0D0D0),
      );

      final frame = await renderFrame(
        draw: (context) => context.drawSurface(_square(material, vertex)),
        lights: lights(),
      );

      final (px, py) = pixelAt(0, 0);
      final expected = look.shade(
        position: _worldAt(px, py),
        normal: vertex.normal,
        vertexColor: _rgb(vertex.color),
        skyFill: Vector3(0.35, 0.35, 0.32),
      );
      final scalar = look.shade(
        position: _worldAt(px, py),
        normal: vertex.normal,
        vertexColor: _rgb(vertex.color),
      );
      // The weight shows in the blue channel only.
      expect(expected.$3, lessThan(scalar.$3));
      expect(_difference(frame.pixels.at(px, py), expected), lessThan(2));
    });

    testGpuEngine('adds a clear coat and a gem MatCap by gloss', () async {
      const coat = Color(0xFF204060);
      const gem = Color(0xFF605020);
      final material = newMaterial()
        ..matCapTexture = ColorTexture(coat)
        ..matCapStrength = 0.5
        ..matCapThreshold = 0.36
        ..matCapGlossWeight = 0
        ..gemMatCapTexture = ColorTexture(gem)
        ..gemThreshold = 1.5;
      // (x, gloss, expected MatCap)
      final squares = [
        (-0.6, 0.3, Vector3.zero()),
        (0.0, 0.6, _rgb(coat) * 0.5),
        (0.6, 0.52 / 0.28, _rgb(gem)),
      ];

      final frame = await renderFrame(
        draw: (context) {
          for (final (x, gloss, _) in squares) {
            context.drawSurface(
              _square(
                material,
                _Vertex(
                  normal: Vector3(0, 0, 1),
                  color: const Color(0xFF606060),
                  gloss: gloss,
                ),
                x: x,
              ),
            );
          }
        },
        lights: lights(),
      );

      for (final (x, gloss, cap) in squares) {
        final (px, py) = pixelAt(x, 0);
        final expected = look.shade(
          position: _worldAt(px, py),
          normal: Vector3(0, 0, 1),
          vertexColor: _rgb(const Color(0xFF606060)),
          gloss: gloss,
          cap: cap,
        );
        expect(
          _difference(frame.pixels.at(px, py), expected),
          lessThan(2),
          reason: 'gloss $gloss: ${frame.pixels.at(px, py)} vs $expected',
        );
      }
    });

    testGpuEngine(
      'reflects a metallic MatCap tinted by the lit surface',
      () async {
        const coat = Color(0xFFE0A030);
        const gem = Color(0xFFB0C8E0);
        const tint = Color(0xFFFFD54F);
        StylizedMaterial metal(double metallic) => newMaterial()
          ..matCapTexture = ColorTexture(coat)
          ..matCapThreshold = 0.36
          ..matCapGlossWeight = 0
          ..gemMatCapTexture = ColorTexture(gem)
          ..gemThreshold = 1.5
          ..matCapMetallic = metallic;
        // (x, y, metallic, vertex, expected MatCap: null for none)
        final squares = <(double, double, double, _Vertex, Color?)>[
          // Below the MatCap threshold: lit as without a MatCap.
          (
            -0.6,
            0.5,
            1,
            _Vertex(normal: Vector3(0, 0, 1), tint: 1, gloss: 0.2),
            null,
          ),
          // The clear-coat tile, multiplied by the gold surface.
          (
            0,
            0.5,
            1,
            _Vertex(normal: Vector3(0, 0.6, 0.8), tint: 1, gloss: 0.6),
            coat,
          ),
          // The gem tile, multiplied by the gold surface.
          (
            0.6,
            0.5,
            1,
            _Vertex(
              normal: Vector3(0.3, 0.3, 0.9),
              tint: 1,
              gloss: 0.52 / 0.28,
            ),
            gem,
          ),
          // A surface lit beyond 1 shows the tile as it is.
          (
            -0.6,
            -0.5,
            1,
            _Vertex(normal: Vector3(0, 0, 1), occlusion: 4, gloss: 0.6),
            coat,
          ),
          // Half metallic: half way between the sheen and the reflection.
          (
            0,
            -0.5,
            0.5,
            _Vertex(normal: Vector3(0, 0, 1), tint: 1, gloss: 0.6),
            coat,
          ),
        ];

        final frame = await renderFrame(
          draw: (context) {
            for (final (x, y, metallic, vertex, _) in squares) {
              context.drawSurface(
                _square(metal(metallic), vertex, x: x, y: y),
                color: tint,
              );
            }
          },
          lights: lights(),
        );

        for (final (i, (x, y, metallic, vertex, cap)) in squares.indexed) {
          final (px, py) = pixelAt(x, y);
          final expected = look.shade(
            position: _worldAt(px, py),
            normal: vertex.normal,
            vertexColor: _rgb(vertex.color),
            ao: vertex.occlusion,
            tint: vertex.tint == 1 ? _rgb(tint) : null,
            gloss: vertex.gloss,
            gem: vertex.gloss > 1.5,
            cap: cap == null ? null : _rgb(cap),
            reflected: cap == null ? null : _rgb(cap),
            metallic: metallic,
          );
          expect(
            _difference(frame.pixels.at(px, py), expected),
            lessThan(2),
            reason: 'square $i: ${frame.pixels.at(px, py)} vs $expected',
          );
        }

        // The reflection keeps the gold saturated where the sheen washes it
        // out: the blue channel of the clear-coat square.
        final (px, py) = pixelAt(0, 0.5);
        final sheen = look.shade(
          position: _worldAt(px, py),
          normal: Vector3(0, 0.6, 0.8),
          vertexColor: Vector3.all(1),
          tint: _rgb(tint),
          gloss: 0.6,
          cap: _rgb(coat),
        );
        expect(frame.pixels.at(px, py).$3, lessThan(sheen.$3 - 60));
      },
    );

    testGpuEngine(
      'orients the MatCap as the picture, also through a mirroring projection',
      () async {
        const left = Color(0xFFFF0000);
        const right = Color(0xFF00FF00);
        // The left half of the MatCap red, the right half green.
        final matCap = Texture(
          ByteData.sublistView(
            Uint8List.fromList([255, 0, 0, 255, 0, 255, 0, 255]),
          ),
          width: 2,
          height: 1,
        );
        final material = newMaterial()
          ..matCapTexture = matCap
          ..matCapThreshold = -1
          ..matCapGlossWeight = 0;
        // Black and tilted towards +x: the MatCap alone (and a faint rim).
        final surface = _square(
          material,
          _Vertex(normal: Vector3(0.6, 0, 0.8), color: const Color(0xFF000000)),
        );

        Future<(int, int, int, int)> centerWith(Matrix4 projection) async {
          final frame = await renderFrame(
            draw: (context) => context.drawSurface(surface),
            projection: projection,
            lights: lights(),
          );
          return frame.pixels.at(32, 32);
        }

        // A standard camera shows +x on the right of the picture.
        final standard = await centerWith(defaultProjection);
        // Mirrored left to right, +x is on the left of the picture.
        final mirrored = await centerWith(
          defaultProjection..setEntry(0, 0, -1),
        );
        expect(standard.$2, greaterThan(200), reason: '$standard ($right)');
        expect(standard.$1, lessThan(20), reason: '$standard ($right)');
        expect(mirrored.$1, greaterThan(200), reason: '$mirrored ($left)');
        expect(mirrored.$2, lessThan(20), reason: '$mirrored ($left)');
      },
    );

    testGpuEngine(
      'keeps the lit color of a metallic material without MatCap textures',
      () async {
        final material = newMaterial()
          ..matCapThreshold = -1
          ..matCapMetallic = 1;
        final vertex = _Vertex(
          normal: Vector3(0, 0.6, 0.8),
          color: const Color(0xFFC09060),
          gloss: 0.6,
        );

        final frame = await renderFrame(
          draw: (context) => context.drawSurface(_square(material, vertex)),
          lights: lights(),
        );

        final (px, py) = pixelAt(0, 0);
        final expected = look.shade(
          position: _worldAt(px, py),
          normal: vertex.normal,
          vertexColor: _rgb(vertex.color),
          gloss: 0.6,
        );
        expect(
          _difference(frame.pixels.at(px, py), expected),
          lessThan(2),
          reason: '${frame.pixels.at(px, py)} vs $expected',
        );
      },
    );
  });
}
