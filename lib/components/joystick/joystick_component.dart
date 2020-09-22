import 'dart:ui';

import '../../game/base_game.dart';
import '../../gestures.dart';
import '../component.dart';
import '../mixins/has_game_ref.dart';
import 'joystick_action.dart';
import 'joystick_directional.dart';
import 'joystick_events.dart';

mixin JoystickListener {
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

  void onReceiveDrag(DragEvent drag) {}

  @override
  bool isHud() => true;
}

class JoystickComponent extends JoystickController {
  final List<JoystickAction> actions;
  final JoystickDirectional directional;
  final int componentPriority;

  JoystickComponent({
    this.actions,
    this.directional,
    this.componentPriority = 0,
  });

  void addAction(JoystickAction action) {
    if (gameRef?.size != null) {
      action.initialize(gameRef.size, this);
      actions?.add(action);
    }
  }

  void removeAction(int actionId) {
    actions?.removeWhere((action) => action.actionId == actionId);
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

  @override
  void onReceiveDrag(DragEvent event) {
    directional?.onReceiveDrag(event);
    actions?.forEach((action) => action.onReceiveDrag(event));
  }

  @override
  int priority() {
    return componentPriority;
  }
}
