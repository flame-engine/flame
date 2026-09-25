import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/connectors/component_snapshot_connector.dart';
import 'package:flame/src/devtools/connectors/game_snapshot_connector.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';

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

class _BackgroundGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF0000FF);
}

void main() {
  group('ComponentSnapshotConnector.snapshotComponent', () {
    testWithFlameGame('renders a top left anchored component', (game) async {
      final component = RectangleComponent(
        position: Vector2(50, 60),
        size: Vector2(20, 10),
        paint: Paint()..color = Colors.white,
      );
      await game.world.ensureAdd(component);

      final image = ComponentSnapshotConnector.snapshotComponent(component);

      expect(image.width, 20);
      expect(image.height, 10);
      expect(await _pixelAt(image, 0, 0), Colors.white);
      expect(await _pixelAt(image, 19, 9), Colors.white);
    });

    testWithFlameGame('renders a center anchored component', (game) async {
      final component = RectangleComponent(
        position: Vector2(50, 60),
        size: Vector2(20, 10),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.white,
      );
      await game.world.ensureAdd(component);

      final image = ComponentSnapshotConnector.snapshotComponent(component);

      expect(image.width, 20);
      expect(image.height, 10);
      expect(await _pixelAt(image, 0, 0), Colors.white);
      expect(await _pixelAt(image, 19, 9), Colors.white);
    });

    testWithFlameGame('includes scale and angle in the size', (game) async {
      final component = RectangleComponent(
        position: Vector2(50, 60),
        size: Vector2(20, 10),
        scale: Vector2.all(2),
        angle: pi / 2,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.white,
      );
      await game.world.ensureAdd(component);

      final image = ComponentSnapshotConnector.snapshotComponent(component);

      expect(image.width, 20);
      expect(image.height, 40);
      expect(await _pixelAt(image, 10, 20), Colors.white);
    });

    testWithFlameGame('scales the image with the pixel ratio', (game) async {
      final component = RectangleComponent(
        size: Vector2(20, 10),
        paint: Paint()..color = Colors.white,
      );
      await game.world.ensureAdd(component);

      final image = ComponentSnapshotConnector.snapshotComponent(
        component,
        pixelRatio: 2,
      );

      expect(image.width, 40);
      expect(image.height, 20);
      expect(await _pixelAt(image, 39, 19), Colors.white);
    });

    testWithFlameGame('renders the world without the camera', (game) async {
      await game.world.ensureAdd(
        RectangleComponent(
          position: Vector2(-1000, 500),
          size: Vector2(20, 10),
          paint: Paint()..color = Colors.white,
        ),
      );

      final image = ComponentSnapshotConnector.snapshotComponent(game.world);

      expect(image.width, 20);
      expect(image.height, 10);
      expect(await _pixelAt(image, 0, 0), Colors.white);
    });

    testWithFlameGame('gives zero sized components a size', (game) async {
      final component = PositionComponent();
      await game.world.ensureAdd(component);

      final image = ComponentSnapshotConnector.snapshotComponent(component);

      expect(image.width, 1);
      expect(image.height, 1);
    });
  });

  group('GameSnapshotConnector.snapshotGame', () {
    testWithGame(
      'renders the background and the world through the camera',
      _BackgroundGame.new,
      (game) async {
        game.camera.viewfinder.anchor = Anchor.topLeft;
        await game.world.ensureAdd(
          RectangleComponent(
            size: Vector2(10, 10),
            paint: Paint()..color = Colors.white,
          ),
        );

        final image = await GameSnapshotConnector.snapshotGame(game);

        expect(image.width, game.canvasSize.x);
        expect(image.height, game.canvasSize.y);
        expect(await _pixelAt(image, 5, 5), Colors.white);
        expect(await _pixelAt(image, 20, 20), const Color(0xFF0000FF));
      },
    );

    testWithFlameGame('scales the image with the pixel ratio', (game) async {
      final image = await GameSnapshotConnector.snapshotGame(
        game,
        pixelRatio: 2,
      );

      expect(image.width, game.canvasSize.x * 2);
      expect(image.height, game.canvasSize.y * 2);
    });
  });

  group('GameSnapshotConnector.worldBounds', () {
    testWithFlameGame('is null for an empty world', (game) async {
      expect(GameSnapshotConnector.worldBounds(game.world), isNull);
    });

    testWithFlameGame('contains all position components', (game) async {
      await game.world.ensureAddAll([
        PositionComponent(position: Vector2(-10, -20), size: Vector2(5, 5)),
        PositionComponent(
          position: Vector2(100, 50),
          size: Vector2(10, 10),
          anchor: Anchor.center,
          children: [
            PositionComponent(position: Vector2(20, 0), size: Vector2(4, 4)),
          ],
        ),
      ]);

      expect(
        GameSnapshotConnector.worldBounds(game.world),
        const Rect.fromLTRB(-10, -20, 119, 55),
      );
    });
  });

  group('GameSnapshotConnector.snapshotWorld', () {
    testWithGame(
      'renders a rect of the world in world coordinates',
      _BackgroundGame.new,
      (game) async {
        await game.world.ensureAdd(
          RectangleComponent(
            position: Vector2(-1000, -1000),
            size: Vector2(10, 10),
            paint: Paint()..color = Colors.white,
          ),
        );

        final image = await GameSnapshotConnector.snapshotWorld(
          game,
          const Rect.fromLTWH(-1005, -1005, 20, 20),
          pixelRatio: 2,
        );

        expect(image.width, 40);
        expect(image.height, 20 * 2);
        expect(await _pixelAt(image, 2, 2), const Color(0xFF0000FF));
        expect(await _pixelAt(image, 20, 20), Colors.white);
      },
    );
  });
}
