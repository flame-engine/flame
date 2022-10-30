import 'dart:math';

import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('testRandom', () {
    // The primary difficulty with testing `testRandom` is that it is a *test*
    // and tests cannot be invoked within other tests. So, instead we will
    // invoke `testRandom` in the main body, and then hope that all these tests
    // will be invoked in order.

    group('Uses different seed each time', () {
      final seeds = <int>[];
      for (var i = 0; i < 50; i++) {
        testRandom('a', (Random rnd) => seeds.add(rnd.nextInt(1000000)));
      }
      test('verify', () {
        final nTotal = seeds.length;
        // Allow some seeds to coincide by pure luck
        expect(seeds.toSet().length, greaterThanOrEqualTo(nTotal - 2));
      });
    });

    group('Uses specific seed', () {
      final seeds = <int>[];
      testRandom(
        'b',
        (Random rnd) => seeds.add(rnd.nextInt(1000000)),
        seed: 123456,
      );
      test('verify', () {
        expect(seeds[0], 778213);
      });
    });

    group('Repeat count works', () {
      final seeds = <int>[];
      testRandom(
        'c',
        (Random rnd) => seeds.add(rnd.nextInt(1000000)),
        repeatCount: 20,
      );
      test('verify', () {
        expect(seeds.length, 20);
        expect(seeds.toSet().length, greaterThanOrEqualTo(18));
      });
    });
  });
}
