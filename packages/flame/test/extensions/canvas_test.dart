import 'package:flame/extensions.dart';
import 'package:flame/test.dart';
import 'package:test/test.dart';

void main() {
  group('Canvas extensions tests', () {
    test('renderPoint', () {
      final canvas = MokkCanvas();
      canvas.renderPoint(Vector2.all(10.0), size: 2);
      expect(
        canvas,
        MokkCanvas()..drawRect(const Rect.fromLTWH(9, 9, 2, 2)),
      );
    });
  });
}
