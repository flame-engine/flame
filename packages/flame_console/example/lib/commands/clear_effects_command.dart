import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flame_console_example/game.dart';

class ClearEffectsCommand extends FlameConsoleCommand<MyGame> {
  @override
  String get name => 'clear_effects';

  @override
  String get description => 'Clear all effects on all components';

  @override
  (String?, String) execute(MyGame game, ArgResults args) {
    var total = 0;
    for (final child in game.children) {
      total += _removeEffects(child);
    }
    return (null, 'Removed $total effects');
  }

  int _removeEffects(Component component) {
    var total = 0;
    for (final child in component.children) {
      if (child is Effect) {
        child.removeFromParent();
        total++;
      } else {
        total += _removeEffects(child);
      }
    }
    return total;
  }
}
