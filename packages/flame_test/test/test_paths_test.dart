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

    test('has a unique name for each path', () {
      expect(TestPaths.names.length, TestPaths.count);
      expect(TestPaths.names.toSet().length, TestPaths.count);
      expect(TestPaths.names.first, 'roundRect');
    });

    test('has names that can not be changed', () {
      expect(() => TestPaths.names.add('other'), throwsUnsupportedError);
    });

    test('finds every path by its name', () {
      const size = Size(100, 60);
      for (var index = 0; index < TestPaths.count; index++) {
        expect(
          TestPaths.byName(TestPaths.names[index], size).getBounds(),
          TestPaths.byIndex(index, size).getBounds(),
          reason: TestPaths.names[index],
        );
      }
    });

    test('has closed contours in every path', () {
      for (var index = 0; index < TestPaths.count; index++) {
        final path = TestPaths.byIndex(index, const Size(100, 60));
        expect(
          path.computeMetrics().any((metric) => metric.isClosed),
          isTrue,
          reason: TestPaths.names[index],
        );
      }
    });

    test('scales the paths with the size', () {
      final small = TestPaths.byIndex(1, const Size.square(50)).getBounds();
      final large = TestPaths.byIndex(1, const Size.square(200)).getBounds();
      expect(large.width, closeTo(small.width * 4, 1e-3));
      expect(large.height, closeTo(small.height * 4, 1e-3));
    });

    group('roundRect', () {
      const size = Size(100, 60);

      test('has the given size', () {
        final path = TestPaths.roundRect(size);
        expect(path.getBounds(), Offset.zero & size);
        expect(path.computeMetrics().single.isClosed, isTrue);
      });

      test('has rounded corners', () {
        final path = TestPaths.roundRect(size);
        expect(path.contains(const Offset(50, 30)), isTrue);
        expect(path.contains(const Offset(0.5, 0.5)), isFalse);
      });
    });

    group('shapes', () {
      final shapes = <String, Path Function()>{
        'flame': TestPaths.flame,
        'invader1': TestPaths.invader1,
        'invader2': TestPaths.invader2,
        'invader3': TestPaths.invader3,
        'clover': TestPaths.clover,
        'abstractShape': TestPaths.abstractShape,
        'alien1': TestPaths.alien1,
        'alien2': TestPaths.alien2,
        'setup': TestPaths.setup,
        'recycle': TestPaths.recycle,
      };

      shapes.forEach((name, build) {
        test('$name is not empty', () {
          final bounds = build().getBounds();
          expect(bounds.width, greaterThan(0));
          expect(bounds.height, greaterThan(0));
        });
      });
    });
  });
}
