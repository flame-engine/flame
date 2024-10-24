import 'package:flame/game.dart';
import 'package:flame_console/src/commands/pause_command.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pause Command', () {
    testWithGame(
      'pauses the game',
      FlameGame.new,
      (game) async {
        expect(game.paused, isFalse);
        final command = PauseConsoleCommand();
        command.execute(game, command.parser.parse([]));
        expect(game.paused, isTrue);
      },
    );

    group('when the game is already paused', () {
      testWithGame(
        'returns error',
        FlameGame.new,
        (game) async {
          game.pauseEngine();
          expect(game.paused, isTrue);
          final command = PauseConsoleCommand();
          final result = command.execute(game, command.parser.parse([]));
          expect(game.paused, isTrue);

          expect(
            result.$1,
            'Game is already paused, use the resume command start it again',
          );
        },
      );
    });
  });
}
