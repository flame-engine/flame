import 'dart:math' as math;
import 'dart:ui' hide Offset;

import '../anchor.dart';
import '../extensions/offset.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import 'base_component.dart';
import 'component.dart';
import 'mixins/hitbox.dart';

/// A [Component] implementation that represents a component that has a
/// specific, possibly dynamic position on the screen.
///
/// It represents a rectangle of dimension [size], on the [position],
/// rotated around its [anchor] with angle [angle].
///
/// It also uses the [anchor] property to properly position itself.
///
/// A [PositionComponent] can have children. The children are all updated and
/// rendered automatically when this is updated and rendered.
/// They are translated by this component's (x,y). They do not need to fit
/// within this component's (width, height).
abstract class PositionComponent extends BaseComponent {
  /// The matrix that combines all the transforms into a single entity.
  /// This matrix is cached and automatically recalculated when the position/
  /// rotation/scale of the component changes.
  final Matrix4 _transformMatrix;

  /// This variable keeps track whether the transform matrix is "dirty" and
  /// needs to be recalculated. It ensures that if the user updates multiple
  /// properties at once, such as [x], [y] and [angle], then the transform
  /// matrix will be recalculated only once, usually during the rendering stage.
  bool _recalculateTransform;

  /// The position of this component's anchor on the screen.
  late _NotifyingVector2 _position;
  Vector2 get position => _position;
  set position(Vector2 position) {
    _recalculateTransform = true;
    _position.setFrom(position);
  }

  /// X position of this component's anchor on the screen.
  double get x => _position.x;
  set x(double x) {
    _recalculateTransform = true;
    _position.x = x;
  }

  /// Y position of this component's anchor on the screen.
  double get y => _position.y;
  set y(double y) {
    _recalculateTransform = true;
    _position.y = y;
  }

  /// The logical size of the component. The game assumes that this is the
  /// approximate size of the object that will be drawn on the screen.
  /// This size will therefore be used for collision detection and tap
  /// handling.
  late _NotifyingVector2 _size;
  Vector2 get size => _size;
  set size(Vector2 size) {
    _recalculateTransform = true;
    _size.setFrom(size);
  }

  /// Width (size) that this component is rendered with.
  double get width => _size.x;
  set width(double width) {
    _recalculateTransform = true;
    _size.x = width;
  }

  /// Height (size) that this component is rendered with.
  double get height => size.y;
  set height(double height) {
    _recalculateTransform = true;
    _size.y = height;
  }

  /// Get the absolute position, with the anchor taken into consideration
  Vector2 get absolutePosition => absoluteParentPosition + position;

  /// Get the relative top left position regardless of the anchor and angle
  Vector2 get topLeftPosition {
    return _anchor.toOtherAnchorPosition(
      position,
      Anchor.topLeft,
      size,
    );
  }

  /// Set the top left position regardless of the anchor
  set topLeftPosition(Vector2 position) {
    this.position = position + (_anchor.toVector2()..multiply(size));
  }

  /// Get the absolute top left position regardless of whether it is a child or not
  Vector2 get absoluteTopLeftPosition {
    final p = parent;
    if (p is PositionComponent) {
      return p.absoluteTopLeftPosition + topLeftPosition;
    } else {
      return topLeftPosition;
    }
  }

  /// Get the position that everything in this component is positioned in relation to
  /// If this component has no parent the absolute parent position is the origin,
  /// otherwise it's the parents absolute top left position
  Vector2 get absoluteParentPosition {
    final p = parent;
    if (p is PositionComponent) {
      return p.absoluteTopLeftPosition;
    } else {
      return Vector2.zero();
    }
  }

  /// Get the position of the center of the component's bounding rectangle
  Vector2 get center {
    if (_anchor == Anchor.center) {
      return position;
    } else {
      return _anchor.toOtherAnchorPosition(position, Anchor.center, size)
        ..rotate(angle, center: absolutePosition);
    }
  }

  /// Get the absolute center of the component
  Vector2 get absoluteCenter => absoluteParentPosition + center;

