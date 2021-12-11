import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _HasTappablesGame extends FlameGame with HasTappables {}

class _MyTap extends PositionComponent with Tappable {
  late Vector2 gameSize;

  int tapTimes = 0;
  bool get tapped => tapTimes > 0;
  bool updated = false;
  bool rendered = false;

  @override
  void update(double dt) {
    updated = true;
  }

  @override
  void render(Canvas canvas) {
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
    return false;
  }
}

class _MyAsyncChild extends _MyTap {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    return Future.value();
  }
}

void main() {
  final size = Vector2.all(300);
  final withTappables = FlameTester(() => _HasTappablesGame());

  group('Composability', () {
    withTappables.test('child is not added until the component is prepared',
        (game) async {
      final child = Component();
      final wrapper = Component();
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
      final child = Component();
      final wrapper = Component();
      await game.ensureAdd(wrapper);

      await wrapper.add(child);
      expect(wrapper.contains(child), false);
      wrapper.updateTree(0); // children are only added on the next tick
      expect(wrapper.contains(child), true);

      wrapper.remove(child);
      expect(wrapper.contains(child), true);
      wrapper.updateTree(0); // children are only removed on the next tick
      expect(wrapper.contains(child), false);
    });

    withTappables.test(
      'when child is async loading, the child is added to the component after '
      'loading',
      (game) async {
        final child = _MyAsyncChild();
        final wrapper = Component();
        await game.ensureAdd(wrapper);

        final future = wrapper.add(child);
        expect(wrapper.contains(child), false);
        await future;
        expect(wrapper.contains(child), false);
        wrapper.updateTree(0);
        expect(wrapper.contains(child), true);
      },
    );

    withTappables.test('taps and resizes children', (game) async {
      final child = _MyTap();
      final wrapper = Component();

      game.onGameResize(size);
      child.size.setValues(1.0, 1.0);
      await game.ensureAdd(wrapper);
      await wrapper.ensureAdd(child);
      game.onTapDown(1, createTapDownEvent(game));

      expect(child.gameSize, size);
      expect(child.tapped, true);
    });

    withTappables.test('add multiple children with addAll', (game) async {
      final children = List.generate(10, (_) => _MyTap());
      final wrapper = Component();
      await wrapper.addAll(children);

      await game.ensureAdd(wrapper);
      expect(wrapper.children.length, children.length);
    });

    withTappables.test('tap on offset children', (game) async {
      final child = _MyTap()
        ..position.setFrom(Vector2.all(100))
        ..size.setFrom(Vector2.all(100));
      final wrapper = PositionComponent()
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

    withTappables.test(
      'tap on child on top of child without propagation',
      (game) async {
        final child1 = _MyTap()..size.setFrom(Vector2.all(100));
        final child2 = _MyTap()..size.setFrom(Vector2.all(100));
        final parent = PositionComponent()..size.setFrom(Vector2.all(300));

        game.onGameResize(size);
        await game.ensureAdd(parent);
        await parent.ensureAdd(child1);
        await parent.ensureAdd(child2);
        game.onTapDown(
          1,
          createTapDownEvent(
            game,
            globalPosition: const Offset(50, 50),
          ),
        );

        expect(child2.tapped, isTrue);
        expect(child2.tapTimes, equals(1));
        expect(child1.tapped, isFalse);
        expect(child1.tapTimes, equals(0));
      },
    );

    withTappables.test('updates and renders children', (game) async {
      final child = _MyTap();
      final wrapper = Component();

      await wrapper.ensureAdd(child);
      await game.ensureAdd(wrapper);
      game.render(MockCanvas());

      expect(child.rendered, true);
      expect(child.updated, true);
    });

    withTappables.test('initially same debugMode as parent', (game) async {
      final child = Component();
      final wrapper = Component();
      wrapper.debugMode = true;

      wrapper.add(child);
      await game.ensureAdd(wrapper);

      expect(child.debugMode, true);
      wrapper.debugMode = false;
      expect(child.debugMode, true);
    });
  });
}
