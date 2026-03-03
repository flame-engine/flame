import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';

class RiveExampleGame extends FlameGame with TapCallbacks {
  NumberInput? levelInput;

  @override
  Future<void> onLoad() async {
    final skillsArtboard = await loadArtboard(
      File.asset(
        'assets/skills.riv',
        riveFactory: Factory.flutter,
      ).then((file) => file!),
    );

    final stateMachine = skillsArtboard.stateMachine("Designer's Test");
    if (stateMachine != null) {
      // ignore: deprecated_member_use
      levelInput = stateMachine.number('Level');
    }

    add(
      RiveComponent(
        artboard: skillsArtboard,
        stateMachine: stateMachine,
        size: canvasSize,
      ),
    );
  }

  @override
  void onTapDown(_) {
    if (levelInput != null) {
      levelInput!.value = (levelInput!.value + 1) % 3;
    }
  }
}
