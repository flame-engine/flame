import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var instructions = 0;

  tearDown(() {
    assert(instructions == 9, 'There should be exactly 9 instructions');
  });
  flameGame.test(
    'runs all the async tests',
    (game) async {
      await game.ensureAdd(Component());
      instructions++;
      await game.ensureAdd(Component());
      instructions++;
      await game.ensureAdd(Component());
      instructions++;
      await game.ensureAdd(Component());
      instructions++;
      await game.ensureAdd(Component());
      instructions++;
      await game.ensureAdd(Component());
      instructions++;
      await game.ensureAdd(Component());
      instructions++;
      await game.ensureAdd(Component());
      instructions++;

      expect(game.children.length, equals(8));
      instructions++;
    },
  );
}
