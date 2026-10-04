import 'dart:typed_data';
import 'dart:ui';

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
/// [threshold] if it changed linearly between them. Only the outer outlines
/// are kept, not the ones of the holes, and each of them goes clockwise in
/// the screen coordinate system.
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
  // The alpha of the region with a transparent border around it, so that
  // every outline is closed.
  final gridWidth = columns + 2;
  final gridHeight = rows + 2;
  final alpha = Float64List(gridWidth * gridHeight);
  for (var y = 0; y < rows; y++) {
    final pixel = (top + y) * width + left;
    final sample = (y + 1) * gridWidth + 1;
    for (var x = 0; x < columns; x++) {
      alpha[sample + x] = pixels[(pixel + x) * 4 + 3] / 255;
    }
  }

  // An edge joins a sample with the one at its right (2 * sample) or with the
  // one below it (2 * sample + 1). Each crossed edge starts one segment of an
  // outline, which ends at the edge stored here, and it ends another one.
  final next = Int32List(gridWidth * gridHeight * 2)
    ..fillRange(
      0,
      gridWidth * gridHeight * 2,
      -1,
    );
  // The corners and the edges of a cell in clockwise order, where the edge at
  // an index goes from the corner at that index to the following one.
  final corners = Int32List(4);
  final edges = Int32List(4);
  final inside = List.filled(4, false);
  final crossed = Int32List(4);
  for (var y = 0; y < gridHeight - 1; y++) {
    for (var x = 0; x < gridWidth - 1; x++) {
      final topLeft = y * gridWidth + x;
      corners[0] = topLeft;
      corners[1] = topLeft + 1;
      corners[2] = topLeft + gridWidth + 1;
      corners[3] = topLeft + gridWidth;
      var insideCount = 0;
      for (var i = 0; i < 4; i++) {
        inside[i] = alpha[corners[i]] >= threshold;
        if (inside[i]) {
          insideCount++;
        }
      }
      if (insideCount == 0 || insideCount == 4) {
        continue;
      }
      edges[0] = 2 * corners[0];
      edges[1] = 2 * corners[1] + 1;
      edges[2] = 2 * corners[3];
      edges[3] = 2 * corners[0] + 1;
      var count = 0;
      for (var i = 0; i < 4; i++) {
        if (inside[i] != inside[(i + 1) % 4]) {
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
          (alpha[corners[0]] +
                  alpha[corners[1]] +
                  alpha[corners[2]] +
                  alpha[corners[3]]) /
              4 >=
          threshold;
      for (var i = 0; i < count; i++) {
        final edge = crossed[i];
        if (inside[edge]) {
          final end = joined
              ? crossed[(i + 1) % count]
              : crossed[(i + count - 1) % count];
          next[edges[edge]] = edges[end];
        }
      }
    }
  }

  Offset crossing(int edge) {
    final sample = edge >> 1;
    final other = edge.isEven ? sample + 1 : sample + gridWidth;
    final t = (threshold - alpha[sample]) / (alpha[other] - alpha[sample]);
    // The sample at (1, 1) is the center of the first pixel of the region.
    final x = sample % gridWidth - 0.5 + (edge.isEven ? t : 0);
    final y = sample ~/ gridWidth - 0.5 + (edge.isEven ? 0 : t);
    return Offset(x * scaleX, y * scaleY);
  }

  for (var start = 0; start < next.length; start++) {
    if (next[start] < 0) {
      continue;
    }
    final points = <Offset>[];
    var edge = start;
    do {
      points.add(crossing(edge));
      final following = next[edge];
      next[edge] = -1;
      edge = following;
    } while (edge != start && edge >= 0);
    final outline = _withoutCollinear(points);
    // The outer outlines have the inside on their right, so they go clockwise
    // on the screen, while the outlines of the holes go counterclockwise.
    if (outline.length >= 3 && _signedArea(outline) > 0) {
      path.addPolygon(outline, true);
    }
  }
  return path;
}

/// Removes the points of the closed outline that are in the middle of a
/// straight stretch, like the ones along the sides of the pixels.
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

bool _isCollinear(Offset previous, Offset point, Offset next) {
  final cross =
      (point.dx - previous.dx) * (next.dy - point.dy) -
      (point.dy - previous.dy) * (next.dx - point.dx);
  return cross.abs() <= 1e-9;
}

/// Twice the area of the polygon, positive when it goes clockwise on the
/// screen.
double _signedArea(List<Offset> points) {
  var area = 0.0;
  for (var i = 0; i < points.length; i++) {
    final a = points[i];
    final b = points[(i + 1) % points.length];
    area += a.dx * b.dy - b.dx * a.dy;
  }
  return area;
}
