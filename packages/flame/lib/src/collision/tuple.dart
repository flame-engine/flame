import 'package:meta/meta.dart';

import '../../components.dart';

abstract class CollisionItem {
  Aabb2 get aabb;
  CollidableType get collidableType;
}

@immutable
class Potential<T> {
  final T a;
  final T b;

  const Potential(this.a, this.b);
}
