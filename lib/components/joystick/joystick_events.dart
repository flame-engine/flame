enum JoystickMoveDirectional {
  MOVE_UP,
  MOVE_UP_LEFT,
  MOVE_UP_RIGHT,
  MOVE_RIGHT,
  MOVE_DOWN,
  MOVE_DOWN_RIGHT,
  MOVE_DOWN_LEFT,
  MOVE_LEFT,
  IDLE
}

enum ActionEvent { DOWN, UP, MOVE, CANCEL }

class JoystickDirectionalEvent {
  final JoystickMoveDirectional directional;
  final double intensity;
  final double radAngle;

  JoystickDirectionalEvent({
    this.directional,
    this.intensity = 0.0,
    this.radAngle = 0.0,
  });

  static JoystickMoveDirectional calculateDirectionalByDegrees(double degrees) {
    if (degrees > -22.5 && degrees <= 22.5) {
      return JoystickMoveDirectional.MOVE_RIGHT;
    } else if (degrees > 22.5 && degrees <= 67.5) {
      return JoystickMoveDirectional.MOVE_DOWN_RIGHT;
    } else if (degrees > 67.5 && degrees <= 112.5) {
      return JoystickMoveDirectional.MOVE_DOWN;
    } else if (degrees > 112.5 && degrees <= 157.5) {
      return JoystickMoveDirectional.MOVE_DOWN_LEFT;
    } else if ((degrees > 157.5 && degrees <= 180) ||
        (degrees >= -180 && degrees <= -157.5)) {
      return JoystickMoveDirectional.MOVE_LEFT;
    } else if (degrees > -157.5 && degrees <= -112.5) {
      return JoystickMoveDirectional.MOVE_UP_LEFT;
    } else if (degrees > -112.5 && degrees <= -67.5) {
      return JoystickMoveDirectional.MOVE_UP;
    } else if (degrees > -67.5 && degrees <= -22.5) {
      return JoystickMoveDirectional.MOVE_UP_RIGHT;
    } else {
      return JoystickMoveDirectional.IDLE;
    }
  }

  @override
  String toString() {
    return 'JoystickDirectionalEvent{directional: $directional, intensity: $intensity, radAngle: $radAngle}';
  }
}

class JoystickActionEvent {
  final int id;
  final double intensity;
  final double radAngle;
  final ActionEvent event;

  JoystickActionEvent({
    this.id,
    this.intensity = 0.0,
    this.radAngle = 0.0,
    this.event,
  });

  @override
  String toString() {
    return 'JoystickActionEvent{id: $id, intensity: $intensity, radAngle: $radAngle, event: $event}';
  }
}
