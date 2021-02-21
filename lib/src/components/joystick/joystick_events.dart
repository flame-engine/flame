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
  final double intensity;
  final double radAngle;

  JoystickDirectionalEvent({
    this.directional,
    this.intensity = 0.0,
    this.radAngle = 0.0,
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
