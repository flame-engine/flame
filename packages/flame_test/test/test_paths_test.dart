import 'dart:ui';

import 'package:flame_test/test_paths.dart';
import 'package:test/test.dart';

void main() {
  group('TestPaths', () {
    test('fits every path into the size and centers it', () {
      const size = Size(100, 60);
      for (var index = 0; index < TestPaths.count; index++) {
        final bounds = TestPaths.byIndex(index, size).getBounds();
        expect(bounds.center.dx, closeTo(0, 1e-3), reason: 'path $index');
        expect(bounds.center.dy, closeTo(0, 1e-3), reason: 'path $index');
        expect(bounds.width, lessThanOrEqualTo(size.width + 1e-3));
        expect(bounds.height, lessThanOrEqualTo(size.height + 1e-3));
        expect(
          bounds.width > size.width - 1e-3 ||
              bounds.height > size.height - 1e-3,
          isTrue,
          reason: 'path $index should touch the size on one side',
        );
      }
    });

    test('finds paths by name', () {
      const size = Size(50, 50);
      expect(
        TestPaths.byName('flame', size).getBounds(),
        TestPaths.byIndex(1, size).getBounds(),
      );
      expect(() => TestPaths.byName('unknown', size), throwsArgumentError);
      expect(() => TestPaths.byIndex(TestPaths.count, size), throwsRangeError);
    });
  });
}
