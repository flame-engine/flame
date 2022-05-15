import 'dart:ui';

import 'package:flame/src/experimental/geometry/shapes/circle.dart';
import 'package:flame/src/experimental/geometry/shapes/polygon.dart';
import 'package:flame/src/experimental/geometry/shapes/rectangle.dart';
import 'package:flame/src/experimental/geometry/shapes/rounded_rectangle.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:vector_math/vector_math_64.dart';

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
  Aabb2 get aabb;

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
  ///
  /// If [target] is provided and it has a proper type, then this method should
  /// modify the target in-place and return it. If [target] is null, or if its
  /// type is not compatible with the requested [transform], then the method
  /// should create and return a new [Shape].
  Shape project(Transform2D transform, [Shape? target]);

  /// Translates the shape by the specified [offset] vector, in-place.
  ///
  /// This method is a simpler version of [project], since all shapes can be
  /// moved without changing the shape type, and with little modifications to
  /// the internal state.
  void move(Vector2 offset);

  /// Finds the intersection of this shape with another one, if it exists.
  // Intersection? intersection(GeometricPrimitive other);

  /// Returns a point on the boundary that is furthest in the given [direction].
  ///
  /// In other words, this returns such a point `p` within in the shape for
  /// which the dot-product `p·direction` is maximal. If multiple such points
  /// exist, then any one of them can be returned.
  ///
  /// The [direction] vector may have length not equal to 1.
  ///
  /// This method is only used for convex shapes.
  Vector2 support(Vector2 direction);
}
