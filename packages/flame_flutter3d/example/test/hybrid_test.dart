/// The example's world, built the way the app builds it and stepped the way
/// Flame steps it: `update(dt)` called directly, no widget tree.
library;

import 'package:flame_flutter3d_example/main.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_cpu/testing.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';

HybridGame _newGame() {
  final it = cpuTestDevice(width: 32, height: 24);
  return HybridGame()..buildWorld(it.device, Scene());
}

void _run(HybridGame game, int steps) {
  for (var i = 0; i < steps; i++) {
    game.update(1 / 60);
  }
}

void main() {
  test('the crate falls onto the pad and Flame hears it land', () {
    final game = _newGame();
    expect(game.landings, 0);

    // Four metres at one g is under a second; two is plenty.
    _run(game, 120);

    expect(game.landings, 1);
    expect(game.crate.position.y, lessThan(1.0));
    expect(game.hud.text, contains('land'));
  });

  test('an arrow key moves the cube in the scene, through Flame', () {
    final game = _newGame();
    // One frame first: the bridge writes Flame's position into the node on
    // update, so until then the node is still at the origin.
    _run(game, 1);
    final before = game.cube.node.readPosition().x;
    expect(before, closeTo(-2.0, 1e-6));

    game.input.press(GameAction.moveRight);
    _run(game, 30);

    // Flame's position moved, and the flameToScene bridge wrote it into
    // the node the 3D layer draws.
    expect(game.cube.position.x, greaterThan(-2.0));
    expect(game.cube.node.readPosition().x, greaterThan(before));
  });
}
