import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  final withTappables = FlameTester(_GameWithTappables.new);

  group('HasTappables', () {
    testWithGame<_GameWithTappables>(
      'make sure Tappables can be added to valid games',
      _GameWithTappables.new,
      (game) async {
        await game.ensureAdd(_TappableComponent());
      },
    );

    testWithFlameGame(
      'make sure Tappables cannot be added to invalid games',
      (game) async {
        expect(
          () => game.ensureAdd(_TappableComponent()),
          failsAssert(
            'Tappable components can only be added to a FlameGame with '
            'HasTappables',
          ),
        );
      },
    );

    withTappables.testGameWidget(
      'tap correctly registered handled event',
      setUp: (game, _) async {
        await game.ensureAdd(_TappableComponent());
      },
      verify: (game, tester) async {
        await tester.tapAt(const Offset(10, 10));
        await tester.pump(const Duration(seconds: 1));
        expect(game.handledOnTapDown, 1);
        expect(game.handledOnLongTapDown, 0);
        expect(game.handledOnTapUp, 1);
        expect(game.handledOnTapCancel, 0);
      },
    );

    withTappables.testGameWidget(
      'long tap correctly registered handled event',
      setUp: (game, _) async {
        await game.ensureAdd(_TappableComponent());
      },
      verify: (game, tester) async {
        await tester.longPressAt(const Offset(10, 10));
        await tester.pump(const Duration(seconds: 1));
        expect(game.handledOnTapDown, 1);
        expect(game.handledOnLongTapDown, 1);
        expect(game.handledOnTapUp, 1);
        expect(game.handledOnTapCancel, 0);
      },
    );

    withTappables.testGameWidget(
      'tap outside of component is not registered as handled',
      setUp: (game, _) async {
        await game.ensureAdd(_TappableComponent());
      },
      verify: (game, tester) async {
        await tester.tapAt(const Offset(110, 110));
        await tester.pump(const Duration(seconds: 1));
        expect(game.handledOnTapDown, 0);
        expect(game.handledOnLongTapDown, 0);
        expect(game.handledOnTapUp, 0);
        expect(game.handledOnTapCancel, 0);
      },
    );

    testWithGame<_GameWithTappables>(
      'taps and resizes children',
      _GameWithTappables.new,
      (game) async {
        final child = _MyTapComponent()..size = Vector2.all(1);
        final parent = Component();
        game.add(parent..add(child));
        await game.ready();

        game.onTapDown(1, createTapDownEvent(game));
        expect(child.gameSize, Vector2(800, 600));
        expect(child.tapped, true);
      },
    );

    testWithGame<_GameWithTappables>(
      'tap on offset children',
      _GameWithTappables.new,
      (game) async {
        final child = _MyTapComponent()
          ..position = Vector2.all(100)
          ..size = Vector2.all(100)
          ..addToParent(
            PositionComponent()
              ..position = Vector2.all(100)
              ..size = Vector2.all(300)
              ..addToParent(game),
          );
        await game.ready();

        game.onTapDown(
          1,
          createTapDownEvent(
            game,
            globalPosition: const Offset(250, 250),
          ),
        );

        expect(child.gameSize, Vector2(800, 600));
        expect(child.tapped, true);
        expect(child.tapTimes, 1);
      },
    );

    testWithGame<_GameWithTappables>(
      'tap on child on top of child without propagation',
      _GameWithTappables.new,
      (game) async {
        final child1 = _MyTapComponent()..size = Vector2.all(100);
        final child2 = _MyTapComponent()..size = Vector2.all(100);
        final parent = PositionComponent()..size = Vector2.all(300);
        game.add(parent..addAll([child1, child2]));
        await game.ready();
        game.onTapDown(
          1,
          createTapDownEvent(
            game,
            globalPosition: const Offset(50, 50),
          ),
        );

        expect(child2.tapped, true);
        expect(child2.tapTimes, 1);
        expect(child1.tapped, false);
        expect(child1.tapTimes, 0);
      },
    );

    testWithGame<_GameWithTappables>(
      'updates and renders children',
      _GameWithTappables.new,
      (game) async {
        final child = _MyTapComponent();
        final parent = Component()..add(child);
        game.add(parent);
        await game.ready();

        game.update(0);
        expect(child.updated, true);
        game.render(MockCanvas());
        expect(child.rendered, true);
      },
    );
  });
}

class _GameWithTappables extends FlameGame with HasTappables {
  int handledOnTapDown = 0;
  int handledOnLongTapDown = 0;
  int handledOnTapUp = 0;
  int handledOnTapCancel = 0;

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    if (info.handled) {
      handledOnTapDown++;
    }
  }

  @override
  void onLongTapDown(int pointerId, TapDownInfo info) {
    super.onLongTapDown(pointerId, info);
    if (info.handled) {
      handledOnLongTapDown++;
    }
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    super.onTapUp(pointerId, info);
    if (info.handled) {
      handledOnTapUp++;
    }
  }

  @override
  void onTapCancel(int pointerId) {
    super.onTapCancel(pointerId);
    handledOnTapCancel++;
  }
}

class _TappableComponent extends PositionComponent with Tappable {
  _TappableComponent() : super(size: Vector2.all(100));

  @override
  bool onTapCancel() {
    return true;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    info.handled = true;
    return true;
  }

  @override
  bool onLongTapDown(TapDownInfo info) {
    info.handled = true;
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    info.handled = true;
    return true;
  }
}

class _MyTapComponent extends PositionComponent with Tappable {
  late Vector2 gameSize;

  int tapTimes = 0;
  bool get tapped => tapTimes > 0;
  bool updated = false;
  bool rendered = false;

  @override
  void update(double dt) => updated = true;

  @override
  void render(Canvas canvas) => rendered = true;

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
