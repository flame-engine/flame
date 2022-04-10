import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../../game/transform2d.dart';
import 'circle.dart';
import 'line_segment.dart';
import 'rectangle.dart';

/// Base class for various 2D geometric primitives defined on a Cartesian
/// coordinate plane.
///
/// Implementations include:
///   - [Circle]
///   - [LineSegment]
///   - [Rectangle]
abstract class Shape {
  /// True if the shape is "closed", in the sense that it has an interior. For
  /// example, a closed shape can be filled with a paint.
  bool get isClosed;

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
  Aabb2 get aabb;

  /// Returns true if the given [point] is inside (or on the boundary of) the
  /// shape.
  ///
  /// The parameter [epsilon] can optionally be used to allow points that are
  /// very close to the boundary of the shape to also be included. This is
  /// especially important for shapes that are not closed (such as `Line`),
  /// where due to floating-point rounding errors it might be impossible to find
  /// points that lie _exactly_ on the boundary.
  bool containsPoint(Vector2 point, {double epsilon = 1e-5});

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

  /// Finds the intersection of this shape with another one, if it exists.
  // Intersection? intersection(GeometricPrimitive other);
}
