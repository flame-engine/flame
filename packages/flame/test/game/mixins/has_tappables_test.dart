import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

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

void main() {
  final withTappables = FlameTester(_GameWithTappables.new);

  group('HasTappables', () {
    withTappables.test(
      'make sure Tappables can be added to valid games',
      (game) async {
        await game.ensureAdd(_TappableComponent());
      },
    );

    flameGame.test(
      'make sure Tappables cannot be added to invalid games',
      (game) {
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
  });
}
