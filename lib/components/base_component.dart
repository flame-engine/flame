import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import '../effects/effects.dart';
import '../effects/effects_handler.dart';
import '../extensions/vector2.dart';
import '../game.dart';
import 'component.dart';

/// This can be extended to represent a basic Component for your game.
///
/// The difference between this and [Component] is that this can have children,
/// handles effects on your component and can be used to see whether a point is
/// on your component, which is useful for handling the effect of gestures.
abstract class BaseComponent extends Component {
  final EffectsHandler _effectsHandler = EffectsHandler();

  final OrderedSet<Component> children =
      OrderedSet(Comparing.on((c) => c.priority));

  /// This method is called periodically by the game engine to request that your component updates itself.
  ///
  /// The time [dt] in seconds (with microseconds precision provided by Flutter) since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update your state considering this.
  /// All components on [BaseGame] are always updated by the same amount. The time each one takes to update adds up to the next update cycle.
  @mustCallSuper
  @override
  void update(double dt) {
    _effectsHandler.update(dt);
  }

  /// Called to check whether the point should be counted as a tap on the component
  bool checkOverlap(Vector2 point) => false;

  /// Add an effect to the component
  void addEffect(ComponentEffect effect) {
    _effectsHandler.add(effect, this);
  }

  /// Mark an effect for removal on the component
  void removeEffect(ComponentEffect effect) {
    _effectsHandler.removeEffect(effect);
  }

  /// Remove all effects
  void clearEffects() {
    _effectsHandler.clearEffects();
  }

  /// Get a list of non removed effects
  List<ComponentEffect> get effects => _effectsHandler.effects;

  /// Uses the game passed in to prepare the child component before it is added
  /// to the list of children
  void addChild(Game gameRef, Component c) {
    if (gameRef is BaseGame) {
      gameRef.prepare(c);
    }
    children.add(c);
  }

  /// This method first calls the passed function on itself and then recursively propagates it to every children
  /// and grandchildren (and so on) of this component, either until it has propagated through the whole tree or
  /// if the handler at any point returns false.
  ///
  /// This method is important to be used by the engine to propagate actions like rendering, taps, etc,
  /// but you can call it yourself if you need to apply an action to the whole component chain.
  /// It will only consider components of type T in the hierarchy, so use T = Component to target everything.
  bool propagateToChildren<T extends Component>(
    bool Function(T) handler,
  ) {
    bool shouldContinue = true;
    if (this is T) {
      shouldContinue = handler(this as T);
      if (!shouldContinue) {
        return false;
      }
    }
    for (Component child in children) {
      if (child is T) {
        shouldContinue = handler(child);
        if (shouldContinue && child is BaseComponent) {
          shouldContinue = child.propagateToChildren(handler);
        } else {
          break;
        }
      }
    }
    return shouldContinue;
  }
}
