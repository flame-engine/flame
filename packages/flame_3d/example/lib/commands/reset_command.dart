import 'package:example/example_game_3d.dart';
import 'package:flame_console/flame_console.dart';

class ResetCommand extends FlameConsoleCommand<ExampleGame3D> {
  @override
  String get name => 'reset';

  @override
  String get description => 'Resets the camera and player';

  @override
  (String?, String) execute(ExampleGame3D game, ArgResults args) {
    game.camera.reset();
    game.player.reset();
    return (null, 'Camera was reset.');
  }
}
