import 'dart:math';
import 'package:flutter/widgets.dart' show EdgeInsets;

import '../../../components.dart';
import '../../../extensions.dart';
import '../../gestures/events.dart';
import 'joystick_element.dart';

enum JoystickDirection {
  up,
  upLeft,
  upRight,
  right,
  down,
  downRight,
  downLeft,
  left,
  idle,
}

class JoystickComponent extends PositionComponent with Draggable, HasGameRef {
  @override
  final bool isHud = true;

  late final JoystickElement knob;
  late final JoystickElement? background;

  /// The percentage [0.0, 1.0] the knob is dragged from the center to the edge
  double intensity = 0.0;

  /// The amount the knob is dragged from the center
  Vector2 get delta => knob.position;

  late final double radius;

  final EdgeInsets? margin;

  final bool _definedPosition;

  JoystickComponent({
    required this.knob,
    this.background,
    this.margin,
    Vector2? position,
    double? size,
    Anchor anchor = Anchor.center,
  })  : assert(
          size != null || background != null,
          'Either size or background must be defined',
        ),
        assert(
        margin != null || position != null,
        'Either margin or position must be defined',
        ),
        _definedPosition = position != null,
        super(
          size: background?.size ?? Vector2.all(size ?? 0),
          position: position,
          anchor: anchor,
        ) {
    radius = this.size.x / 2;
  }

  @override
  Future<void> onLoad() async {
    if (!_definedPosition) {
      final margin = this.margin!;
      final x = margin.left != 0
          ? margin.left + size.x/2
          : gameRef.viewport.effectiveSize.x - margin.right - size.x/2;
      final y = margin.top != 0
          ? margin.top + size.y/2
          : gameRef.viewport.effectiveSize.y - margin.bottom - size.y/2;
      final center = Vector2(x, y);
      position = Anchor.center.toOtherAnchorPosition(center, anchor, size);
    }
    if (background != null) {
      addChild(background!);
    }
    addChild(knob);
  }

  @override
  void update(double dt) {
    super.update(dt);
    intensity = knob.position.length2 / radius * radius;
  }

  void _clampKnob() {
    knob.position.clampScalar(-radius, radius);
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    knob.position = center - info.eventPosition.widget;
    _clampKnob();
    return false;
  }

  @override
  bool onDragUpdate(_, DragUpdateInfo info) {
    knob.position.add(info.delta.global);
    _clampKnob();
    return true;
  }

  @override
  bool onDragEnd(_, __) {
    knob.position.setZero();
    return true;
  }

  @override
  bool onDragCancel(_) {
    knob.position.setZero();
    return true;
  }

  static const double _eighthOfPi = pi / 8;
  final _circleStart = Vector2(0.0, 1.0);

  JoystickDirection get direction {
    if (delta.isZero()) {
      return JoystickDirection.idle;
    }

    // Since angleTo doesn't care about "direction" of the angle we have to use
    // angleToSigned and create an only increasing angle by removing negative
    // angles from 2*pi.
    var knobAngle = delta.angleToSigned(_circleStart);
    knobAngle = knobAngle < 0 ? 2 * pi + knobAngle : knobAngle;
    if (knobAngle >= 0 && knobAngle <= _eighthOfPi) {
      return JoystickDirection.up;
    } else if (knobAngle > 1 * _eighthOfPi && knobAngle <= 3 * _eighthOfPi) {
      return JoystickDirection.upRight;
    } else if (knobAngle > 3 * _eighthOfPi && knobAngle <= 5 * _eighthOfPi) {
      return JoystickDirection.right;
    } else if (knobAngle > 5 * _eighthOfPi && knobAngle <= 7 * _eighthOfPi) {
      return JoystickDirection.downRight;
    } else if (knobAngle > 7 * _eighthOfPi && knobAngle <= 9 * _eighthOfPi) {
      return JoystickDirection.down;
    } else if (knobAngle > 9 * _eighthOfPi && knobAngle <= 11 * _eighthOfPi) {
      return JoystickDirection.downLeft;
    } else if (knobAngle > 11 * _eighthOfPi && knobAngle <= 13 * _eighthOfPi) {
      return JoystickDirection.left;
    } else if (knobAngle > 13 * _eighthOfPi && knobAngle <= 15 * _eighthOfPi) {
      return JoystickDirection.upLeft;
    } else if (knobAngle > 15 * _eighthOfPi) {
      return JoystickDirection.up;
    } else {
      return JoystickDirection.idle;
    }
  }
}
