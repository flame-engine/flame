import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/src/commands/commands.dart';

class DebugConsoleCommand<G extends FlameGame> extends QueryCommand<G> {
  @override
  (String?, String) processChildren(List<Component> children) {
    for (final child in children) {
      child.debugMode = !child.debugMode;
    }
    return (null, '');
  }

  @override
  String get name => 'debug';

  @override
  String get description => 'Toggle debug mode on the matched components.';
}
