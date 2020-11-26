import 'dart:ui' hide Offset;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../anchor.dart';
import '../extensions/offset.dart';
import '../extensions/vector2.dart';
import '../text_config.dart';
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
abstract class PositionComponent extends Component {
  /// The position of this component on the screen (relative to the anchor).
  Vector2 position = Vector2.zero();

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

  /// Get the top left position regardless of the anchor and angle
  Vector2 get topLeftPosition => anchor.translate(position, size);

  /// Set the top left position regardless of the anchor
  set topLeftPosition(Vector2 position) {
    this.position = position + (anchor.relativePosition..multiply(size));
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

  /// This is set by the BaseGame to tell this component to render additional debug information,
  /// like borders, coordinates, etc.
  /// This is very helpful while debugging. Set your BaseGame debugMode to true.
  /// You can also manually override this for certain components in order to identify issues.
  bool debugMode = false;

  Color get debugColor => const Color(0xFFFF00FF);

  Paint get _debugPaint => Paint()
    ..color = debugColor
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  TextConfig get debugTextConfig => TextConfig(color: debugColor, fontSize: 12);

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
  bool checkOverlap(Vector2 point) {
    final corners = _rotatedCorners();
    corners.add(corners.first);
    for (int i = 1; i < corners.length; i++) {
      final lastCorner = corners[i - 1];
      final corner = corners[i];
      final isOutside = (corner.x - lastCorner.x) * (point.y - lastCorner.y) -
              (point.x - lastCorner.x) * (corner.y - lastCorner.y) >
          0;
      if (isOutside) {
        // Point is outside of convex polygon (only used for rectangles so far)
        return false;
      }
    }
    return true;
  }

  List<Vector2> _rotatedCorners() {
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

  void renderDebugMode(Canvas canvas) {
    canvas.drawRect(size.toRect(), _debugPaint);
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

  void _prepareCanvas(Canvas canvas) {
    canvas.translate(x, y);

    canvas.rotate(angle);
    final Vector2 delta = -anchor.relativePosition
      ..multiply(size);
    canvas.translate(delta.x, delta.y);

    // Handle inverted rendering by moving center and flipping.
    if (renderFlipX || renderFlipY) {
      canvas.translate(width / 2, height / 2);
      canvas.scale(renderFlipX ? -1.0 : 1.0, renderFlipY ? -1.0 : 1.0);
      canvas.translate(-width / 2, -height / 2);
    }
  }

  @mustCallSuper
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    children.forEach((child) => child.onGameResize(gameSize));
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    _prepareCanvas(canvas);

    if (debugMode) {
      renderDebugMode(canvas);
    }

    canvas.save();
    children.forEach((c) => _renderChild(canvas, c));
    canvas.restore();
  }

  void _renderChild(Canvas canvas, Component c) {
    if (!c.loaded) {
      return;
    }
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }
}
