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
  final Transform2D _transform;

  /// The position of this component's anchor on the screen.
  Vector2 get position => _transform.position;
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

  /// The scale factor of this component
  Vector2 get scale => _transform.scale;
  set scale(Vector2 scale) => _transform.scale = scale;

  /// Anchor point for this component. This is where flame "grabs it".
  /// The [position] is relative to this point inside the component.
  /// The [angle] is rotated around this point.
  Anchor _anchor;
  Anchor get anchor => _anchor;
  set anchor(Anchor a) {
    _anchor = a;
    _updateOffset();
  }

  /// The logical size of the component. The game assumes that this is the
  /// approximate size of the object that will be drawn on the screen.
  /// This size will therefore be used for collision detection and tap
  /// handling.
  final NotifyingVector2 _size;
  Vector2 get size => _size;
  set size(Vector2 size) => _size.setFrom(size);

  /// Width (size) that this component is rendered with.
  double get width => scaledSize.x;
  set width(double width) => _size.x = width / scale.x.abs();

  /// Height (size) that this component is rendered with.
  double get height => scaledSize.y;
  set height(double height) => _size.y = height / scale.y.abs();

  /// Cache to store the calculated scaled size
  final Vector2 _scaledSize;
  Vector2 get scaledSize => _scaledSize;

  void _updateScaledSize() {
    _scaledSize.x = _size.x * scale.x.abs();
    _scaledSize.y = _size.y * scale.y.abs();
  }

  void _updateOffset() {
    _transform.offset = Vector2(-_anchor.x * _size.x, -_anchor.y * _size.y);
  }

  /// Get the absolute position, with the anchor taken into consideration
  Vector2 get absolutePosition => absoluteParentPosition + position;

  /// Get the relative top left position regardless of the anchor and angle
  Vector2 get topLeftPosition {
    return _anchor.toOtherAnchorPosition(
      position,
      Anchor.topLeft,
      scaledSize,
    );
  }

  /// Set the top left position regardless of the anchor
  set topLeftPosition(Vector2 position) {
    this.position = position + (anchor.toVector2()..multiply(scaledSize));
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
      return anchor.toOtherAnchorPosition(position, Anchor.center, scaledSize)
        ..rotate(angle, center: absolutePosition);
    }
  }

  /// Get the absolute center of the component
  Vector2 get absoluteCenter => absoluteParentPosition + center;

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

  /// Whether this component should be flipped on the X axis before being rendered.
  bool renderFlipX = false;

  /// Whether this component should be flipped ofn the Y axis before being rendered.
  bool renderFlipY = false;

  PositionComponent({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double angle = 0.0,
    Anchor anchor = Anchor.topLeft,
    this.renderFlipX = false,
    this.renderFlipY = false,
    int? priority,
  })  : _transform = Transform2D()
          ..position = position ?? Vector2.zero()
          ..angle = angle
          ..scale = scale ?? Vector2(1, 1),
        _anchor = anchor,
        _size = NotifyingVector2()..setFrom(size ?? Vector2.zero()),
        _scaledSize = Vector2(0, 0),
        super(priority: priority) {
    _size.addListener(_handleSizeOrAnchorChange);
    _size.addListener(_updateScaledSize);
    _transform.scale.addListener(_updateScaledSize);
    _updateOffset();
    _updateScaledSize();
  }

  void _handleSizeOrAnchorChange() {
    _updateOffset();
  }

  /// The total transformation matrix for the component. This matrix combines
  /// translation, rotation and scale transforms into a single entity. The
  /// matrix is cached and gets recalculated only as necessary.
  Matrix4 get transformMatrix => _transform.transformMatrix;

  /// Transform `point` from local coordinates into the parent coordinate space.
  Vector2 localToParent(Vector2 point) => _transform.localToGlobal(point);

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
  Vector2 parentToLocal(Vector2 point) => _transform.globalToLocal(point);

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
    canvas.drawRect(scaledSize.toRect(), debugPaint);
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
    // TODO(st-pasha): remove this, using `flipHorizontallyAroundCenter()` instead
    if (renderFlipX || renderFlipY) {
      final size = scaledSize;
      canvas.translate(size.x / 2, size.y / 2);
      canvas.scale(
        renderFlipX ? -1.0 : 1.0,
        renderFlipY ? -1.0 : 1.0,
      );
      canvas.translate(-size.x / 2, -size.y / 2);
    }
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
