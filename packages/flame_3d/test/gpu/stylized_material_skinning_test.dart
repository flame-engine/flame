import 'dart:math' as math;
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

/// A square tube along the y axis, from `y = -0.7` to `y = 0.7`, `0.3` wide,
/// cut into `rings` rings: four flat sides of `rings` x 2 vertices each, the
/// vertex arrays of a [StylizedMaterial] surface.
class _Tube({int rings = 9}) {
  this {
    const half = 0.15;
    // The four sides: their normal and the two corners (x, z) of a ring.
    const sides = [
      ((0.0, 1.0), (-half, half), (half, half)),
      ((1.0, 0.0), (half, half), (half, -half)),
      ((0.0, -1.0), (half, -half), (-half, -half)),
      ((-1.0, 0.0), (-half, -half), (-half, half)),
    ];
    for (final ((nx, nz), (ax, az), (bx, bz)) in sides) {
      final first = positions.length ~/ 3;
      for (var r = 0; r < rings; r++) {
        final y = -0.7 + 1.4 * r / (rings - 1);
        positions.addAll([ax, y, az, bx, y, bz]);
        normals.addAll([nx, 0, nz, nx, 0, nz]);
      }
      for (var r = 0; r + 1 < rings; r++) {
        final a = first + r * 2;
        indices.addAll([a, a + 1, a + 3, a + 3, a + 2, a]);
      }
    }
    final count = positions.length ~/ 3;
    for (var v = 0; v < count; v++) {
      final y = positions[v * 3 + 1];
      // Joint 0 below the middle, joint 1 above it, blended in between;
      // the top ring also follows joint 2 a quarter.
      final up = ((y + 0.25) / 0.5).clamp(0.0, 1.0);
      final top = y > 0.65 ? 0.25 : 0.0;
      joints.addAll([0, 1, 2, 0]);
      weights.addAll([1 - up, up - top, top, 0]);
      sway.add((y + 0.7) / 1.4);
      final shade = 0.5 + 0.4 * (y + 0.7) / 1.4;
      colors.addAll([shade, 0.6, 1 - shade, 1]);
    }
  }

  final List<double> positions = [];
  final List<double> normals = [];
  final List<double> colors = [];
  final List<double> sway = [];
  final List<double> joints = [];
  final List<double> weights = [];
  final List<int> indices = [];

  int get vertexCount => positions.length ~/ 3;

  /// The skinned surface.
  Surface skinned(Material material) => StylizedMaterial.buildSurface(
    positions: positions,
    normals: normals,
    colors: colors,
    gloss: List.filled(vertexCount, 0.6),
    sway: sway,
    joints: joints,
    weights: weights,
    indices: indices,
    material: material,
  );

  /// An unskinned surface of the same vertices, moved on the CPU by the
  /// blend of [jointMatrices] as the skinned variant moves them: positions
  /// by `sum(w * J) * (p, 1)`, normals by `sum(w * J) * (n, 0)`.
  Surface skinnedOnCpu(Material material, List<Matrix4> jointMatrices) {
    final skinnedPositions = <double>[];
    final skinnedNormals = <double>[];
    for (var v = 0; v < vertexCount; v++) {
      final blend = Matrix4.zero();
      for (var k = 0; k < 4; k++) {
        final w = weights[v * 4 + k];
        if (w == 0) {
          continue;
        }
        final joint = jointMatrices[joints[v * 4 + k].toInt()];
        for (var e = 0; e < 16; e++) {
          blend.storage[e] += w * joint.storage[e];
        }
      }
      final p = blend.transformed3(
        Vector3(positions[v * 3], positions[v * 3 + 1], positions[v * 3 + 2]),
      );
      final n = blend.rotated3(
        Vector3(normals[v * 3], normals[v * 3 + 1], normals[v * 3 + 2]),
      );
      skinnedPositions.addAll([p.x, p.y, p.z]);
      skinnedNormals.addAll([n.x, n.y, n.z]);
    }
    return StylizedMaterial.buildSurface(
      positions: skinnedPositions,
      normals: skinnedNormals,
      colors: colors,
      gloss: List.filled(vertexCount, 0.6),
      sway: sway,
      indices: indices,
      material: material,
    );
  }
}