  /// Rotation angle (in radians) of the component. The component will be
  /// rotated around its anchor point in the clockwise direction if the
  /// angle is positive, or counterclockwise if the angle is negative.
  double _angle;
  double get angle => _angle;
  set angle(double a) {
    _recalculateTransform = true;
    _angle = a;
  }

  /// Scale factor applied to the component.
  double _scaleX;
  double _scaleY;

  /// Flip the component horizontally around its anchor point.
  void flipHorizontally() {
    _recalculateTransform = true;
    _scaleX = -_scaleX;
  }

  /// Flip the component horizontally around its center line.
  void flipHorizontallyAroundCenter() {
    final delta = (1 - 2 * _anchor.x) * _size.x * _scaleX;
    _position.x += delta * math.cos(_angle);
    _position.y += delta * math.sin(_angle);
    _scaleX = -_scaleX;
    _recalculateTransform = true;
  }

  /// Flip the component vertically around its anchor point.
  void flipVertically() {
    _recalculateTransform = true;
    _scaleY = -_scaleY;
  }

  /// Flip the component vertically around its center line.
  void flipVerticallyAroundCenter() {
    final delta = (1 - 2 * _anchor.y) * _size.y * _scaleY;
    _position.x += -delta * math.sin(_angle);
    _position.y += delta * math.cos(_angle);
    _scaleY = -_scaleY;
    _recalculateTransform = true;
  }

  /// Anchor point for this component. This is where flame "grabs it".
  /// The [position] is relative to this point inside the component.
  /// The [angle] is rotated around this point.
  Anchor _anchor;
  Anchor get anchor => _anchor;
  set anchor(Anchor a) {
    _anchor = a;
    _recalculateTransform = true;
  }

  /// Whether this component should be flipped on the X axis before being rendered.
  bool renderFlipX = false;

  /// Whether this component should be flipped ofn the Y axis before being rendered.
  bool renderFlipY = false;

  /// Returns the relative position/size of this component.
  /// Relative because it might be translated by their parents (which is not considered here).
  Rect toRect() => topLeftPosition.toPositionedRect(size);

  /// Returns the absolute position/size of this component.
  /// Absolute because it takes any possible parent position into consideration.
  Rect toAbsoluteRect() => absoluteTopLeftPosition.toPositionedRect(size);

  /// Mutates position and size using the provided [rect] as basis.
  /// This is a relative rect, same definition that [toRect] use
  /// (therefore both methods are compatible, i.e. setByRect ∘ toRect = identity).
  void setByRect(Rect rect) {
    size.setValues(rect.width, rect.height);
    topLeftPosition = rect.topLeft.toVector2();
  }

  PositionComponent({
    Vector2? position,
    Vector2? size,
    double angle = 0.0,
    Anchor anchor = Anchor.topLeft,
    this.renderFlipX = false,
    this.renderFlipY = false,
    int? priority,
  })  : _anchor = anchor,
        _angle = angle,
        _scaleX = 1.0,
        _scaleY = 1.0,
        _transformMatrix = Matrix4.identity(),
        _recalculateTransform = true,
        super(priority: priority) {
    _position = _NotifyingVector2(this)..setFrom(position ?? Vector2.zero());
    _size = _NotifyingVector2(this)..setFrom(size ?? Vector2.zero());
  }

  /// The total transformation matrix for the component. This matrix combines
  /// translation, rotation and scale transforms into a single entity. The
  /// matrix is cached and gets recalculated only as necessary.
  Matrix4 get transformMatrix {
    if (_recalculateTransform) {
      final m = _transformMatrix.storage;
      final cosA = math.cos(_angle);
      final sinA = math.sin(_angle);
      final deltaX = -_anchor.x * _size.x;
      final deltaY = -_anchor.y * _size.y;
      m[0] = cosA * _scaleX;
      m[1] = sinA * _scaleX;
      m[4] = -sinA * _scaleY;
      m[5] = cosA * _scaleY;
      m[12] = _position.x + m[0] * deltaX + m[4] * deltaY;
      m[13] = _position.y + m[1] * deltaX + m[5] * deltaY;
      _recalculateTransform = false;
    }
    return _transformMatrix;
  }

