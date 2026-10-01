/// A Flame component in full 3D: moved, turned and scaled by Flame's
/// effect controllers, nested as the scene nests, and tapped.
library;

import 'package:flame/components.dart' show Component;
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart';
import 'package:flutter3d_cpu/flutter3d_cpu.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Space extends FlameGame with HasFlutter3d {}

final class _Fighter extends Node3dComponent with Tap3dCallbacks {
  _Fighter(GraphicsDevice device, Scene scene, {super.position})
    : super(
        node: MeshNode(
          DeviceMesh.upload(
            device,
            CuboidShape(size: Vector3.all(1.0)).build(),
          ),
          Material(),
        ),
        scene: scene,
      );

  int taps = 0;

  @override
  void onTap3d(Vector2 screen) => taps++;
}

Future<({_Space game, CpuDevice device})> _open() async {
  final device = CpuDevice(
    width: 32,
    height: 24,
    shaders: CpuShaderLibrary(builtinCpuShaders()),
  );
  final game = await initializeGame(_Space.new);
  game.open3d(device);
  return (game: game, device: device);
}

void main() {
  test("moved, turned and scaled by Flame's effect controllers", () async {
    // Mutation: apply the whole move at each step rather than its share.
    final (:game, :device) = await _open();
    final fighter = _Fighter(device, game.scene);
    fighter.addAll(<Component>[
      Move3dEffect.by(
        Vector3(0.0, 4.0, -10.0),
        EffectController(duration: 1.0),
      ),
      Rotate3dEffect.by(
        Vector3(0.0, 1.0, 0.0),
        1.5707963267948966,
        EffectController(duration: 1.0),
      ),
      Scale3dEffect.to(Vector3(2.0, 1.0, 3.0), EffectController(duration: 1.0)),
    ]);
    game.add(fighter);
    await game.ready();

    game.update(0.5);
    expect(fighter.node.readPosition().z, closeTo(-5.0, 1e-5));
    for (var i = 0; i < 4; i++) {
      game.update(0.25);
    }
    final at = fighter.node.readPosition();
    expect(at.y, closeTo(4.0, 1e-5));
    expect(at.z, closeTo(-10.0, 1e-5));
    final forward = fighter.node.readRotation().asRotationMatrix().transform(
      Vector3(0.0, 0.0, -1.0),
    );
    expect(forward.x, closeTo(-1.0, 1e-5), reason: 'a quarter turn left');
    final scale = fighter.node.readScale();
    expect(scale.x, closeTo(2.0, 1e-5));
    expect(scale.z, closeTo(3.0, 1e-5));
  });

  test('an alternating controller brings it back where it began', () async {
    final (:game, :device) = await _open();
    final fighter = _Fighter(device, game.scene)
      ..add(
        Move3dEffect.by(
          Vector3(6.0, 0.0, 0.0),
          EffectController(duration: 1.0, alternate: true),
        ),
      );
    game.add(fighter);
    await game.ready();
    for (var i = 0; i < 8; i++) {
      game.update(0.25);
    }
    expect(fighter.position3.x, closeTo(0.0, 1e-5));
  });

  test('a turret turns with its tank, and a cockpit camera flies with its '
      'ship', () async {
    // Mutation: add every node to the scene's root.
    final (:game, :device) = await _open();
    final tank = _Fighter(device, game.scene, position: Vector3(5.0, 0.0, 0.0));
    final turret = _Fighter(
      device,
      game.scene,
      position: Vector3(0.0, 1.0, 0.0),
    );
    tank.add(turret);
    game.add(tank);
    await game.ready();
    tank.node.add(game.camera3d..setPosition(0.0, 0.5, 0.0));

    tank.position3.x = 9.0;
    game.update(0.0);
    expect(turret.node.readWorldPosition().x, closeTo(9.0, 1e-5));
    expect(turret.node.readWorldPosition().y, closeTo(1.0, 1e-5));
    expect(game.camera3d.readWorldPosition().x, closeTo(9.0, 1e-5));
  });

  test('a tap on it is heard, as on anything bridged', () async {
    // Mutation: ask taps of bridged components on a plane alone.
    final (:game, :device) = await _open();
    game.camera3d
      ..setPosition(0.0, 2.0, 8.0)
      ..lookAt(Vector3.zero());
    final fighter = _Fighter(device, game.scene);
    final taps = Taps3dComponent();
    game.addAll(<Component>[fighter, taps]);
    await game.ready();
    game.update(0.0);

    final screen = game.projector.toScreen(Vector3.zero())!;
    expect(taps.nearestAt(screen), same(fighter));
  });
}
