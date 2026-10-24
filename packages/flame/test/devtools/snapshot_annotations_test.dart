import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/src/devtools/connectors/component_snapshot_connector.dart';
import 'package:flame/src/devtools/connectors/game_snapshot_connector.dart';
import 'package:flame/src/devtools/snapshot_annotations.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _Player() extends PositionComponent;

class _HiddenComponent() extends PositionComponent with HasVisibility;

Future<Color> _pixelAt(Image image, int x, int y) async {
  final bytes = (await image.toByteData())!;
  final offset = (y * image.width + x) * 4;
  return Color.fromARGB(
    bytes.getUint8(offset + 3),
    bytes.getUint8(offset),
    bytes.getUint8(offset + 1),
    bytes.getUint8(offset + 2),
  );
}

void _expectBox(SnapshotAnnotation annotation, Rect expected) {
  final box = annotation.box;
  const tolerance = 1e-4;
  expect(box.left, closeTo(expected.left, tolerance));
  expect(box.top, closeTo(expected.top, tolerance));
  expect(box.width, closeTo(expected.width, tolerance));
  expect(box.height, closeTo(expected.height, tolerance));
}

void main() {
  group('SnapshotOptions', () {
    test('parses the parameters', () {
      final options = SnapshotOptions.parse({
        'annotate': 'true',
        'annotationFilter': 'play',
        'maxSize': '100',
      });

      expect(options.annotate, isTrue);
      expect(options.annotationFilter!.hasMatch('Player'), isTrue);
      expect(options.maxSize, 100);
      expect(SnapshotOptions.parse({}).annotate, isFalse);
    });

    test('rejects invalid parameters', () {
      expect(
        () => SnapshotOptions.parse({'annotationFilter': '('}),
        throwsFormatException,
      );
      expect(
        () => SnapshotOptions.parse({'maxSize': '0'}),
        throwsFormatException,
      );
      expect(
        () => SnapshotOptions.parse({'maxSize': '1.5'}),
        throwsFormatException,
      );
    });

    test('lowers the pixel ratio to fit the maximum size', () {
      final options = SnapshotOptions(maxSize: 100);

      final pixelRatio = options.fitPixelRatio(2, const Size(800, 600));
      final size = GameSnapshotConnector.imageSize(800, 600, pixelRatio);

      expect(pixelRatio, closeTo(0.125, 1e-6));
      expect(size, const Size(100, 75));
      expect(options.fitPixelRatio(0.1, const Size(800, 600)), 0.1);
      expect(SnapshotOptions().fitPixelRatio(2, const Size(800, 600)), 2);
    });

    test('never makes the image larger than the maximum size', () {
      for (var maxSize = 1; maxSize < 500; maxSize += 7) {
        for (final longestSide in [3.0, 333.3, 799.9, 1000.0, 1234.5]) {
          final options = SnapshotOptions(maxSize: maxSize);
          final pixelRatio = options.fitPixelRatio(4, Size(longestSide, 1));
          final size = GameSnapshotConnector.imageSize(
            longestSide,
            1,
            pixelRatio,
          );
          expect(size.width, lessThanOrEqualTo(maxSize));
        }
      }
    });
  });

  group('GameSnapshotConnector.annotateGame', () {
    testWithFlameGame('maps the world through the camera', (game) async {
      game.camera.viewfinder
        ..anchor = Anchor.topLeft
        ..position = Vector2(10, 20)
        ..zoom = 2;
      final player = _Player()
        ..position = Vector2(15, 25)
        ..size = Vector2(10, 5);
      await game.world.ensureAdd(player);

      final annotations = GameSnapshotConnector.annotateGame(
        game,
        pixelRatio: 2,
      );

      final annotation = annotations.single;
      expect(annotation.id, player.hashCode);
      expect(annotation.name, '_Player');
      _expectBox(annotation, const Rect.fromLTWH(20, 20, 40, 20));
      expect(annotation.toJson(), {
        'id': player.hashCode,
        'name': '_Player',
        'box': [20.0, 20.0, 40.0, 20.0],
      });
    });

    testWithFlameGame('lines up with a rotated camera', (game) async {
      game.camera.viewfinder
        ..anchor = Anchor.center
        ..position = Vector2.zero()
        ..angle = pi / 2
        ..zoom = 1.5;
      await game.world.ensureAdd(
        RectangleComponent(
          position: Vector2(10, 0),
          size: Vector2(20, 10),
          paint: Paint()..color = const Color(0xFFFFFFFF),
        ),
      );

      final annotation = GameSnapshotConnector.annotateGame(
        game,
        pixelRatio: 2,
      ).single;
      final image = await GameSnapshotConnector.snapshotGame(
        game,
        pixelRatio: 2,
      );

      final center = game.canvasSize;
      final box = annotation.box;
      expect(box.width, closeTo(30, 1e-4));
      expect(box.height, closeTo(60, 1e-4));
      expect((box.left - center.x).abs(), lessThan(31));
      expect((box.top - center.y).abs(), lessThan(91));
      const white = Color(0xFFFFFFFF);
      final inside = box.deflate(2);
      final outside = box.inflate(2);
      for (final point in [
        inside.topLeft,
        inside.bottomRight,
        inside.center,
      ]) {
        expect(
          await _pixelAt(image, point.dx.floor(), point.dy.floor()),
          white,
        );
      }
      for (final point in [outside.topLeft, outside.bottomRight]) {
        expect(
          await _pixelAt(image, point.dx.floor(), point.dy.floor()),
          isNot(white),
        );
      }
    });

    testWithFlameGame('includes nested and viewport components', (game) async {
      game.camera.viewfinder.anchor = Anchor.topLeft;
      final child = PositionComponent(
        position: Vector2(5, 5),
        size: Vector2(10, 10),
        scale: Vector2.all(2),
      );
      await game.world.ensureAdd(
        PositionComponent(
          position: Vector2(100, 100),
          size: Vector2(50, 50),
          children: [child],
        ),
      );
      final hud = PositionComponent(
        position: Vector2(1, 2),
        size: Vector2(3, 4),
      );
      await game.camera.viewport.ensureAdd(hud);

      final annotations = GameSnapshotConnector.annotateGame(game);

      expect(annotations, hasLength(3));
      _expectBox(
        annotations.firstWhere((a) => a.id == child.hashCode),
        const Rect.fromLTWH(105, 105, 20, 20),
      );
      _expectBox(
        annotations.firstWhere((a) => a.id == hud.hashCode),
        const Rect.fromLTWH(1, 2, 3, 4),
      );
    });

    testWithFlameGame(
      'leaves out hidden, empty, off screen and filtered components',
      (game) async {
        game.camera.viewfinder.anchor = Anchor.topLeft;
        await game.world.ensureAddAll([
          _HiddenComponent()
            ..size = Vector2.all(10)
            ..isVisible = false,
          PositionComponent(size: Vector2.zero()),
          PositionComponent(position: Vector2(-100, 0), size: Vector2(10, 10)),
          PositionComponent(size: Vector2(10, 10)),
          _Player()..size = Vector2.all(10),
        ]);

        expect(GameSnapshotConnector.annotateGame(game), hasLength(2));
        expect(
          GameSnapshotConnector.annotateGame(
            game,
            filter: RegExp('player', caseSensitive: false),
          ).map((a) => a.name),
          ['_Player'],
        );
      },
    );

    testWithFlameGame('scales with a fixed resolution viewport', (game) async {
      game.camera = CameraComponent.withFixedResolution(
        width: game.canvasSize.x / 2,
        height: game.canvasSize.y / 2,
        world: game.world,
      );
      game.camera.viewfinder.anchor = Anchor.topLeft;
      await game.ready();
      await game.world.ensureAdd(
        PositionComponent(position: Vector2(10, 20), size: Vector2(30, 40)),
      );
      await game.camera.viewport.ensureAdd(
        PositionComponent(position: Vector2(1, 2), size: Vector2(3, 4)),
      );

      final annotations = GameSnapshotConnector.annotateGame(game);

      expect(annotations, hasLength(2));
      _expectBox(annotations.first, const Rect.fromLTWH(20, 40, 60, 80));
      _expectBox(annotations.last, const Rect.fromLTWH(2, 4, 6, 8));
    });

    testWithFlameGame('maps the backdrop through the viewport', (game) async {
      final backdrop = RectangleComponent(
        position: Vector2(10, 20),
        size: Vector2(30, 40),
        paint: Paint()..color = const Color(0xFFFFFFFF),
      );
      game.camera = CameraComponent(
        viewport: FixedSizeViewport(200, 200)..position = Vector2(50, 60),
        backdrop: backdrop,
        world: game.world,
      );
      await game.ready();

      final annotation = GameSnapshotConnector.annotateGame(game).single;
      final image = await GameSnapshotConnector.snapshotGame(game);

      expect(annotation.id, backdrop.hashCode);
      _expectBox(annotation, const Rect.fromLTWH(60, 80, 30, 40));
      expect(await _pixelAt(image, 75, 100), const Color(0xFFFFFFFF));
      image.dispose();
      _expectBox(
        ComponentSnapshotConnector.annotateComponent(backdrop).single,
        const Rect.fromLTWH(0, 0, 30, 40),
      );
    });

    testWithFlameGame('clips viewport components', (game) async {
      game.camera.viewport = FixedSizeViewport(100, 100);
      await game.ready();
      await game.camera.viewport.ensureAddAll([
        PositionComponent(position: Vector2(10, 10), size: Vector2(10, 10)),
        PositionComponent(position: Vector2(200, 10), size: Vector2(10, 10)),
      ]);

      final annotations = GameSnapshotConnector.annotateGame(game);

      _expectBox(annotations.single, const Rect.fromLTWH(10, 10, 10, 10));
    });

    testWithFlameGame('clips the world to the viewport', (game) async {
      game.camera.viewport = FixedSizeViewport(100, 100);
      game.camera.viewfinder.anchor = Anchor.topLeft;
      await game.ready();
      await game.world.ensureAddAll([
        PositionComponent(position: Vector2(10, 10), size: Vector2(10, 10)),
        PositionComponent(position: Vector2(200, 10), size: Vector2(10, 10)),
      ]);

      final annotations = GameSnapshotConnector.annotateGame(game);

      _expectBox(annotations.single, const Rect.fromLTWH(10, 10, 10, 10));
    });
  });

  group('GameSnapshotConnector.annotateWorld', () {
    testWithFlameGame('uses world coordinates of the rect', (game) async {
      game.camera.viewfinder.zoom = 3;
      await game.world.ensureAdd(
        PositionComponent(
          position: Vector2(-1000, -1000),
          size: Vector2(10, 10),
          anchor: Anchor.center,
        ),
      );

      final annotations = GameSnapshotConnector.annotateWorld(
        game,
        const Rect.fromLTWH(-1010, -1010, 20, 20),
        pixelRatio: 2,
      );

      _expectBox(annotations.single, const Rect.fromLTWH(10, 10, 20, 20));
    });
  });

  group('ComponentSnapshotConnector.annotateComponent', () {
    testWithFlameGame('annotates the component and its children', (
      game,
    ) async {
      final child = PositionComponent(
        position: Vector2(10, 0),
        size: Vector2(5, 5),
      );
      final component = PositionComponent(
        position: Vector2(50, 60),
        size: Vector2(20, 10),
        anchor: Anchor.center,
        children: [child],
      );
      await game.world.ensureAdd(component);

      final annotations = ComponentSnapshotConnector.annotateComponent(
        component,
        pixelRatio: 2,
      );

      expect(annotations, hasLength(2));
      _expectBox(annotations.first, const Rect.fromLTWH(0, 0, 40, 20));
      _expectBox(annotations.last, const Rect.fromLTWH(20, 0, 10, 10));
    });
  });

  group('SnapshotAnnotation.paint', () {
    testWithFlameGame('draws the labels on top of the snapshot', (game) async {
      game.camera.viewfinder.anchor = Anchor.topLeft;
      await game.world.ensureAdd(
        PositionComponent(position: Vector2(10, 10), size: Vector2(50, 30)),
      );

      final annotations = GameSnapshotConnector.annotateGame(game);
      final image = await GameSnapshotConnector.snapshotGame(
        game,
        annotations: annotations,
      );

      expect(await _pixelAt(image, 10, 10), const Color(0xFFFFEB3B));
      expect(await _pixelAt(image, 9, 30), isNot(const Color(0xFF000000)));
      expect(await _pixelAt(image, 200, 200), const Color(0xFF000000));
    });

    testWithFlameGame('keeps the rendered size of the image', (game) async {
      await game.world.ensureAdd(
        PositionComponent(position: Vector2(10, 10), size: Vector2(50, 30)),
      );

      final image = ComponentSnapshotConnector.snapshotComponent(
        game.world,
        annotations: ComponentSnapshotConnector.annotateComponent(game.world),
      );

      expect(image.width, 50);
      expect(image.height, 30);
    });
  });
}
