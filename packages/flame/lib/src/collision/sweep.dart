import '../../components.dart';
import 'broadphase.dart';
import 'tuple.dart';

class Sweep<T> extends Broadphase<T> {
  Sweep(List<CollisionItem<T>> items) : super(items);

  final List<CollisionItem<T>> _active = [];
  final List<Potential<T>> _potentials = [];

  @override
  Iterable<Potential<T>> query() {
    _active.clear();
    _potentials.clear();
    items.sort((a, b) => (a.aabb.min.x - b.aabb.min.x).ceil());
    for (final item in items) {
      if (_active.isEmpty) {
        _active.add(item);
        continue;
      }
      final currentBox = item.aabb;
      final currentMin = currentBox.min.x;
      for (var i = _active.length - 1; i > 0; i--) {
        final activeItem = _active[i];
        final activeBox = activeItem.aabb;
        if (activeBox.max.x >= currentMin) {
          if (item.type == CollidableType.active ||
              activeItem.type == CollidableType.active) {
            _potentials.add(Potential<T>(item.content, activeItem.content));
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
