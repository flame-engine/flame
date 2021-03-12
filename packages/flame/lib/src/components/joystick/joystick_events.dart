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
  /// The direction the knob was moved towards, converted to a set of 8
  /// cardinal directions.
  final JoystickMoveDirectional directional;

  /// How much the knob was moved, from 0 (center) to 1 (edge).
  final double intensity;

  /// The direction the knob was moved towards (in radians).
  ///
  /// It uses the trigonometric circle convention (i.e. start on the
  /// positive x-axis and rotates counter-clockwise).
  final double angle;

  JoystickDirectionalEvent({
    required this.directional,
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
}

class JoystickActionEvent {
  /// The id of this action as defined in the setup code.
  final int id;

  /// What action was performed in this button.
  final ActionEvent event;

  /// How much the knob was moved, from 0 (center) to 1 (edge).
  final double intensity;

  /// The direction the knob was moved towards (in radians).
  ///
  /// It uses the trigonometric circle convention (i.e. start on the
  /// positive x-axis and rotates counter-clockwise).
  final double angle;

  JoystickActionEvent({
    required this.id,
    required this.event,
    this.intensity = 0.0,
    this.angle = 0.0,
  });
}
