import 'dart:ui' hide Canvas;

import '../../components.dart';
import '../../geometry.dart';
import '../components/cache/value_cache.dart';
import '../extensions/canvas.dart';
import '../extensions/offset.dart';
import '../extensions/rect.dart';

class Polygon extends Shape {
  late final List<Vector2> vertices;
  // These lists are used to minimize the amount of objects that are created,
  // and only change the contained object if the corresponding `ValueCache` is
  // deemed outdated.
  late final List<Vector2> _globalVertices;
  late final List<LineSegment> _lineSegments;
  late final Path _path;

  final _cachedGlobalVertices = ValueCache<List<Vector2>>();

  /// With this constructor you create your [Polygon] from positions in your
  /// intended space. It will automatically calculate the [size] and [position]
  /// of the Polygon.
  /// NOTE: Always define your polygon in a counter-clockwise fashion (in the
  /// screen coordinate system).
  Polygon(
    this.vertices, {
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  })  : assert(
          vertices.length > 3,
          'List of vertices is too short to create a polygon',
        ),
        super(scale: scale, angle: angle, anchor: anchor, priority: priority) {
    final verticesLength = vertices.length;
    _path = Path()
      ..addPolygon(
        vertices.map((p) => p.toOffset()).toList(growable: false),
        true,
      );
    final boundingRect = _path.getBounds();
    final center = boundingRect.center.toVector2();
    size = boundingRect.bottomRight.toVector2();
    position = Anchor.center.toOtherAnchorPosition(center, this.anchor, size);

    _globalVertices = List.generate(
      verticesLength,
      (_) => Vector2.zero(),
      growable: false,
    );
    _lineSegments = List.generate(
      verticesLength,
      (_) => LineSegment.zero(),
      growable: false,
    );
  }

  // TODO(spydon): Move to HitboxPolygon.fill
  /// With this constructor you define the [Polygon] from the center of and with
  /// percentages of the size of the shape.
  /// Example: [[1.0, 0.0], [0.0, -1.0], [-1.0, 0.0], [0.0, 1.0]]
  /// This will form a diamond shape within the bounding size box.

  /// Gives back the shape vectors multiplied by the size
  //Iterable<Vector2> localVertices() {
  //  final center = this.center;
  //  if (!_cachedLocalVertices.isCacheValid([size, center])) {
  //    final halfSize = this.halfSize;
  //    for (var i = 0; i < _localVertices.length; i++) {
  //      final point = normalizedVertices[i];
  //      (_localVertices[i]..setFrom(point))
  //        ..multiply(halfSize)
  //        ..add(center)
  //        ..rotate(angle, center: center);
  //    }
  //    _cachedLocalVertices.updateCache(_localVertices, [
  //      size.clone(),
  //      center.clone(),
  //    ]);
  //  }
  //  return _cachedLocalVertices.value!;
  //}

  /// Gives back the shape vectors multiplied by the size and scale
  List<Vector2> globalVertices() {
    final scale = absoluteScale;
    final angle = absoluteAngle;
    final position = absolutePosition;
    final center = absoluteCenter;
    if (!_cachedGlobalVertices.isCacheValid<dynamic>(<dynamic>[
      position,
      scale,
      angle,
    ])) {
      var i = 0;
      for (final vertex in vertices) {
        _globalVertices[i]
          ..setFrom(vertex)
          ..multiply(scale)
          ..add(position)
          ..rotate(absoluteAngle - angle, center: center)
          ..rotate(angle, center: position);
        i++;
      }
      if (scale.y.isNegative || scale.x.isNegative) {
        // Since the list will be clockwise we have to reverse it for it to
        // become counterclockwise.
        _reverseList(_globalVertices);
      }
      _cachedGlobalVertices.updateCache<dynamic>(
        _globalVertices,
        <dynamic>[position.clone(), scale.clone(), angle],
      );
    }
    return _cachedGlobalVertices.value!;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_path, paint);
  }

  /// Checks whether the polygon contains the [point].
  /// Note: The polygon needs to be convex for this to work.
  @override
  bool containsPoint(Vector2 point) {
    print('THIS IS CALLED');
    // If the size is 0 then it can't contain any points
    if (size.x == 0 || size.y == 0) {
      return false;
    }

    final vertices = globalVertices();
    for (var i = 0; i < vertices.length; i++) {
      final edge = getEdge(i, vertices: vertices);
      final isOutside = (edge.to.x - edge.from.x) * (point.y - edge.from.y) -
              (point.x - edge.from.x) * (edge.to.y - edge.from.y) >
          0;
      if (isOutside) {
        // Point is outside of convex polygon
        return false;
      }
    }
    return true;
  }

  /// Return all vertices as [LineSegment]s that intersect [rect], if [rect]
  /// is null return all vertices as [LineSegment]s.
  List<LineSegment> possibleIntersectionVertices(Rect? rect) {
    final rectIntersections = <LineSegment>[];
    if ((rect?.width == 0 || false) ||
        (rect?.height == 0 || false) ||
        width == 0 ||
        height == 0) {
      return rectIntersections;
    }
    final vertices = globalVertices();
    for (var i = 0; i < vertices.length; i++) {
      final edge = getEdge(i, vertices: vertices);
      if (rect?.intersectsSegment(edge.from, edge.to) ?? true) {
        rectIntersections.add(edge);
      }
    }
    return rectIntersections;
  }

  LineSegment getEdge(int i, {required List<Vector2> vertices}) {
    _lineSegments[i].from.setFrom(getVertex(i, vertices: vertices));
    _lineSegments[i].to.setFrom(getVertex(i + 1, vertices: vertices));
    return _lineSegments[i];
  }

  Vector2 getVertex(int i, {List<Vector2>? vertices}) {
    vertices ??= globalVertices();
    return vertices[i % vertices.length];
  }

  void _reverseList(List<Object> list) {
    for (var i = 0; i < list.length / 2; i++) {
      final temp = list[i];
      list[i] = list[list.length - 1 - i];
      list[list.length - 1 - i] = temp;
    }
  }
}
