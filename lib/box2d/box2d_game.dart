import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';

class Box2DGame extends BaseGame {
  final Box2DComponent box;
  final List<BodyComponent> _addLater = [];

  Box2DGame(this.box) : super();

  @override
  void add(Component c) {
    super.add(c);
    if(c is BodyComponent) {
      box.add(c);
    }
  }

  @override
  void addLater(Component c) {
    super.addLater(c);
    if(c is BodyComponent) {
      _addLater.add(c);
    }
  }

  @override
  void update(double t) {
    super.update(t);
    components
        .where((c) => c is BodyComponent && c.destroy())
        .forEach((body) => box.remove(body));
    box.addAll(_addLater);
    _addLater.clear();
  }
}
