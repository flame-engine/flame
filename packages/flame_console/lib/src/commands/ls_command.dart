import 'package:args/args.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';

class LsConsoleCommand<G extends FlameGame> extends ConsoleCommand<G> {
  @override
  (String?, String) execute(G game, ArgResults results) {
    final out = StringBuffer();

    final components = listAllChildren(game);

    final type = results['type'] as String?;

    for (final component in components) {
      final componentType = component.runtimeType.toString();

      if (type != null && componentType != type) {
        continue;
      }

      out.writeln('${component.hashCode}@$componentType');
    }

    return (null, out.toString());
  }

  @override
  ArgParser get parser => ArgParser()
    ..addOption(
      'type',
      abbr: 't',
    );
}
