import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LookAtExample extends FlameGame<_TapWorld>
    with HasKeyboardHandlerComponents {
  static const description =
      'This example demonstrates how a component can be '
      'made to look at a specific target using the lookAt method. Tap anywhere '
      'to change the target point for both the choppers. '
      'It also shows how nativeAngle can be used to make the component '
      'oriented in the desired direction if the image is not facing the '
      'correct direction.';

  LookAtExample() : super(world: _TapWorld());

  late List<_ChopperParent> _choppers;

  @override
  Color backgroundColor() => const Color.fromARGB(255, 96, 145, 112);

  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await images.load('animations/chopper.png'),
      srcSize: Vector2.all(48),
    );

    _spawnChoppers(spriteSheet);
  }

  void _spawnChoppers(SpriteSheet spriteSheet) {
    _choppers = [
      // Notice now the nativeAngle is set to pi because the chopper
      // is facing in down/south direction in the original image.
      _ChopperParent(
        position: Vector2(0, -200),
        chopper: SpriteAnimationComponent(
          nativeAngle: pi,
          size: Vector2.all(128),
          anchor: Anchor.center,
          animation: spriteSheet.createAnimation(row: 0, stepTime: 0.05),
        ),
      ),
      // This chopper does not use correct nativeAngle, hence using
      // lookAt on it results in the sprite pointing in incorrect
      // direction visually.
      _ChopperParent(
        position: Vector2(0, 200),
        chopper: SpriteAnimationComponent(
          size: Vector2.all(128),
          anchor: Anchor.center,
          animation: spriteSheet.createAnimation(row: 0, stepTime: 0.05),
        ),
      ),
    ];
    world.addAll(_choppers);
  }
}

class _TapWorld extends World
    with TapCallbacks, KeyboardHandler, HasGameReference<LookAtExample> {
  final CircleComponent target = CircleComponent(
    radius: 5,
    anchor: Anchor.center,
    paint: BasicPalette.black.paint(),
  );

  int _currentFlipIndex = 0;
  final _flips = [
    (Vector2(1, 1), Vector2(1, 1)),
    (Vector2(1, 1), Vector2(1, -1)),
    (Vector2(1, 1), Vector2(-1, 1)),
    (Vector2(1, 1), Vector2(-1, -1)),
    (Vector2(1, -1), Vector2(1, 1)),
    (Vector2(1, -1), Vector2(1, -1)),
    (Vector2(1, -1), Vector2(-1, 1)),
    (Vector2(1, -1), Vector2(-1, -1)),
    (Vector2(-1, 1), Vector2(1, 1)),
    (Vector2(-1, 1), Vector2(1, -1)),
    (Vector2(-1, 1), Vector2(-1, 1)),
    (Vector2(-1, 1), Vector2(-1, -1)),
    (Vector2(-1, -1), Vector2(1, 1)),
    (Vector2(-1, -1), Vector2(1, -1)),
    (Vector2(-1, -1), Vector2(-1, 1)),
    (Vector2(-1, -1), Vector2(-1, -1)),
  ];

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.keyF)) {
        _cycleFlips();
        return true;
      }
    }
    return false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    _updatePosition(event.localPosition);
  }

  void _cycleFlips() {
    _currentFlipIndex = (_currentFlipIndex + 1) % _flips.length;
    final nextFlip = _flips[_currentFlipIndex];
    for (final parent in game._choppers) {
      parent.scale = nextFlip.$1;
      parent.chopper.scale = nextFlip.$2;
    }
  }

  void _updatePosition(Vector2 position) {
    if (!target.isMounted) {
      add(target);
    }
    target.position = position;
    for (final parent in game._choppers) {
      parent.chopper.lookAt(position);
    }
  }
}

class _ChopperParent extends PositionComponent
    with HasGameReference<LookAtExample> {
  final PositionComponent chopper;
  late TextBoxComponent textBox;

  _ChopperParent({
    required super.position,
    required this.chopper,
  }) : super(children: [chopper]);

  @override
  FutureOr<void> onLoad() {
    final shaded = TextPaint(
      style: TextStyle(
        color: BasicPalette.white.color,
        fontSize: 30.0,
        shadows: const [
          Shadow(offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    );
    parent!.add(
      textBox = TextBoxComponent(
        text: '-',
        position: position + Vector2(0, -150),
        anchor: Anchor.center,
        align: Anchor.topCenter,
        textRenderer: shaded,
        boxConfig: const TextBoxConfig(
          maxWidth: 600,
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    final angleTo = chopper.angleTo(game.world.target.position);
    textBox.text =
        '''
      nativeAngle = ${chopper.nativeAngle.toStringAsFixed(2)}
      angleTo = ${angleTo.toStringAsFixed(2)}
      absoluteAngle = ${chopper.absoluteAngle.toStringAsFixed(2)}
      absoluteScale = ${_asSigns(chopper.absoluteScale)} (${_asSigns(absoluteScale)} * ${_asSigns(chopper.scale)})
    ''';
  }

  String _asSigns(Vector2 v) {
    return '[${_asSign(v.x)}, ${_asSign(v.y)}]';
  }

  String _asSign(double value) {
    return switch (value.sign) {
      1 => '+',
      -1 => '-',
      _ => '0',
    };
  }
}
