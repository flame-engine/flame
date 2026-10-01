/// Flame's straight world laid along a road that bends.
library;

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter_test/flutter_test.dart';

/// Forty metres ahead, then a right-angle turn right.
OpenPath _road() => OpenPath(<Vector3>[
  Vector3(0.0, 0.0, 0.0),
  Vector3(0.0, 0.0, -40.0),
  Vector3(30.0, 0.0, -40.0),
]);

void main() {
  testWithGame<FlameGame>(
    'a car across and along the road is on the bend, facing along it',
    FlameGame.new,
    (game) async {
      // Mutation: place it on the flat plane however the road runs.
      final car = Object3dComponent(
        node: SceneNode(),
        scene: Scene(),
        plane: BridgePlane.ground(),
        direction: SyncDirection.flameToScene,
        space: CurvilinearSpace(_road()),
        elevation: 0.5,
        position: Vector2(2.0, -55.0),
      );
      game.add(car);
      await game.ready();
      game.update(0.0);

      final at = car.node.readPosition();
      // Fifteen metres into the turn, two to the right of the middle, which
      // after turning right is towards the camera (+z).
      expect(at.x, closeTo(15.0, 1e-5));
      expect(at.y, closeTo(0.5, 1e-5));
      expect(at.z, closeTo(-38.0, 1e-5));

      final facing = car.node.readRotation().asRotationMatrix().transform(
        Vector3(0.0, 0.0, -1.0),
      );
      expect(facing.x, closeTo(1.0, 1e-5), reason: 'along the road');
      expect(car.scenePosition.distanceTo(at), lessThan(1e-5));
    },
  );
}
