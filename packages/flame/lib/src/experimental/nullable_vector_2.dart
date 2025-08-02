class NullableVector2 {
  NullableVector2(this.x, this.y);

  double? x;
  double? y;

  /// Access the component of the vector at the index [i].
  double? operator [](int i) {
    if (i == 0) {
      return x;
    } else if (i == 1) {
      return y;
    } else {
      throw Exception('Unsupported index: $i');
    }
  }

  /// Set the component of the vector at the index [i].
  void operator []=(int i, double v) {
    if (i == 0) {
      x = v;
    } else if (i == 1) {
      y = v;
    } else {
      throw Exception('Unsupported index: $i');
    }
  }
}
