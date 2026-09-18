import 'dart:math';
import 'dart:ui';

import 'package:examples/commons/paths.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';

mixin PathsCreationMixin on FlameGame {
  final random = Random();

  var _lastRandom = -1;
  int get nextRandomPath {
    var index = random.nextIntBetween(0, TestPaths.count);
    while (index == _lastRandom) {
      index = random.nextIntBetween(0, TestPaths.count);
    }
    _lastRandom = index;
    return index;
  }

  Vector2 randomPosition(Size dimension) {
    final rnd = Vector2.random();
    final half = dimension * 0.5;
    return Vector2(
          rnd.x * (size.x - dimension.width),
          rnd.y * (size.y - dimension.height),
        ) +
        half.toVector2();
  }

  void addFixedPaths(Paint paint) {
    add(
      CircleComponent(
        position: Vector2(100, 100),
        radius: 50,
        paint: paint,
        children: [CircleHitbox()],
      ),
    );
    add(
      CircleComponent(
        position: Vector2(150, 500),
        radius: 50,
        paint: paint,
        children: [CircleHitbox()],
      ),
    );
    add(
      RectangleComponent(
        position: Vector2.all(300),
        size: Vector2.all(100),
        paint: paint,
        children: [RectangleHitbox()],
      ),
    );
    add(
      RectangleComponent(
        position: Vector2.all(500),
        size: Vector2(100, 200),
        paint: paint,
        children: [RectangleHitbox()],
      ),
    );
    add(
      RectangleComponent(
        position: Vector2(550, 200),
        size: Vector2(200, 150),
        paint: paint,
        children: [RectangleHitbox()],
      ),
    );
  }

  void addTestPaths(
    Paint paint, {
    int numPaths = 5,
    bool renderHitboxes = false,
  }) {
    const pathSize = Size.square(100);
    for (var index = 0; index < numPaths; ++index) {
      final pathIndex = nextRandomPath;
      add(
        pathComponent(
          pathIndex,
          const Size.square(100),
          position: randomPosition(pathSize),
          paint: paint,
          renderHitboxes: renderHitboxes,
        ),
      );
    }
  }
}
