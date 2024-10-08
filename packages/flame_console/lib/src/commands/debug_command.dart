import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/src/commands/commands.dart';

class DebugConsoleCommand<G extends FlameGame> extends QueryCommand<G> {
  @override
  void processChild(Component child) {
    child.debugMode = !child.debugMode;
  }
}
