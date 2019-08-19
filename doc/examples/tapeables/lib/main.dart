import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/events/gestures.dart';

void main() {
    final game = MyGame();
    runApp(game.widget);

    game.addComps();
}

class TapeableSquare extends PositionComponent with Tapeable {
    static final Paint _white = Paint()..color = const Color(0xffffffff);
    static final Paint _grey = Paint()..color = const Color(0xffa5a5a5);

    bool _beenPressed = false;

    TapeableSquare() {
        x = y = width = height = 100;
    }

    @override
    void update(double dt) {}

    @override
    void render(Canvas canvas) {
        if (_beenPressed) {
            canvas.drawRect(toRect(), _grey);
        } else {
            canvas.drawRect(toRect(), _white);
        }
    }

    @override
    void onTapUp(TapUpDetails details) {
        _beenPressed = false;
    }

    @override
    void onTapDown(TapDownDetails details) {
        _beenPressed = true;
    }

    @override
    void onTapCancel() {
        _beenPressed = false;
    }
}

class MyGame extends BaseGame {
    void addComps() {
        add(TapeableSquare());
    }
}
