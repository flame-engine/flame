import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CullWhenOffscreen', () {
    // The camera looks at the world origin, so with a 60x40 viewport the
    // visible world rect is (-30, -20) to (30, 20).
    Future<(FlameGame, World, CameraComponent)> setUp(FlameGame game) async {
      final world = World();
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(60, 40),
      );
      game.addAll([world, camera]);
      await game.ready();
      return (game, world, camera);
    }

    void renderGame(FlameGame game) => game.render(MockCanvas());

    testWithFlameGame('renders a component inside the view', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2.zero());
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('skips a component outside the view', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 0);
    });

    testWithFlameGame('still updates a culled component', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      game.update(0.1);
      expect(component.updateCount, 1);
    });

    testWithFlameGame('skips the children of a culled component', (
      game,
    ) async {
      final (_, world, _) = await setUp(game);
      final child = _CountingComponent(position: Vector2.zero());
      final parent = _CountingComponent(
        position: Vector2(500, 500),
        children: [child],
      );
      await world.ensureAdd(parent);

      renderGame(game);
      expect(child.renderCount, 0);
    });

    testWithFlameGame('reacts to the camera moving', (game) async {
      final (_, world, camera) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 0);

      camera.viewfinder.position = Vector2(500, 500);
      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('reacts to the component moving', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 0);

      component.position = Vector2.zero();
      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('cullPadding extends the bounds', (game) async {
      final (_, world, _) = await setUp(game);
      // Bounds are (40, 0) to (50, 10), just right of the visible rect.
      final component = _CountingComponent(position: Vector2(40, 0));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 0);

      component.cullPadding = 15;
      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('does not cull when cullingEnabled is false', (
      game,
    ) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500))
        ..cullingEnabled = false;
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);

      component.cullingEnabled = true;
      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('uses an overridden cullBounds', (game) async {
      final (_, world, _) = await setUp(game);
      final component = _CountingComponent(
        position: Vector2(500, 500),
        bounds: const Rect.fromLTWH(0, 0, 10, 10),
      );
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('never culls components in the viewport', (game) async {
      final (_, _, camera) = await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await camera.viewport.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('never culls components outside of a world', (
      game,
    ) async {
      await setUp(game);
      final component = _CountingComponent(position: Vector2(500, 500));
      await game.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('is conservative for a rotated camera', (game) async {
      final (_, world, camera) = await setUp(game);
      camera.viewfinder.angle = 0.7;
      // Inside the rotated view, but outside the unrotated 60x40 rect.
      final component = _CountingComponent(position: Vector2(-10, 25));
      await world.ensureAdd(component);

      renderGame(game);
      expect(component.renderCount, 1);
    });

    testWithFlameGame('uses the camera that is rendering the world', (
      game,
    ) async {
      final (_, world, _) = await setUp(game);
      final minimap = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(20, 20),
      )..viewfinder.position = Vector2(500, 500);
      await game.ensureAdd(minimap);
      final component = _CountingComponent(position: Vector2(500, 500));
      await world.ensureAdd(component);

      // Seen by the minimap, culled by the main camera.
      renderGame(game);
      expect(component.renderCount, 1);
    });
  });
}

class _CountingComponent({
  super.position,
  super.children,
  Rect? bounds,
}) extends PositionComponent with CullWhenOffscreen {
  this {
    size = Vector2.all(10);
  }

  final Rect? _bounds = bounds;
  int renderCount = 0;
  int updateCount = 0;

  @override
  Rect get cullBounds => _bounds ?? super.cullBounds;

  @override
  void render(Canvas canvas) {
    renderCount++;
  }

  @override
  void update(double dt) {
    updateCount++;
  }
}
