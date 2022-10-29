import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';

class RiveExampleGame extends FlameGame with TapDetector {
  late SMIInput<double>? levelInput;

  @override
  Future<void> onLoad() async {
    final skillsArtboard =
        await loadArtboard(RiveFile.asset('assets/skills.riv'));

    final controller = StateMachineController.fromArtboard(
      skillsArtboard,
      "Designer's Test",
    );

    skillsArtboard.addController(controller!);

    levelInput = controller.findInput<double>('Level');

    add(RiveComponent(artboard: skillsArtboard, size: canvasSize));
  }

  @override
  void onTap() {
    super.onTap();
    if (levelInput != null) {
      levelInput!.value = (levelInput!.value + 1) % 3;
    }
  }
}
