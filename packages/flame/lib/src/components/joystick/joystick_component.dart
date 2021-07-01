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
  @override
  bool isHud = true;

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
}

class JoystickComponent extends JoystickController {
  @override
  int priority;

  JoystickComponent({
    required BaseGame gameRef,
    List<JoystickAction> actions = const [],
    JoystickDirectional? directional,
    this.priority = 0,
  }) {
    if (directional != null) {
      addChild(directional, gameRef: gameRef);
    }
    actions.forEach((action) => addChild(action, gameRef: gameRef));
  }

  void addAction(JoystickAction action) {
    addChild(action, gameRef: gameRef);
  }

  void removeAction(int actionId) {
    final action = children
        .firstWhere((e) => e is JoystickAction && e.actionId == actionId);
    children.remove(action);
  }
}
