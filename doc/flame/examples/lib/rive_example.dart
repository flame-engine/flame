import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';

// ignore: depend_on_referenced_packages
import 'package:rive/rive.dart';

class RiveExampleGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final skillsArtboard =
        await loadArtboard(RiveFile.asset('assets/skills.riv'));

    final controller = StateMachineController.fromArtboard(
      skillsArtboard,
      "Designer's Test",
    );

    skillsArtboard.addController(controller!);

    add(RiveComponent(artboard: skillsArtboard, size: canvasSize));
  }
}
