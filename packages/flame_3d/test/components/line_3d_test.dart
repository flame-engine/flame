import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/components/line_3d.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Line 3D Mesh Component', () {
    test('can create line', () {
      final line = Line3D.generate(
        start: Vector3(0, -1, 0),
        end: Vector3(0, 1, 0),
        color: const Color(0xFFFFFFFF),
      );

      expect(
        line.transform.transformMatrix,
        equals(Matrix4.identity()),
      );
    });
  });
}
