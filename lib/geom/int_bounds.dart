import 'int_rect.dart';
import 'overlapable.dart';

///
/// This is an [Overlapable] composed of an arbitrary union of rects.
///
/// If any of the rects overlaps, this overlaps.
class IntBounds with Overlapable {
  List<IntRect> rects;

  /// Creates this with a list of [IntRect].
  ///
  /// This shape represents the union of those rectangles.
  IntBounds(this.rects);

  /// Creates this from a single [IntRect]
  IntBounds.fromRect(IntRect rect) : rects = [rect];

  @override
  bool overlaps(Overlapable target) {
    if (target is IntRect) {
      return rects.any((r) => r.overlaps(target));
    } else if (target is IntBounds) {
      return rects.any((r1) => target.rects.any((r2) => r1.overlaps(r2)));
    } else if (target is CertainOverlap) {
      return true;
    } else {
      throw 'unknown Overlapable: ${target.runtimeType}';
    }
  }
}
