import 'dart:typed_data';

import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/signed_area.dart';
import 'package:meta/meta.dart';

/// Traces the outlines of the areas of a region of [pixels] whose alpha is at
/// least the [threshold], and returns them as the closed contours of a [Path].
///
/// The [pixels] are in the RGBA format, row by row, and the image is [width]
/// pixels wide. The region starts at [left] and [top] and it is [columns]
/// pixels wide and [rows] pixels high. The contours are in the coordinates of
/// the region, where each pixel is a square of side one, multiplied by the
/// [scaleX] and the [scaleY].
///
/// The outlines are found with marching squares on the alpha of the pixel
/// centers, so they cross between two pixels where the alpha would reach the
/// [threshold] if it changed linearly between them, and they stay within the
/// region. Only the outer outlines are kept, not the ones of the holes, and
/// each of them goes clockwise in the screen coordinate system.
@internal
Path traceAlphaContours(
  Uint8List pixels, {
  required int width,
  required int left,
  required int top,
  required int columns,
  required int rows,
  required double threshold,
  double scaleX = 1.0,
  double scaleY = 1.0,
}) {
  final path = Path();
  if (columns <= 0 || rows <= 0) {
    return path;
  }
  // The samples are the pixels of the region with a transparent border around
  // them, so that every outline is closed.
  final gridWidth = columns + 2;
  final gridHeight = rows + 2;

  /// The alpha of the pixel at the [sample], which is zero on the border.
  double alphaAt(int sample) {
    final x = sample % gridWidth - 1;
    final y = sample ~/ gridWidth - 1;
    if (x < 0 || y < 0 || x >= columns || y >= rows) {
      return 0;
    }
    return pixels[((top + y) * width + left + x) * 4 + 3] / 255;
  }

  // Whether each sample is inside, which is all that the scan of the cells
  // needs, while the alpha itself is only read along the outlines. The
  // smallest alpha that is inside is found with the same comparison that the
  // alpha of a sample would go through.
  var minAlpha = 0;
  while (minAlpha < 256 && minAlpha / 255 < threshold) {
    minAlpha++;
  }
  final inside = Uint8List(gridWidth * gridHeight);
  for (var y = 0; y < rows; y++) {
    final pixel = ((top + y) * width + left) * 4 + 3;
    final sample = (y + 1) * gridWidth + 1;
    for (var x = 0; x < columns; x++) {
      if (pixels[pixel + x * 4] >= minAlpha) {
        inside[sample + x] = 1;
      }
    }
  }

  // An edge joins a sample with the one at its right (2 * sample) or with the
  // one below it (2 * sample + 1). Each crossed edge starts one segment of an
  // outline, which ends at the edge stored here, and it ends another one. Only
  // the edges along the outlines are stored, in the order they are found in,
  // which is also the order of the [starts].
  final next = <int, int>{};
  final starts = <int>[];
  // The edges of a cell in clockwise order, where the edge at an index goes
  // from the corner at that index to the following one, and the corners are
  // the bits of the cell in the same order.
  final edges = Int32List(4);
  final crossed = Int32List(4);
  for (var y = 0; y < gridHeight - 1; y++) {
    final row = y * gridWidth;
    // The left corners of a cell are the right corners of the previous one.
    var topLeftBit = inside[row];
    var bottomLeftBit = inside[row + gridWidth];
    for (var x = 0; x < gridWidth - 1; x++) {
      final topLeft = row + x;
      final topRightBit = inside[topLeft + 1];
      final bottomRightBit = inside[topLeft + gridWidth + 1];
      final cell =
          topLeftBit |
          topRightBit << 1 |
          bottomRightBit << 2 |
          bottomLeftBit << 3;
      topLeftBit = topRightBit;
      bottomLeftBit = bottomRightBit;
      if (cell == 0 || cell == 15) {
        continue;
      }
      edges[0] = 2 * topLeft;
      edges[1] = 2 * (topLeft + 1) + 1;
      edges[2] = 2 * (topLeft + gridWidth);
      edges[3] = 2 * topLeft + 1;
      var count = 0;
      for (var i = 0; i < 4; i++) {
        if ((cell >> i & 1) != (cell >> (i + 1) % 4 & 1)) {
          crossed[count++] = i;
        }
      }
      // A segment goes from where the clockwise walk around the cell leaves
      // the inside to where it enters it again, so that the inside is on its
      // right. When the inside corners are opposite, the alpha at the center
      // decides whether they are joined, by cutting off the outside corners,
      // or apart: the segments then end at the next or at the previous
      // crossing, which are the same one in the other cases.
      final joined =
          count == 4 &&
          (alphaAt(topLeft) +
                      alphaAt(topLeft + 1) +
                      alphaAt(topLeft + gridWidth + 1) +
                      alphaAt(topLeft + gridWidth)) /
                  4 >=
              threshold;
      for (var i = 0; i < count; i++) {
        final edge = crossed[i];
        if (cell >> edge & 1 == 1) {
          final end = joined
              ? crossed[(i + 1) % count]
              : crossed[(i + count - 1) % count];
          next[edges[edge]] = edges[end];
          starts.add(edges[edge]);
        }
      }
    }
  }

  Offset crossing(int edge) {
    final sample = edge >> 1;
    final other = edge.isEven ? sample + 1 : sample + gridWidth;
    final alpha = alphaAt(sample);
    final t = (threshold - alpha) / (alphaAt(other) - alpha);
    // The sample at (1, 1) is the center of the first pixel of the region,
    // while the samples of the border are half a pixel outside of it, so the
    // crossings on their edges are kept within the region.
    final x = sample % gridWidth - 0.5 + (edge.isEven ? t : 0);
    final y = sample ~/ gridWidth - 0.5 + (edge.isEven ? 0 : t);
    return Offset(
      x.clamp(0, columns).toDouble() * scaleX,
      y.clamp(0, rows).toDouble() * scaleY,
    );
  }

  for (final start in starts) {
    if (!next.containsKey(start)) {
      continue;
    }
    final points = <Offset>[];
    int? edge = start;
    do {
      points.add(crossing(edge!));
      edge = next.remove(edge);
    } while (edge != start && edge != null);
    final outline = _withoutCollinear(_withoutDuplicates(points));
    // The outer outlines have the inside on their right, so they go clockwise
    // on the screen, while the outlines of the holes go counterclockwise.
    if (outline.length >= 3 &&
        signedArea([for (final point in outline) point.toVector2()]) > 0) {
      path.addPolygon(outline, true);
    }
  }
  return path;
}

