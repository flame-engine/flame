import 'package:flame/src/components/component.dart';

class Event {
  bool handled = false;

  bool continuePropagation = false;

  void deliverToComponents<T, E>(Component root, void Function(T, E) handler) {
    for (final child in root
        .descendants(reversed: true, includeSelf: true)
        .whereType<T>()) {
      continuePropagation = false;
      handler(child, this as E);
      if (!continuePropagation) {
        break;
      }
    }
  }
}
