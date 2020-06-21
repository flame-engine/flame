import 'dart:ui';

import 'package:flame/game/base_game.dart';
import 'package:test/test.dart';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';

class MyComponent extends PositionComponent with Resizable {
  String name;
  List<MyComponent> myChildren;

  MyComponent(this.name, {this.myChildren = const []});

  @override
  Iterable<Resizable> resizableChildren() => myChildren;

  @override
  void render(Canvas c) {}
}

class MyGame extends BaseGame {}

Size size = const Size(1.0, 1.0);

void main() {
  group('resizable test', () {
    test('propagate resize to children', () {
      final MyComponent a = MyComponent('a');
      final MyComponent b = MyComponent('b', myChildren: [a]);
      b.resize(size);
      expect(a.size, size);
    });

    test('game calls resize on add', () {
      final MyComponent a = MyComponent('a');
      final MyGame game = MyGame();
      game.resize(size);
      game.add(a);
      expect(a.size, size);
    });

    test('game calls resize after added', () {
      final MyComponent a = MyComponent('a');
      final MyGame game = MyGame();
      game.add(a);
      game.resize(size);
      expect(a.size, size);
    });
  });
}
