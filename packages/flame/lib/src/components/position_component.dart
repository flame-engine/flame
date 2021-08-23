import 'dart:math' as math;
import 'dart:ui' hide Offset;

import '../anchor.dart';
import '../extensions/offset.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import '../game/notifying_vector2.dart';
import '../game/transform2d.dart';
import 'component.dart';

/// A [Component] implementation that represents an object that can be
/// freely moved around the screen, rotated, and scaled.
///
/// The [PositionComponent] class has no visual representation of its own
/// (except in debug mode). It is common, therefore, to derive from this
/// class, implementing a specific rendering logic. For example:
/// ```dart
/// class MyCircle extends PositionComponent {
///   MyCircle({required double radius, Paint? paint, Vector2? position})
///     : _radius = radius,
///       _paint = paint ?? Paint()..color=Color(0xFF80C080),
///       super(
///         position: position,
///         size: Vector2.all(2 * radius),
///         anchor: Anchor.center,
///       );
///
///   double _radius;
///   Paint _paint;
///
///   @override
///   void render(Canvas canvas) {
///     super.render(canvas);
///     canvas.drawCircle(Offset(_radius, _radius), _radius, _paint);
///   }
/// }
/// ```
///
/// The base [PositionComponent] class can also be used as a container
/// for several other components. In this case, changing the position,
/// rotating or scaling the [PositionComponent] will affect the whole
/// group as if it was a single entity.
///
/// The main properties of this class is the [_transform] (which combines
/// the [position], [angle] of rotation, and [scale]), the [size], and
/// the [anchor]. Thus, the [PositionComponent] can be imagined as an
/// abstract picture whose of a certain [size]. Within that picture
/// a point at location [anchor] is selected, and that point is designated as
/// a "logical center" of the picture. Then, a sequence of transforms is
/// applied: the picture is moved so that the anchor becomes at point
/// [position] on the screen, then the picture is rotated for [angle]
/// radians around the anchor point, and finally scaled by [scale] also
/// around the anchor point.
///
/// The [size] property of the [PositionComponent] is used primarily for
/// tap and collision detection. Thus, the [size] should be set equal to
/// the approximate bounding rectangle of the rendered picture. If you
/// do not specify the size of a PositionComponent, then it will be
/// equal to zero and the component won't be able to respond to taps.
class PositionComponent extends Component {
  PositionComponent({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double angle = 0.0,
    Anchor anchor = Anchor.topLeft,
    int? priority,
  })  : _transform = Transform2D(),
        _anchor = anchor,
        _size = NotifyingVector2.copy(size ?? Vector2.zero()),
        super(priority: priority) {
    if (position != null) {
      _transform.position = position;
    }
    if (angle != 0) {
      _transform.angle = angle;
    }
    if (scale != null) {
      _transform.scale = scale;
    }
    _size.addListener(_onModifiedSizeOrAnchor);
    _onModifiedSizeOrAnchor();
  }

  final Transform2D _transform;
  final NotifyingVector2 _size;
  Anchor _anchor;

  /// The total transformation matrix for the component. This matrix combines
  /// translation, rotation and scale transforms into a single entity. The
  /// matrix is cached and gets recalculated only as necessary.
  Matrix4 get transformMatrix => _transform.transformMatrix;

  /// The position of this component's anchor on the screen.
  NotifyingVector2 get position => _transform.position;
  set position(Vector2 position) => _transform.position = position;

  /// X position of this component's anchor on the screen.
  double get x => _transform.x;
  set x(double x) => _transform.x = x;

  /// Y position of this component's anchor on the screen.
  double get y => _transform.y;
  set y(double y) => _transform.y = y;

  /// Rotation angle (in radians) of the component. The component will be
  /// rotated around its anchor point in the clockwise direction if the
  /// angle is positive, or counterclockwise if the angle is negative.
  double get angle => _transform.angle;
  set angle(double a) => _transform.angle = a;

  /// The scale factor of this component. The scale can be different along
  /// the X and Y dimensions. A scale greater than 1 makes the component
  /// bigger, and less than 1 smaller. The scale can also be negative,
  /// which results in a mirror reflection along the corresponding axis.
  NotifyingVector2 get scale => _transform.scale;
  set scale(Vector2 scale) => _transform.scale = scale;

