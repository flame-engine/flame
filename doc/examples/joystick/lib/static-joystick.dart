import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/joystick.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';

import 'player.dart';

class StaticJoystick extends Joystick {
  StaticJoystick() {
    visible = true;
    fixedPosition = true;
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

    // Placing the joystick in the bottom right corner of the screen
    setPosition(size.width * 0.8, size.height * 0.8);
  }
}

class StaticJoystickGame extends BaseGame with PanDetector {
  final player = Player();
  final joystick = StaticJoystick();

  StaticJoystickGame() {
    add(player);
    add(joystick);
  }

  void _input(Offset pos) {
    joystick.moveKnob(pos);
    player.updateVelocity(joystick.offset);
  }

  void _endInput() {
    joystick.releaseKnob();
    player.updateVelocity(joystick.offset); // offset will be zero
  }

  @override
  void onPanDown(DragDownDetails details) => _input(details.localPosition);

  @override
  void onPanStart(DragStartDetails details) => _input(details.localPosition);

  @override
  void onPanUpdate(DragUpdateDetails details) => _input(details.localPosition);

  @override
  void onPanEnd(DragEndDetails details) => _endInput();

  @override
  void onPanCancel() => _endInput();
}
