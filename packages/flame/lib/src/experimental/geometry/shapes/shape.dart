import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../../game/transform2d.dart';
import 'circle.dart';
import 'polygon.dart';
import 'rectangle.dart';
import 'rounded_rectangle.dart';

/// Base class for various 2D geometric primitives defined on a Cartesian
/// coordinate plane.
///
/// Implementations include:
///   - [Circle]
///   - [Polygon]
///   - [Rectangle]
///   - [RoundedRectangle]
abstract class Shape {
  /// True if the shape is "closed", in the sense that it has an interior. For
  /// example, a closed shape can be filled with a paint.
  bool get isClosed => true;

  /// True if the shape is convex, i.e. a line segment connecting any two points
  /// of the shape would lie completely within the shape.
  bool get isConvex;

  /// The length of the shape's boundary. For some more complicated shapes this
  /// can be computed approximately.
  double get perimeter;

  /// The central point of the shape.
  ///
  /// For some shapes (circle, rectangle) the center is well-defined and
  /// unambiguous. For some, there could be multiple definitions (triangle,
  /// polygon), in which case it is up to the component to decide what its
  /// "center" should be.
  Vector2 get center;

  /// The axis-aligned bounding box of the shape.
  ///
  /// Implementations are encouraged to cache the computed Aabb in order to
  /// avoid repeated recalculations on every game tick.
  Aabb2 get aabb => _aabb ??= calculateAabb();
  Aabb2? _aabb;
  @protected
  Aabb2 calculateAabb();

  /// Returns true if the given [point] is inside the shape or on the boundary.
  bool containsPoint(Vector2 point);

  /// Converts the shape to a [Path] object, suitable for rendering on a canvas.
  /// If a particular geometric primitive cannot be represented as a [Path]
  /// faithfully, an approximate path can be returned.
  Path asPath();

  /// Returns the result of applying an affine transformation to the shape.
  ///
  /// Certain shapes may be transformed into shapes of a different kind during
  /// the projection. For example, a `Circle` may transform into an `Ellipse`,
  /// and `Rectangle` into a `Polygon`.
  Shape project(Transform2D transform);

  @mustCallSuper
  void move(Vector2 offset) {
    if (_aabb != null) {
      _aabb!.min.add(offset);
      _aabb!.max.add(offset);
    }
  }

  /// Finds the intersection of this shape with another one, if it exists.
  // Intersection? intersection(GeometricPrimitive other);
}
