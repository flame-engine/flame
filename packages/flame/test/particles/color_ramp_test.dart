import 'dart:ui';

import 'package:flame/particles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorRamp', () {
    test('solid keeps the same color over the whole lifetime', () {
      final ramp = ColorRamp.solid(const Color(0xff123456));
      expect(ramp.colorAt(0), const Color(0xff123456));
      expect(ramp.colorAt(0.5), const Color(0xff123456));
      expect(ramp.colorAt(1), const Color(0xff123456));
    });

    test('interpolates between the given colors', () {
      final ramp = ColorRamp(const [Color(0xff000000), Color(0xffffffff)]);
      expect(ramp.colorAt(0), const Color(0xff000000));
      expect(ramp.colorAt(1), const Color(0xffffffff));
      final middle = ramp.colorAt(0.5);
      expect((middle.r * 255).round(), closeTo(128, 8));
    });

    test('respects explicit stops', () {
      final ramp = ColorRamp(
        const [Color(0xff000000), Color(0xffffffff)],
        stops: const [0, 0.1],
      );
      expect(ramp.colorAt(0.5), const Color(0xffffffff));
    });

    test('interpolates alpha', () {
      final ramp = ColorRamp(const [Color(0xffffffff), Color(0x00ffffff)]);
      expect(ramp.colorAt(0).a, closeTo(1, 0.05));
      expect(ramp.colorAt(0.5).a, closeTo(0.5, 0.05));
      expect(ramp.colorAt(1).a, closeTo(0, 0.05));
    });

    test('clamps the input to the unit interval', () {
      final ramp = ColorRamp(const [Color(0xff000000), Color(0xffffffff)]);
      expect(ramp.colorAt(-1), ramp.colorAt(0));
      expect(ramp.colorAt(2), ramp.colorAt(1));
    });
  });
}
