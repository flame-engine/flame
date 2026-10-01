/// A day on Flame's clock, on the game's 3D world.
library;

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_hardware/testing.dart';
import 'package:flutter_test/flutter_test.dart';

final class _World extends FlameGame with HasFlutter3d {}

void main() {
  test('the day turns, and its air is on the scene and in the sky', () async {
    final game = _World()..open3d(FakeBackend());
    await initializeGame(() => game);
    final sun = LightNode();
    final day = AtmosphereComponent(
      cycle: AtmosphereCycle(<(double, Atmosphere)>[
        (
          0.0,
          Atmosphere(sky: Vector3(0.4, 0.6, 0.9), sunColor: Vector3.all(1.0)),
        ),
        (
          10.0,
          Atmosphere(
            sky: Vector3(0.0, 0.0, 0.1),
            fogDensity: 0.02,
            sunColor: Vector3.all(0.2),
            sunIntensity: 0.1,
          ),
        ),
      ], period: 20.0),
      sun: sun,
    );
    game.add(day);
    await game.ready();

    game.update(10.0);
    expect(game.clearColor.z, closeTo(0.1, 1e-6));
    expect(sun.intensity, closeTo(0.1, 1e-6));
    expect(day.fog.density, closeTo(0.02, 1e-6));
    // The frame is drawn through the day's fog without the game reading it
    // across by hand.
    //
    // Mutation: leave the fog to the game's own settings.
    expect(game.renderSettings().fog.density, closeTo(0.02, 1e-6));
  });
}
