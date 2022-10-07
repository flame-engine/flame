import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

void main() {
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

        expect(component.hasOnLongTapDown, true);
      },
    );
  });
}

class _TappableComponent extends PositionComponent with Tappable {
  bool hasOnTapUp = false;
  bool hasOnTapDown = false;
  bool hasOnTapCancel = false;
  bool hasOnLongTapDown = false;

  @override
  bool onTapDown(TapDownInfo info) {
    hasOnTapDown = true;
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
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
    hasOnLongTapDown = true;
    return true;
  }
}

class _GameHasTappables extends FlameGame with HasTappables {}
