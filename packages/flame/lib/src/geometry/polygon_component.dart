import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';

class PolygonComponent extends ShapeComponent {
  final List<Vector2> _vertices;
  UnmodifiableListView<Vector2> get vertices => UnmodifiableListView(_vertices);
  // These lists are used to minimize the amount of objects that are created,
  // and only change the contained object if the cached absolute transform is
  // deemed outdated.
  late final List<Vector2> _globalVertices;
  late final List<LineSegment> _lineSegments;
  final Path _path = Path();
  final bool shrinkToBounds;
  final bool manuallyPositioned;

  /// With this constructor you create your [PolygonComponent] from positions
  /// anywhere in the 2d-space. It will automatically calculate the [size] of
  /// the Polygon (the bounding box) if no size is given.
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
    super.key,
    bool? shrinkToBounds,
  }) : assert(
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
    ComponentKey? key,
    List<Component>? children,
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
         key: key,
         children: children,
       );

  /// With this constructor you create a regular (equiangular and equilateral)
  /// polygon from number of sides and radius anywhere in the 2d-space. It will
  /// automatically calculate the [size] of the Polygon (the bounding box) if no
  /// size is given.
  PolygonComponent.regular({
    required int sides,
    required double radius,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
    Paint? paint,
    List<Paint>? paintLayers,
    ComponentKey? key,
    bool? shrinkToBounds,
  }) : this(
         List.generate(sides, (i) {
           final angle = tau * i / sides;
           return Vector2(radius * cos(angle), radius * sin(angle));
         }, growable: false),
         position: position,
         size: size,
         scale: scale,
         angle: angle,
         anchor: anchor,
         children: children,
         priority: priority,
         paint: paint,
         paintLayers: paintLayers,
         key: key,
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
    final topLeft = Vector2.zero();
    topLeft.setFrom(newVertices[0]);
    for (var i = 0; i < newVertices.length; i++) {
      final newVertex = newVertices[i];
      _vertices[i].setFrom(newVertex);
      topLeft.x = min(topLeft.x, newVertex.x);
      topLeft.y = min(topLeft.y, newVertex.y);
    }
    for (var i = 0; i < newVertices.length; i++) {
      final newVertex = newVertices[i];
      _vertices[i].setFrom(newVertex - topLeft);
    }
    _path
      ..reset()
      ..addPolygon(
        _vertices.map((p) => p.toOffset()).toList(growable: false),
        true,
      );
    if (shrinkToBoundsOverride ?? shrinkToBounds) {
      final bounds = _path.getBounds();
      size.setValues(bounds.width, bounds.height);
      if (!manuallyPositioned) {
        position = Anchor.topLeft.toOtherAnchorPosition(topLeft, anchor, size);
      }
    }
  }

  /// gives back the shape vectors multiplied by the size and scale
  List<Vector2> globalVertices() {
    _composeAbsoluteTransform();
    final m = _absoluteTransform;
    final cache = _globalVerticesCacheKey;
    var isCacheValid = _hasGlobalVertices;
    if (isCacheValid) {
      for (var i = 0; i < 6; i++) {
        if (cache[i] != m[i]) {
          isCacheValid = false;
          break;
        }
      }
      isCacheValid = isCacheValid && cache[6] == size.x && cache[7] == size.y;
    }
    if (!isCacheValid) {
      for (var i = 0; i < _vertices.length; i++) {
        final vertex = _vertices[i];
        _globalVertices[i].setValues(
          m[0] * vertex.x + m[2] * vertex.y + m[4],
          m[1] * vertex.x + m[3] * vertex.y + m[5],
        );
      }
      // A negative determinant means the transform mirrors the polygon, so the
      // list will be clockwise and has to be reversed to become
      // counterclockwise.
      if (m[0] * m[3] - m[1] * m[2] < 0) {
        _reverseList(_globalVertices);
      }
      for (var i = 0; i < 6; i++) {
        cache[i] = m[i];
      }
      cache[6] = size.x;
      cache[7] = size.y;
      _hasGlobalVertices = true;
    }
    return _globalVertices;
  }

  final Float64List _absoluteTransform = Float64List(6);
  final Float64List _globalVerticesCacheKey = Float64List(8);
  bool _hasGlobalVertices = false;

  /// Composes the 2D affine transform from local to global coordinates into
  /// [_absoluteTransform] as `[a, b, c, d, tx, ty]`, where a point maps to
  /// `(a * x + c * y + tx, b * x + d * y + ty)`.
  void _composeAbsoluteTransform() {
    final own = transform.transformMatrix.storage;
    var a = own[0];
    var b = own[1];
    var c = own[4];
    var d = own[5];
    var tx = own[12];
    var ty = own[13];
    var ancestor = parent;
    while (ancestor != null) {
      if (ancestor is PositionComponent) {
        final p = ancestor.transform.transformMatrix.storage;
        final p0 = p[0];
        final p1 = p[1];
        final p4 = p[4];
        final p5 = p[5];
        final newA = p0 * a + p4 * b;
        final newB = p1 * a + p5 * b;
        final newC = p0 * c + p4 * d;
        final newD = p1 * c + p5 * d;
        final newTx = p0 * tx + p4 * ty + p[12];
        final newTy = p1 * tx + p5 * ty + p[13];
        a = newA;
        b = newB;
        c = newC;
        d = newD;
        tx = newTx;
        ty = newTy;
      }
      ancestor = ancestor.parent;
    }
    _absoluteTransform[0] = a;
    _absoluteTransform[1] = b;
    _absoluteTransform[2] = c;
    _absoluteTransform[3] = d;
    _absoluteTransform[4] = tx;
    _absoluteTransform[5] = ty;
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

  bool _containsPoint(Vector2 point, List<Vector2> vertices) {
    // If the size is 0 then it can't contain any points
    if (size.x == 0 || size.y == 0) {
      return false;
    }

    // Count the amount of edges crossed by going left from the point
    var count = 0;
    for (var i = 0; i < vertices.length; i++) {
      final from = vertices[i];
      final to = vertices[(i + 1) % vertices.length];

      // Skip if the edge is entirely to the right, above or below the point
      if (from.x > point.x && to.x > point.x ||
          min(from.y, to.y) > point.y ||
          max(from.y, to.y) < point.y) {
        continue;
      }

      // Get x coordinate of where the edge intersects with the horizontal line
      double intersectionX;
      if (from.y == to.y) {
        intersectionX = min(from.x, to.x);
      } else {
        intersectionX =
            ((point.y - from.y) * (to.x - from.x)) / (to.y - from.y) + from.x;
      }

      if (intersectionX == point.x) {
        // If the point is on the edge, return true
        return true;
      } else if (intersectionX < point.x) {
        // Only count one edge if vertex is crossed
        // Only count if edges cross the line, not just touch it and go back
        if ((from.y != point.y && to.y != point.y) ||
            to.y == from.y ||
            point.y == max(from.y, to.y)) {
          count++;
        }
      }
    }

    // If the amount of edges crossed is odd, the point is inside the polygon
    return (count % 2).isOdd;
  }

  @override
  bool containsPoint(Vector2 point) {
    final vertices = globalVertices();
    return _containsPoint(point, vertices);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return _containsPoint(point, _vertices);
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
