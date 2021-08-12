import 'dart:math' as math;
import 'dart:ui' hide Offset;
import '../anchor.dart';
import '../extensions/offset.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import '../game/notifying_vector2.dart';
import '../game/transform2d.dart';
import 'base_component.dart';
import 'component.dart';

/// A [Component] implementation that represents a component that can be
/// freely moved around the screen, rotated, and scaled.
///
/// The [PositionComponent] class has no visual representation (except in
/// debug mode). It is common, therefore, to derive from this class,
/// implementing a particular rendering logic.
///
/// The base [PositionComponent] class can also be used as a container for
/// a group of other components. In this case, changing the position,
/// rotating or scaling the container component will affect the whole
/// group as if it was a single entity.
///
/// The main properties of this class is the [_transform] (which combines
/// the [position], [angle] of rotation, and [scale]), the [size], and
/// the [anchor]. Thus, the [PositionComponent] can be imagined as an
/// abstract picture whose size originally is [size]; within that picture
/// a point at location [anchor] is selected, that point is designated as
/// a logical "center" of the picture. Then, the transform is applied to
/// the picture: its anchor is moved to the point [position] on the screen,
/// then the picture is rotated by [angle] around the anchor point, and
/// scaled by [scale] also around the anchor point.
///
/// The [size] property of the [PositionComponent] is used primarily for
/// tap and collision detection. Thus, the [size] should be set equal to
/// the approximate bounding rectangle of the rendered picture. If you
/// do not specify the size of a PositionComponent, then it will be
/// equal to zero and the component won't be able to respond to taps.
///
class PositionComponent extends BaseComponent {
  final Transform2D _transform;

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
        _scaledSize = Vector2.zero(),
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
    _size.addListener(_onModifiedSizeOrScale);
    _transform.scale.addListener(_onModifiedSizeOrScale);
    _onModifiedSizeOrAnchor();
    _onModifiedSizeOrScale();
  }

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

  /// Rotation angle (in degrees) of the component. The component will be
  /// rotated around its anchor point in the clockwise direction if the
  /// angle is positive, or counterclockwise if the angle is negative.
  double get angleDegrees => _transform.angleDegrees;
  set angleDegrees(double a) => _transform.angleDegrees = a;

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
  Anchor _anchor;
  Anchor get anchor => _anchor;
  set anchor(Anchor a) {
    _anchor = a;
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
  final NotifyingVector2 _size;
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
  final Vector2 _scaledSize;
  Vector2 get scaledSize => _scaledSize;

  /// Measure the distance (in parent's coordinate space) between this
  /// component's anchor and the [other] component's anchor.
  double distance(PositionComponent other) =>
      position.distanceTo(other.position);

  //----------------------------------------------------------------------------
  // Coordinate transformations
  //----------------------------------------------------------------------------

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

  /// Convert local coordinates of a point [p] inside the component into
  /// the parent's coordinate space. Point [p] can be either a [Vector2],
  /// an [Anchor] (relative to component's [size]), or an [Offset].
  Vector2 positionOf(dynamic p) {
    if (p is Vector2) {
      return _transform.localToGlobal(p);
    }
    if (p is Anchor) {
      if (p == _anchor) {
        return position;
      }
      return positionOf(Vector2(p.x * size.x, p.y * size.y));
    }
    if (p is Offset) {
      return positionOf(Vector2(p.dx, p.dy));
    }
    throw ArgumentError(p);
  }

  /// Convert local coordinates of a point [p] inside the component into
  /// the global (world) coordinate space. Point [p] can be either a
  /// [Vector2], an [Anchor] (relative to component's [size]), or an
  /// [Offset].
  Vector2 absolutePositionOf(dynamic p) {
    var point = positionOf(p);
    var ancestor = parent;
    while (ancestor != null) {
      if (ancestor is PositionComponent) {
        point = ancestor.positionOf(point);
      }
      ancestor = ancestor.parent;
    }
    return point;
  }

  /// Transform [point] from the parent's coordinate space into the local
  /// coordinates.
  Vector2 toLocal(Vector2 point) => _transform.globalToLocal(point);

  /// Transform [point] from the global (world) coordinate space into the
  /// local coordinates. This can be used, for example, to detect whether
  /// a specific point on the screen lies within this [PositionComponent],
  /// and where exactly it is.
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
  Vector2 get topLeftPosition => positionOf(Anchor.topLeft);
  set topLeftPosition(Vector2 point) {
    position += point - topLeftPosition;
  }

  /// The position of the center of the component's bounding rectangle
  /// in the parent's coordinates.
  Vector2 get center => positionOf(Anchor.center);
  set center(Vector2 point) {
    position += point - center;
  }

  /// The [anchor]'s position in absolute (world) coordinates.
  Vector2 get absolutePosition => absolutePositionOf(_anchor);

  /// Get the absolute top left position regardless of whether it is a child or not
  Vector2 get absoluteTopLeftPosition => absolutePositionOf(Anchor.topLeft);

  /// Get the absolute center of the component
  Vector2 get absoluteCenter => absolutePositionOf(Anchor.center);

  //----------------------------------------------------------------------------
  // Mutators
  //----------------------------------------------------------------------------

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

  //----------------------------------------------------------------------------
  // Private
  //----------------------------------------------------------------------------

  /// Internal handler which is called automatically whenever either
  /// the [size] or [scale] change.
  void _onModifiedSizeOrScale() {
    _scaledSize.x = _size.x * scale.x.abs();
    _scaledSize.y = _size.y * scale.y.abs();
  }

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
      final p1 = absolutePositionOf(Anchor.topLeft);
      final x1str = p1.x.toStringAsFixed(precision);
      final y1str = p1.y.toStringAsFixed(precision);
      debugTextPaint.render(
        canvas,
        'x:$x1str y:$y1str',
        Vector2(-10 * (precision + 3), -15),
      );
      // print coordinates at the bottom-right corner
      final p2 = absolutePositionOf(Anchor.bottomRight);
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
} // ignore: number-of-methods
