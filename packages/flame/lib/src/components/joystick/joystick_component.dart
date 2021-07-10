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

  final bool _definedPosition;

  final EdgeInsets? margin;

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
      final x = margin.right != 0
          ? margin.right
          : gameRef.viewport.effectiveSize.x - margin.right;
      final y = margin.top != 0
          ? margin.top
          : gameRef.viewport.effectiveSize.y - margin.bottom;
      position.setValues(x, y);
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

  static const double _sixteenthOfPi = pi / 16;

  JoystickDirection get direction {
    if (delta.isZero()) {
      return JoystickDirection.idle;
    } else if (angle >= 0 * _sixteenthOfPi && angle <= 1 * _sixteenthOfPi) {
      return JoystickDirection.right;
    } else if (angle > 1 * _sixteenthOfPi && angle <= 3 * _sixteenthOfPi) {
      return JoystickDirection.downRight;
    } else if (angle > 3 * _sixteenthOfPi && angle <= 5 * _sixteenthOfPi) {
      return JoystickDirection.down;
    } else if (angle > 5 * _sixteenthOfPi && angle <= 7 * _sixteenthOfPi) {
      return JoystickDirection.downLeft;
    } else if (angle > 7 * _sixteenthOfPi && angle <= 9 * _sixteenthOfPi) {
      return JoystickDirection.left;
    } else if (angle > 9 * _sixteenthOfPi && angle <= 11 * _sixteenthOfPi) {
      return JoystickDirection.upLeft;
    } else if (angle > 11 * _sixteenthOfPi && angle <= 13 * _sixteenthOfPi) {
      return JoystickDirection.up;
    } else if (angle > 13 * _sixteenthOfPi && angle <= 15 * _sixteenthOfPi) {
      return JoystickDirection.upRight;
    } else if (angle > 15 * _sixteenthOfPi) {
      return JoystickDirection.right;
    } else {
      return JoystickDirection.idle;
    }
  }
}
