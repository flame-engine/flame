import 'dart:math';
import 'dart:ui';

import 'package:flame/game/base_game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/joystick.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';

import 'player.dart';

class DynamicJoystick extends Joystick {
  DynamicJoystick() {
    // The joystick is invisible by default and only shown when the player touches the screen
    visible = false;
    fixedPosition = false;
    // Setting the visuals of the base and knob
    base.sprite = Sprite('joystick_socket.png');
    knob.sprite = Sprite('joystick_knob.png');
  }

  @override
  void resize(Size size) {
    // The size of the joystick will be 20% of the screen's width
    final side = size.width * 0.2;
    knob.width = knob.height = side;
    base.width = base.height = side;
    movementRadius = side * sqrt2 / 2; // half the hypotenuse of the square
  }
}

class DynamicJoystickGame extends BaseGame with PanDetector {
  final player = Player();
  final joystick = DynamicJoystick();

  DynamicJoystickGame() {
    add(player);
    add(joystick);
  }

  void _startInput(Offset pos) => joystick.showAt(pos);

  void _updateInput(Offset pos) {
    joystick.moveKnob(pos);
    player.updateVelocity(joystick.offset);
  }

  void _endInput() {
    joystick.hideAndRelease();
    player.updateVelocity(joystick.offset); // offset will be zero
  }

  @override
  void onPanDown(DragDownDetails details) => _startInput(details.localPosition);

  @override
  void onPanStart(DragStartDetails details) =>
      _updateInput(details.localPosition);

  @override
  void onPanUpdate(DragUpdateDetails details) =>
      _updateInput(details.localPosition);

  @override
  void onPanEnd(DragEndDetails details) => _endInput();

  @override
  void onPanCancel() => _endInput();
}
