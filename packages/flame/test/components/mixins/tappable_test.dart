import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

void main() {
  final withTappables = FlameTester(_GameHasTappables.new);

  group('Tappable', () {
    testWithGame<_GameHasTappables>(
      'make sure they can be added to game with HasTappables',
      _GameHasTappables.new,
      (game) async {
        await game.add(_TappableComponent());
        await game.ready();
      },
    );

    testWithFlameGame(
      'make sure they cannot be added to invalid games',
      (game) async {
        expect(
          () => game.ensureAdd(_TappableComponent()),
          failsAssert(
            'Tappable components can only be added to '
            'a FlameGame with HasTappables',
          ),
        );
      },
    );

    testWithGame<_GameHasTappables>(
      'can be Tapped Down',
      _GameHasTappables.new,
      (game) async {
        final component = _TappableComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);

        game.handleTapDown(
          1,
          TapDownDetails(
            kind: PointerDeviceKind.touch,
            globalPosition: const Offset(10, 10),
            localPosition: const Offset(10, 10),
          ),
        );

        expect(component.hasOnTapDown, true);
      },
    );

    testWithGame<_GameHasTappables>(
      'can be Tapped Up',
      _GameHasTappables.new,
      (game) async {
        final component = _TappableComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);

        game
          ..handleTapDown(
            1,
            TapDownDetails(
              kind: PointerDeviceKind.touch,
              globalPosition: const Offset(10, 10),
              localPosition: const Offset(10, 10),
            ),
          )
          ..handleTapUp(
            1,
            TapUpDetails(
              kind: PointerDeviceKind.touch,
              globalPosition: const Offset(10, 10),
              localPosition: const Offset(10, 10),
            ),
          );

        expect(component.hasOnTapUp, true);
      },
    );

    testWithGame<_GameHasTappables>(
      'can be Tapped Canceled',
      _GameHasTappables.new,
      (game) async {
        final component = _TappableComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);

        game
          ..handleTapDown(
            1,
            TapDownDetails(
              kind: PointerDeviceKind.touch,
              globalPosition: const Offset(10, 10),
              localPosition: const Offset(10, 10),
            ),
          )
          ..handleTapCancel(
            1,
          );

        expect(component.hasOnTapCancel, true);
      },
    );

    testWithGame<_GameHasTappables>(
      'can be Long Tapped Down',
      _GameHasTappables.new,
      (game) async {
        final component = _TappableComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);

        game
          ..handleTapDown(
            1,
            TapDownDetails(
              kind: PointerDeviceKind.touch,
              globalPosition: const Offset(10, 10),
              localPosition: const Offset(10, 10),
            ),
          )
          ..handleLongTapDown(
            1,
            TapDownDetails(
              kind: PointerDeviceKind.touch,
              globalPosition: const Offset(10, 10),
              localPosition: const Offset(10, 10),
            ),
          );

        expect(component.hasOnLongTapDown, isTrue);
      },
    );
  });

  withTappables.testGameWidget(
    'tap correctly registered handled event',
    setUp: (game, _) async {
      final component = _TappableComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;

      await game.ensureAdd(component);
    },
    verify: (game, tester) async {
      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(seconds: 1));

      expect(game.handledOnTapDown, equals(1));
      expect(game.handledOnLongTapDown, equals(0));
      expect(game.handledOnTapUp, equals(1));
      expect(game.handledOnTapCancel, equals(0));
    },
  );

  withTappables.testGameWidget(
    'long tap correctly registered handled event',
    setUp: (game, _) async {
      final component = _TappableComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;

      await game.ensureAdd(component);
    },
    verify: (game, tester) async {
      await tester.longPressAt(const Offset(10, 10));
      await tester.pump(const Duration(seconds: 1));
      expect(game.handledOnTapDown, equals(1));
      expect(game.handledOnLongTapDown, equals(1));
      expect(game.handledOnTapUp, equals(1));
      expect(game.handledOnTapCancel, equals(0));
    },
  );

  withTappables.testGameWidget(
    'tap outside of component is not registered as handled',
    setUp: (game, _) async {
      final component = _TappableComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;

      await game.ensureAdd(component);
    },
    verify: (game, tester) async {
      await tester.tapAt(const Offset(200, 200));
      await tester.pump(const Duration(seconds: 1));
      expect(game.handledOnTapDown, equals(0));
      expect(game.handledOnLongTapDown, equals(0));
      expect(game.handledOnTapUp, equals(0));
      expect(game.handledOnTapCancel, equals(0));
    },
  );
}

class _TappableComponent extends PositionComponent with Tappable {
  bool hasOnTapUp = false;
  bool hasOnTapDown = false;
  bool hasOnTapCancel = false;
  bool hasOnLongTapDown = false;

  @override
  bool onTapDown(TapDownInfo info) {
    info.handled = true;
    hasOnTapDown = true;
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    info.handled = true;
    hasOnTapUp = true;
    return true;
  }

  @override
  bool onTapCancel() {
    hasOnTapCancel = true;
    return true;
  }

  @override
  bool onLongTapDown(TapDownInfo info) {
    info.handled = true;
    hasOnLongTapDown = true;
    return true;
  }
}

class _GameHasTappables extends FlameGame with HasTappables {
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
