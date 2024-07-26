import 'package:flame_3d/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Vector4 extensions', () {
    test('can convert back and forth to mutable', () {
      final src = Vector4(1, 2, 3, 4);

      final immutable = src.immutable;
      expect(immutable.x, 1);
      expect(immutable.y, 2);
      expect(immutable.z, 3);
      expect(immutable.w, 4);
      expect(immutable.storage, [1, 2, 3, 4]);

      final mutable = immutable.mutable;
      expect(mutable.x, 1);
      expect(mutable.y, 2);
      expect(mutable.z, 3);
      expect(mutable.w, 4);
    });

    test('can convert to Color', () {
      final src = Vector4(0.1, 0.2, 0.3, 0.4);

      final color = src.toColor();
      expect(color.alpha, 102);
      expect(color.red, 25);
      expect(color.green, 51);
      expect(color.blue, 76);
    });
  });
}
