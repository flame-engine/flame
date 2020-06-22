import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/joystick/Joystick_action.dart';
import 'package:flame/components/joystick/Joystick_directional.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/game/base_game.dart';

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

class JoystickDirectionalEvent {
  final JoystickMoveDirectional directional;
  final double intensity;
  final double radAngle;

  JoystickDirectionalEvent({
    this.directional,
    this.intensity = 0.0,
    this.radAngle = 0.0,
  });
}

enum ActionEvent { DOWN, UP, MOVE }

class JoystickActionEvent {
  final int id;
  final double intensity;
  final double radAngle;
  final ActionEvent event;

  JoystickActionEvent(
      {this.id, this.intensity = 0.0, this.radAngle = 0.0, this.event});
}

abstract class JoystickListener {
  void joystickChangeDirectional(JoystickDirectionalEvent event);
  void joystickAction(JoystickActionEvent event);
}

abstract class JoystickController extends Component with HasGameRef<BaseGame> {
  final List<JoystickListener> _observers = [];

  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _observers.forEach((o) => o.joystickChangeDirectional(event));
  }

  void joystickAction(JoystickActionEvent event) {
    _observers.forEach((o) => o.joystickAction(event));
  }

  void addObserver(JoystickListener listener) {
    _observers.add(listener);
  }

  @override
  bool isHud() => true;
}

class JoystickComponent extends JoystickController {
  final List<JoystickAction> actions;
  final JoystickDirectional directional;

  JoystickComponent({this.actions, this.directional});

  void addAction(JoystickAction action) {
    if (actions != null && gameRef?.size != null) {
      action.initialize(gameRef.size, this);
      actions.add(action);
    }
  }

  @override
  void render(Canvas canvas) {
    directional?.render(canvas);
    actions?.forEach((action) => action.render(canvas));
  }

  @override
  void update(double t) {
    directional?.update(t);
    actions?.forEach((action) => action.update(t));
  }

  @override
  void resize(Size size) {
    directional?.initialize(size, this);
    actions?.forEach((action) => action.initialize(size, this));
    super.resize(size);
  }
}
