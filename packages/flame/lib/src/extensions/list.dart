import 'dart:math';

import 'package:flame/math.dart';

extension ListExtension<E> on List<E> {
  /// Reverses the list in-place.
  void reverse() {
    for (var i = 0, j = length - 1; i < j; i++, j--) {
      final temp = this[i];
      this[i] = this[j];
      this[j] = temp;
    }
  }

  /// Returns a random element from the list.
  E random([Random? random]) {
    assert(isNotEmpty, "Can't get a random element from an empty list");
    final randomGenerator = random ?? randomFallback;
    return this[randomGenerator.nextInt(length)];
  }
}
