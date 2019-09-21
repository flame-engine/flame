import 'dart:ui';

import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/tapeable.dart';
import 'package:flame/game.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import 'component.dart';
import 'mixins/resizable.dart';

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
mixin ComposedComponent on Component, HasGameRef, Tapeable {
  OrderedSet<Component> components =
      OrderedSet(Comparing.on((c) => c.priority()));

  @override
  void render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) => _renderComponent(canvas, comp));
    canvas.restore();
  }

  void _renderComponent(Canvas canvas, Component c) {
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  @override
  void update(double t) {
    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
  }

  void add(Component c) {
    if (gameRef is BaseGame) {
      (gameRef as BaseGame).preAdd(c);
    }
    components.add(c);
  }

  // this is an important override for the Tapeable mixin
  @override
  Iterable<Tapeable> tapeableChildren() => _findT<Tapeable>();

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
