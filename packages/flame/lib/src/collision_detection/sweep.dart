import 'broadphase.dart';
import 'collision_callbacks.dart';
import 'hitboxes/hitbox.dart';

class Sweep<T extends Hitbox<T>> extends Broadphase<T> {
  Sweep({List<T>? items}) : super(items: items);

  final List<T> _active = [];
  final Set<Potential<T>> _potentials = {};

  @override
  Set<Potential<T>> query() {
    _active.clear();
    _potentials.clear();
    items.sort((a, b) => (a.aabb.min.x - b.aabb.min.x).ceil());
    for (final item in items) {
      if (item.collidableType == CollidableType.inactive) {
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
          if (item.collidableType == CollidableType.active ||
              activeItem.collidableType == CollidableType.active) {
            _potentials.add(Potential<T>(item, activeItem));
          }
        } else {
          _active.remove(activeItem);
        }
      }
      _active.add(item);
    }
    return _potentials;
  }
}
