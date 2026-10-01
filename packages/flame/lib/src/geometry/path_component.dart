import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';

/// Renders a [Path] and gives it a polygon for each of its closed contours.
///
/// The path is moved so that its bounds start at the origin of the component,
/// which gets the size of those bounds, so that the anchor and the transform
/// of the component apply to the path like to any other shape.
///
/// The polygons follow the contours with straight edges, in the same way as
/// [PolygonComponent.fromPath] follows a single contour, and they decide
/// whether a point is inside of the component. Their vertices are available
/// in [polygons].
class PathComponent({
  required Path path,

  /// The step used when sampling the contours of the [path].
  final double sampling = 1.0,

  /// The tolerance used when simplifying the sampled contours; if not given,
  /// it is half the [sampling].
  final double? tolerance,

  /// Whether the polygons that lie inside of the largest one are left out.
  final bool filter = true,
  super.position,
  super.scale,
  super.angle,
  super.anchor,
  super.children,
  super.priority,
  super.key,
  super.paint,
  super.paintLayers,
  super.isSolid,
}) extends ShapeComponent {
  /// With this constructor you create a [PathComponent] from all the contours
  /// of the [path].
  ///
  /// The contours are sampled every [sampling] along their length, and the
  /// samples that are not needed to stay within the [tolerance] of the contour
  /// are left out; by default, the tolerance is half the [sampling]. See
  /// [PathMetricExtension.walkContour] for the details of both parameters.
  ///
  /// Contours that end up with fewer than three vertices, like open lines, do
  /// not become polygons. When [filter] is true, the polygons whose vertices
  /// all lie inside of the largest polygon are left out too, since they are
  /// details of the shape that it already covers, like the eyes of a face.
  this : super(size: path.getBounds().size.toVector2()) {
    _polygons = _polygonsOf(
      this.path,
      sampling: sampling,
      tolerance: tolerance,
      filter: filter,
    );
    _globalPolygons = [
      for (final polygon in _polygons)
        List.generate(polygon.length, (_) => Vector2.zero(), growable: false),
    ];
    _lineSegments = [
      for (final polygon in _polygons)
        List.generate(
          polygon.length,
          (_) => LineSegment.zero(),
          growable: false,
        ),
    ];
    for (final polygon in _polygons) {
      _polygonsPath.addPolygon(
        polygon.map((vertex) => vertex.toOffset()).toList(growable: false),
        true,
      );
    }
  }

  /// The path to display, already rooted at the origin.
  final Path path = path.toOrigin;

  late final List<List<Vector2>> _polygons;

  /// The vertices of each polygon, in the local coordinates of the component.
  ///
  /// There is one polygon for each closed contour of the [path], unless it was
  /// left out by the [filter], and the vertices of each one go
  /// counterclockwise in the screen coordinate system.
  UnmodifiableListView<UnmodifiableListView<Vector2>> get polygons =>
      UnmodifiableListView([
        for (final polygon in _polygons) UnmodifiableListView(polygon),
      ]);

  // These lists are used to minimize the amount of objects that are created,
  // and only change the contained objects if the corresponding `ValueCache` is
  // deemed outdated.
  late final List<List<Vector2>> _globalPolygons;
  late final List<List<LineSegment>> _lineSegments;
  final Path _polygonsPath = Path();

  final _cachedGlobalPolygons = ValueCache<List<List<Vector2>>>();

  /// The vertices of each polygon in the global coordinate system, see
  /// [PolygonComponent.globalVertices].
  List<List<Vector2>> globalPolygons() {
    final scale = absoluteScale;
    final shouldReverse = scale.y.isNegative ^ scale.x.isNegative;
    final angle = absoluteAngle;
    final position = absoluteTopLeftPosition;
    if (!_cachedGlobalPolygons.isCacheValid<dynamic>(<dynamic>[
      position,
      size,
      scale,
      angle,
    ])) {
      for (var i = 0; i < _polygons.length; i++) {
        final polygon = _polygons[i];
        final globalPolygon = _globalPolygons[i];
        for (var j = 0; j < polygon.length; j++) {
          globalPolygon[j].setFrom(absolutePositionOf(polygon[j]));
        }
        if (shouldReverse) {
          // Since the list will be clockwise we have to reverse it for it to
          // become counterclockwise.
          globalPolygon.reverse();
        }
      }
      _cachedGlobalPolygons.updateCache<dynamic>(_globalPolygons, <dynamic>[
        position.clone(),
        size.clone(),
        scale.clone(),
        angle,
      ]);
    }
    return _cachedGlobalPolygons.value!;
  }

  @override
  void render(Canvas canvas) {
    if (renderShape) {
      if (hasPaintLayers) {
        for (final paint in paintLayers) {
          canvas.drawPath(path, paint);
        }
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    canvas.drawPath(_polygonsPath, debugPaint);
  }

  /// The [polygons] as a single [Path], in the local coordinates of the
  /// component.
  @protected
  Path get polygonsPath => _polygonsPath;

  bool _containsPoint(Vector2 point, List<List<Vector2>> polygons) {
    // If the size is 0 then it can't contain any points
    if (size.x == 0 || size.y == 0) {
      return false;
    }
    for (final polygon in polygons) {
      if (PolygonComponent.polygonContainsPoint(point, polygon)) {
        return true;
      }
    }
    return false;
  }

  /// Whether any of the polygons contains the [point], which is in the global
  /// coordinate system.
  @override
  bool containsPoint(Vector2 point) {
    return _containsPoint(point, globalPolygons());
  }

  /// Whether any of the polygons contains the [point], which is in the local
  /// coordinate system of the component.
  @override
  bool containsLocalPoint(Vector2 point) {
    return _containsPoint(point, _polygons);
  }

  /// Return all edges of all polygons as [LineSegment]s that intersect [rect],
  /// if [rect] is null return all edges as [LineSegment]s.
  List<LineSegment> possibleIntersectionVertices(Rect? rect) {
    final rectIntersections = <LineSegment>[];
    if ((rect?.width == 0) ||
        (rect?.height == 0) ||
        width == 0 ||
        height == 0) {
      return rectIntersections;
    }
    final polygons = globalPolygons();
    for (var i = 0; i < polygons.length; i++) {
      final vertices = polygons[i];
      final lineSegments = _lineSegments[i];
      for (var j = 0; j < vertices.length; j++) {
        final edge = lineSegments[j]
          ..from.setFrom(vertices[j])
          ..to.setFrom(vertices[(j + 1) % vertices.length]);
        if (rect?.intersectsSegment(edge.from, edge.to) ?? true) {
          rectIntersections.add(edge);
        }
      }
    }
    return rectIntersections;
  }

  /// Returns the polygon of each closed contour of the [path] with at least
  /// three vertices, with the vertices going counterclockwise.
  static List<List<Vector2>> _polygonsOf(
    Path path, {
    required double sampling,
    required double? tolerance,
    required bool filter,
  }) {
    final polygons = <List<Vector2>>[];
    for (final metric in path.computeMetrics()) {
      if (!metric.isClosed) {
        continue;
      }
      final contour = metric.walkContour(sampling, tolerance);
      if (contour.length > 2) {
        final vertices = contour.vertices;
        if (PolygonComponent.isClockwise(vertices)) {
          vertices.reverse();
        }
        polygons.add(vertices);
      }
    }
    if (filter && polygons.length > 1) {
      final largest = polygons.reduce((a, b) => _area(a) >= _area(b) ? a : b);
      final largestPath = Path()
        ..addPolygon(
          largest.map((vertex) => vertex.toOffset()).toList(growable: false),
          true,
        );
      polygons.removeWhere(
        (polygon) =>
            polygon != largest &&
            polygon.every((vertex) => largestPath.contains(vertex.toOffset())),
      );
    }
    return polygons;
  }

  /// The area of the bounds of the polygon with the given [vertices].
  static double _area(List<Vector2> vertices) {
    final bounds = RectExtension.getBounds(vertices);
    return bounds.width * bounds.height;
  }
}
