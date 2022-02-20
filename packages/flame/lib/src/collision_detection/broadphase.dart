import 'package:meta/meta.dart';

import 'hitbox.dart';

abstract class Broadphase<T extends Hitbox<T>> {
  final List<T> items;

  Broadphase({List<T>? items}) : items = items ?? [];

  Set<Potential<T>> query();
}

@immutable
class Potential<T> {
  final T a;
  final T b;

  const Potential(this.a, this.b);

  @override
  bool operator ==(Object o) => o is Potential && o.a == a && o.b == b;

  @override
  int get hashCode => Object.hash(a.hashCode, b.hashCode);
}
