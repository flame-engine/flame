import 'dart:math' as math;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/particles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmitterShape3D', () {
    final random = math.Random(7);
    final position = Vector3.zero();
    final direction = Vector3.zero();

    void sampleMany(
      EmitterShape3D shape,
      void Function(Vector3 position, Vector3 direction) check,
    ) {
      for (var i = 0; i < 500; i++) {
        shape.sample(random, position, direction);
        expect(direction.length, closeTo(1, 1e-6));
        check(position, direction);
      }
    }

    test('point spawns at the origin in every direction', () {
      final sum = Vector3.zero();
      sampleMany(const PointEmitterShape3D(), (p, d) {
        expect(p.length, 0);
        sum.add(d);
      });
      // Uniform directions average out.
      expect(sum.length / 500, lessThan(0.15));
    });

    test('sphere spawns inside it, moving outwards', () {
      sampleMany(const SphereEmitterShape3D(2), (p, d) {
        expect(p.length, lessThanOrEqualTo(2 + 1e-6));
        if (p.length > 1e-6) {
          expect(p.normalized().dot(d), closeTo(1, 1e-6));
        }
      });
    });

    test('sphere surface and hemisphere', () {
      sampleMany(
        const SphereEmitterShape3D(1.5, surface: true, hemisphere: true),
        (p, d) {
          expect(p.length, closeTo(1.5, 1e-6));
          expect(p.y, greaterThanOrEqualTo(0));
        },
      );
    });

    test('box spawns inside it, moving up', () {
      sampleMany(const BoxEmitterShape3D(2, 4, 6), (p, d) {
        expect(p.x.abs(), lessThanOrEqualTo(1));
        expect(p.y.abs(), lessThanOrEqualTo(2));
        expect(p.z.abs(), lessThanOrEqualTo(3));
        expect(d, Vector3(0, 1, 0));
      });
    });

    test('disc and ring spawn in the xz plane', () {
      sampleMany(const DiscEmitterShape3D(2), (p, d) {
        expect(p.y, 0);
        expect(p.length, lessThanOrEqualTo(2 + 1e-6));
        expect(d, Vector3(0, 1, 0));
      });
      sampleMany(
        const DiscEmitterShape3D(2, innerRadius: 1.5, radial: true),
        (p, d) {
          expect(p.length, inInclusiveRange(1.5 - 1e-6, 2 + 1e-6));
          expect(d.y, 0);
          expect(p.normalized().dot(d), closeTo(1, 1e-6));
        },
      );
      sampleMany(const DiscEmitterShape3D(1, innerRadius: 1), (p, d) {
        expect(p.length, closeTo(1, 1e-6));
      });
    });

    test('cone emits within its angle', () {
      const angle = 0.4;
      sampleMany(const ConeEmitterShape3D(angle: angle), (p, d) {
        expect(p.length, 0);
        expect(
          math.acos(d.y.clamp(-1.0, 1.0)),
          lessThanOrEqualTo(angle + 1e-6),
        );
      });
      sampleMany(const ConeEmitterShape3D(angle: angle, radius: 0.5), (p, d) {
        expect(p.y, 0);
        final r = p.length;
        expect(r, lessThanOrEqualTo(0.5 + 1e-6));
        // Tilted away from the axis in proportion to the distance from it.
        expect(math.acos(d.y.clamp(-1.0, 1.0)), closeTo(angle * r / 0.5, 1e-6));
      });
    });

    test('random directions in a cone stay within it', () {
      final axis = Vector3(1, 2, -1).normalized();
      final out = Vector3.zero();
      for (var i = 0; i < 500; i++) {
        EmitterShape3D.randomDirectionInCone(random, axis, 0.3, out);
        expect(out.length, closeTo(1, 1e-6));
        expect(math.acos(out.dot(axis).clamp(-1.0, 1.0)), lessThan(0.3 + 1e-6));
      }
    });
  });

  group('CurlNoise3D', () {
    test('is divergence free', () {
      final noise = CurlNoise3D(3);
      final a = Vector3.zero();
      final b = Vector3.zero();
      // Vector3 holds 32-bit floats: a step too small loses the precision.
      const e = 1e-3;
      final random = math.Random(1);
      for (var i = 0; i < 50; i++) {
        final x = random.nextDouble() * 10 - 5;
        final y = random.nextDouble() * 10 - 5;
        final z = random.nextDouble() * 10 - 5;
        var divergence = 0.0;
        noise.sample(x + e, y, z, 0.7, 1.3, 1, a);
        noise.sample(x - e, y, z, 0.7, 1.3, 1, b);
        divergence += (a.x - b.x) / (2 * e);
        noise.sample(x, y + e, z, 0.7, 1.3, 1, a);
        noise.sample(x, y - e, z, 0.7, 1.3, 1, b);
        divergence += (a.y - b.y) / (2 * e);
        noise.sample(x, y, z + e, 0.7, 1.3, 1, a);
        noise.sample(x, y, z - e, 0.7, 1.3, 1, b);
        divergence += (a.z - b.z) / (2 * e);
        expect(divergence.abs(), lessThan(1e-3));
      }
    });

    test('depends on its seed only', () {
      final a = Vector3.zero();
      final b = Vector3.zero();
      CurlNoise3D(5).sample(1, 2, 3, 0.5, 1, 2, a);
      CurlNoise3D(5).sample(1, 2, 3, 0.5, 1, 2, b);
      expect(a, b);
      CurlNoise3D(6).sample(1, 2, 3, 0.5, 1, 2, b);
      expect(a, isNot(b));
    });
  });
}
