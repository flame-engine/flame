extension IntRangeExtensions on int {
  /// Generates an Iterable of ints from this int to [to] (exclusive).
  Iterable<int> to(int to) sync* {
    for (var i = this; i < to; i++) {
      yield i;
    }
  }
}
