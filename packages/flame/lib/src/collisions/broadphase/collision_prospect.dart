import 'dart:math';

import 'package:meta/meta.dart';

/// A [CollisionProspect] is an immutable view of a pair of two potentially
/// colliding hitboxes.
///
/// Equality is based on unordered pair identity: {A, B} == {B, A}.
@immutable
abstract class CollisionProspect<T> {
  T get a;
  T get b;

  @override
  int get hashCode {
    final h1 = a.hashCode;
    final h2 = b.hashCode;
    return Object.hash(min(h1, h2), max(h1, h2));
  }

  @override
  bool operator ==(Object other) {
    if (other is! CollisionProspect) {
      return false;
    }
    return (identical(a, other.a) && identical(b, other.b)) ||
        (identical(a, other.b) && identical(b, other.a));
  }
}
