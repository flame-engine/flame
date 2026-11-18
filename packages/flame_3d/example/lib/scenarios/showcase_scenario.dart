import 'package:flame/game.dart';
import 'package:flame_3d_example/scenarios/standalone_scenario.dart';
import 'package:flame_3d_example/showcase/pure_camera_lab_game.dart';
import 'package:flame_3d_example/showcase/showcase_game.dart';

/// All-in-one maximum-feature `flame_3d` testbed scenario, see [ShowcaseGame].
class ShowcaseScenario() extends StandaloneScenario {
  @override
  Game createGame() => ShowcaseGame();
}

/// Pure 3D `FlameGame3D` camera & projection testbed scenario, see
/// [PureCameraLabGame].
class CameraLabScenario() extends StandaloneScenario {
  @override
  Game createGame() => PureCameraLabGame();
}
