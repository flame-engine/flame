import '../components/base_component.dart';
import 'effects.dart';

export './move_effect.dart';
export './rotate_effect.dart';
export './scale_effect.dart';
export './sequence_effect.dart';

class EffectsHandler {
  /// The effects that should run on the component
  final List<ComponentEffect> _effects = [];

  /// The effects that should be added on the next update iteration
  final List<ComponentEffect> _addLater = [];

  void update(double dt) {
    _effects.addAll(_addLater);
    _addLater.clear();
    _effects.removeWhere((e) => e.hasCompleted());
    _effects.where((e) => !e.isPaused).forEach((e) {
      e.update(dt);
      if (e.hasCompleted()) {
        e.setComponentToEndState();
        e.onComplete?.call();
      }
    });
  }

  /// Add an effect to the handler
  void add(ComponentEffect effect, BaseComponent component) {
    _addLater.add(effect..initialize(component));
  }

  /// Mark an effect for removal
  void removeEffect(ComponentEffect effect) {
    effect.dispose();
  }

  /// Remove all effects
  void clearEffects() {
    _addLater.forEach(removeEffect);
    _effects.forEach(removeEffect);
  }

  /// Get a list of non removed effects
  List<ComponentEffect> get effects {
    return List<ComponentEffect>.from(_effects)
      ..addAll(_addLater)
      ..where((e) => !e.hasCompleted());
  }
}