  /// Anchor point for this component. An anchor point describes a point
  /// within the rectangle of size [size]. This point is considered to
  /// be the logical "center" of the component. This can be visualized
  /// as the point where Flame "grabs" the component. All transforms
  /// occur around this point: the [position] is where the anchor point
  /// will end up after the component is translated; the rotation and
  /// scaling also happen around this anchor point.
  ///
  /// The [anchor] of a component can be modified during runtime. When
  /// this happens, the [position] of the component will remain unchanged,
  /// which means that visually the component will shift on the screen
  /// so that its new anchor will be at the same screen coordinates as
  /// the old anchor was.
  Anchor get anchor => _anchor;
  set anchor(Anchor anchor) {
    _anchor = anchor;
    _onModifiedSizeOrAnchor();
  }

  /// The logical size of the component. The game assumes that this is the
  /// approximate size of the object that will be drawn on the screen.
  /// This size will therefore be used for collision detection and tap
  /// handling.
  ///
  /// This property can be reassigned at runtime, although this is not
  /// recommended. Instead, in order to make the [PositionComponent] larger
  /// or smaller, change its [scale].
  Vector2 get size => _size;
  set size(Vector2 size) => _size.setFrom(size);

  /// The width of the component in local coordinates. Note that the object
  /// may visually appear larger or smaller due to application of [scale].
  double get width => _size.x;
  set width(double w) => _size.x = w;

  /// The height of the component in local coordinates. Note that the object
  /// may visually appear larger or smaller due to application of [scale].
  double get height => _size.y;
  set height(double h) => _size.y = h;

  /// The "physical" size of the component. This is the size of the
  /// component as seen from the parent's perspective, and it is equal to
  /// [size] * [scale]. This is a computed property and cannot be
  /// modified by the user.
  Vector2 get scaledSize =>
      Vector2(width * scale.x.abs(), height * scale.y.abs());

  /// Measure the distance (in parent's coordinate space) between this
  /// component's anchor and the [other] component's anchor.
  double distance(PositionComponent other) =>
      position.distanceTo(other.position);

  //#region Coordinate transformations

  /// Test whether the `point` (given in global coordinates) lies within this
  /// component. The top and the left borders of the component are inclusive,
  /// while the bottom and the right borders are exclusive.
  @override
  bool containsPoint(Vector2 point) {
    final local = absoluteToLocal(point);
    return (local.x >= 0) &&
        (local.y >= 0) &&
        (local.x < _size.x) &&
        (local.y < _size.y);
  }

  /// Convert local coordinates of a point [point] inside the component
  /// into the parent's coordinate space.
  Vector2 positionOf(Vector2 point) {
    return _transform.localToGlobal(point);
  }

  /// Similar to [positionOf()], but applies to any anchor point within
  /// the component.
  Vector2 positionOfAnchor(Anchor anchor) {
    if (anchor == _anchor) {
      return position;
    }
    return positionOf(Vector2(anchor.x * size.x, anchor.y * size.y));
  }

  /// Convert local coordinates of a point [point] inside the component
  /// into the global (world) coordinate space.
  Vector2 absolutePositionOf(Vector2 point) {
    var parentPoint = positionOf(point);
    var ancestor = parent;
    while (ancestor != null) {
      if (ancestor is PositionComponent) {
        parentPoint = ancestor.positionOf(parentPoint);
      }
      ancestor = ancestor.parent;
    }
    return parentPoint;
  }

  /// Similar to [absolutePositionOf()], but applies to any anchor
  /// point within the component.
  Vector2 absolutePositionOfAnchor(Anchor anchor) =>
      absolutePositionOf(Vector2(anchor.x * size.x, anchor.y * size.y));

  /// Transform [point] from the parent's coordinate space into the local
  /// coordinates. This function is the inverse of [positionOf()].
  Vector2 toLocal(Vector2 point) => _transform.globalToLocal(point);

  /// Transform [point] from the global (world) coordinate space into the
  /// local coordinates. This function is the inverse of
  /// [absolutePositionOf()].
  ///
  /// This can be used, for example, to detect whether a specific point
  /// on the screen lies within this [PositionComponent], and where
  /// exactly it hits.
  Vector2 absoluteToLocal(Vector2 point) {
    var c = parent;
    while (c != null) {
      if (c is PositionComponent) {
        return toLocal(c.absoluteToLocal(point));
      }
      c = c.parent;
    }
    return toLocal(point);
  }

