import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final _withHasTappableComponents =
      FlameTester(_GameWithHasTappableComponents.new);

  group('TapCallbacks', () {
    testWithGame<_GameWithHasTappableComponents>(
        'make sure they can be added to game with HasTappableComponents',
        _GameWithHasTappableComponents.new, (game) async {
      await game.ensureAdd(_TapCallbacksComponent());
    });

    testWithFlameGame(
      'make sure TapCallbacks cannot be added to invalid games',
      (game) async {
        expect(
          () => game.ensureAdd(_TapCallbacksComponent()),
          failsAssert(
            'The components with TapCallbacks can only be added to a '
            'FlameGame with '
            'the HasTappableComponents mixin',
          ),
        );
      },
    );

    testWithGame<_GameWithHasTappableComponents>(
      'tap up, down event',
      _GameWithHasTappableComponents.new,
      (game) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);

        // [onTapUp] will call, if there was an [onTapDown] event before
        game.onTapUp(
          createTapUpEvents(
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(game.tapUpEvent, 0);

        game.onTapDown(
          createTapDownEvents(
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.containsLocalPoint(Vector2(10, 10)), false);
        expect(game.tapDownEvent, 1);

        // [onTapUp] will call, if there was an [onTapDown] event before
        game.onTapUp(
          createTapUpEvents(
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.containsLocalPoint(Vector2(9, 9)), true);
        expect(game.tapUpEvent, 1);

        // [onTapCancel] will call, when there was an [onTapDown] event
        // previously, but the [onTapUp] can no longer occur.
        game.onTapCancel(
          TapCancelEvent(
            1,
          ),
        );
        expect(game.tapCancelEvent, 0);
      },
    );

    testWithGame<_GameWithHasTappableComponents>(
      'longTapDown and tapCancel event',
      _GameWithHasTappableComponents.new,
      (game) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);

        game.onTapDown(
          createTapDownEvents(
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(game.tapDownEvent, 1);

        // [onLongTapDown] will call, if there was an [onTapDown] event before
        // ,and who remain at the point where the user is touching the screen.
        game.onLongTapDown(
          createTapDownEvents(
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(game.longTapDownEvent, 1);

        // [onTapCancel] will call, when there was an [onTapDown] event
        // previously, but the [onTapUp] can no longer occur.
        game.onTapCancel(
          TapCancelEvent(
            1,
          ),
        );
        expect(game.tapCancelEvent, 1);
      },
    );

    testWithGame<_GameWithHasTappableComponents>(
      'updates and renders children',
      _GameWithHasTappableComponents.new,
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

    _withHasTappableComponents.testGameWidget(
      'tap correctly registered handled event',
      setUp: (game, _) async {
        await game.ensureAdd(
          _TapCallbacksComponent()
            ..x = 10
            ..y = 10
            ..width = 10
            ..height = 10,
        );
      },
      verify: (game, tester) async {
        await tester.tapAt(const Offset(10, 10));
        await tester.pump(const Duration(seconds: 1));
        expect(game.tapDownEvent, 1);
        expect(game.longTapDownEvent, 0);
        expect(game.tapUpEvent, 1);
        expect(game.tapCancelEvent, 0);
      },
    );

    _withHasTappableComponents.testGameWidget(
      'long tap correctly registered handled event',
      setUp: (game, _) async {
        await game.ensureAdd(
          _TapCallbacksComponent()
            ..x = 10
            ..y = 10
            ..width = 10
            ..height = 10,
        );
      },
      verify: (game, tester) async {
        await tester.longPressAt(const Offset(10, 10));
        await tester.pump(const Duration(seconds: 1));
        expect(game.tapDownEvent, 1);
        expect(game.longTapDownEvent, 1);
        expect(game.tapUpEvent, 1);
        expect(game.tapCancelEvent, 0);
      },
    );

    _withHasTappableComponents.testGameWidget(
      'tap outside of component is not registered as handled',
      setUp: (game, _) async {
        await game.ensureAdd(
          _TapCallbacksComponent()
            ..x = 10
            ..y = 10
            ..width = 10
            ..height = 10,
        );
      },
      verify: (game, tester) async {
        await tester.tapAt(const Offset(110, 110));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(game.tapDownEvent, 0);
        expect(game.longTapDownEvent, 0);
        expect(game.tapUpEvent, 0);
        expect(game.tapCancelEvent, 0);
      },
    );

    testWithGame<_GameWithHasTappableComponents>(
      'taps and resizes children',
      _GameWithHasTappableComponents.new,
      (game) async {
        final child = _MyTapComponent()..size = Vector2.all(1);
        final parent = Component();
        game.add(parent..add(child));
        await game.ready();

        game.onTapDown(
          createTapDownEvents(),
        );
        expect(child.gameSize, Vector2(800, 600));
        expect(child.tapped, true);
      },
    );

    testWithGame<_GameWithHasTappableComponents>(
      'tap on offset children',
      _GameWithHasTappableComponents.new,
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
          createTapDownEvents(
            localPosition: const Offset(250, 250),
            globalPosition: const Offset(250, 250),
          ),
        );

        expect(child.gameSize, Vector2(800, 600));
        expect(child.tapped, true);
        expect(child.tapTimes, 1);
      },
    );

    testWithGame<_GameWithHasTappableComponents>(
      'tap on child on top of child without propagation',
      _GameWithHasTappableComponents.new,
      (game) async {
        final child1 = _MyTapComponent()..size = Vector2.all(100);
        final child2 = _MyTapComponent()..size = Vector2.all(100);
        final parent = PositionComponent()..size = Vector2.all(300);
        game.add(parent..addAll([child1, child2]));
        await game.ready();
        game.onTapDown(
          createTapDownEvents(
            globalPosition: const Offset(50, 50),
          ),
        );

        expect(child2.tapped, true);
        expect(child2.tapTimes, 1);
        expect(child1.tapped, false);
        expect(child1.tapTimes, 0);
      },
    );

    testWithGame<_GameWithHasTappableComponents>(
      'updates and renders children',
      _GameWithHasTappableComponents.new,
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

class _GameWithHasTappableComponents extends FlameGame
    with HasTappableComponents {
  int tapDownEvent = 0;
  int longTapDownEvent = 0;
  int tapUpEvent = 0;
  int tapCancelEvent = 0;

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (event.handled) {
      tapDownEvent++;
    }
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    super.onLongTapDown(event);
    if (event.handled) {
      longTapDownEvent++;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (event.handled) {
      tapUpEvent++;
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    if (event.handled) {
      tapCancelEvent++;
    }
  }
}

class _TapCallbacksComponent extends PositionComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    event.handled = true;
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    event.handled = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    event.handled = true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    event.handled = true;
  }
}

class _MyTapComponent extends PositionComponent with TapCallbacks {
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
