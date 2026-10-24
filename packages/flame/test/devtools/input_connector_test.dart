import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/connectors/input_connector.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Tapper() extends PositionComponent with TapCallbacks {
  this : super(position: Vector2(10, 10), size: Vector2(20, 20));

  final taps = <Vector2>[];

  @override
  void onTapUp(TapUpEvent event) => taps.add(event.localPosition);
}

class _Dragger() extends PositionComponent with DragCallbacks {
  this : super(size: Vector2(100, 100));

  int starts = 0;
  int updates = 0;
  int ends = 0;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    starts++;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) => updates++;

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    ends++;
  }
}

class _KeyGame() extends FlameGame with HasKeyboardHandlerComponents;

class _Listener() extends Component with KeyboardHandler {
  final events = <KeyEvent>[];
  final pressed = <Set<LogicalKeyboardKey>>[];

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    events.add(event);
    pressed.add(keysPressed);
    return true;
  }
}

void main() {
  group('InputConnector', () {
    testWithFlameGame('taps the component at the position', (game) async {
      final tapper = _Tapper();
      await game.ensureAdd(tapper);

      expect(InputConnector.tap(game, const Offset(15, 20)), isNull);

      expect(tapper.taps, [Vector2(5, 10)]);
    });

    testWithFlameGame('reports when nothing handles taps', (game) async {
      expect(
        InputConnector.tap(game, Offset.zero),
        contains('TapCallbacks'),
      );
    });

    testWithFlameGame('drags across the component in steps', (game) async {
      final dragger = _Dragger();
      await game.ensureAdd(dragger);

      expect(
        InputConnector.drag(
          game,
          const Offset(10, 10),
          const Offset(50, 10),
          steps: 4,
        ),
        isNull,
      );

      expect(dragger.starts, 1);
      expect(dragger.updates, 4);
      expect(dragger.ends, 1);
    });

    testWithFlameGame('reports when nothing handles drags', (game) async {
      expect(
        InputConnector.drag(game, Offset.zero, Offset.zero),
        contains('DragCallbacks'),
      );
    });

    testWithGame('presses and releases a key', _KeyGame.new, (game) async {
      final listener = _Listener();
      await game.ensureAdd(listener);

      expect(
        InputConnector.pressKey(game, LogicalKeyboardKey.space),
        isNull,
      );

      expect(listener.events, [isA<KeyDownEvent>(), isA<KeyUpEvent>()]);
      expect(listener.events.first.logicalKey, LogicalKeyboardKey.space);
      expect(listener.pressed, [
        {LogicalKeyboardKey.space},
        <LogicalKeyboardKey>{},
      ]);
    });

    testWithGame('only presses a key down', _KeyGame.new, (game) async {
      final listener = _Listener();
      await game.ensureAdd(listener);

      InputConnector.pressKey(game, LogicalKeyboardKey.keyA, action: 'down');

      expect(listener.events, [isA<KeyDownEvent>()]);
      expect(listener.events.single.character, 'A');
    });

    testWithFlameGame('reports when the game ignores keys', (game) async {
      expect(
        InputConnector.pressKey(game, LogicalKeyboardKey.space),
        contains('HasKeyboardHandlerComponents'),
      );
    });
  });

  group('InputConnector.canvasPositionOf', () {
    Offset? positionOf(
      FlameGame game,
      Component component, {
      Anchor anchor = Anchor.center,
    }) {
      return InputConnector.canvasPositionOf(
        game,
        component,
        anchor: anchor,
      ).position;
    }

    String? errorOf(FlameGame game, Component component) {
      return InputConnector.canvasPositionOf(game, component).error;
    }

    void expectOffset(Offset? actual, Offset expected) {
      expect(actual, isNotNull);
      expect(actual!.dx, closeTo(expected.dx, 1e-4));
      expect(actual.dy, closeTo(expected.dy, 1e-4));
    }

    testWithFlameGame('finds a component on the game', (game) async {
      final tapper = _Tapper();
      await game.ensureAdd(tapper);

      expect(positionOf(game, tapper), const Offset(20, 20));
      expect(
        positionOf(game, tapper, anchor: Anchor.topLeft),
        const Offset(10, 10),
      );
      expect(
        positionOf(game, tapper, anchor: const Anchor(1, 0.25)),
        const Offset(30, 15),
      );
    });

    testWithFlameGame('goes through rotated parents', (game) async {
      final child = PositionComponent(
        position: Vector2(10, 0),
        size: Vector2(4, 4),
      );
      final parent = PositionComponent(
        position: Vector2(100, 100),
        angle: pi / 2,
        children: [child],
      );
      await game.ensureAdd(parent);

      expectOffset(positionOf(game, child), const Offset(98, 112));
    });

    testWithFlameGame(
      'finds a component in the world through a moved and zoomed camera',
      (game) async {
        final tapper = _Tapper()..position = Vector2(110, 60);
        await game.world.ensureAdd(tapper);
        game.camera.viewfinder
          ..position = Vector2(100, 50)
          ..zoom = 2;
        game.update(0);

        final position = positionOf(game, tapper);
        expectOffset(position, const Offset(440, 340));

        expect(InputConnector.tap(game, position!), isNull);
        expect(tapper.taps.single.x, closeTo(10, 1e-4));
        expect(tapper.taps.single.y, closeTo(10, 1e-4));
      },
    );

    testWithFlameGame('finds a component through a rotated camera', (
      game,
    ) async {
      final tapper = _Tapper()..position = Vector2(30, -20);
      await game.world.ensureAdd(tapper);
      game.camera.viewfinder
        ..position = Vector2(20, -10)
        ..zoom = 1.5
        ..angle = pi / 3;
      game.update(0);

      final expected = game.camera.localToGlobal(tapper.absoluteCenter);
      expectOffset(positionOf(game, tapper), expected.toOffset());

      expect(InputConnector.tap(game, positionOf(game, tapper)!), isNull);
      expect(tapper.taps.single.x, closeTo(10, 1e-4));
      expect(tapper.taps.single.y, closeTo(10, 1e-4));
    });

    testWithFlameGame('finds a component on the viewfinder', (game) async {
      final component = PositionComponent(
        position: Vector2(110, 60),
        size: Vector2(10, 10),
      );
      await game.camera.viewfinder.ensureAdd(component);
      game.camera.viewfinder
        ..position = Vector2(100, 50)
        ..zoom = 2;
      game.update(0);

      expectOffset(positionOf(game, component), const Offset(430, 330));
    });

    testWithFlameGame(
      'finds a component on a fixed resolution viewport',
      (game) async {
        game.camera = CameraComponent.withFixedResolution(
          world: game.world,
          width: 400,
          height: 300,
        );
        await game.ready();
        final component = PositionComponent(
          position: Vector2(50, 60),
          size: Vector2(20, 20),
        );
        await game.camera.viewport.ensureAdd(component);
        final worldComponent = PositionComponent(size: Vector2(10, 10));
        await game.world.ensureAdd(worldComponent);

        expectOffset(positionOf(game, component), const Offset(120, 140));
        expectOffset(positionOf(game, worldComponent), const Offset(410, 310));
      },
    );

    testWithFlameGame('reports components without a position', (game) async {
      final component = Component();
      await game.ensureAdd(component);

      expect(errorOf(game, component), contains('not a PositionComponent'));
    });

    testWithFlameGame('reports components off screen', (game) async {
      final outside = PositionComponent(
        position: Vector2(-100, 10),
        size: Vector2(10, 10),
      );
      final inWorld = PositionComponent(
        position: Vector2(1000, 0),
        size: Vector2(10, 10),
      );
      await game.ensureAdd(outside);
      await game.world.ensureAdd(inWorld);

      expect(errorOf(game, outside), contains('not visible'));
      expect(errorOf(game, inWorld), contains('it is at 1405.0,305.0'));
    });

    testWithFlameGame('reports components clipped by the viewport', (
      game,
    ) async {
      game.camera = CameraComponent(
        world: game.world,
        viewport: CircularViewport(100),
      );
      await game.ready();
      final component = PositionComponent(
        position: Vector2(90, 90),
        size: Vector2(10, 10),
      );
      await game.world.ensureAdd(component);

      expect(errorOf(game, component), contains('not visible'));
    });

    testWithFlameGame('reports worlds that no camera shows', (game) async {
      final world = World();
      final component = PositionComponent(size: Vector2(10, 10));
      await game.ensureAdd(world);
      await world.ensureAdd(component);

      expect(errorOf(game, component), contains('no camera'));
    });

    testWithFlameGame('uses another camera that shows the world', (
      game,
    ) async {
      final world = World();
      final camera = CameraComponent(world: world)
        ..viewport.position = Vector2(100, 0)
        ..viewfinder.anchor = Anchor.topLeft;
      final component = PositionComponent(size: Vector2(10, 10));
      await game.ensureAddAll([world, camera]);
      await world.ensureAdd(component);

      expectOffset(positionOf(game, component), const Offset(105, 5));
    });
    testWithFlameGame(
      'taps a component through a fixed resolution viewport and a moved, '
      'zoomed and rotated camera',
      (game) async {
        game.camera = CameraComponent.withFixedResolution(
          world: game.world,
          width: 300,
          height: 400,
        );
        await game.ready();
        game.camera.viewfinder
          ..position = Vector2(20, -10)
          ..zoom = 1.7
          ..angle = 0.7;
        final tapper = _Tapper();
        await game.world.ensureAdd(tapper);

        final position = positionOf(
          game,
          tapper,
          anchor: const Anchor(0.25, 0.75),
        );
        expect(InputConnector.tap(game, position!), isNull);
        expect(tapper.taps.single.x, closeTo(5, 1e-4));
        expect(tapper.taps.single.y, closeTo(15, 1e-4));
      },
    );

    testWithFlameGame('taps a component through a moved viewport', (
      game,
    ) async {
      game.camera = CameraComponent(
        world: game.world,
        viewport: FixedSizeViewport(300, 200)
          ..position = Vector2(500, 400)
          ..anchor = Anchor.center,
      );
      await game.ready();
      game.camera.viewfinder.angle = 0.7;
      final tapper = _Tapper();
      await game.world.ensureAdd(tapper);

      expect(InputConnector.tap(game, positionOf(game, tapper)!), isNull);
      expect(tapper.taps.single.x, closeTo(10, 1e-4));
      expect(tapper.taps.single.y, closeTo(10, 1e-4));
    });

    testWithFlameGame('taps a component through a camera in a world', (
      game,
    ) async {
      final world = World();
      final camera = CameraComponent(
        world: world,
        viewport: FixedSizeViewport(300, 200)..position = Vector2(10, 20),
      );
      await game.ensureAdd(world);
      await game.world.ensureAdd(camera);
      camera.viewfinder.zoom = 1.5;
      game.camera.viewfinder.angle = 0.1;
      final tapper = _Tapper();
      await world.ensureAdd(tapper);

      expect(InputConnector.tap(game, positionOf(game, tapper)!), isNull);
      expect(tapper.taps.single.x, closeTo(10, 1e-4));
      expect(tapper.taps.single.y, closeTo(10, 1e-4));
    });

    testWithFlameGame('finds a component on the backdrop', (game) async {
      game.camera = CameraComponent.withFixedResolution(
        world: game.world,
        width: 300,
        height: 400,
      );
      await game.ready();
      final component = PositionComponent(
        position: Vector2(10, 10),
        size: Vector2(20, 20),
      );
      await game.camera.backdrop.ensureAdd(component);

      expectOffset(positionOf(game, component), const Offset(205, 30));
    });

    testWithFlameGame('reports components on the camera', (game) async {
      final component = PositionComponent(size: Vector2(10, 10));
      await game.camera.ensureAdd(component);

      expect(errorOf(game, component), contains('not visible'));
    });

    testWithFlameGame('reports worlds only shown from within', (game) async {
      final world = World();
      final component = PositionComponent(size: Vector2(10, 10));
      await game.ensureAdd(world);
      await world.ensureAddAll([CameraComponent(world: world), component]);

      expect(errorOf(game, component), contains('no camera'));
    });
  });

  group('InputConnector.parseAnchor', () {
    test('parses names and fractions', () {
      expect(InputConnector.parseAnchor(null), Anchor.center);
      expect(InputConnector.parseAnchor('topLeft'), Anchor.topLeft);
      expect(InputConnector.parseAnchor('bottomright'), Anchor.bottomRight);
      expect(InputConnector.parseAnchor('0.25,1'), const Anchor(0.25, 1));
    });

    test('returns null for invalid anchors', () {
      expect(InputConnector.parseAnchor('middle'), isNull);
      expect(InputConnector.parseAnchor('1,2,3'), isNull);
      expect(InputConnector.parseAnchor('a,b'), isNull);
    });
  });

  group('InputConnector.findLogicalKey', () {
    test('finds keys by name, letter and label', () {
      expect(
        InputConnector.findLogicalKey('arrowLeft'),
        LogicalKeyboardKey.arrowLeft,
      );
      expect(
        InputConnector.findLogicalKey('Arrow Left'),
        LogicalKeyboardKey.arrowLeft,
      );
      expect(
        InputConnector.findLogicalKey('arrow_left'),
        LogicalKeyboardKey.arrowLeft,
      );
      expect(InputConnector.findLogicalKey('space'), LogicalKeyboardKey.space);
      expect(InputConnector.findLogicalKey('a'), LogicalKeyboardKey.keyA);
      expect(InputConnector.findLogicalKey('keyA'), LogicalKeyboardKey.keyA);
      expect(InputConnector.findLogicalKey('1'), LogicalKeyboardKey.digit1);
      expect(InputConnector.findLogicalKey('F5'), LogicalKeyboardKey.f5);
    });

    test('returns null for unknown keys', () {
      expect(InputConnector.findLogicalKey(''), isNull);
      expect(InputConnector.findLogicalKey('banana'), isNull);
    });
  });
}
