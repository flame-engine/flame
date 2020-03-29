import 'dart:ui';

import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';

class Box2DGame extends BaseGame {
  final Box2DComponent box;
  final List<BodyComponent> _addLater = [];

  Box2DGame(this.box) : super();

  @override
  void add(Component c) {
    if(c is BodyComponent) {
      box.add(c);
    } else {
      super.add(c);
    }
  }

  @override
  void addLater(Component c) {
    if(c is BodyComponent) {
      _addLater.add(c);
    } else {
      super.addLater(c);
    }
  }

  @override
  void update(double t) {
    super.update(t);
    box.update(t);
    box.components
        .where((c) => c.destroy()).toList()
        .forEach((c) => box.remove(c));
    box.addAll(_addLater);
    _addLater.clear();
  }

  @override
  void render(Canvas c) {
    super.render(c);
    box.render(c);
  }
}
