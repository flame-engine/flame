import 'dart:ui';

/// A simple solution to packing a series of rectangles into a larger bin.
///
/// Packing different rectangles in the smallest area possible is an
/// NP-Complete problem. We are not going for perfection here, just something
/// that works.
///
/// Light reading:
///   * https://en.wikipedia.org/wiki/Rectangle_packing#Packing_different_rectangles_in_a_minimum-area_rectangle
///   * https://www.david-colson.com/2020/03/10/exploring-rect-packing.html
class RectangleBinPacker {
  final double maxX;
  final double maxY;

  /// The bins of free space that we can search.
  late final List<Rect> bins = [Rect.fromLTWH(0, 0, maxX, maxY)];

  RectangleBinPacker(this.maxX, this.maxY);

  /// Finds a free space for a rectangle of lengths [width] and [height] in
  /// the atlas.
  Rect pack(double width, double height) {
    // Search the list of bins for the first one that can hold this rectangle.
    Rect? search;
    for (search in bins) {
      if (search.width >= width && search.height >= height) {
        // found one!
        break;
      }
    }
    // If we exhausted our search, return an empty rect.
    if (search == null || search.width < width || search.height < height) {
      assert(
        false,
        '''RectangleBinPacker failed to pack an image. Consider using a bigger atlas if you are sure that your target platform can handle it.''',
      );
      return Rect.zero;
    }

    // If we found one, record the found rectangle position and replace the
    // bin with left over spaces (could be zero, 1, or two rectangles).
    bins.remove(search);
    final found = Rect.fromLTWH(search.left, search.top, width, height);
    if (found == search) {
      return found;
    }

    if (found.height != search.height) {
      final newRect = Rect.fromLTRB(
        search.left,
        found.bottom,
        search.right,
        search.bottom,
      );
      bins.add(newRect);
    }
    if (found.width != search.width) {
      final newRect = Rect.fromLTRB(
        found.right,
        search.top,
        search.right,
        found.bottom,
      );
      bins.add(newRect);
    }
    bins.sort(_compare);
    return found;
  }

  /// Comparator function used to sort rectangles in a stable fashion.
  int _compare(Rect a, Rect b) {
    final height = a.height - b.height;
    return (height != 0 ? height : a.width - b.width).toInt();
  }
}
