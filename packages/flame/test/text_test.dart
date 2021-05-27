import 'package:flame/components.dart';
import 'package:test/test.dart';

void main() {
  group('Text', () {
    test('copyWith', () {
      const config = TextPaintConfig(fontSize: 12, fontFamily: 'Times');
      final tp = TextPaint(config: config)
          .copyWith((t) => t.withFontFamily('Helvetica'));
      expect(tp.config.fontSize, 12);
      expect(tp.config.fontFamily, 'Helvetica');
    });
  });
}
