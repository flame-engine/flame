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
    test('createDefault', () {
      final tp = TextRenderer.createDefault<TextPaint>();
      expect(tp, isNotNull);
      expect(tp, isA<TextPaint>());

      final tr = TextRenderer.createDefault();
      expect(tr, isNotNull);
      expect(tr, isA<TextRenderer>());
    });
    test('change parameters of text component', () {
      final tc = TextComponent<TextPaint>('foo');
      tc.textRenderer = tc.textRenderer.copyWith((c) => c.withFontSize(200));
      expect(tc.textRenderer.config.fontSize, 200);
    });
  });
}
