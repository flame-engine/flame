import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init();
  runApp(const GameWidget.controlled(gameFactory: RiveExampleGame.new));
}

class RiveExampleGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final skillsArtboard = await loadArtboard(
      File.asset(
        'assets/skills.riv',
        riveFactory: Factory.flutter,
      ).then((file) => file!),
    );
    add(SkillsAnimationComponent(skillsArtboard));
  }
}

class SkillsAnimationComponent extends RiveComponent with TapCallbacks {
  SkillsAnimationComponent(Artboard artboard) : super(artboard: artboard);

  StateMachine? _stateMachine;
  ViewModelInstanceNumber? _levelInput;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void onLoad() {
    _stateMachine = artboard.stateMachine("Designer's Test");
    if (_stateMachine != null) {
      _levelInput = _stateMachine!.boundRuntimeViewModelInstance?.number(
        'Level',
      );
      _levelInput?.value = 0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _stateMachine?.advanceAndApply(dt);
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
