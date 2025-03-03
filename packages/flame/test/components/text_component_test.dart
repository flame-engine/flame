import 'package:flame/src/components/text_component.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('TextComponent', () {
    test('sets the size of the text component', () {
      final t = TextComponent(text: 'foobar');
      expect(t.size, isNot(equals(Vector2.zero())));
    });
  });
}
