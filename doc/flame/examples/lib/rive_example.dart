import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';

class RiveExampleGame extends FlameGame with TapCallbacks {
  StateMachine? stateMachine;
  ViewModelInstanceNumber? levelInput;

  @override
  Future<void> onLoad() async {
    final skillsArtboard = await loadArtboard(
      File.asset(
        'assets/skills.riv',
        riveFactory: Factory.flutter,
      ).then((file) => file!),
    );

    stateMachine = skillsArtboard.stateMachine("Designer's Test");
    if (stateMachine != null) {
      levelInput = stateMachine!.boundRuntimeViewModelInstance?.number('Level');
    }

    add(RiveComponent(artboard: skillsArtboard, size: canvasSize));
  }

  @override
  void update(double dt) {
    super.update(dt);
    stateMachine?.advanceAndApply(dt);
  }

  @override
  void onTapDown(_) {
    if (levelInput != null) {
      levelInput!.value = (levelInput!.value + 1) % 3;
    }
  }
}
