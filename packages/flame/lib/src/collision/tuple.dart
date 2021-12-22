import 'package:meta/meta.dart';

import '../../components.dart';

@immutable
class CollisionItem<T> {
  final T content;
  final Aabb2 aabb;
  final CollidableType type;

  const CollisionItem(this.content, this.aabb, this.type);
}

@immutable
class Potential<T> {
  final T a;
  final T b;

  const Potential(this.a, this.b);
}
