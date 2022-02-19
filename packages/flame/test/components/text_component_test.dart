import 'package:flame/src/components/text_component.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('TextComponent', () {
    test('text component size is set', () {
      final t = TextComponent(text: 'foobar');
      expect(t.size, isNot(equals(Vector2.zero())));
    });
  });
}
