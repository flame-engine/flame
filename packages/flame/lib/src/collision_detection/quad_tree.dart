import '../../extensions.dart';

class QuadTree<T> {
  final Aabb2 boundingBox;
  final Map<T, Aabb2> content = {};
  final int capacity;

  QuadTree<T>? northWest;
  QuadTree<T>? northEast;
  QuadTree<T>? southWest;
  QuadTree<T>? southEast;

  QuadTree(this.boundingBox, {this.capacity = 8});

  bool get hasChildren {
    return northWest != null ||
        northEast != null ||
        southWest != null ||
        southEast != null;
  }

  void insert(Aabb2 box, T value) {
    if (boundingBox.intersectsWithAabb2(box)) {
      content[value] = box;
    }
  }

  void remove(T key) {
    content.remove(key);
    northWest?.remove(key);
    northEast?.remove(key);
    southWest?.remove(key);
    southEast?.remove(key);
  }

  void split() {}

  Set<T> query(Aabb2 aabb) {
    return {};
  }
}
