import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Draws a [Joint] so that the constraint itself is visible, not only the
/// bodies it connects.
///
/// The line runs between the two anchor points, with a dot on each anchor.
/// The renderer removes itself once the joint is destroyed.
class JointRenderer extends Component {
  JointRenderer({required this.joint, Color? color, super.priority = -1})
    : color = color ?? ExampleColors.slate;

  final Joint joint;
  final Color color;

  static const _anchorRadius = 0.22;

  late final Paint linePaint = Paint()
    ..color = color.withValues(alpha: 0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.1;

  late final Paint anchorPaint = Paint()..color = color.withValues(alpha: 0.95);

  /// The anchor of the first body in world coordinates.
  Vector2 get anchorA => joint.bodyA.worldPoint(joint.localAnchorA);

  /// The anchor of the second body in world coordinates.
  Vector2 get anchorB => joint.bodyB.worldPoint(joint.localAnchorB);

  @override
  void update(double dt) {
    if (!joint.isValid) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!joint.isValid) {
      return;
    }
    renderJoint(canvas, anchorA.toOffset(), anchorB.toOffset());
  }

  /// Override this to draw something else than a line between the anchors.
  void renderJoint(Canvas canvas, Offset anchorA, Offset anchorB) {
    canvas
      ..drawLine(anchorA, anchorB, linePaint)
      ..drawCircle(anchorA, _anchorRadius, anchorPaint)
      ..drawCircle(anchorB, _anchorRadius, anchorPaint);
  }
}

/// Draws a [MouseJoint] from the body it drags to the target it is pulling
/// towards, which is what makes the joint's spring visible.
class MouseJointRenderer extends JointRenderer {
  MouseJointRenderer({required MouseJoint super.joint, super.color});

  MouseJoint get mouseJoint => joint as MouseJoint;

  @override
  void render(Canvas canvas) {
    if (!joint.isValid) {
      return;
    }
    // Body B is the dragged body, and body A is only the anchor that the
    // joint is attached to, so the interesting line is target to body.
    final target = mouseJoint.target.toOffset();
    final body = anchorB.toOffset();
    canvas
      ..drawLine(target, body, linePaint)
      ..drawCircle(body, JointRenderer._anchorRadius, anchorPaint)
      ..drawCircle(target, JointRenderer._anchorRadius, anchorPaint)
      ..drawCircle(
        target,
        JointRenderer._anchorRadius * 2.5,
        linePaint,
      );
  }
}

/// Draws the axis of a [PrismaticJoint] between its lower and upper limit, so
/// that the range the body can travel is visible.
class PrismaticJointRenderer extends JointRenderer {
  PrismaticJointRenderer({
    required PrismaticJoint super.joint,
    required this.axis,
    required this.anchor,
    super.color,
  });

  PrismaticJoint get prismaticJoint => joint as PrismaticJoint;

  /// The axis that the joint moves along, in world coordinates.
  final Vector2 axis;

  /// The point that the axis passes through, in world coordinates.
  final Vector2 anchor;

  final Vector2 _lower = Vector2.zero();
  final Vector2 _upper = Vector2.zero();

  @override
  void render(Canvas canvas) {
    if (!joint.isValid) {
      return;
    }
    _lower
      ..setFrom(axis)
      ..scale(prismaticJoint.lowerLimit)
      ..add(anchor);
    _upper
      ..setFrom(axis)
      ..scale(prismaticJoint.upperLimit)
      ..add(anchor);
    canvas
      ..drawLine(_lower.toOffset(), _upper.toOffset(), linePaint)
      ..drawCircle(_lower.toOffset(), JointRenderer._anchorRadius, anchorPaint)
      ..drawCircle(_upper.toOffset(), JointRenderer._anchorRadius, anchorPaint);
  }
}
