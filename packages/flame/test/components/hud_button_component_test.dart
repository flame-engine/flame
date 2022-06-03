import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game/flame_game_test.dart';

void main() async {
  group('HudButtonComponent', () {
    testWithGame<GameWithTappables>(
        'correctly registers taps', GameWithTappables.new, (game) async {
      var pressedTimes = 0;
      var releasedTimes = 0;
      const initialGameSize = Offset(100, 100);
      final componentSize = Vector2.all(10);
      const margin = EdgeInsets.only(bottom: 10, right: 10);
      late final HudButtonComponent button;
      await game.ensureAdd(
        button = HudButtonComponent(
          button: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          onReleased: () => releasedTimes++,
          size: componentSize,
          margin: margin,
        ),
      );
      print(game.children);
      print('Are we empty: ${game.children.isEmpty}');

      expect(pressedTimes, 0);
      expect(releasedTimes, 0);

      game.onTapDown(
        1,
        TapDownInfo.fromDetails(
          game,
          TapDownDetails(globalPosition: const Offset(50, 50)),
        ),
      );
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);

      game.onTapUp(
        1,
        TapUpInfo.fromDetails(
          game,
          TapUpDetails(
            globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
            kind: PointerDeviceKind.mouse,
          ),
        ),
      );
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);

      game.onTapDown(
        1,
        TapDownInfo.fromDetails(
          game,
          TapDownDetails(
            globalPosition: initialGameSize + margin.bottomRight,
            localPosition: initialGameSize + margin.bottomRight,
          ),
        ),
      );
      print(initialGameSize + margin.bottomRight);
      expect(pressedTimes, 1);
      expect(releasedTimes, 0);

      game.onTapUp(
        1,
        TapUpInfo.fromDetails(
          game,
          TapUpDetails(
            globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
            kind: PointerDeviceKind.mouse,
          ),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 1);
    });
  });
}
