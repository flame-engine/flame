import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/box2d/contact_callbacks.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game/base_game.dart';

class Box2DGame extends BaseGame {
  final Box2DComponent box;
  final List<BodyComponent> _addLater = [];
  final ContactCallbacks _contactCallbacks = ContactCallbacks();

  Box2DGame(this.box) : super() {
    add(box);
    box.world.setContactListener(_contactCallbacks);
  }

  @override
  void add(Component c) {
    if (c is BodyComponent) {
      preAdd(c);
      box.add(c);
    } else {
      super.add(c);
    }
  }

  @override
  void addLater(Component c) {
    if (c is BodyComponent) {
      preAdd(c);
      _addLater.add(c);
    } else {
      super.addLater(c);
    }
  }

  @override
  void update(double t) {
    super.update(t);
    box.components
        .where((c) => c.destroy())
        .toList()
        .forEach((c) => box.remove(c));
    box.addAll(_addLater);
    _addLater.clear();
  }

  void addContactCallback(ContactCallback callback) {
    _contactCallbacks.register(callback);
  }

  void removeContactCallback(ContactCallback callback) {
    _contactCallbacks.deregister(callback);
  }

  void clearContactCallbacks() {
    _contactCallbacks.clear();
  }
}
