import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';

class RemoveConsoleCommand<G extends FlameGame> extends QueryCommand<G> {
  @override
  void processChild(Component child) {
    child.removeFromParent();
  }
}
