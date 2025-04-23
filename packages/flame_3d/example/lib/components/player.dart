import 'dart:math';

import 'package:example/example_game_3d.dart';
import 'package:example/keyboard_utils.dart';
import 'package:flame/components.dart' show HasGameReference, KeyboardHandler;
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/services.dart';

class Player extends MeshComponent
    with HasGameReference<ExampleGame3D>, KeyboardHandler {
  final Vector2 _input = Vector2.zero();

  double _lookAngle = 0.0;
  double get lookAngle => _lookAngle;
  set lookAngle(double value) {
    _lookAngle = value % tau;
    transform.rotation.setAxisAngle(_up, value);
  }

  Vector3 get lookAt => Vector3(sin(_lookAngle), 0.0, cos(_lookAngle));

  Player({required Vector3 position})
      : super(
          position: position,
          mesh: CuboidMesh(
            size: Vector3(1, 2, 1),
            material: SpatialMaterial(
              albedoTexture: ColorTexture(BasicPalette.yellow.color),
            ),
          ),
        );

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return readArrowLikeKeysIntoVector2(event, keysPressed, _input);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _handleMovement(dt);
  }

  void reset() {
    position.setFrom(Vector3(0, 1, 0));
    lookAngle = 0.0;
    _input.setZero();
  }

  void _handleMovement(double dt) {
    lookAngle += -_input.x * _rotationSpeed * dt;

    final movement = lookAt.scaled(-_input.y * _walkingSpeed * dt);
    position.add(movement);
  }

  static const double _rotationSpeed = 3.0;
  static const double _walkingSpeed = 1.85;
  static final Vector3 _up = Vector3(0, 1, 0);
}
