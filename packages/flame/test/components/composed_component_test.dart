import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

import '../util/mock_canvas.dart';
import '../util/mock_gesture_events.dart';

class MyGame extends BaseGame with HasTappableComponents {}

class MyTap extends PositionComponent with Tappable {
  late Vector2 gameSize;

  int tapTimes = 0;
  bool get tapped => tapTimes > 0;
  bool updated = false;
  bool rendered = false;

  @override
  void update(double dt) {
    super.update(dt);
    updated = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    rendered = true;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    this.gameSize = gameSize;
  }

  @override
  bool onTapDown(_) {
    ++tapTimes;
    return true;
  }
}

class MyAsyncChild extends MyTap {
  @override
  Future<void> onLoad() => Future.value();
}

class MyComposed extends PositionComponent with HasGameRef, Tappable {}

class MySimpleComposed extends BaseComponent with HasGameRef, Tappable {}

// composed w/o HasGameRef
class PlainComposed extends BaseComponent {}

Vector2 size = Vector2.all(300);

void main() {
  group('composable component test', () {
    test('adds the child to the component', () {
      final child = MyTap();
      final wrapper = MyComposed();
      wrapper.addChild(child);
      wrapper.update(0); // children are only added on the next tick

      expect(wrapper.containsChild(child), true);
    });

    test('removes the child from the component', () {
      final child = MyTap();
      final wrapper = MyComposed();

      wrapper.addChild(child);
      expect(wrapper.containsChild(child), false);
      wrapper.update(0); // children are only added on the next tick
      expect(wrapper.containsChild(child), true);

      wrapper.children.remove(child);
      expect(wrapper.containsChild(child), true);
      wrapper.update(0); // children are only removed on the next tick
      expect(wrapper.containsChild(child), false);
    });

    test(
      'when child is async loading, adds the child to the component after loading',
      () async {
        final child = MyAsyncChild();
        final wrapper = MyComposed();

        final future = wrapper.addChild(child);
        expect(wrapper.containsChild(child), false);
        await future;
        expect(wrapper.containsChild(child), false);
        wrapper.update(0);
        expect(wrapper.containsChild(child), true);
      },
    );

    test('taps and resizes children', () {
      final game = MyGame();
      final child = MyTap();
      final wrapper = MyComposed();

      game.onResize(size);
      child.size.setValues(1.0, 1.0);
      game.add(wrapper);
      wrapper.addChild(child);
      game.update(0.0);
      game.onTapDown(1, createTapDownEvent(game));

      expect(child.gameSize, size);
      expect(child.tapped, true);
    });

    test('add multiple children with addChildren', () {
      final game = MyGame();
      final children = List.generate(10, (_) => MyTap());
      final wrapper = MyComposed();
      wrapper.children.addChildren(children);

      game.onResize(size);
      game.add(wrapper);
      game.update(0.0);
      expect(wrapper.children.length, children.length);
    });

    test('tap on offset children', () {
      final game = MyGame();
      final child = MyTap()
        ..position.setFrom(Vector2.all(100))
        ..size.setFrom(Vector2.all(100));
      final wrapper = MyComposed()
        ..position.setFrom(Vector2.all(100))
        ..size.setFrom(Vector2.all(300));

      game.onResize(size);
      game.add(wrapper);
      wrapper.addChild(child);
      game.update(0.0);
      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          position: const Offset(250, 250),
        ),
      );

      expect(child.gameSize, size);
      expect(child.tapped, true);
      expect(child.tapTimes, 1);
    });

    test('updates and renders children', () {
      final game = MyGame();
      game.onResize(Vector2.all(100));
      final child = MyTap();
      final wrapper = MyComposed();

      wrapper.addChild(child);
      game.add(wrapper);
      game.update(0.0);
      game.render(MockCanvas());

      expect(child.rendered, true);
      expect(child.updated, true);
    });

    test('initially same debugMode as parent', () {
      final game = MyGame();
      game.onResize(Vector2.all(100));
      final child = MyTap();
      final wrapper = MyComposed();
      wrapper.debugMode = true;

      wrapper.addChild(child);
      game.add(wrapper);
      game.update(0.0);

      expect(child.debugMode, true);
      wrapper.debugMode = false;
      expect(child.debugMode, true);
    });
    test('initially same debugMode as parent when BaseComponent', () {
      final game = MyGame();
      game.onResize(Vector2.all(100));
      final child = MyTap();
      final wrapper = MySimpleComposed();
      wrapper.debugMode = true;

      wrapper.addChild(child);
      game.add(wrapper);
      game.update(0.0);

      expect(child.debugMode, true);
    });
    test('fail to add child if no gameRef can be acquired', () {
      final game = MyGame();
      game.onResize(Vector2.all(100));

      final parent = PlainComposed();

      // this is ok; when the parent is added to the game the children will
      // get mounted
      parent.addChild(MyTap());

      game.add(parent);
      game.update(0);

      // this is not ok, the child would never be mounted!
      expect(
        () => parent.addChild(MyTap()),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
