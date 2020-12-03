import 'dart:ui';

import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import '../effects/effects.dart';
import '../effects/effects_handler.dart';
import '../extensions/vector2.dart';
import '../game.dart';
import '../text_config.dart';
import 'component.dart';

/// This can be extended to represent a basic Component for your game.
///
/// The difference between this and [Component] is that the [BaseComponent] can
/// have children, handle effects and can be used to see whether a position on
/// the screen is on your component, which is useful for handling gestures.
abstract class BaseComponent extends Component {
  final EffectsHandler _effectsHandler = EffectsHandler();

  final OrderedSet<Component> _children =
      OrderedSet(Comparing.on((c) => c.priority));

  OrderedSet<Component> get children =>
      OrderedSet<Component>()..addAll(_children);

  /// This is set by the BaseGame to tell this component to render additional debug information,
  /// like borders, coordinates, etc.
  /// This is very helpful while debugging. Set your BaseGame debugMode to true.
  /// You can also manually override this for certain components in order to identify issues.
  bool debugMode = false;

  Color get debugColor => const Color(0xFFFF00FF);

  Paint get debugPaint => Paint()
    ..color = debugColor
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  TextConfig get debugTextConfig => TextConfig(color: debugColor, fontSize: 12);

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

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);

    if (debugMode) {
      renderDebugMode(canvas);
    }

    canvas.save();
    _children.forEach((c) => _renderChild(canvas, c));
    canvas.restore();
  }

  void renderDebugMode(Canvas canvas) {}

  void _renderChild(Canvas canvas, Component c) {
    if (!c.loaded) {
      return;
    }
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  @protected
  void prepareCanvas(Canvas canvas) {}

  @mustCallSuper
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    _children.forEach((child) => child.onGameResize(gameSize));
  }

  /// Called to check whether the point is to be counted as within the component
  /// It needs to be overridden to have any effect, like it is in the
  /// [PositionComponent]
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

  /// Uses the game passed in, or uses the game from [HasGameRef] otherwise,
  /// to prepare the child component before it is added to the list of children
  void addChild(Component c, {Game gameRef}) {
    assert(gameRef != null || this is HasGameRef);
    gameRef ??= (this as HasGameRef).gameRef;
    if (gameRef is BaseGame) {
      gameRef.prepare(c);
    }
    _children.add(c);
  }

  bool removeChild(Component c) {
    return _children.remove(c);
  }

  void clearChildren() {
    _children.clear();
  }

  /// This method first calls the passed handler on the leaves in the tree, the children without any children of their own.
  /// Then it continues through all other children.
  /// The propagation continues until the handler returns false, which means "do not continue", or when the handler has been called with all children
  ///
  /// This method is important to be used by the engine to propagate actions like rendering, taps, etc,
  /// but you can call it yourself if you need to apply an action to the whole component chain.
  /// It will only consider components of type T in the hierarchy, so use T = Component to target everything.
  bool propagateToChildren<T extends Component>(
    bool Function(T) handler,
  ) {
    bool shouldContinue = true;
    for (Component child in _children) {
      if (child is T && child is BaseComponent) {
        shouldContinue = child.propagateToChildren(handler);
        if (shouldContinue) {
          shouldContinue = handler(child);
        }
        if (!shouldContinue) {
          break;
        }
      }
    }
    return shouldContinue;
  }
}
