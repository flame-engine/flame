import 'package:example/main.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('flame_test', () {
    test('can test vector2', () {
      final changer = MyVectorChanger();
      final vector = Vector2.all(1.0);
      final changedVector = changer.addOne(vector);
      expectVector2(vector + Vector2.all(1.0), changedVector);
      expectVector2(vector + Vector2.all(1.1), changedVector, epsilon: 0.2);
    });

    test('can test double', () {
      final changer = MyDoubleChanger();
      const one = 1.0;
      final two = changer.addOne(one);
      expectDouble(one + 1.0, two);
      expectDouble(one + 1.1, two, epsilon: 0.11);
    });
  });
}
