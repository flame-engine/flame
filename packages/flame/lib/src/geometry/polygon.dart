import 'dart:ui' hide Canvas;

import '../../game.dart';
import '../../geometry.dart';
import '../components/cache/value_cache.dart';
import '../extensions/canvas.dart';
import '../extensions/offset.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import 'shape.dart';

// TODO(spydon): Migrate this to [Path]
class Polygon extends Shape {
  final List<Vector2> normalizedVertices;
  // These lists are used to minimize the amount of objects that are created,
  // and only change the contained object if the cache is deemed outdated.
  late final List<Vector2> _sizedVertices;
  late final List<Vector2> _scaledVertices;
  late final List<Vector2> _hitboxVertices;
  late final List<Offset> _renderVertices;
  late final List<LineSegment> _lineSegments;

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
  /// Example: [[1.0, 0.0], [0.0, 1.0], [-1.0, 0.0], [0.0, -1.0]]
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

    _sizedVertices = generateList();
    _scaledVertices = generateList();
    _hitboxVertices = generateList();
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

  final _cachedSizedVertices = ValueCache<Iterable<Vector2>>();

  /// Gives back the shape vectors multiplied by the size
  Iterable<Vector2> sizedVertices() {
    if (!_cachedSizedVertices.isCacheValid([size])) {
      for (var i = 0; i < _sizedVertices.length; i++) {
        final point = normalizedVertices[i];
        (_sizedVertices[i]..setFrom(point)).multiply(halfSize);
      }
      _cachedSizedVertices.updateCache(_sizedVertices, [size.clone()]);
    }
    return _cachedSizedVertices.value!;
  }

  final _cachedScaledVertices = ValueCache<Iterable<Vector2>>();

  /// Gives back the shape vectors multiplied by the size and scale
  Iterable<Vector2> scaledVertices() {
    final scale = this.scale;
    if (scale.isIdentity()) {
      return sizedVertices();
    }
    if (!_cachedScaledVertices.isCacheValid([size, scale])) {
      final sizedVertices = this.sizedVertices();
      var i = 0;
      for (final point in sizedVertices) {
        _scaledVertices[i]
          ..setFrom(point)
          ..multiply(scale);
        i++;
      }
      _cachedScaledVertices.updateCache(_scaledVertices, [size.clone(), scale]);
    }
    return _cachedScaledVertices.value!;
  }

  final _cachedRenderPath = ValueCache<Path>();
  final _path = Path();

  @override
  void render(Canvas canvas, Paint paint) {
    if (!_cachedRenderPath
        .isCacheValid([offsetPosition, relativeOffset, size, angle])) {
      final center = localCenter;
      var i = 0;
      scaledVertices().forEach((point) {
        final pathPoint = center + point;
        if (!isCanvasPrepared) {
          pathPoint.rotate(angle, center: center);
        }
        _renderVertices[i] = pathPoint.toOffset();
        i++;
      });
      _cachedRenderPath.updateCache(
        _path
          ..reset()
          ..addPolygon(_renderVertices, true),
        [
          offsetPosition.clone(),
          relativeOffset.clone(),
          size.clone(),
          angle,
        ],
      );
    }
    canvas.drawPath(_cachedRenderPath.value!, paint);
  }

  final _cachedHitbox = ValueCache<List<Vector2>>();

  /// Gives back the vertices represented as a list of points which
  /// are the "corners" of the hitbox rotated with [angle].
  /// These are in the global hitbox coordinate space since all hitboxes are
  /// compared towards each other.
  List<Vector2> hitbox() {
    // Use cached bounding vertices if state of the component hasn't changed
    if (!_cachedHitbox
        .isCacheValid([absoluteCenter, size, scale, parentAngle, angle])) {
      final scaledVertices = this.scaledVertices();
      final center = absoluteCenter;
      var i = 0;
      for (final scaledVertex in scaledVertices) {
        _hitboxVertices[i]
          ..setFrom(center)
          ..add(scaledVertex)
          ..rotate(parentAngle + angle, center: center);
        i++;
      }
      _cachedHitbox.updateCache(
        _hitboxVertices,
        [absoluteCenter, size.clone(), scale.clone(), parentAngle, angle],
      );
    }
    return _cachedHitbox.value!;
  }

  /// Checks whether the polygon contains the [point].
  /// Note: The polygon needs to be convex for this to work.
  @override
  bool containsPoint(Vector2 point) {
    // If the size is 0 then it can't contain any points
    if (size.x == 0 || size.y == 0) {
      return false;
    }
    print('Tap down: $point');

    final vertices = hitbox();
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
    final vertices = hitbox();
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
    vertices ??= hitbox();
    return vertices[i % vertices.length];
  }
}

class HitboxPolygon extends Polygon with HitboxShape {
  HitboxPolygon(List<Vector2> definition) : super.fromDefinition(definition);

  factory HitboxPolygon.fromPolygon(Polygon polygon) =>
      HitboxPolygon(polygon.normalizedVertices);
}
