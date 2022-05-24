import 'package:flame/src/components/component.dart';

class Event {
  bool handled = false;

  bool continuePropagation = false;

  void deliverToComponents<T extends Component, E extends Event>(
    Component root,
    void Function(T, E) handler,
  ) {
    assert(this is E);
    for (final child
        in root.descendants(reversed: true, includeSelf: true).whereType<T>()) {
      continuePropagation = false;
      handler(child, this as E);
      if (!continuePropagation) {
        break;
      }
    }
  }
}