/// [rotation] about the z axis through [pivot], then translated by [shift].
Matrix4 _turnAbout(Vector3 pivot, double rotation, {Vector3? shift}) {
  return Matrix4.translation(pivot + (shift ?? Vector3.zero()))
    ..rotateZ(rotation)
    ..translateByVector3(-pivot);
}

void main() {
  setUpGpu();

  List<Light> lights() => [
    Light(
      position: Vector3.zero(),
      source: HemisphereLight(
        skyColor: const Color(0xFFB0D0FF),
        groundColor: const Color(0xFF806040),
      ),
    ),
    Light(
      position: Vector3.zero(),
      source: DirectionalLight(
        color: const Color(0xFFFFF0D0),
        intensity: 0.8,
        direction: Vector3(-0.5, -0.4, -1),
      ),
    ),
  ];

  // The tube stands in the middle of the default camera's view, turned
  // about y so that two of its sides face the camera.
  final model = Matrix4.translationValues(0, 0, -5)
    ..rotateY(0.6)
    ..scaleByDouble(0.9, 0.9, 0.9, 1);

  StylizedMaterial material() => StylizedMaterial(
    windTime: 0.7,
    windAmplitude: 0.06,
    windSpace: WindSpace.model,
    windDirection: Vector3(1, 0, 0),
  );

  group('StylizedMaterial skinning', () {
    testGpuEngine('matches the same mesh transformed on the CPU', () async {
      final tube = _Tube();
      final skinnedMaterial = material();
      final cpuMaterial = material();
      // A bend at the bottom, a sharp one in the middle, and a joint that
      // also scales, for the blended vertices of the top ring.
      final jointMatrices = [
        _turnAbout(Vector3(0, -0.7, 0), 0.2),
        _turnAbout(Vector3(0, 0, 0), -0.7, shift: Vector3(0.05, 0, 0)),
        Matrix4.translationValues(-0.1, 0.05, 0)
          ..scaleByDouble(1.3, 1.1, 1.3, 1),
      ];
      final skinned = tube.skinned(skinnedMaterial);
      final onCpu = tube.skinnedOnCpu(cpuMaterial, jointMatrices);

      final gpuFrame = await renderFrame(
        width: 128,
        height: 128,
        lights: lights(),
        draw: (context) => context.drawSurface(
          skinned,
          transform: model,
          jointTransforms: jointMatrices,
        ),
      );
      final cpuFrame = await renderFrame(
        width: 128,
        height: 128,
        lights: lights(),
        draw: (context) => context.drawSurface(onCpu, transform: model),
      );
      final restFrame = await renderFrame(
        width: 128,
        height: 128,
        lights: lights(),
        draw: (context) => context.drawSurface(
          tube.skinnedOnCpu(cpuMaterial, List.filled(3, Matrix4.identity())),
          transform: model,
        ),
      );

      final covered = gpuFrame.pixels.count((r, g, b, a) => a > 0);
      expect(covered, greaterThan(1500));
      // The pose moved the tube a lot...
      expect(
        differingPixels(gpuFrame.pixels, restFrame.pixels),
        greaterThan(covered ~/ 4),
      );
      // ...and the GPU put it where the CPU does, with the same shading: at
      // most a few edge pixels flip from float rounding.
      expect(
        differingPixels(gpuFrame.pixels, cpuFrame.pixels),
        lessThanOrEqualTo(covered ~/ 200),
      );
      expect(gpuFrame.stats.drawCalls, 1);
    });

    testGpuEngine('draws the rest pose with identity joints', () async {
      final tube = _Tube();
      final skinned = tube.skinned(material());
      final identity = List.filled(3, Matrix4.identity());
      final rest = tube.skinnedOnCpu(material(), identity);

      final gpuFrame = await renderFrame(
        lights: lights(),
        draw: (context) => context.drawSurface(
          skinned,
          transform: model,
          jointTransforms: identity,
        ),
      );
      final restFrame = await renderFrame(
        lights: lights(),
        draw: (context) => context.drawSurface(rest, transform: model),
      );

      expect(differingPixels(gpuFrame.pixels, restFrame.pixels), 0);
    });

    testGpuEngine('draws every skinned object on its own', () async {
      final tube = _Tube();
      final shared = material();
      final skinned = tube.skinned(shared);
      final left = [
        for (var k = 0; k < 3; k++) _turnAbout(Vector3.zero(), 0.4),
      ];
      final right = [
        for (var k = 0; k < 3; k++) _turnAbout(Vector3.zero(), -0.4),
      ];

      final frame = await renderFrame(
        lights: lights(),
        draw: (context) {
          context
            ..drawSurface(
              skinned,
              transform: Matrix4.translationValues(-0.5, 0, -5),
              jointTransforms: left,
            )
            ..drawSurface(
              skinned,
              transform: Matrix4.translationValues(0.5, 0, -5),
              jointTransforms: right,
            );
        },
      );

      expect(frame.stats.drawCalls, 2);
      // Each drew with its own joints: the left tube leans left at the top,
      // the right one right.
      bool covered(double x, double y) {
        final (px, py) = pixelAt(x, y);
        return !frame.pixels.isClear(px, py);
      }

      final lean = math.sin(0.4) * 0.6;
      expect(covered(-0.5 - lean, 0.55), isTrue);
      expect(covered(0.5 + lean, 0.55), isTrue);
      expect(covered(-0.5 + lean, 0.55), isFalse);
      expect(covered(0.5 - lean, 0.55), isFalse);
    });
  });

  group('StylizedMaterial color grade', () {
    Surface square(Material material) => StylizedMaterial.buildSurface(
      positions: [-0.5, -0.5, -5, 0.5, -0.5, -5, 0.5, 0.5, -5, -0.5, 0.5, -5],
      normals: [
        for (var i = 0; i < 4; i++) ...[0.0, 0.0, 1.0],
      ],
      colors: [
        for (var i = 0; i < 4; i++) ...[0.9, 0.5, 0.2, 1.0],
      ],
      indices: [0, 1, 2, 2, 3, 0],
      material: material,
    );

    Future<(int, int, int, int)> centre(StylizedMaterial material) async {
      final frame = await renderFrame(
        lights: lights(),
        draw: (context) => context.drawSurface(square(material)),
      );
      final (px, py) = pixelAt(0, 0);
      return frame.pixels.at(px, py);
    }

    testGpuEngine('greys out and overlays the final color', () async {
      final (r, g, b, a) = await centre(StylizedMaterial());
      expect(a, 255);
      expect((r - b).abs(), greaterThan(60), reason: 'a saturated orange');

      final grey = await centre(StylizedMaterial(saturation: 0));
      final luminosity = 0.3 * r + 0.59 * g + 0.11 * b;
      for (final channel in [grey.$1, grey.$2, grey.$3]) {
        expect((channel - luminosity).abs(), lessThan(2));
      }

      final half = await centre(StylizedMaterial(saturation: 0.5));
      expect((half.$1 - (r + luminosity) / 2).abs(), lessThan(2));
      expect((half.$3 - (b + luminosity) / 2).abs(), lessThan(2));

      const overlay = Color(0x4000FFFF);
      final tinted = await centre(StylizedMaterial(overlayColor: overlay));
      final k = overlay.a;
      expect((tinted.$1 - r * (1 - k)).abs(), lessThan(2));
      expect((tinted.$2 - (g * (1 - k) + 255 * k)).abs(), lessThan(2));
      expect((tinted.$3 - (b * (1 - k) + 255 * k)).abs(), lessThan(2));
      expect(tinted.$4, 255);
    });
  });
}
