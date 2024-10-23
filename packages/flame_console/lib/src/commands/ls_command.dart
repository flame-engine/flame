import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';

class LsConsoleCommand<G extends FlameGame> extends QueryCommand<G> {
  @override
  (String?, String) processChildren(List<Component> children) {
    final out = StringBuffer();
    for (final component in children) {
      final componentType = component.runtimeType.toString();
      out.writeln('${component.hashCode}@$componentType');
    }

    return (null, out.toString());
  }

  @override
  String get name => 'ls';

  @override
  String get description => 'List components that match the query arguments.';
}
