import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/geometry/collision_detection.dart'
    as CollisionDetectionFunction;
import 'package:test/test.dart';

class _TestBlock extends PositionComponent with Hitbox, Collidable {
  Set<Collidable> onCollidables = {};
  Set<Collidable> cacheCollidables = {};
  _TestBlock() {
    addShape(
      HitboxCircle(),
    );
  }
  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    onCollidables.add(other);
    super.onCollision(points, other);
  }
}

class _TestBlockA extends _TestBlock {
  _TestBlockA(Vector2 pos, Vector2 size) {
    activeCollidable = false;
    position = pos;
    this.size = size;
  }
}

class _TestBlockB extends _TestBlock {
  _TestBlockB(Vector2 pos, Vector2 size) {
    activeCollidable = true;
    position = pos;
    this.size = size;
  }
}

void _standardCollisionDetection(List<Collidable> collidables) {
  for (var x = 0; x < collidables.length; x++) {
    final collidableX = collidables[x];
    for (var y = x + 1; y < collidables.length; y++) {
      final collidableY = collidables[y];
      final points =
          CollisionDetectionFunction.intersections(collidableX, collidableY);
      if (points.isNotEmpty) {
        collidableX.onCollision(points, collidableY);
        collidableY.onCollision(points, collidableX);
      }
    }
  }
}

void main() {
  group('collision_detection_make_activity', () {
    test('Activity Marker is no empty tests', () {
      final tba = _TestBlockB(Vector2(0, 0), Vector2(10, 10));
      final tbb = _TestBlockB(Vector2(0, 0), Vector2(10, 10));
      final tbc = _TestBlockB(Vector2(0, 0), Vector2(10, 10));
      final tbs = [tba, tbb, tbc];
      _standardCollisionDetection(tbs);
      tbs.forEach((element) {
        element.cacheCollidables = element.onCollidables;
      });
      CollisionDetectionFunction.collisionDetection(tbs);
      tbs.forEach((element) {
        expect(element.cacheCollidables.isNotEmpty, true);
        expect(element.onCollidables.isNotEmpty, true);
      });
    });
    test('Activity Marker tests', () {
      final size = Vector2(5, 5);
      final vList = <Vector2>[];
      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 10; x++) {
          vList.add(Vector2(x.toDouble(), y.toDouble()));
        }
      }

      final cList = vList.map((e) {
        switch (e.x.toInt() % 4) {
          case 0:
          case 1:
            return _TestBlockA(e, size);

          case 2:
          case 3:
            return _TestBlockB(e, size);
        }
      }).toList();
      cList.shuffle();
      _standardCollisionDetection(cList);
      cList.forEach((element) {
        element.cacheCollidables = element.onCollidables;
      });
      CollisionDetectionFunction.collisionDetection(cList);
      cList.where((element) {
        return element.activeCollidable;
      }).forEach((element) {
        expect(
          element.cacheCollidables.length == element.onCollidables.length,
          true,
        );

        expect(
          (<Collidable>{}
                    ..addAll(element.cacheCollidables)
                    ..addAll(element.onCollidables))
                  .length ==
              element.onCollidables.length,
          true,
        );
      });
    });

    test('No Activity Marker tests', () {
      final size = Vector2(5, 5);
      final vList = <Vector2>[];
      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 10; x++) {
          vList.add(Vector2(x.toDouble(), y.toDouble()));
        }
      }

      final cList = vList.map((e) {
        switch (e.x.toInt() % 4) {
          case 0:
          case 1:
          case 2:
          case 3:
            return _TestBlockB(e, size);
        }
      }).toList();
      cList.shuffle();
      _standardCollisionDetection(cList);
      cList.forEach((element) {
        element.cacheCollidables = element.onCollidables;
      });
      CollisionDetectionFunction.collisionDetection(cList);
      cList.where((element) {
        return element.activeCollidable;
      }).forEach((element) {
        expect(
          element.cacheCollidables.length == element.onCollidables.length,
          true,
        );

        expect(
          (<Collidable>{}
                    ..addAll(element.cacheCollidables)
                    ..addAll(element.onCollidables))
                  .length ==
              element.onCollidables.length,
          true,
        );
      });
    });

    test('Random Activity Marker tests', () {
      final size = Vector2(5, 5);
      final vList = <Vector2>[];
      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 10; x++) {
          vList.add(Vector2(
            x.toDouble() * Random().nextInt(4),
            y.toDouble() * Random().nextInt(4),
          ));
        }
      }
      final cList = vList.map((e) {
        switch (e.x.toInt() % 4) {
          case 0:
          case 1:
            return _TestBlockA(e, size);
          case 2:
          case 3:
            return _TestBlockB(e, size);
        }
      }).toList();
      cList.shuffle();
      _standardCollisionDetection(cList);
      cList.forEach((element) {
        element.cacheCollidables = element.onCollidables;
      });
      CollisionDetectionFunction.collisionDetection(cList);
      cList.where((element) {
        return element.activeCollidable;
      }).forEach((element) {
        expect(
          element.cacheCollidables.length == element.onCollidables.length,
          true,
        );
        expect(
          (<Collidable>{}
                    ..addAll(element.cacheCollidables)
                    ..addAll(element.onCollidables))
                  .length ==
              element.onCollidables.length,
          true,
        );
      });
    });
  });
}
