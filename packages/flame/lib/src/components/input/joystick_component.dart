import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/src/components/input/hud_margin_component.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:meta/meta.dart';

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

class JoystickComponent extends HudMarginComponent with Draggable {
  late final PositionComponent? knob;
  late final PositionComponent? background;

  /// The percentage `[0.0, 1.0]` the knob is dragged from the center to the
  /// edge.
  double intensity = 0.0;

  /// The amount the knob is dragged from the center, scaled to fit inside the
  /// bounds of the joystick.
  final Vector2 delta = Vector2.zero();

  /// The total amount the knob is dragged from the center of the joystick.
  final Vector2 _unscaledDelta = Vector2.zero();

  /// The percentage, presented as a [Vector2], and direction that the knob is
  /// currently pulled from its base position to a edge of the joystick.
  Vector2 get relativeDelta => delta / knobRadius;

  /// The radius from the center of the knob to the edge of as far as the knob
  /// can be dragged.
  late double knobRadius;

  /// The position where the knob rests.
  late Vector2 _baseKnobPosition;

  JoystickComponent({
    this.knob,
    this.background,
    super.margin,
    super.position,
    double? size,
    double? knobRadius,
    Anchor super.anchor = Anchor.center,
    super.children,
    super.priority,
  })  : assert(
          size != null || background != null,
          'Either size or background must be defined',
        ),
        assert(
          (knob?.position.isZero() ?? true) &&
              (background?.position.isZero() ?? true),
          'Positions should not be set for the knob or the background',
        ),
        super(
          size: background?.size ?? Vector2.all(size ?? 0),
        ) {
    this.knobRadius = knobRadius ?? this.size.x / 2;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    assert(
      knob != null,
      'The knob has to either be passed in as an argument or set in onLoad',
    );

    knob!.anchor = Anchor.center;
    knob!.position = size / 2;
    _baseKnobPosition = knob!.position.clone();

    if (background != null) {
      add(background!);
    }
    add(knob!);
  }

  @override
  void update(double dt) {
    final knobRadius2 = knobRadius * knobRadius;
    delta.setFrom(_unscaledDelta);
    if (delta.isZero() && _baseKnobPosition != knob!.position) {
      knob!.position = _baseKnobPosition;
    } else if (delta.length2 > knobRadius2) {
      delta.scaleTo(knobRadius);
    }
    if (!delta.isZero()) {
      knob!.position
        ..setFrom(_baseKnobPosition)
        ..add(delta);
    }
    intensity = delta.length2 / knobRadius2;
  }

  @override
  bool onDragStart(DragStartInfo info) {
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    _unscaledDelta.add(info.delta.viewport);
    return false;
  }

  @override
  bool onDragEnd(_) {
    onDragCancel();
    return false;
  }

  @override
  bool onDragCancel() {
    _unscaledDelta.setZero();
    return false;
  }

  static const double _eighthOfPi = pi / 8;

  JoystickDirection get direction {
    if (delta.isZero()) {
      return JoystickDirection.idle;
    }

    var knobAngle = delta.screenAngle();
    // Since screenAngle and angleTo doesn't care about "direction" of the angle
    // we have to use angleToSigned and create an only increasing angle by
    // removing negative angles from 2*pi.
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
