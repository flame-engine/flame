import 'package:flame/collisions.dart';

class Sweep<T extends Hitbox<T>> extends Broadphase<T> {
  Sweep({super.items, this.broadphaseCheck});

  late final List<T> _active = [];
  late final Set<CollisionProspect<T>> _potentials = {};
  final _potentialsTmp = <List<T>>[];

  ExternalBroadphaseCheck? broadphaseCheck;
  final _broadphaseCheckCache = <T, Map<T, bool>>{};

  @override
  void update() {
    items.sort((a, b) => a.aabb.min.x.compareTo(b.aabb.min.x));
  }

  @override
  Set<CollisionProspect<T>> query() {
    _active.clear();
    _potentials.clear();
    for (final item in items) {
      if (item.collisionType == CollisionType.inactive) {
        continue;
      }
      if (_active.isEmpty) {
        _active.add(item);
        continue;
      }
      final currentBox = item.aabb;
      final currentMin = currentBox.min.x;
      for (var i = _active.length - 1; i >= 0; i--) {
        final activeItem = _active[i];
        final activeBox = activeItem.aabb;
        if (activeBox.max.x >= currentMin) {
          if (item.collisionType == CollisionType.active ||
              activeItem.collisionType == CollisionType.active) {
            // _potentials.add(CollisionProspect<T>(item, activeItem));

            _potentialsTmp.add([item, activeItem]);
          }
        } else {
          _active.remove(activeItem);
        }
      }
      _active.add(item);
    }
    if (_potentialsTmp.isNotEmpty) {
      for (var i = 0; i < _potentialsTmp.length; i++) {
        final item0 = _potentialsTmp[i].first;
        final item1 = _potentialsTmp[i].last;
        final checkFunction = broadphaseCheck;
        var checkSuccess = false;
        if (checkFunction != null &&
            item0 is ShapeHitbox &&
            item1 is ShapeHitbox) {
          final asShapeHitbox0 = item0 as ShapeHitbox;
          final asShapeHitbox1 = item1 as ShapeHitbox;
          checkSuccess = checkFunction(asShapeHitbox0, asShapeHitbox1);
          if (checkSuccess) {
            _potentials.add(CollisionProspect(item0, item1));
          }
        }

        if (!checkSuccess) {
          if (_broadphaseCheckCache[item0] == null) {
            _broadphaseCheckCache[item0] = {};
          }
          _broadphaseCheckCache[item0]![item1] = false;
        }
      }
    }
    return _potentials;
  }
}
