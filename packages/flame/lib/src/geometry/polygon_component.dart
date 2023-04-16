import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';

class PolygonComponent extends ShapeComponent {
  final List<Vector2> _vertices;
  UnmodifiableListView<Vector2> get vertices => UnmodifiableListView(_vertices);
  // These lists are used to minimize the amount of objects that are created,
  // and only change the contained object if the corresponding `ValueCache` is
  // deemed outdated.
  late final List<Vector2> _globalVertices;
  late final List<LineSegment> _lineSegments;
  final Path _path = Path();
  final bool shrinkToBounds;
  final bool manuallyPositioned;

  final _cachedGlobalVertices = ValueCache<List<Vector2>>();

  /// With this constructor you create your [PolygonComponent] from positions in
  /// anywhere in the 2d-space. It will automatically calculate the [size] of
  /// the Polygon (the bounding box) if no size it given.
  /// NOTE: Always define your polygon in a counter-clockwise fashion (in the
  /// screen coordinate system).
  PolygonComponent(
    this._vertices, {
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.paint,
    super.paintLayers,
    bool? shrinkToBounds,
  })  : assert(
          _vertices.length > 2,
          'Number of vertices are too few to create a polygon',
        ),
        shrinkToBounds = shrinkToBounds ?? size == null,
        manuallyPositioned = position != null {
    refreshVertices(newVertices: _vertices);

    final verticesLength = _vertices.length;
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

  /// With this constructor you define the [PolygonComponent] in relation to the
  /// [parentSize] of the shape.
  ///
  /// Example: `[[1.0, 0.0], [0.0, -1.0], [-1.0, 0.0], [0.0, 1.0]]`
  /// This will form a diamond shape within the bounding size box.
  /// NOTE: Always define your shape in a counter-clockwise fashion (in the
  /// screen coordinate system).
  PolygonComponent.relative(
    List<Vector2> relation, {
    required Vector2 parentSize,
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    Paint? paint,
    List<Paint>? paintLayers,
    bool? shrinkToBounds,
  }) : this(
          normalsToVertices(relation, parentSize),
          position: position,
          angle: angle,
          anchor: anchor,
          scale: scale,
          priority: priority,
          paint: paint,
          paintLayers: paintLayers,
          shrinkToBounds: shrinkToBounds,
        );

  @internal
  static List<Vector2> normalsToVertices(
    List<Vector2> normals,
    Vector2 size,
  ) {
    final halfSize = size / 2;
    return normals
        .map(
          (v) => v.clone()
            ..multiply(halfSize)
            ..add(halfSize),
        )
        .toList(growable: false);
  }

  // Used to not create new Vector2 objects when calculating the top left of the
  // bounds of the polygon.
  final _topLeft = Vector2.zero();

  @protected
  void refreshVertices({
    required List<Vector2> newVertices,
    bool? shrinkToBoundsOverride,
  }) {
    assert(
      newVertices.length == _vertices.length,
      'A polygon can not change their number of vertices',
    );
    // If the list isn't ccw we have to reverse the order in order for
    // `containsPoint` to work.
    if (_isClockwise(newVertices)) {
      newVertices.reverse();
    }
    _topLeft.setFrom(newVertices[0]);
    newVertices.forEachIndexed((i, _) {
      final newVertex = newVertices[i];
      _vertices[i].setFrom(newVertex);
      _topLeft.x = min(_topLeft.x, newVertex.x);
      _topLeft.y = min(_topLeft.y, newVertex.y);
    });
    _path
      ..reset()
      ..addPolygon(
        vertices.map((p) => (p - _topLeft).toOffset()).toList(growable: false),
        true,
      );
    if (shrinkToBoundsOverride ?? shrinkToBounds) {
      final bounds = _path.getBounds();
      size.setValues(bounds.width, bounds.height);
      if (!manuallyPositioned) {
        position = Anchor.topLeft.toOtherAnchorPosition(_topLeft, anchor, size);
      }
    }
  }

  /// gives back the shape vectors multiplied by the size and scale
  List<Vector2> globalVertices() {
    final scale = absoluteScale;
    final angle = absoluteAngle;
    final position = absoluteTopLeftPosition;
    if (!_cachedGlobalVertices.isCacheValid<dynamic>(<dynamic>[
      position,
      size,
      scale,
      angle,
    ])) {
      vertices.forEachIndexed((i, vertex) {
        _globalVertices[i]
          ..setFrom(vertex)
          ..sub(_topLeft)
          ..multiply(scale)
          ..add(position)
          ..rotate(angle, center: position);
      });
      if (scale.y.isNegative || scale.x.isNegative) {
        // Since the list will be clockwise we have to reverse it for it to
        // become counterclockwise.
        _reverseList(_globalVertices);
      }
      _cachedGlobalVertices.updateCache<dynamic>(
        _globalVertices,
        <dynamic>[position.clone(), size.clone(), scale.clone(), angle],
      );
    }
    return _cachedGlobalVertices.value!;
  }

  @override
  void render(Canvas canvas) {
    if (renderShape) {
      if (hasPaintLayers) {
        for (final paint in paintLayers) {
          canvas.drawPath(_path, paint);
        }
      } else {
        canvas.drawPath(_path, paint);
      }
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    canvas.drawPath(_path, debugPaint);
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

  @override
  bool containsLocalPoint(Vector2 point) {
    if (size.x == 0 || size.y == 0) {
      return false;
    }
    for (var i = 0; i < _vertices.length; i++) {
      final edge = getEdge(i, vertices: vertices);
      final isOutside = (edge.to.x - edge.from.x) *
                  (point.y - edge.from.y + _topLeft.y) -
              (point.x - edge.from.x + _topLeft.x) * (edge.to.y - edge.from.y) >
          0;
      if (isOutside) {
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

  bool _isClockwise(List<Vector2> vertices) {
    var area = 0.0;
    for (var i = 0; i < vertices.length; i++) {
      final j = (i + 1) % vertices.length;
      area += vertices[i].x * vertices[j].y - vertices[j].x * vertices[i].y;
    }
    return area >= 0;
  }
}
