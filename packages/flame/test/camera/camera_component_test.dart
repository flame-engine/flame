import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/post_process.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'camera_test_helpers.dart';

void main() {
  group('CameraComponent', () {
    testGolden(
      'CameraComponent.withFixedResolution',
      (game, tester) async {
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

    testWithFlameGame('camera should be able to retarget follow', (game) async {
      // Creating new camera as the one included with game is not mounted and
      // will therefore not be queued.
      final camera = CameraComponent(world: game.world)..addToParent(game);
      final player = PositionComponent()..addToParent(game.world);
      final player2 = PositionComponent()..addToParent(game.world);
      camera.follow(player);
      camera.follow(player2);
      await game.ready();

      expect(camera.viewfinder.children.length, 1);
      expect(camera.viewfinder.children.first, isA<FollowBehavior>());
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
      game.camera.viewport = FixedSizeViewport(600, 400)
        ..anchor = Anchor.center
        ..position = Vector2(400, 300)
        ..priority = -1;
      game.camera.viewfinder.position = Vector2(100, 50);
      final component = PositionComponent(
        size: Vector2(300, 100),
        position: Vector2(50, 30),
      );
      final world = game.world;
      final camera = game.camera;
      world.add(component);
      await game.ready();

      final nested = <Vector2>[];
      final it = game.componentsAtPoint(Vector2(400, 300), nested).iterator;
      expect(it.moveNext(), true);
      expect(it.current, camera.viewport);
      expect(nested, [Vector2(400, 300), Vector2(300, 200)]);
      expect(it.moveNext(), true);
      expect(it.current, component);
      expect(nested, [Vector2(400, 300), Vector2(100, 50), Vector2(50, 20)]);
      expect(it.moveNext(), true);
      expect(it.current, world);
      expect(nested, [Vector2(400, 300), Vector2(100, 50)]);
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
      await game.ready();
      final camera = game.camera;
      game.onGameResize(Vector2(60, 40));

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

    testWithFlameGame('visibleWorldRect with FixedSizeViewport', (game) async {
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

      expect(
        () => camera.visibleWorldRect,
        failsAssert(),
      );
    });

    testWithFlameGame('component is in view for the camera', (game) async {
      final component = PositionComponent(
        size: Vector2(10, 10),
        position: Vector2(0, 0),
      );
      final world = World(children: [component]);
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(60, 40),
      );
      game.addAll([world, camera]);
      await game.ready();

      expect(camera.canSee(component), isTrue);
    });

    testWithFlameGame('component is out of view for the camera', (game) async {
      final component = PositionComponent(
        size: Vector2(10, 10),
        position: Vector2(100, 100),
      );
      final world = World(children: [component]);
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(60, 40),
      );
      game.addAll([world, camera]);
      await game.ready();

      expect(camera.canSee(component), isFalse);
    });

    testGolden(
      'Correct order of rendering',
      (game, tester) async {
        final world = World();
        final camera = CameraComponent(world: world);
        game.addAll([world, camera]);
        camera.viewfinder.position = Vector2.all(4);
        camera.backdrop.add(
          CrossHair(
            size: Vector2.all(28),
            position: camera.viewport.size / 2 + Vector2.all(4),
            color: Colors.teal,
          ),
        );
        camera.viewfinder.add(
          CrossHair(
            size: Vector2.all(20),
            position: Vector2(-2, 4),
            color: Colors.white,
          ),
        );
        world.add(
          CrossHair(size: Vector2.all(14), color: Colors.green),
        );
        camera.viewport.add(
          CrossHair(
            size: Vector2.all(8),
            position: camera.viewport.size / 2 + Vector2(4, -4),
            color: Colors.red,
          ),
        );
      },
      goldenFile: '../_goldens/camera_component_order_test.png',
      size: Vector2(50, 50),
    );
  });

  testGolden(
    'Correct scale of rendering',
    (game, tester) async {
      final world = World();
      final resolution = Vector2(40, 60);
      final camera = CameraComponent.withFixedResolution(
        world: world,
        width: resolution.x,
        height: resolution.y,
      );
      game.addAll([world, camera]);
      camera.viewfinder.position = Vector2.all(4);
      camera.backdrop.add(
        CrossHair(
          size: Vector2.all(28),
          position: resolution / 2 + Vector2.all(4),
          color: Colors.teal,
        ),
      );
      camera.viewfinder.add(
        CrossHair(
          size: Vector2.all(20),
          position: Vector2(0, 2),
          color: Colors.white,
        ),
      );
      world.add(
        CrossHair(size: Vector2.all(14), color: Colors.green),
      );
      camera.viewport.add(
        CrossHair(
          size: Vector2.all(8),
          position: resolution / 2 + Vector2(2, -2),
          color: Colors.red,
        ),
      );
    },
    goldenFile: '../_goldens/camera_component_fixed_resolution_order_test.png',
    size: Vector2(50, 50),
  );

  testGolden(
    'Correct scale of rendering after zoom',
    (game, tester) async {
      final world = World();
      final resolution = Vector2(40, 60);
      final camera = CameraComponent.withFixedResolution(
        world: world,
        width: resolution.x,
        height: resolution.y,
      );
      game.addAll([world, camera]);
      camera.viewfinder.position = Vector2.all(4);
      camera.viewfinder.zoom = 1.5;
      camera.backdrop.add(
        CrossHair(
          size: Vector2.all(28),
          position: resolution / 2 + Vector2.all(4),
          color: Colors.teal,
        ),
      );
      camera.viewfinder.add(
        CrossHair(
          size: Vector2.all(20),
          position: Vector2(-2, 4),
          color: Colors.white,
        ),
      );
      world.add(
        CrossHair(size: Vector2.all(14), color: Colors.green),
      );
      camera.viewport.add(
        CrossHair(
          size: Vector2.all(8),
          position: resolution / 2 + Vector2(4, -4),
          color: Colors.red,
        ),
      );
    },
    goldenFile:
        '../_goldens/camera_component_fixed_resolution_order_zoom_test.png',
    size: Vector2(50, 50),
  );

  group('CameraComponent.canSee', () {
    testWithFlameGame('null world', (game) async {
      final player = PositionComponent();
      final world = World(children: [player]);
      final camera = CameraComponent();

      await game.addAll([camera, world]);
      await game.ready();
      expect(camera.canSee(player), false);

      camera.world = world;
      expect(camera.canSee(player), true);
    });

    testWithFlameGame('unmounted world', (game) async {
      final player = PositionComponent();
      final world = World(children: [player]);
      final camera = CameraComponent(world: world);

      await game.addAll([camera]);
      await game.ready();
      expect(camera.canSee(player), false);

      await game.add(world);
      await game.ready();
      expect(camera.canSee(player), true);
    });

    testWithFlameGame('unmounted component', (game) async {
      final player = PositionComponent();
      final world = World();
      final camera = CameraComponent(world: world);

      await game.addAll([camera, world]);
      await game.ready();
      expect(camera.canSee(player), false);

      await world.add(player);
      await game.ready();
      expect(camera.canSee(player), true);
    });

    testWithFlameGame('component from another world', (game) async {
      final player = PositionComponent();
      final world1 = World(children: [player]);
      final world2 = World();
      final camera = CameraComponent(world: world2);

      await game.addAll([camera, world1, world2]);
      await game.ready();

      // can see when player world is not known.
      expect(camera.canSee(player), true);

      // can't see when the player world is known.
      expect(camera.canSee(player, componentWorld: world1), false);
    });

    testWithFlameGame('coordinate transformations', (game) async {
      game.onGameResize(Vector2.all(1000.0));

      final size = Vector2.all(100.0);
      final world = World();
      final camera = CameraComponent.withFixedResolution(
        width: size.x,
        height: size.y,
        world: world,
      );

      await game.addAll([camera, world]);
      await game.ready();

      camera.moveBy(size / 2);
      game.update(0);

      expect(camera.globalToLocal(Vector2.zero()), Vector2.zero());
      expect(camera.globalToLocal(Vector2.all(100.0)), Vector2.all(10.0));
      expect(camera.globalToLocal(Vector2.all(500.0)), Vector2.all(50.0));
      expect(camera.globalToLocal(Vector2.all(1000.0)), Vector2.all(100.0));

      expect(camera.localToGlobal(Vector2.zero()), Vector2.zero());
      expect(camera.localToGlobal(Vector2.all(10.0)), Vector2.all(100.0));
      expect(camera.localToGlobal(Vector2.all(50.0)), Vector2.all(500.0));
      expect(camera.localToGlobal(Vector2.all(100.0)), Vector2.all(1000.0));
    });

    testWithFlameGame('postProcess can be changed', (game) async {
      game.camera.postProcess = _PostProcessChecker();
      await game.ready();
      expect(
        () => game.camera.postProcess = _PostProcessChecker(),
        returnsNormally,
      );
    });

    testWithFlameGame('postProcess onLoad is called', (game) async {
      game.camera.postProcess = _PostProcessChecker();
      await game.ready();
      expect(
        (game.camera.postProcess! as _PostProcessChecker).isLoaded,
        isTrue,
      );
    });

    testWithFlameGame('multiple postProcess add and remove ', (game) async {
      final postProcessA = _PostProcessChecker();
      final postProcessB = _PostProcessChecker();
      final postProcessC = _PostProcessChecker();
      game.camera.postProcess = postProcessA;
      game.camera.postProcess = postProcessB;
      game.camera.postProcess = postProcessC;
      await game.ready();
      expect(game.camera.postProcess, postProcessC);

      game.camera.postProcess = postProcessA;
      game.camera.postProcess = postProcessB;
      game.camera.postProcess = postProcessA;
      await game.ready();
      expect(game.camera.postProcess, postProcessA);

      game.camera.postProcess = postProcessB;
      game.camera.postProcess = null;
      await game.ready();
      expect(game.camera.postProcess, isNull);
    });
  });
}

class _SolidBackground extends Component with HasPaint {
  _SolidBackground(this.color);
  final Color color;
  @override
  void render(Canvas canvas) => canvas.drawColor(color, BlendMode.src);
}

class _PostProcessChecker extends PostProcess {
  bool isLoaded = false;

  @override
  void onLoad() {
    isLoaded = true;
  }
}