/// Removes the points of the closed outline that are the same as the previous
/// one, which happens where the alpha of a pixel is exactly the threshold:
/// the outline then passes through the center of the pixel, where all the
/// edges of the pixel are crossed.
List<Offset> _withoutDuplicates(List<Offset> points) {
  final result = <Offset>[];
  for (final point in points) {
    if (result.isEmpty || result.last != point) {
      result.add(point);
    }
  }
  while (result.length > 1 && result.last == result.first) {
    result.removeLast();
  }
  return result;
}

/// Removes the points of the closed outline that are in the middle of a
/// straight stretch, like the ones along the sides of the pixels. The outline
/// must not have consecutive duplicate points, since both of them would be
/// removed.
List<Offset> _withoutCollinear(List<Offset> points) {
  final count = points.length;
  return [
    for (var i = 0; i < count; i++)
      if (!_isCollinear(
        points[(i + count - 1) % count],
        points[i],
        points[(i + 1) % count],
      ))
        points[i],
  ];
}

/// Whether the [point] is on the line through the [previous] and the [next]
/// ones, within an angle of about 1e-9 radians, which doesn't depend on the
/// scale of the outline, unlike its area.
bool _isCollinear(Offset previous, Offset point, Offset next) {
  final firstDx = point.dx - previous.dx;
  final firstDy = point.dy - previous.dy;
  final secondDx = next.dx - point.dx;
  final secondDy = next.dy - point.dy;
  final cross = firstDx * secondDy - firstDy * secondDx;
  final squaredLengths =
      (firstDx * firstDx + firstDy * firstDy) *
      (secondDx * secondDx + secondDy * secondDy);
  return cross * cross <= 1e-18 * squaredLengths;
}
