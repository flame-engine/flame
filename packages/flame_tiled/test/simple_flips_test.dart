import 'dart:math' as math;

import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimpleFlips.fromHexagonalFlips', () {
    Flips flips({
      bool horizontally = false,
      bool vertically = false,
      bool diagonally = false,
      bool antiDiagonally = false,
    }) {
      return Flips(
        horizontally: horizontally,
        vertically: vertically,
        diagonally: diagonally,
        antiDiagonally: antiDiagonally,
      );
    }

    test('does not rotate or flip a tile without flips', () {
      final simple = SimpleFlips.fromHexagonalFlips(flips());

      expect(simple.angle, 0);
      expect(simple.cos, 1);
      expect(simple.sin, 0);
      expect(simple.flip, isFalse);
      expect(simple.isHexagonal, isTrue);
    });

    test('rotates 60º with the diagonal flip', () {
      final simple = SimpleFlips.fromHexagonalFlips(flips(diagonally: true));

      expect(simple.angle, 1);
      expect(simple.cos, closeTo(math.cos(math.pi / 3), 1e-12));
      expect(simple.sin, closeTo(math.sin(math.pi / 3), 1e-12));
      expect(simple.flip, isFalse);
    });

    test('rotates 120º with the anti-diagonal flip', () {
      final simple = SimpleFlips.fromHexagonalFlips(
        flips(antiDiagonally: true),
      );

      expect(simple.angle, 2);
      expect(simple.cos, closeTo(-0.5, 1e-12));
      expect(simple.sin, closeTo(math.sqrt(3) / 2, 1e-12));
    });

    test('rotates 180º with both rotation flags', () {
      final simple = SimpleFlips.fromHexagonalFlips(
        flips(diagonally: true, antiDiagonally: true),
      );

      expect(simple.angle, 3);
      expect(simple.cos, -1);
      expect(simple.sin, 0);
    });

    test('a vertical flip is a horizontal flip and a 180º rotation', () {
      final simple = SimpleFlips.fromHexagonalFlips(flips(vertically: true));

      expect(simple.angle, 3);
      expect(simple.cos, -1);
      expect(simple.sin, 0);
      expect(simple.flip, isTrue);
    });

    test('flipping both ways is a 180º rotation without a flip', () {
      final simple = SimpleFlips.fromHexagonalFlips(
        flips(horizontally: true, vertically: true),
      );

      expect(simple.angle, 3);
      expect(simple.flip, isFalse);
    });

    test('keeps the angle within a full turn', () {
      final simple = SimpleFlips.fromHexagonalFlips(
        flips(vertically: true, diagonally: true, antiDiagonally: true),
      );

      // 60º + 120º + 180º = 360º.
      expect(simple.angle, 0);
      expect(simple.cos, 1);
      expect(simple.sin, 0);
      expect(simple.flip, isTrue);
    });
  });
}