  /// The top-left corner's position in the parent's coordinates.
  Vector2 get topLeftPosition => positionOfAnchor(Anchor.topLeft);
  set topLeftPosition(Vector2 point) {
    position += point - topLeftPosition;
  }

  /// The position of the center of the component's bounding rectangle
  /// in the parent's coordinates.
  Vector2 get center => positionOfAnchor(Anchor.center);
  set center(Vector2 point) {
    position += point - center;
  }

  /// The [anchor]'s position in absolute (world) coordinates.
  Vector2 get absolutePosition => absolutePositionOfAnchor(_anchor);

  /// Get the absolute top left position regardless of whether it is a child or not
  Vector2 get absoluteTopLeftPosition =>
      absolutePositionOfAnchor(Anchor.topLeft);

  /// Get the absolute center of the component
  Vector2 get absoluteCenter => absolutePositionOfAnchor(Anchor.center);

  //#endregion

  //#region Mutators

  /// Flip the component horizontally around its anchor point.
  void flipHorizontally() => _transform.flipHorizontally();

  /// Flip the component vertically around its anchor point.
  void flipVertically() => _transform.flipVertically();

  /// Flip the component horizontally around its center line.
  void flipHorizontallyAroundCenter() {
    final delta = (1 - 2 * _anchor.x) * width;
    _transform.x += delta * math.cos(_transform.angle);
    _transform.y += delta * math.sin(_transform.angle);
    _transform.flipHorizontally();
  }

  /// Flip the component vertically around its center line.
  void flipVerticallyAroundCenter() {
    final delta = (1 - 2 * _anchor.y) * height;
    _transform.x += -delta * math.sin(_transform.angle);
    _transform.y += delta * math.cos(_transform.angle);
    _transform.flipVertically();
  }

  //#endregion

  /// Internal handler that must be invoked whenever either the [size]
  /// or the [anchor] change.
  void _onModifiedSizeOrAnchor() {
    _transform.offset = Vector2(-_anchor.x * _size.x, -_anchor.y * _size.y);
  }

  @override
  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    final precision = debugCoordinatesPrecision;
    canvas.drawRect(size.toRect(), debugPaint);
    // draw small cross at the anchor point
    final p0 = -_transform.offset;
    canvas.drawLine(Offset(p0.x, p0.y - 2), Offset(p0.x, p0.y + 2), debugPaint);
    canvas.drawLine(Offset(p0.x - 2, p0.y), Offset(p0.x + 2, p0.y), debugPaint);
    if (precision != null) {
      // print coordinates at the top-left corner
      final p1 = absolutePositionOfAnchor(Anchor.topLeft);
      final x1str = p1.x.toStringAsFixed(precision);
      final y1str = p1.y.toStringAsFixed(precision);
      debugTextPaint.render(
        canvas,
        'x:$x1str y:$y1str',
        Vector2(-10 * (precision + 3), -15),
      );
      // print coordinates at the bottom-right corner
      final p2 = absolutePositionOfAnchor(Anchor.bottomRight);
      final x2str = p2.x.toStringAsFixed(precision);
      final y2str = p2.y.toStringAsFixed(precision);
      debugTextPaint.render(
        canvas,
        'x:$x2str y:$y2str',
        Vector2(size.x - 10 * (precision + 3), size.y),
      );
    }
  }

  @override
  void preRender(Canvas canvas) {
    canvas.transform(transformMatrix.storage);
  }

  /// Returns the relative position/size of this component.
  /// Relative because it might be translated by their parents (which is not considered here).
  Rect toRect() => topLeftPosition.toPositionedRect(scaledSize);

  /// Returns the absolute position/size of this component.
  /// Absolute because it takes any possible parent position into consideration.
  Rect toAbsoluteRect() => absoluteTopLeftPosition.toPositionedRect(scaledSize);

  /// Mutates position and size using the provided [rect] as basis.
  /// This is a relative rect, same definition that [toRect] use
  /// (therefore both methods are compatible, i.e. setByRect ∘ toRect = identity).
  void setByRect(Rect rect) {
    size.setValues(rect.width, rect.height);
    topLeftPosition = rect.topLeft.toVector2();
  }
}
