import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug Command', () {
    final components = [
      RectangleComponent(),
      PositionedComponent(),
    ];
    testWithGame(
      'toggle debug mode on components',
      FlameGame.new,
      (game) async {
        await game.world.addAll(components);

        await game.ready();

        final command = DebugConsoleCommand();
        command.execute(game, command.parser.parse([]));

        for (final component in components) {
          expect(component.debugMode, isTrue);
        }

        command.execute(game, command.parser.parse([]));
        for (final component in components) {
          expect(component.debugMode, isFalse);
        }
      },
    );
  });
}
