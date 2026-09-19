import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/test_paths.dart';
import 'package:test/test.dart';

void main() {
  test('PathComponent roundRect preserves the path bounds', () {
    const size = Size(64, 64);
    final path = TestPaths.byName('roundRect', size);

    final pathComponent = PathComponent(path: path);

    expect(pathComponent.width, closeTo(size.width, 1e-10));
    expect(pathComponent.height, closeTo(size.height, 1e-10));
  });

  test('PathComponent flame preserves the path bounds', () {
    const size = Size(64, 64);
    final path = TestPaths.byName('flame', size);
    final pathSize = path.getBounds().size;

    final pathComponent = PathComponent(path: path);

    expect(pathComponent.width, pathSize.width);
    expect(pathComponent.height, pathSize.height);
  });

  test('PathComponent invader1 preserves the aspect ratio', () {
    const size = Size(64, 64);
    final path = TestPaths.byName('invader1', size);

    final invader1 = TestPaths.invader1();
    final invader1Size = invader1.getBounds().size;
    final scaleX = size.width / invader1Size.width;
    final scaleY = size.height / invader1Size.height;
    final scale = min(scaleX, scaleY);

    final pathComponent = PathComponent(path: path);
    expect(pathComponent.width, closeTo(invader1Size.width * scale, 1e-6));
    expect(pathComponent.height, closeTo(invader1Size.height * scale, 1e-6));
  });

  test('PathComponent invader2 keeps only one disjoint contour', () {
    const size = Size(64, 64);
    final path = TestPaths.byName('invader2', size);

    final pathComponent = PathComponent(path: path, addHitboxes: true);

    expect(pathComponent.children.length, 1);
  });

  test('PathComponent invader2 explicitly keeps all disjoint contours', () {
    const size = Size(64, 64);
    final path = TestPaths.byName('invader2', size);

    final pathComponent = PathComponent(
      path: path,
      addHitboxes: true,
      filterHitboxes: false,
    );

    expect(pathComponent.children.length, 3);
  });

  test('PathComponent alien2 implicitly keeps all disjoint contours', () {
    const size = Size(64, 64);
    final path = TestPaths.byName('alien2', size);

    final pathComponent = PathComponent(path: path, addHitboxes: true);

    expect(pathComponent.children.length, 4);
  });
}
