import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('expectVector2', () {
    test('can test vector2', () {
      final vector = Vector2.all(1.0);
      expectVector2(vector + Vector2.all(1.0), Vector2.all(2.0));
      expectVector2(vector + Vector2.all(1.1), Vector2.all(2.0), epsilon: 0.2);
    });
  });
}
