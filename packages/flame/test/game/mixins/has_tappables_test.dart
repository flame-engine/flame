import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _GameWithTappables extends FlameGame with HasTappables {
  int handledOnTapDown = 0;
  int handledOnTapUp = 0;
  int handledOnTapCancel = 0;

  @override
  bool onTapDown(int pointerId, TapDownInfo info) {
    final handled = !super.onTapDown(pointerId, info);
    if (handled) {
      handledOnTapDown++;
    }
    return true;
  }

  @override
  bool onTapUp(int pointerId, TapUpInfo info) {
    final handled = !super.onTapUp(pointerId, info);
    if (handled) {
      handledOnTapUp++;
    }
    return true;
  }

  @override
  bool onTapCancel(int pointerId) {
    final handled = !super.onTapCancel(pointerId);
    if (handled) {
      handledOnTapCancel++;
    }
    return true;
  }
}

class _TappableComponent extends PositionComponent with Tappable {
  _TappableComponent() : super(size: Vector2.all(100));

  @override
  bool onTapCancel() {
    return false;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    return false;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    return false;
  }
}

void main() {
  final withTappables = FlameTester(() => _GameWithTappables());

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
            'Tappable Components can only be added to a FlameGame with '
            'HasTappables',
          ),
        );
      },
    );

    withTappables.widgetTest(
      'tap correctly registered handled event',
      (game, tester) async {
        await game.ensureAdd(_TappableComponent());
        await tester.tapAt(const Offset(10, 10));
        expect(game.handledOnTapDown, 1);
        expect(game.handledOnTapUp, 1);
        expect(game.handledOnTapCancel, 0);
      },
    );

    withTappables.widgetTest(
      'tap outside of component is not registered as handled',
      (game, tester) async {
        await game.ensureAdd(_TappableComponent());
        await tester.tapAt(const Offset(110, 110));
        expect(game.handledOnTapDown, 0);
        expect(game.handledOnTapUp, 0);
        expect(game.handledOnTapCancel, 0);
      },
    );
  });
}
