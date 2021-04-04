import 'package:flame/extensions.dart';
import 'package:test/test.dart';

import '../util/mock_canvas.dart';

void main() {
  group('Canvas extensions tests', () {
    test('renderPoint', () {
      final canvas = MockCanvas();
      canvas.renderPoint(Vector2.all(10.0), size: 2);
      expect(
        canvas.methodCalls,
        contains('drawRect(9.0, 9.0, 2.0, 2.0)'),
      );
    });
  });
}
