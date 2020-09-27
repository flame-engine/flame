import 'dart:ui';

import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import '../game/base_game.dart';
import 'component.dart';
import 'mixins/has_game_ref.dart';
import 'mixins/resizable.dart';
import 'mixins/tapable.dart';

/// A mixin that helps you to make a `Component` wraps other components. It is useful to group visual components through a hierarchy.
/// When implemented, makes every item in its `components` collection field be updated and rendered with the same conditions.
///
/// Example of usage, where visibility of two components are handled by a wrapper:
///
/// ```dart
///  class GameOverPanel extends PositionComponent with Resizable, ComposedComponent {
///   bool visible = false;
///
///   GameOverText gameOverText;
///   GameOverButton gameOverButton;
///
///   GameOverPanel(Image spriteImage) : super() {
///     gameOverText = GameOverText(spriteImage); // GameOverText is a Component
///     gameOverButton = GameOverButton(spriteImage); // GameOverRestart is a SpriteComponent
///
///     components..add(gameOverText)..add(gameOverButton);
///   }
///
///   @override
///   void render(Canvas canvas) {
///     if (visible) {
///       super.render(canvas);
///     } // If not, neither of its `components` will be rendered
///   }
/// }
/// ```
///
mixin ComposedComponent on Component, HasGameRef, Tapable {
  OrderedSet<Component> components =
      OrderedSet(Comparing.on((c) => c.priority()));

  final List<Component> _removeLater = [];

  @override
  void render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) => _renderComponent(canvas, comp));
    canvas.restore();
  }

  void _renderComponent(Canvas canvas, Component c) {
    if (!c.loaded()) {
      return;
    }
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  @override
  void update(double t) {
    _removeLater.forEach((c) => components.remove(c));
    _removeLater.clear();

    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
  }

  void add(Component c) {
    if (gameRef is BaseGame) {
      (gameRef as BaseGame).preAdd(c);
    }
    components.add(c);
  }

  void markToRemove(Component component) {
    _removeLater.add(component);
  }

  // this is an important override for the Tapable mixin
  @override
  Iterable<Tapable> tapableChildren() => _findT<Tapable>();

  // this is an important override for the Resizable mixin
  Iterable<Resizable> resizableChildren() => _findT<Resizable>();

  // Finds all children of type T, recursively
  Iterable<T> _findT<T>() => components.expand((c) {
        final List<T> r = [];
        if (c is T) {
          r.add(c as T);
        }
        if (c is ComposedComponent) {
          r.addAll(c._findT<T>());
        }
        return r;
      }).cast();
}
