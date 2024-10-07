import 'package:args/args.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';

class RemoveConsoleCommand<G extends FlameGame> extends ConsoleCommand<G> {
  @override
  (String?, String) execute(G game, ArgResults results) {
    final components = listAllChildren(game);

    final id = results['id'] as String;
    final componentToRemove =
        components.where((element) => element.hashCode.toString() == id);

    if (componentToRemove.isNotEmpty) {
      componentToRemove.first.removeFromParent();
      return (null, 'Removed component with id $id');
    }

    return ('Component not found', '');
  }

  @override
  ArgParser get parser => ArgParser()
    ..addOption(
      'id',
      mandatory: true,
      abbr: 'i',
    );
}
