import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  group('text box component test', () {
    test('size is properly computed', () async {
      final c = TextBoxComponent(
        'The quick brown fox jumps over the lazy dog.',
        boxConfig: TextBoxConfig(
          maxWidth: 100.0,
        ),
      );

      expect(c.size.x, 100 + 2 * 8);
      expect(c.size.y, greaterThan(1));
    });
  });
}
