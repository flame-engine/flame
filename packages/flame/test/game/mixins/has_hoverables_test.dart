import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasHoverables', () {
    testWithGame<_GameWithHoverables>('testName', _GameWithHoverables.new,
        (game) async {
      game.onMouseMove(
        PointerHoverInfo.fromDetails(
          game,
          const PointerHoverEvent(),
        ),
      );

      expect(game.handledOnMouseMove, 1);
    });
  });
}

class _GameWithHoverables extends FlameGame with HasHoverables {
  int handledOnMouseMove = 0;

  @override
  void onMouseMove(PointerHoverInfo info) {
    super.onMouseMove(info);
    handledOnMouseMove++;
  }
}
