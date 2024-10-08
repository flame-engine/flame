import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';

class RemoveConsoleCommand<G extends FlameGame> extends QueryCommand<G> {
  @override
  (String?, String) processChildren(List<Component> children) {
    for (final component in children) {
      component.removeFromParent();
    }
    return (null, '');
  }

  @override
  String get description =>
      'Removes components that match the query arguments.';
}
