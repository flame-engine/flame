/// Defines how MockCanvas#matches behaves.
enum AssertionMode {
  /// Actual and expected must match exactly in nature and order.
  ///
  /// This is implemented by MockCanvas#matchExactly.
  matchExactly,

  /// All elements on expect must match to at least one element on actual,
  /// regardless of order.
  ///
  /// This is implemented by MockCanvas#containsAnyOrder.
  containsAnyOrder,
}
