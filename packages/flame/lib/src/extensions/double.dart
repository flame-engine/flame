extension DoubleExtension on double {
  /// Converts +-[infinity] to +-[maxFinite].
  /// If it is already a finite value, that is returned.
  double toFinite() {
    if (this == double.infinity) {
      return double.maxFinite;
    } else if (this == -double.infinity) {
      return -double.maxFinite;
    } else {
      return this;
    }
  }
}
