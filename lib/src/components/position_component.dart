import 'dart:ui' hide Offset;
import 'dart:math' as math;

import '../anchor.dart';
import '../extensions/offset.dart';
import '../extensions/vector2.dart';
import '../../game.dart';
import 'base_component.dart';
import 'component.dart';

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
  /// The position of this component on the screen (relative to the anchor).
  Vector2 position = Vector2.zero();

  /// If the component has a [PositionComponent] as a parent it will be
  /// added here
  PositionComponent positionParent;

  /// X position of this component on the screen (relative to the anchor).
  double get x => position.x;
  set x(double x) => position.x = x;

  /// Y position of this component on the screen (relative to the anchor).
  double get y => position.y;
  set y(double y) => position.y = y;

  /// The size that this component is rendered with.
  /// This is not necessarily the source size of the asset.
  Vector2 size = Vector2.zero();

  /// Width (size) that this component is rendered with.
  double get width => size.x;
  set width(double width) => size.x = width;

  /// Height (size) that this component is rendered with.
  double get height => size.y;
  set height(double height) => size.y = height;

  /// Get the relative top left position regardless of the anchor and angle
  Vector2 get topLeftPosition => anchor.translate(position, size);

  /// Get the absolute top left position regardless of whether it is a child or not
  Vector2 get absoluteTopLeftPosition {
    return (positionParent?.absoluteTopLeftPosition ?? Vector2.zero()) +
        topLeftPosition;
  }

  /// Set the top left position regardless of the anchor
  set topLeftPosition(Vector2 position) {
    this.position = position + (anchor.toVector2..multiply(size));
  }

  /// Angle (with respect to the x-axis) this component should be rendered with.
  /// It is rotated around its anchor.
  double angle = 0.0;

  /// Anchor point for this component. This is where flame "grabs it".
  /// The [position] is relative to this point inside the component.
  /// The [angle] is rotated around this point.
  Anchor anchor = Anchor.topLeft;

  /// Whether this component should be flipped on the X axis before being rendered.
  bool renderFlipX = false;

  /// Whether this component should be flipped ofn the Y axis before being rendered.
  bool renderFlipY = false;

  /// Returns the relative position/size of this component.
  /// Relative because it might be translated by their parents (which is not considered here).
  Rect toRect() => topLeftPosition.toPositionedRect(size);

  /// Mutates position and size using the provided [rect] as basis.
  /// This is a relative rect, same definition that [toRect] use (therefore both methods are compatible, i.e. setByRect ∘ toRect = identity).
  void setByRect(Rect rect) {
    size.setValues(rect.width, rect.height);
    topLeftPosition = rect.topLeft.toVector2();
  }

  @override
  bool checkOverlap(Vector2 absolutePoint) {
    final point = absolutePoint -
        (positionParent?.absoluteTopLeftPosition ?? Vector2.zero());
    final corners = _rotatedCorners();
    for (int i = 0; i < corners.length; i++) {
      final previousCorner = corners[i];
      final corner = corners[(i + 1) % corners.length];
      final isOutside =
          (corner.x - previousCorner.x) * (point.y - previousCorner.y) -
                  (point.x - previousCorner.x) * (corner.y - previousCorner.y) >
              0;
      if (isOutside) {
        // Point is outside of convex polygon (only used for rectangles so far)
        return false;
      }
    }
    return true;
  }

  List<Vector2> _rotatedCorners() {
    // Rotates the corner around [position]
    Vector2 rotateCorner(Vector2 corner) {
      return Vector2(
        math.cos(angle) * (corner.x - position.x) -
            math.sin(angle) * (corner.y - position.y) +
            position.x,
        math.sin(angle) * (corner.x - position.x) +
            math.cos(angle) * (corner.y - position.y) +
            position.y,
      );
    }

    // Counter-clockwise direction
    return [
      rotateCorner(topLeftPosition), // Top-left
      rotateCorner(topLeftPosition + Vector2(0.0, size.y)), // Bottom-left
      rotateCorner(topLeftPosition + size), // Bottom-right
      rotateCorner(topLeftPosition + Vector2(size.x, 0.0)), // Top-right
    ];
  }

  double angleTo(PositionComponent c) => position.angleTo(c.position);

  double distance(PositionComponent c) => position.distanceTo(c.position);

  @override
  void renderDebugMode(Canvas canvas) {
    canvas.drawRect(size.toRect(), debugPaint);
    debugTextConfig.render(
      canvas,
      'x: ${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}',
      Vector2(-50, -15),
    );

    final Rect rect = toRect();
    final dx = rect.right;
    final dy = rect.bottom;
    debugTextConfig.render(
      canvas,
      'x:${dx.toStringAsFixed(2)} y:${dy.toStringAsFixed(2)}',
      Vector2(width - 50, height),
    );
  }

  @override
  void prepareCanvas(Canvas canvas) {
    canvas.translate(x, y);
    canvas.rotate(angle);
    final Vector2 delta = -anchor.toVector2
      ..multiply(size);
    canvas.translate(delta.x, delta.y);

    // Handle inverted rendering by moving center and flipping.
    if (renderFlipX || renderFlipY) {
      canvas.translate(width / 2, height / 2);
      canvas.scale(renderFlipX ? -1.0 : 1.0, renderFlipY ? -1.0 : 1.0);
      canvas.translate(-width / 2, -height / 2);
    }
  }

  @override
  Future<void> addChild(Component child, {Game gameRef}) async {
    super.addChild(child, gameRef: gameRef);
    if (child is PositionComponent) {
      child.positionParent = this;
    }
  }
}
