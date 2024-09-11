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

    test('can lerp', () {
      final a = Vector4(1, 2, 3, 4);
      final b = Vector4(3, 4, 5, 6);

      final result = Vector4Extension.lerp(a, b, 0.5);
      expect(result.x, 2);
      expect(result.y, 3);
      expect(result.z, 4);
      expect(result.w, 5);
    });
  });
}
