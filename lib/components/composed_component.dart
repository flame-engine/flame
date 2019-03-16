import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

/// A mixin that helps you to make a `Component` wraps other components. It is useful to group visual components through a hierarchy. When implemented, makes every item in its `components` collection field be updated and rendered with the same conditions.
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
mixin ComposedComponent on Component {
  OrderedSet<Component> components =
      OrderedSet(Comparing.on((c) => c.priority()));

  @override
  render(Canvas canvas) {
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
    this.components.add(c);

    if (this is Resizable) {
      // first time resize
      Resizable thisResizable = this as Resizable;
      if (thisResizable.size != null) {
        c.resize(thisResizable.size);
      }
    }
  }

  List<Resizable> children() =>
      this.components.where((r) => r is Resizable).cast<Resizable>().toList();
}
