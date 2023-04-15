extension ListExtension<E> on List<E> {
  /// Reverses the list in-place.
  void reverse() {
    for (var i = 0, j = length - 1; i < j; i++, j--) {
      final temp = this[i];
      this[i] = this[j];
      this[j] = temp;
    }
  }
}
