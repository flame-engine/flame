/// A stretch of river the jet has left behind gives its buffers back through
/// the renderer, after the frames that may still be drawing it, and not at
/// once. On a fake device, which records what it is handed back.
library;

import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_hardware/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:river_sortie/src/course.dart';
import 'package:river_sortie/src/river_game.dart';

void main() {
  test(
    'a stretch left behind is released after the frames in flight',
    () async {
      final device = FakeBackend();
      final scene = Scene();
      final camera = CameraNode();
      scene.add(camera);
      final renderer = Renderer.create(device: device);
      final game = await initializeGame(RiverGame.new);
      game
        ..open3d(device, scene: scene)
        ..attachRenderer(renderer);
      await game.ready();

      void frame() => renderer.render(
        width: 16,
        height: 12,
        scene: scene,
        views: <RenderView>[RenderView(camera: camera)],
      );

      frame();
      // Two stretches on, far enough that the one behind the start is dropped.
      game.jet.position.y = -(sectionLength * 2.0 + 10.0);
      game.phase = Phase.flying;
      game.update(1 / 60);
      await game.ready();
      expect(device.releasedGeometry, isEmpty, reason: 'released at once');

      frame();
      frame();
      frame();
      expect(device.releasedGeometry, isNotEmpty);
    },
  );
}
