import 'package:flame_3d/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShadowGroup', () {
    test('holds the worlds that join it, in order', () {
      final group = ShadowGroup();
      final a = World3D();
      final b = World3D();
      expect(group.worlds, isEmpty);
      a.shadowGroup = group;
      b.shadowGroup = group;
      expect(group.worlds, [a, b]);
      expect(a.shadowGroup, same(group));
      // Joining again changes nothing.
      a.shadowGroup = group;
      expect(group.worlds, [a, b]);
      expect(() => group.worlds.add(a), throwsUnsupportedError);
    });

    test('a world leaves its group, or moves to another', () {
      final first = ShadowGroup();
      final second = ShadowGroup();
      final a = World3D()..shadowGroup = first;
      final b = World3D()..shadowGroup = first;
      a.shadowGroup = second;
      expect(first.worlds, [b]);
      expect(second.worlds, [a]);
      b.shadowGroup = null;
      expect(first.worlds, isEmpty);
      expect(b.shadowGroup, isNull);
    });
  });
}
