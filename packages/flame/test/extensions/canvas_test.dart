import 'package:canvas_test/canvas_test.dart';
import 'package:flame/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Canvas extensions tests', () {
    test('renderPoint', () {
      final canvas = MockCanvas();
      canvas.renderPoint(Vector2.all(10.0), size: 2);
      expect(
        canvas,
        MockCanvas()..drawRect(const Rect.fromLTWH(9, 9, 2, 2)),
      );
    });
  });
}
