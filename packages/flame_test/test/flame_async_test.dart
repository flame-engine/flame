import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var instructions = 0;

  tearDown(() {
    assert(instructions == 9, 'There should be exactly 9 instructions');
  });
  testWithFlameGame(
    'runs all the async tests',
    (game) async {
      final world = game.world;
      await world.ensureAdd(Component());
      instructions++;
      await world.ensureAdd(Component());
      instructions++;
      await world.ensureAdd(Component());
      instructions++;
      await world.ensureAdd(Component());
      instructions++;
      await world.ensureAdd(Component());
      instructions++;
      await world.ensureAdd(Component());
      instructions++;
      await world.ensureAdd(Component());
      instructions++;
      await world.ensureAdd(Component());
      instructions++;

      expect(world.children.length, equals(8));
      instructions++;
    },
  );
}
