import 'package:flame_3d/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Vector3 extensions', () {
    test('can convert back and forth to mutable', () {
      final src = Vector3(1, 2, 3);

      final immutable = src.immutable;
      expect(immutable.x, 1);
      expect(immutable.y, 2);
      expect(immutable.z, 3);
      expect(immutable.storage, [1, 2, 3]);

      final mutable = immutable.mutable;
      expect(mutable.x, 1);
      expect(mutable.y, 2);
      expect(mutable.z, 3);
    });

    test('can subtract immutable vector3', () {
      final a = Vector3(0, 10, 0).immutable;
      final b = Vector3(1, 2, 3);

      expect((a - b).storage, [-1, 8, -3]);
      expect((a - b.immutable).storage, [-1, 8, -3]);
    });

    test('can convert to Color', () {
      final src = Vector3(0.1, 0.2, 0.3);

      final color = src.toColor();
      expect(color.alpha, 255);
      expect(color.red, 26);
      expect(color.green, 51);
      expect(color.blue, 77);
    });
  });
}
