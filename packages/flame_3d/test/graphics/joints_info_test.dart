import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/graphics/joints_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JointsInfo', () {
    test('selects the joints of a surface', () {
      final joints = [Matrix4.identity()];
      final info = JointsInfo()..jointTransformsPerSurface = {1: joints};

      info.setSurface(1);

      expect(info.jointTransforms, same(joints));
    });

    test('has no joints for a surface without joints', () {
      final info = JointsInfo()
        ..jointTransformsPerSurface = {
          1: [Matrix4.identity()],
        }
        ..setSurface(2);

      expect(info.jointTransforms, isEmpty);
    });
  });
}
