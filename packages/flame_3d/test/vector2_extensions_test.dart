import 'package:flame_3d/extensions.dart';
import 'package:flame_3d/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Vector2 extensions', () {
    test('can convert back and forth to mutable', () {
      final src = Vector2(1, 2);

      final immutable = src.immutable;
      expect(immutable.x, 1);
      expect(immutable.y, 2);
      expect(immutable.storage, [1, 2]);

      final mutable = immutable.mutable;
      expect(mutable.x, 1);
      expect(mutable.y, 2);
    });
  });
}