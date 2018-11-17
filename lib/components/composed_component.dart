
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/game.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

/// A component that turns lets your component be composed others
/// It resembles [BaseGame]. It has an [components] property and an [add] method
abstract class ComposedComponent implements Component {
  OrderedSet<Component> components = new OrderedSet(Comparing.on((c) => c.priority()));

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

    if(this is Resizable){
      // first time resize
      Resizable thisResizable = this as Resizable;
      if (thisResizable.size != null) {
        c.resize(thisResizable.size);
      }
    }
  }

}