import 'package:example/example_game_3d.dart';
import 'package:example/scenarios/game_scenario.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/parser.dart';

class ModelsScenario implements GameScenario {
  late final Model model;

  @override
  Future<void> onLoad() async {
    // source: https://kaylousberg.itch.io/kaykit-skeletons
    model = await ModelParser.parse('objects/skeleton.glb');
  }

  @override
  void setup(ExampleGame3D game) {
    final skeleton = ModelComponent(
      model: model,
      position: Vector3(0, 0, 0),
      scale: Vector3.all(1.0),
    )..playAnimationByName('Cheer');
    game.world.addAll([
      skeleton,
    ]);
  }
}
