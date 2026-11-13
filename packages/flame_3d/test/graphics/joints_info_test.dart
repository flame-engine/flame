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

    test('reuses one empty list for surfaces without joints', () {
      final info = JointsInfo()..setSurface(0);
      final first = info.jointTransforms;
      info.setSurface(2);

      expect(first, isEmpty);
      expect(info.jointTransforms, same(first));
    });
  });
}
