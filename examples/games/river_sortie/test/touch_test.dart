/// A phone's controls: Flame's own stick and fire button, feeding the same
/// `InputState` the keys do.
library;

import 'package:flame/components.dart' show JoystickComponent;
import 'package:flame/input.dart' show HudButtonComponent;
import 'package:flame_test/flame_test.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter3d_cpu/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:river_sortie/river_sortie.dart' show hasTouchControls;
import 'package:river_sortie/src/river_game.dart';

Future<RiverGame> _touchGame() async {
  final game = await initializeGame(RiverGame.new);
  game
    ..open3d(cpuTestDevice(width: 32, height: 24).device)
    ..addTouchControls();
  await game.ready();
  return game;
}

void main() {
  test('Android and iOS get the stick and the button; the rest keep the '
      'keys', () {
    expect(hasTouchControls(TargetPlatform.android), isTrue);
    expect(hasTouchControls(TargetPlatform.iOS), isTrue);
    for (final platform in <TargetPlatform>[
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.fuchsia,
    ]) {
      expect(hasTouchControls(platform), isFalse, reason: platform.name);
    }
  });

  test("the stick and the fire button are in Flame's viewport", () async {
    final game = await _touchGame();
    final viewport = game.camera.viewport.children;
    expect(viewport.whereType<JoystickComponent>(), hasLength(1));
    expect(viewport.whereType<HudButtonComponent>(), hasLength(1));
    expect(game.touch, isTrue);
  });

  test(
    'the fire button takes off and fires; the stick steers and throttles',
    () async {
      final game = await _touchGame();
      final button = game.camera.viewport.children
          .whereType<HudButtonComponent>()
          .single;
      final stick = game.joystick!;
      final startX = game.jet.position.x;

      button.onPressed!();
      await Future<void>.value();
      game.update(1 / 60);
      await game.ready();
      expect(game.phase, Phase.flying);

      // Right and forward, held for half a second. The stick recomputes its
      // own delta from the drag each update, so the test holds it there.
      for (var i = 0; i < 30; i++) {
        stick.delta.setValues(stick.knobRadius, -stick.knobRadius * 0.9);
        game.update(1 / 60);
        await game.ready();
      }
      expect(game.jet.position.x, greaterThan(startX + 1.0));
      expect(game.speed, greaterThan(RiverGame.cruiseSpeed));
      expect(game.children.whereType<ShotComponent>(), isNotEmpty);

      button.onReleased!();
      game.update(1 / 60);
      expect(game.input.held(RiverGame.fire), isFalse);
    },
  );
}
