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
  List<List<Vector2>>? polygons,
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
  /// Open and degenerate contours do not become polygons, see
  /// [PathExtension.toPolygons]. When [filter] is true, the polygons whose
  /// vertices all lie inside of the largest polygon are left out too, since
  /// they are details of the shape that it already covers, like the eyes of a
  /// face.
  ///
  /// When [polygons] are given, the [path] is not sampled, so that components
  /// of the same path can share the work of sampling it: they have to be in
  /// the coordinates of the [path], as [PathExtension.toPolygons] returns
  /// them, or be the ones of another component, given along with its [path].
  /// Each one needs three vertices or more, going counterclockwise in the
  /// screen coordinate system. They are copied and moved along with the path,
  /// and [sampling], [tolerance] and [filter] are not used.
  this : super(size: path.getBounds().size.toVector2()) {
    _polygons = polygons == null
        ? this.path.toPolygons(
            sampling: sampling,
            tolerance: tolerance,
            filter: filter,
          )
        : _rooted(polygons, path.getBounds().topLeft);
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

  /// Copies of the given [polygons], moved from the [origin] of their path to
  /// the origin of the component, as the [path] is.
  static List<List<Vector2>> _rooted(
    List<List<Vector2>> polygons,
    Offset origin,
  ) {
    assert(
      polygons.every(
        (polygon) =>
            polygon.length > 2 && !PolygonComponent.isClockwise(polygon),
      ),
      'Each polygon needs three vertices or more, going counterclockwise',
    );
    final shift = origin.toVector2();
    return [
      for (final polygon in polygons)
        [for (final vertex in polygon) vertex - shift],
    ];
  }

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
}
