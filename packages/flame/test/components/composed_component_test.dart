import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/test.dart';
import 'package:test/test.dart';

class MyGame extends FlameGame with HasTappableComponents {
  MyGame() : super() {
    onGameResize(Vector2.zero());
  }
}

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
  Future<void> onLoad() async {
    await super.onLoad();
    return Future.value();
  }
}

class MyComposed extends PositionComponent with HasGameRef, Tappable {}

class MySimpleComposed extends Component with HasGameRef, Tappable {}

// composed w/o HasGameRef
class PlainComposed extends Component {}

Vector2 size = Vector2.all(300);

void main() {
  group('composable component test', () {
    test('child is not added until the component is prepared', () async {
      final child = MyTap();
      final wrapper = MyComposed();
      await wrapper.add(child);

      expect(child.isPrepared, false);
      expect(child.isLoaded, false);
      expect(wrapper.contains(child), false);

      final game = MyGame();
      await game.add(wrapper);
      wrapper.update(0); // children are only added on the next tick

      expect(child.isPrepared, true);
      expect(child.isLoaded, true);
      expect(wrapper.contains(child), true);
    });

    test('removes the child from the component', () async {
      final child = MyTap();
      final wrapper = MyComposed();
      final game = MyGame();
      await game.add(wrapper);

      await wrapper.add(child);
      expect(wrapper.contains(child), false);
      wrapper.update(0); // children are only added on the next tick
      expect(wrapper.contains(child), true);

      wrapper.remove(child);
      expect(wrapper.contains(child), true);
      wrapper.update(0); // children are only removed on the next tick
      expect(wrapper.contains(child), false);
    });

    test(
      'when child is async loading, adds the child to the component after loading',
      () async {
        final child = MyAsyncChild();
        final wrapper = MyComposed();
        final game = MyGame();
        await game.add(wrapper);

        final future = wrapper.add(child);
        expect(wrapper.contains(child), false);
        await future;
        expect(wrapper.contains(child), false);
        wrapper.update(0);
        expect(wrapper.contains(child), true);
      },
    );

    test('taps and resizes children', () {
      final game = MyGame();
      final child = MyTap();
      final wrapper = MyComposed();

      game.onGameResize(size);
      child.size.setValues(1.0, 1.0);
      game.add(wrapper);
      wrapper.add(child);
      game.update(0.0);
      game.onTapDown(1, createTapDownEvent(game));

      expect(child.gameSize, size);
      expect(child.tapped, true);
    });

    test('add multiple children with addAll', () async {
      final game = MyGame();
      final children = List.generate(10, (_) => MyTap());
      final wrapper = MyComposed();
      await wrapper.addAll(children);

      game.onGameResize(size);
      await game.add(wrapper);
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

      game.onGameResize(size);
      game.add(wrapper);
      wrapper.add(child);
      game.update(0.0);
      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition: const Offset(250, 250),
        ),
      );

      expect(child.gameSize, size);
      expect(child.tapped, true);
      expect(child.tapTimes, 1);
    });

    test('updates and renders children', () async {
      final game = MyGame();
      final child = MyTap();
      final wrapper = MyComposed();

      wrapper.add(child);
      await game.add(wrapper);
      game.update(0.0);
      game.render(MockCanvas());

      expect(child.rendered, true);
      expect(child.updated, true);
    });

    test('initially same debugMode as parent', () async {
      final game = MyGame();
      final child = MyTap();
      final wrapper = MyComposed();
      wrapper.debugMode = true;

      await wrapper.add(child);
      await game.add(wrapper);
      game.update(0.0);

      expect(child.debugMode, true);
      wrapper.debugMode = false;
      expect(child.debugMode, true);
    });

    test('initially same debugMode as parent when Component', () async {
      final game = MyGame();
      final child = MyTap();
      final wrapper = MySimpleComposed();
      wrapper.debugMode = true;

      wrapper.add(child);
      await game.add(wrapper);
      game.update(0.0);

      expect(child.debugMode, true);
    });
  });
}