  /// Transform `point` from local coordinates into the parent coordinate space.
  Vector2 localToParent(Vector2 point) {
    final m = transformMatrix.storage;
    return Vector2(
      m[0] * point.x + m[4] * point.y + m[12],
      m[1] * point.x + m[5] * point.y + m[13],
    );
  }

  /// Transform `point` from local coordinates into the global (screen)
  /// coordinate space. For example, local point (0, 0) corresponds to
  /// the top left corner of the component. Thus,
  /// `localToAbsolute(Vector2(0, 0))` returns the screen coordinates
  /// of the top left corner of the component.
  Vector2 localToAbsolute(Vector2 point) {
    var c = parent;
    while (c != null) {
      if (c is PositionComponent) {
        return c.localToAbsolute(localToParent(point));
      }
      c = c.parent;
    }
    return localToParent(point);
  }

  /// Transform `point` from the parent's coordinate space into the local
  /// coordinates.
  Vector2 parentToLocal(Vector2 point) {
    // Here we rely on the fact that in the transform matrix only elements
    // `m[0]`, `m[1]`, `m[4]`, `m[5]`, `m[12]`, and `m[13]` are modified.
    // This greatly simplifies computation of the inverse matrix.
    final m = transformMatrix.storage;
    final det = m[0] * m[5] - m[1] * m[4];
    return Vector2(
      ((point.x - m[12]) * m[5] - (point.y - m[13]) * m[4]) / det,
      ((point.y - m[13]) * m[0] - (point.x - m[12]) * m[1]) / det,
    );
  }

  /// Transform `point` from the global (screen) coordinate space into the
  /// local coordinates. This can be used, for example, to detect whether
  /// a specific point on the screen lies within this `PositionComponent`,
  /// and where exactly it is.
  Vector2 absoluteToLocal(Vector2 point) {
    var c = parent;
    while (c != null) {
      if (c is PositionComponent) {
        return parentToLocal(c.absoluteToLocal(point));
      }
      c = c.parent;
    }
    return parentToLocal(point);
  }

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

  double angleTo(PositionComponent c) => position.angleTo(c.position);

  double distance(PositionComponent c) => position.distanceTo(c.position);

  @override
  void renderDebugMode(Canvas canvas) {
    if (this is Hitbox) {
      (this as Hitbox).renderHitboxes(canvas);
    }
    canvas.drawRect(size.toRect(), debugPaint);
    debugTextPaint.render(
      canvas,
      'x: ${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}',
      Vector2(-50, -15),
    );

    final rect = toRect();
    final dx = rect.right;
    final dy = rect.bottom;
    debugTextPaint.render(
      canvas,
      'x:${dx.toStringAsFixed(2)} y:${dy.toStringAsFixed(2)}',
      Vector2(width - 50, height),
    );
  }

  @override
  void preRender(Canvas canvas) {
    canvas.transform(transformMatrix.storage);

    // Handle inverted rendering by moving center and flipping.
    if (renderFlipX || renderFlipY) {
      canvas.translate(width / 2, height / 2);
      canvas.scale(renderFlipX ? -1.0 : 1.0, renderFlipY ? -1.0 : 1.0);
      canvas.translate(-width / 2, -height / 2);
    }
  }
} // ignore: number-of-methods

class _NotifyingVector2 extends Vector2 {
  final PositionComponent _parent;

  _NotifyingVector2(this._parent) : super.zero();

  @override
  void setValues(double x, double y) {
    super.setValues(x, y);
    _parent._recalculateTransform = true;
  }

  @override
  void setFrom(Vector2 v) {
    super.setFrom(v);
    _parent._recalculateTransform = true;
  }

  @override
  void setZero() {
    super.setZero();
    _parent._recalculateTransform = true;
  }

  @override
  void splat(double arg) {
    super.splat(arg);
    _parent._recalculateTransform = true;
  }

  @override
  set x(double x) {
    super.x = x;
    _parent._recalculateTransform = true;
  }

  @override
  set y(double y) {
    super.y = y;
    _parent._recalculateTransform = true;
  }
}
