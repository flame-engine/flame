import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: RiveExampleGame.new));
}

class RiveExampleGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final skillsArtboard = await loadArtboard(
      RiveFile.asset('assets/skills.riv'),
    );
    add(SkillsAnimationComponent(skillsArtboard));
  }
}

class SkillsAnimationComponent extends RiveComponent with TapCallbacks {
  SkillsAnimationComponent(Artboard artboard) : super(artboard: artboard);

  SMIInput<double>? _levelInput;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void onLoad() {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "Designer's Test",
    );
    if (controller != null) {
      artboard.addController(controller);
      _levelInput = controller.findInput<double>('Level');
      _levelInput?.value = 0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final levelInput = _levelInput;
    if (levelInput == null) {
      return;
    }
    levelInput.value = (levelInput.value + 1) % 3;
  }
}
