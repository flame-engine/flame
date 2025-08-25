import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Line 3D Mesh Component', () {
    test('can create vertical line', () {
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

    test('can create horizontal line', () {
      final line = Line3D.generate(
        start: Vector3(-1, 0, 0),
        end: Vector3(1, 0, 0),
        color: const Color(0xFFFFFFFF),
      );

      expect(
        line.transform.transformMatrix,
        closeToMatrix4(
          Matrix4.columns(
            Vector4(0, -1, 0, 0),
            Vector4(1, 0, 0, 0),
            Vector4(0, 0, 1, 0),
            Vector4(0, 0, 0, 1),
          ),
          10e-6,
        ),
      );
    });
  });
}
