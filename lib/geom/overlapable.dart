/// This represents shapes that can overlap one another.
///
/// They must implement the [overlaps] method to tell whether there are overlaps or not.
mixin Overlapable {
  /// Whether two [Overlapable] collide (overlaps) with one another.
  ///
  /// This should be transitive (a.overlaps(b) == b.overlaps(a)) (all implementations must comply).
  /// Some implementations of [Overlapable] might delegate this to others by swapping the parameter and callee.
  bool overlaps(Overlapable o);
}

/// This mock implementation always overlaps with anything. fackri
///
/// Useful for edge cases in methods that return or receive [Overlapable] objects.
class CertainOverlap with Overlapable {
  @override
  bool overlaps(Overlapable o) => true;
}
