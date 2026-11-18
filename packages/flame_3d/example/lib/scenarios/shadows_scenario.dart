import 'package:flame/game.dart';
import 'package:flame_3d_example/scenarios/standalone_scenario.dart';
import 'package:flame_3d_example/shadows/shadows_game.dart';

/// A 2D game whose 3D objects cast shadows onto its 2D ground, see
/// [ShadowsGame].
class ShadowsScenario() extends StandaloneScenario {
  @override
  Game createGame() => ShadowsGame();
}
