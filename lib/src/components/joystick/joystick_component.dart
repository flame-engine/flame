import '../../../components.dart';
import '../../game/base_game.dart';
import '../mixins/has_game_ref.dart';
import 'joystick_action.dart';
import 'joystick_directional.dart';
import 'joystick_events.dart';

mixin JoystickListener {
  void joystickChangeDirectional(JoystickDirectionalEvent event);
  void joystickAction(JoystickActionEvent event);
}

abstract class JoystickController extends BaseComponent
    with HasGameRef<BaseGame>, Draggable {
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
  bool isHud = true;
}

class JoystickComponent extends JoystickController {
  final List<JoystickAction> actions;
  final JoystickDirectional directional;
  @override
  int priority;

  JoystickComponent({
    this.actions,
    this.directional,
    this.priority = 0,
  }) {
    addChild(directional);
    actions.forEach((action) => addChild(action));
  }

  void addAction(JoystickAction action) {
    if (gameRef?.size != null) {
      action.initialize(gameRef.size, this);
      actions?.add(action);
    }
  }

  void removeAction(int actionId) {
    actions?.removeWhere((action) => action.actionId == actionId);
  }
}
