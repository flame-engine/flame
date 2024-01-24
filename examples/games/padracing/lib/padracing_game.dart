import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:padracing/ball.dart';
import 'package:padracing/car.dart';
import 'package:padracing/game_colors.dart';
import 'package:padracing/lap_line.dart';
import 'package:padracing/lap_text.dart';
import 'package:padracing/wall.dart';

final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> playersKeys = [
  {
    LogicalKeyboardKey.arrowUp: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight: LogicalKeyboardKey.arrowRight,
  },
  {
    LogicalKeyboardKey.keyW: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.keyS: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.keyA: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.keyD: LogicalKeyboardKey.arrowRight,
  },
];

class PadRacingGame extends Forge2DGame with KeyboardEvents {
  static const String description = '''
     This is an example game that uses Forge2D to handle the physics.
     In this game you should finish 3 laps in as little time as possible, it can
     be played as single player or with two players (on the same keyboard).
     Watch out for the balls, they make your car spin.
  ''';

  PadRacingGame() : super(gravity: Vector2.zero(), zoom: 1);

  @override
  Color backgroundColor() => Colors.black;

  static final Vector2 trackSize = Vector2.all(500);
  static const double playZoom = 8.0;
  static const int numberOfLaps = 3;
  late CameraComponent startCamera;
  late List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late List<Set<LogicalKeyboardKey>> pressedKeySets;
  final cars = <Car>[];
  bool isGameOver = true;
  Car? winner;
  double _timePassed = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    camera.removeFromParent();
    children.register<CameraComponent>();

    final walls = createWalls(trackSize);
    final bigBall = Ball(initialPosition: Vector2(200, 245), isMovable: false);
    world.addAll([
      LapLine(1, Vector2(25, 50), Vector2(50, 5), isFinish: false),
      LapLine(2, Vector2(25, 70), Vector2(50, 5), isFinish: false),
      LapLine(3, Vector2(52.5, 25), Vector2(5, 50), isFinish: true),
      bigBall,
      ...walls,
      ...createBalls(trackSize, walls, bigBall),
    ]);

    openMenu();
  }

  void openMenu() {
    overlays.add('menu');
    final zoomLevel = min(
      canvasSize.x / trackSize.x,
      canvasSize.y / trackSize.y,
    );
    startCamera = CameraComponent(world: world)
      ..viewfinder.position = trackSize / 2
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = zoomLevel - 0.2;
    add(startCamera);
  }

  void prepareStart({required int numberOfPlayers}) {
    startCamera.viewfinder
      ..add(
        ScaleEffect.to(
          Vector2.all(playZoom),
          EffectController(duration: 1.0),
          onComplete: () => start(numberOfPlayers: numberOfPlayers),
        ),
      )
      ..add(
        MoveEffect.to(
          Vector2.all(20),
          EffectController(duration: 1.0),
        ),
      );
  }

  void start({required int numberOfPlayers}) {
    isGameOver = false;
    overlays.remove('menu');
    startCamera.removeFromParent();
    final isHorizontal = canvasSize.x > canvasSize.y;
    Vector2 alignedVector({
      required double longMultiplier,
      double shortMultiplier = 1.0,
    }) {
      return Vector2(
        isHorizontal
            ? canvasSize.x * longMultiplier
            : canvasSize.x * shortMultiplier,
        !isHorizontal
            ? canvasSize.y * longMultiplier
            : canvasSize.y * shortMultiplier,
      );
    }

    final viewportSize = alignedVector(longMultiplier: 1 / numberOfPlayers);

    RectangleComponent viewportRimGenerator() =>
        RectangleComponent(size: viewportSize, anchor: Anchor.topLeft)
          ..paint.color = GameColors.blue.color
          ..paint.strokeWidth = 2.0
          ..paint.style = PaintingStyle.stroke;
    final cameras = List.generate(numberOfPlayers, (i) {
      return CameraComponent(
        world: world,
        viewport: FixedSizeViewport(viewportSize.x, viewportSize.y)
          ..position = alignedVector(
            longMultiplier: i == 0 ? 0.0 : 1 / (i + 1),
            shortMultiplier: 0.0,
          )
          ..add(viewportRimGenerator()),
      )
        ..viewfinder.anchor = Anchor.center
        ..viewfinder.zoom = playZoom;
    });

    final mapCameraSize = Vector2.all(500);
    const mapCameraZoom = 0.5;
    final mapCameras = List.generate(numberOfPlayers, (i) {
      return CameraComponent(
        world: world,
        viewport: FixedSizeViewport(mapCameraSize.x, mapCameraSize.y)
          ..position = Vector2(
            viewportSize.x - mapCameraSize.x * mapCameraZoom - 50,
            50,
          ),
      )
        ..viewfinder.anchor = Anchor.topLeft
        ..viewfinder.zoom = mapCameraZoom;
    });
    addAll(cameras);

    for (var i = 0; i < numberOfPlayers; i++) {
      final car = Car(playerNumber: i, cameraComponent: cameras[i]);
      final lapText = LapText(
        car: car,
        position: Vector2.all(100),
      );

      car.lapNotifier.addListener(() {
        if (car.lapNotifier.value > numberOfLaps) {
          isGameOver = true;
          winner = car;
          overlays.add('game_over');
          lapText.addAll([
            ScaleEffect.by(
              Vector2.all(1.5),
              EffectController(duration: 0.2, alternate: true, repeatCount: 3),
            ),
            RotateEffect.by(pi * 2, EffectController(duration: 0.5)),
          ]);
        } else {
          lapText.add(
            ScaleEffect.by(
              Vector2.all(1.5),
              EffectController(duration: 0.2, alternate: true),
            ),
          );
        }
      });
      cars.add(car);
      world.add(car);
      cameras[i].viewport.addAll([lapText, mapCameras[i]]);
    }

    pressedKeySets = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }
    _timePassed += dt;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (!isLoaded || isGameOver) {
      return KeyEventResult.ignored;
    }

    _clearPressedKeys();
    for (final key in keysPressed) {
      activeKeyMaps.forEachIndexed((i, keyMap) {
        if (keyMap.containsKey(key)) {
          pressedKeySets[i].add(keyMap[key]!);
        }
      });
    }
    return KeyEventResult.handled;
  }

  void _clearPressedKeys() {
    for (final pressedKeySet in pressedKeySets) {
      pressedKeySet.clear();
    }
  }

  void reset() {
    _clearPressedKeys();
    activeKeyMaps.clear();
    _timePassed = 0;
    overlays.remove('game_over');
    openMenu();
    for (final car in cars) {
      car.removeFromParent();
    }
    for (final camera in children.query<CameraComponent>()) {
      camera.removeFromParent();
    }
  }

  String _maybePrefixZero(int number) {
    if (number < 10) {
      return '0$number';
    }
    return number.toString();
  }

  String get timePassed {
    final minutes = _maybePrefixZero((_timePassed / 60).floor());
    final seconds = _maybePrefixZero((_timePassed % 60).floor());
    final ms = _maybePrefixZero(((_timePassed % 1) * 100).floor());
    return [minutes, seconds, ms].join(':');
  }
}
