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

  JoystickActionEvent(
      {this.id, this.intensity = 0.0, this.radAngle = 0.0, this.event});

  @override
  String toString() {
    return 'JoystickActionEvent{id: $id, intensity: $intensity, radAngle: $radAngle, event: $event}';
  }
}
