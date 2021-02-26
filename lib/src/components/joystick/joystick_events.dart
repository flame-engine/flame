enum JoystickMoveDirectional {
  moveUp,
  moveUpLeft,
  moveUpRight,
  moveRight,
  moveDown,
  moveDownRight,
  moveDownLeft,
  moveLeft,
  idle,
}

enum ActionEvent { down, up, move, cancel }

class JoystickDirectionalEvent {
  final JoystickMoveDirectional directional;

  /// How much the knob was moved, from 0 (center) to 1 (edge).
  final double intensity;

  /// The direction the knob was moved towards.
  final double angle;

  JoystickDirectionalEvent({
    this.directional,
    this.intensity = 0.0,
    this.angle = 0.0,
  });

  static JoystickMoveDirectional calculateDirectionalByDegrees(double degrees) {
    if (degrees > -22.5 && degrees <= 22.5) {
      return JoystickMoveDirectional.moveRight;
    } else if (degrees > 22.5 && degrees <= 67.5) {
      return JoystickMoveDirectional.moveDownRight;
    } else if (degrees > 67.5 && degrees <= 112.5) {
      return JoystickMoveDirectional.moveDown;
    } else if (degrees > 112.5 && degrees <= 157.5) {
      return JoystickMoveDirectional.moveDownLeft;
    } else if ((degrees > 157.5 && degrees <= 180) ||
        (degrees >= -180 && degrees <= -157.5)) {
      return JoystickMoveDirectional.moveLeft;
    } else if (degrees > -157.5 && degrees <= -112.5) {
      return JoystickMoveDirectional.moveUpLeft;
    } else if (degrees > -112.5 && degrees <= -67.5) {
      return JoystickMoveDirectional.moveUp;
    } else if (degrees > -67.5 && degrees <= -22.5) {
      return JoystickMoveDirectional.moveUpRight;
    } else {
      return JoystickMoveDirectional.idle;
    }
  }

  @override
  String toString() {
    return 'JoystickDirectionalEvent{directional: $directional, intensity: $intensity, angle: $angle}';
  }
}

class JoystickActionEvent {
  final int id;

  /// How much the knob was moved, from 0 (center) to 1 (edge).
  final double intensity;

  /// The direction the knob was moved towards.
  final double angle;
  final ActionEvent event;

  JoystickActionEvent({
    this.id,
    this.intensity = 0.0,
    this.angle = 0.0,
    this.event,
  });

  @override
  String toString() {
    return 'JoystickActionEvent{id: $id, intensity: $intensity, angle: $angle, event: $event}';
  }
}
