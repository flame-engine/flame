import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraComponent', () {
    testGolden(
      'CameraComponent.withFixedResolution',
      (game) async {
        final world = World()
          ..addAll([
            _SolidBackground(const Color(0xFF333333)),
            RectangleComponent(
              anchor: Anchor.center,
              position: Vector2.zero(),
              size: Vector2(480, 180),
              paint: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = const Color(0xFF00FF33),
            ),
            RectangleComponent(
              anchor: Anchor.center,
              size: Vector2.all(50),
              paint: Paint()..color = const Color(0xFFFFEEDD),
            ),
          ])
          ..addToParent(game);
        CameraComponent.withFixedResolution(
          world: world,
          width: 500,
          height: 200,
        ).addToParent(game);
      },
      goldenFile: '../_goldens/camera_component_test1.png',
      size: Vector2(200, 150),
    );

    testWithFlameGame('simple camera follow', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      final player = PositionComponent()..addToParent(world);
      camera.follow(player);
      await game.ready();

      expect(camera.viewfinder.children.length, 1);
      expect(camera.viewfinder.children.first, isA<FollowBehavior>());
      for (var i = 0; i < 20; i++) {
        player.position.add(Vector2(i * 5.0, 20.0 - i));
        game.update(0.01);
        expect(camera.viewfinder.position, closeToVector(player.position));
      }
    });

    testWithFlameGame('follow with snap', (game) async {
      final world = World()..addToParent(game);
      final player = PositionComponent()
        ..position = Vector2(100, 100)
        ..addToParent(world);
      final camera = CameraComponent(world: world)
        ..follow(player, maxSpeed: 1, snap: true)
        ..addToParent(game);
      await game.ready();

      expect(camera.viewfinder.position, Vector2(100, 100));
    });

    testWithFlameGame('moveTo', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      final point = Vector2(1000, 2000);
      camera.moveTo(point);
      game.update(0);
      expect(camera.viewfinder.position, Vector2(1000, 2000));
      // updating [point] doesn't affect the camera's target
      point.x = 0;
      game.update(1);
      expect(camera.viewfinder.position, Vector2(1000, 2000));
    });

    testWithFlameGame('moveTo x 2', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      camera.moveTo(Vector2(100, 0), speed: 5);
      for (var i = 0; i < 10; i++) {
        expect(camera.viewfinder.position, closeToVector(Vector2(0.5 * i, 0)));
        game.update(0.1);
      }
      camera.moveTo(Vector2(5, 200), speed: 10);
      for (var i = 0; i < 10; i++) {
        expect(camera.viewfinder.position, closeToVector(Vector2(5, 1.0 * i)));
        game.update(0.1);
      }
      expect(camera.viewfinder.children.length, 1);
    });

    testWithFlameGame('moveBy', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      final point = Vector2(100, 200);
      camera.moveBy(point);
      game.update(1);
      expect(camera.viewfinder.position, Vector2(100, 200));
      // updating [point] doesn't affect the offset.
      point.x = 0;
      game.update(1);
      expect(camera.viewfinder.position, Vector2(100, 200));
    });

    testWithFlameGame('moveBy x 2', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      camera.moveBy(Vector2(100, 0), speed: 5);
      for (var i = 0; i < 10; i++) {
        expect(camera.viewfinder.position, closeToVector(Vector2(0.5 * i, 0)));
        game.update(0.1);
      }
      camera.moveTo(Vector2(5, 200), speed: 10);
      for (var i = 0; i < 10; i++) {
        expect(camera.viewfinder.position, closeToVector(Vector2(5, 1.0 * i)));
        game.update(0.1);
      }
      expect(camera.viewfinder.children.length, 1);
    });

    testWithFlameGame('setBounds', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      camera.setBounds(Rectangle.fromLTRB(0, 0, 400, 50));
      camera.viewfinder.position = Vector2(10, 10);
      game.update(0);
      expect(camera.viewfinder.position, Vector2(10, 10));
      camera.viewfinder.position = Vector2(-10, 10);
      game.update(0);
      expect(camera.viewfinder.position, closeToVector(Vector2(0, 10), 0.5));

      camera.moveTo(Vector2(-20, 0), speed: 10);
      for (var i = 0; i < 20; i++) {
        expect(
          camera.viewfinder.position,
          closeToVector(Vector2(0, 10 - i * 0.45), 0.5),
        );
        game.update(0.1);
      }

      expect(
        camera.viewfinder.firstChild<BoundedPositionBehavior>(),
        isNotNull,
      );
      expect(
        camera.viewfinder.firstChild<BoundedPositionBehavior>()!.bounds,
        isA<Rectangle>(),
      );
      camera.setBounds(Circle(Vector2.zero(), 100));
      expect(
        camera.viewfinder.firstChild<BoundedPositionBehavior>()!.bounds,
        isA<Circle>(),
      );
      camera.setBounds(null);
      game.update(0);
      expect(
        camera.viewfinder.firstChild<BoundedPositionBehavior>(),
        isNull,
      );
    });

    testWithFlameGame('componentsAtPoint', (game) async {
      final world = World();
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(600, 400),
      )
        ..viewport.anchor = Anchor.center
        ..viewport.position = Vector2(400, 300)
        ..viewfinder.position = Vector2(100, 50);
      final component = PositionComponent(
        size: Vector2(300, 100),
        position: Vector2(50, 30),
      );
      world.add(component);
      game.addAll([world, camera]);
      await game.ready();

      final nested = <Vector2>[];
      final it = game.componentsAtPoint(Vector2(400, 300), nested).iterator;
      expect(it.moveNext(), true);
      expect(it.current, component);
      expect(nested, [Vector2(400, 300), Vector2(100, 50), Vector2(50, 20)]);
      expect(it.moveNext(), true);
      expect(it.current, world);
      expect(nested, [Vector2(400, 300), Vector2(100, 50)]);
      expect(it.moveNext(), true);
      expect(it.current, camera.viewport);
      expect(nested, [Vector2(400, 300), Vector2(300, 200)]);
      expect(it.moveNext(), true);
      expect(it.current, game);
      expect(nested, [Vector2(400, 300)]);
      expect(it.moveNext(), false);

      // Check that `componentsAtPoint` is usable with non-top-level components
      // also.
      expect(
        world.componentsAtPoint(Vector2(100, 100)).toList(),
        [component, world],
      );
      expect(
        component.componentsAtPoint(Vector2(100, 50)).toList(),
        [component],
      );
    });

    testWithFlameGame('visibleWorldRect', (game) async {
      final world = World();
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(60, 40),
      );
      game.addAll([world, camera]);
      await game.ready();

      // By default, the viewfinder's position is (0,0), and its anchor is in
      // the center of the viewport.
      expect(camera.visibleWorldRect, const Rect.fromLTRB(-30, -20, 30, 20));

      camera.viewfinder.position = Vector2(100, 200);
      expect(camera.visibleWorldRect, const Rect.fromLTRB(70, 180, 130, 220));

      camera.viewfinder.zoom = 2;
      camera.viewfinder.position = Vector2(20, 30);
      expect(camera.visibleWorldRect, const Rect.fromLTRB(5, 20, 35, 40));

      camera.viewport.size = Vector2(100, 60);
      expect(camera.visibleWorldRect, const Rect.fromLTRB(-5, 15, 45, 45));

      camera.viewfinder.position = Vector2.zero();
      expect(camera.visibleWorldRect, const Rect.fromLTRB(-25, -15, 25, 15));

      // Rotation angle: cos(a) = 0.6, sin(a) = 0.8
      // Each point (x, y) becomes (x*cos(a) - y*sin(a), x*sin(a) + y*cos(a)),
      // and each of the 4 corners turns into
      //   (25, 15) -> (3, 29)
      //   (25, -15) -> (27, 11)
      //   (-25, -15) -> (-3, -29)
      //   (-25, 15) -> (-27, -11)
      // which means the culling rect is (-27, -29, 27, 29)
      camera.viewfinder.angle = acos(0.6);
      expect(camera.visibleWorldRect, const Rect.fromLTRB(-27, -29, 27, 29));
    });

    testWithFlameGame('visibleWorldRect accessed too early', (game) async {
      final world = World();
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(60, 40),
      );
      game.addAll([world, camera]);

      expect(
        () => camera.visibleWorldRect,
        failsAssert(
          'This property cannot be accessed before the camera is mounted',
        ),
      );
    });

    testWithFlameGame('component is in view for the camera', (game) async {
      final world = World();
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(60, 40),
      );
      game.addAll([world, camera]);
      await game.ready();

      final component = PositionComponent(
        size: Vector2(10, 10),
        position: Vector2(0, 0),
      );

      expect(camera.canSee(component), isTrue);
    });

    testWithFlameGame('component is out of view for the camera', (game) async {
      final world = World();
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(60, 40),
      );
      game.addAll([world, camera]);
      await game.ready();

      final component = PositionComponent(
        size: Vector2(10, 10),
        position: Vector2(100, 100),
      );

      expect(camera.canSee(component), isFalse);
    });
  });
}

class _SolidBackground extends Component with HasPaint {
  _SolidBackground(this.color);
  final Color color;
  @override
  void render(Canvas canvas) => canvas.drawColor(color, BlendMode.src);
}
