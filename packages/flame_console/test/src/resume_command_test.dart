import 'package:flame/game.dart';
import 'package:flame_console/src/commands/resume_command.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Resume Command', () {
    testWithGame(
      'resumes the game',
      FlameGame.new,
      (game) async {
        game.pauseEngine();
        expect(game.isPaused, isTrue);
        final command = ResumeConsoleCommand();
        command.execute(game, command.parser.parse([]));
        expect(game.isPaused, isFalse);
      },
    );

    group('when the game is not paused', () {
      testWithGame(
        'returns error',
        FlameGame.new,
        (game) async {
          expect(game.isPaused, isFalse);
          final command = ResumeConsoleCommand();
          final result = command.execute(game, command.parser.parse([]));
          expect(game.isPaused, isFalse);

          expect(
            result.$1,
            'Game is not paused, use the pause command to pause it',
          );
        },
      );
    });
  });
}
