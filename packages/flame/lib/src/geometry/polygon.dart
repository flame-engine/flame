import 'dart:ui' hide Canvas;

import '../../components.dart';
import '../../game.dart';
import '../../geometry.dart';
import '../cache/value_cache.dart';
import '../extensions/canvas.dart';
import '../extensions/offset.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';

class Polygon extends Shape {
  final List<Vector2> normalizedVertices;
  // These lists are used to minimize the amount of objects that are created,
  // and only change the contained object if the corresponding `ValueCache` is
  // deemed outdated.
  late final List<Vector2> _localVertices;
  late final List<Vector2> _globalVertices;
  late final List<Offset> _renderVertices;
  late final List<LineSegment> _lineSegments;
  final _path = Path();

  final _cachedLocalVertices = ValueCache<Iterable<Vector2>>();
  final _cachedGlobalVertices = ValueCache<List<Vector2>>();
  final _cachedRenderPath = ValueCache<Path>();

  /// With this constructor you create your [Polygon] from positions in your
  /// intended space. It will automatically calculate the [size] and center
  /// ([position]) of the Polygon.
  factory Polygon(
    List<Vector2> points, {
    double angle = 0,
  }) {
    assert(
      points.length > 2,
      'List of points is too short to create a polygon',
    );
    final path = Path()
      ..addPolygon(
        points.map((p) => p.toOffset()).toList(growable: false),
        true,
      );
    final boundingRect = path.getBounds();
    final centerOffset = boundingRect.center;
    final center = centerOffset.toVector2();
    final halfSize = (boundingRect.bottomRight - centerOffset).toVector2();
    final definition =
        points.map<Vector2>((v) => (v - center)..divide(halfSize)).toList();
    return Polygon.fromDefinition(
      definition,
      position: center,
      size: halfSize * 2,
      angle: angle,
    );
  }

  /// With this constructor you define the [Polygon] from the center of and with
  /// percentages of the size of the shape.
  ///
  /// Example: `[[1.0, 0.0], [0.0, -1.0], [-1.0, 0.0], [0.0, 1.0]]`
  /// This will form a diamond shape within the bounding size box.
  /// NOTE: Always define your shape in a counter-clockwise fashion (in the
  /// screen coordinate system).
  Polygon.fromDefinition(
    this.normalizedVertices, {
    Vector2? position,
    Vector2? size,
    double? angle,
  }) : super(
          position: position,
          size: size,
          angle: angle ?? 0,
        ) {
    List<Vector2> generateList() {
      return List.generate(
        normalizedVertices.length,
        (_) => Vector2.zero(),
        growable: false,
      );
    }

    _localVertices = generateList();
    _globalVertices = generateList();
    _renderVertices = List.filled(
      normalizedVertices.length,
      Offset.zero,
      growable: false,
    );
    _lineSegments = List.generate(
      normalizedVertices.length,
      (_) => LineSegment.zero(),
      growable: false,
    );
  }

  /// Gives back the shape vectors multiplied by the size
  Iterable<Vector2> localVertices() {
    final center = localCenter;
    if (!_cachedLocalVertices.isCacheValid([size, center])) {
      final halfSize = this.halfSize;
      for (var i = 0; i < _localVertices.length; i++) {
        final point = normalizedVertices[i];
        (_localVertices[i]..setFrom(point))
          ..multiply(halfSize)
          ..add(center)
          ..rotate(angle, center: center);
      }
      _cachedLocalVertices.updateCache(_localVertices, [
        size.clone(),
        center.clone(),
      ]);
    }
    return _cachedLocalVertices.value!;
  }

  /// Gives back the shape vectors multiplied by the size and scale
  List<Vector2> globalVertices() {
    final scale = this.scale;
    final totalAngle = absoluteAngle;
    if (!_cachedGlobalVertices.isCacheValid<dynamic>(<dynamic>[
      position,
      offsetPosition,
      relativeOffset,
      size,
      scale,
      absoluteAngle,
    ])) {
      var i = 0;
      final center = absoluteCenter;
      final halfSize = this.halfSize;
      for (final normalizedPoint in normalizedVertices) {
        _globalVertices[i]
          ..setFrom(normalizedPoint)
          ..multiply(halfSize)
          ..multiply(scale)
          ..add(center)
          ..rotate(absoluteAngle, center: center);
        i++;
      }
      if (scale.y.isNegative || scale.x.isNegative) {
        // Since the list will be clockwise we have to reverse it for it to
        // become counterclockwise.
        _reverseList(_globalVertices);
      }
      _cachedGlobalVertices.updateCache<dynamic>(_globalVertices, <dynamic>[
        position.clone(),
        offsetPosition.clone(),
        relativeOffset.clone(),
        size.clone(),
        scale.clone(),
        totalAngle
      ]);
    }
    return _cachedGlobalVertices.value!;
  }

  @override
  void render(Canvas canvas) {
    if (!_cachedRenderPath.isCacheValid([
      offsetPosition,
      relativeOffset,
      size,
      angle,
    ])) {
      var i = 0;
      localVertices().forEach((point) {
        _renderVertices[i] = point.toOffset();
        i++;
      });
      _cachedRenderPath.updateCache<dynamic>(
        _path
          ..reset()
          ..addPolygon(_renderVertices, true),
        <dynamic>[
          offsetPosition.clone(),
          relativeOffset.clone(),
          size.clone(),
          angle,
        ],
      );
    }
    canvas.drawPath(_cachedRenderPath.value!, paint);
  }

  /// Checks whether the polygon contains the [point].
  /// Note: The polygon needs to be convex for this to work.
  @override
  bool containsPoint(Vector2 point) {
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

class HitboxPolygon extends Polygon with HasHitboxes, HitboxShape {
  HitboxPolygon(List<Vector2> definition) : super.fromDefinition(definition);

  factory HitboxPolygon.fromPolygon(Polygon polygon) =>
      HitboxPolygon(polygon.normalizedVertices);
}
