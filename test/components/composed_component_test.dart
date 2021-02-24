import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

import '../util/mock_canvas.dart';

class MyGame extends BaseGame with HasTapableComponents {}

class MyTap extends PositionComponent with Tapable {
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
  bool onTapDown(TapDownDetails details) {
    ++tapTimes;
    return true;
  }
}

class MyAsyncChild extends MyTap {
  @override
  Future<void> onLoad() => Future.value();
}

class MyComposed extends PositionComponent with HasGameRef, Tapable {}

Vector2 size = Vector2.all(300);

void main() {
  group('composable component test', () {
    test('adds the child to the component', () {
      final MyTap child = MyTap();
      final MyComposed wrapper = MyComposed();
      wrapper.addChild(child);

      expect(true, wrapper.containsChild(child));
    });

    test('removes the child from the component', () {
      final MyTap child = MyTap();
      final MyComposed wrapper = MyComposed();
      wrapper.addChild(child);
      expect(true, wrapper.containsChild(child));

      wrapper.removeChild(child);
      expect(false, wrapper.containsChild(child));
    });

    test(
      'when child is async loading, adds the child to the component after loading',
      () async {
        final MyAsyncChild child = MyAsyncChild();
        final MyComposed wrapper = MyComposed();
        await wrapper.addChild(child);

        expect(true, wrapper.containsChild(child));
      },
    );

    test('taps and resizes children', () {
      final MyGame game = MyGame();
      final MyTap child = MyTap();
      final MyComposed wrapper = MyComposed();

      game.size.setFrom(size);
      game.add(wrapper);
      wrapper.addChild(child);
      game.update(0.0);
      game.onTapDown(1, TapDownDetails(globalPosition: const Offset(0.0, 0.0)));

      expect(child.gameSize, size);
      expect(child.tapped, true);
    });

    test('tap on offset children', () {
      final MyGame game = MyGame();
      final MyTap child = MyTap()
        ..position = Vector2.all(100)
        ..size = Vector2.all(100);
      final MyComposed wrapper = MyComposed()
        ..position = Vector2.all(100)
        ..size = Vector2.all(300);

      game.size.setFrom(size);
      game.add(wrapper);
      wrapper.addChild(child);
      game.update(0.0);
      game.onTapDown(1, TapDownDetails(globalPosition: const Offset(250, 250)));

      expect(child.gameSize, size);
      expect(child.tapped, true);
      expect(child.tapTimes, 1);
    });

    test('updates and renders children', () {
      final MyGame game = MyGame();
      final MyTap child = MyTap();
      final MyComposed wrapper = MyComposed();

      wrapper.addChild(child);
      game.add(wrapper);
      game.update(0.0);
      game.render(MockCanvas());

      expect(child.rendered, true);
      expect(child.updated, true);
    });
  });
}
