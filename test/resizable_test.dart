import 'dart:ui';

import 'package:test/test.dart';

import 'package:flame/game.dart';
import 'package:flame/components/debug_component.dart';
import 'package:flame/components/resizable.dart';

class MyComponent extends DebugComponent with Resizable {
  String name;
  List<MyComponent> myChildren;

  MyComponent(this.name, {this.myChildren = const []});

  @override
  List<Resizable> children() => myChildren;
}

class MyGame extends BaseGame {}

Size size = const Size(1.0, 1.0);

void main() {
  group('resizable test', () {
    test('propagate resize to children', () {
      MyComponent a = new MyComponent('a');
      MyComponent b = new MyComponent('b', myChildren: [a]);
      b.resize(size);
      expect(a.size, size);
    });

    test('game calls resize on add', () {
      MyComponent a = new MyComponent('a');
      MyGame game = new MyGame();
      game.resize(size);
      game.add(a);
      expect(a.size, size);
    });

    test('game calls resize after added', () {
      MyComponent a = new MyComponent('a');
      MyGame game = new MyGame();
      game.add(a);
      game.resize(size);
      expect(a.size, size);
    });
  });
}
