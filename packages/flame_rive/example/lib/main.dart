import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final game = RiveExampleGame();

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
    );
  }
}

class RiveExampleGame extends FlameGame {
  @override
  Color backgroundColor() {
    return const Color(0xFFFFFFFF);
  }

  @override
  Future<void> onLoad() async {
    final skillsArtboard =
        await loadArtboard(RiveFile.asset('assets/skills.riv'));
    add(SkillsAnimationComponent(skillsArtboard));
  }
}

class SkillsAnimationComponent extends RiveComponent with TapCallbacks {
  SkillsAnimationComponent(Artboard artboard)
      : super(
          artboard: artboard,
          size: Vector2.all(550),
        );

  SMIInput<double>? _levelInput;

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
  void onTapDown(TapDownEvent info) {
    final levelInput = _levelInput;
    if (levelInput == null) {
      return;
    }
    levelInput.value = (levelInput.value + 1) % 3;
    info.continuePropagation = true;
  }
}
