import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class HasTappablesGame extends FlameGame with HasTappableComponents {}

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
  final withTappables = FlameTester(() => HasTappablesGame());

  group('composable component test', () {
    withTappables.test('child is not added until the component is prepared',
        (game) async {
      final child = MyTap();
      final wrapper = MyComposed();
      await wrapper.add(child);

      expect(child.isPrepared, false);
      expect(child.isLoaded, false);
      expect(wrapper.contains(child), false);

      await game.ensureAdd(wrapper);

      expect(child.isPrepared, true);
      expect(child.isLoaded, true);
      expect(wrapper.contains(child), true);
    });

    withTappables.test('removes the child from the component', (game) async {
      final child = MyTap();
      final wrapper = MyComposed();
      await game.ensureAdd(wrapper);

      await wrapper.add(child);
      expect(wrapper.contains(child), false);
      wrapper.update(0); // children are only added on the next tick
      expect(wrapper.contains(child), true);

      wrapper.remove(child);
      expect(wrapper.contains(child), true);
      wrapper.update(0); // children are only removed on the next tick
      expect(wrapper.contains(child), false);
    });

    withTappables.test(
      'when child is async loading, adds the child to the component after loading',
      (game) async {
        final child = MyAsyncChild();
        final wrapper = MyComposed();
        await game.ensureAdd(wrapper);

        final future = wrapper.add(child);
        expect(wrapper.contains(child), false);
        await future;
        expect(wrapper.contains(child), false);
        wrapper.update(0);
        expect(wrapper.contains(child), true);
      },
    );

    withTappables.test('taps and resizes children', (game) async {
      final child = MyTap();
      final wrapper = MyComposed();

      game.onGameResize(size);
      child.size.setValues(1.0, 1.0);
      await game.ensureAdd(wrapper);
      await wrapper.ensureAdd(child);
      game.onTapDown(1, createTapDownEvent(game));

      expect(child.gameSize, size);
      expect(child.tapped, true);
    });

    withTappables.test('add multiple children with addAll', (game) async {
      final children = List.generate(10, (_) => MyTap());
      final wrapper = MyComposed();
      await wrapper.addAll(children);

      await game.ensureAdd(wrapper);
      expect(wrapper.children.length, children.length);
    });

    withTappables.test('tap on offset children', (game) async {
      final child = MyTap()
        ..position.setFrom(Vector2.all(100))
        ..size.setFrom(Vector2.all(100));
      final wrapper = MyComposed()
        ..position.setFrom(Vector2.all(100))
        ..size.setFrom(Vector2.all(300));

      game.onGameResize(size);
      await game.ensureAdd(wrapper);
      await wrapper.ensureAdd(child);
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

    withTappables.test('updates and renders children', (game) async {
      final child = MyTap();
      final wrapper = MyComposed();

      await wrapper.ensureAdd(child);
      await game.ensureAdd(wrapper);
      game.render(MockCanvas());

      expect(child.rendered, true);
      expect(child.updated, true);
    });

    withTappables.test('initially same debugMode as parent', (game) async {
      final child = MyTap();
      final wrapper = MyComposed();
      wrapper.debugMode = true;

      wrapper.add(child);
      await game.ensureAdd(wrapper);

      expect(child.debugMode, true);
      wrapper.debugMode = false;
      expect(child.debugMode, true);
    });

    withTappables.test('initially same debugMode as parent when Component',
        (game) async {
      final child = MyTap();
      final wrapper = MySimpleComposed();
      wrapper.debugMode = true;

      wrapper.add(child);
      await game.ensureAdd(wrapper);

      expect(child.debugMode, true);
    });
  });
}
