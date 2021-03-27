import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../commons/square_component.dart';

final R = Random();

class MovableSquare extends SquareComponent
    with Hitbox, Collidable, HasGameRef<CameraAndViewportGame> {
  static const double speed = 300;
  static final TextConfig config = TextConfig(fontSize: 12);

  final Vector2 velocity = Vector2.zero();
  late Timer timer;

  MovableSquare() {
    addShape(HitboxRectangle());
    timer = Timer(3.0)
      ..stop()
      ..callback = () {
        gameRef!.camera.setRelativeOffset(Anchor.center.toVector2());
      };
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);

    final ds = velocity * (speed * dt);
    position += ds;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    final text = '(${x.toInt()}, ${y.toInt()})';
    config.render(c, text, size / 2, anchor: Anchor.center);
  }

  @override
  int get priority => 1;

  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    if (other is Rock) {
      gameRef!.camera.setRelativeOffset(Anchor.topCenter.toVector2());
      timer.start();
    }
  }
}

class Map extends Component {
  static const double S = 1500;
  static const Rect bounds = Rect.fromLTWH(-S, -S, 2 * S, 2 * S);

  static final Paint _paintBorder = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;
  static final Paint _paintBg = Paint()..color = const Color(0xFF333333);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(bounds, _paintBg);
    canvas.drawRect(bounds, _paintBorder);
  }

  @override
  int get priority => 0;

  static double genCoord() {
    return -S + R.nextDouble() * (2 * S);
  }
}

class Rock extends SquareComponent with Hitbox, Collidable {
  Rock(Vector2 position) {
    this.position = position;
    size = Vector2.all(50);
    paint = Paint()..color = const Color(0xFF2222FF);
    addShape(HitboxRectangle());
  }

  @override
  int get priority => 2;
}

class CameraAndViewportGame extends BaseGame
    with KeyboardEvents, HasCollidables {
  late MovableSquare square;

  @override
  Future<void> onLoad() async {
    viewport = FixedResolutionViewport(Vector2(500, 500));
    add(Map());

    add(square = MovableSquare());
    camera.cameraSpeed = 1;
    camera.followObject(square, worldBounds: Map.bounds);

    for (var i = 0; i < 30; i++) {
      add(Rock(Vector2(Map.genCoord(), Map.genCoord())));
    }
  }

  @override
  void onKeyEvent(RawKeyEvent e) {
    final isKeyDown = e is RawKeyDownEvent;
    if (e.data.keyLabel == 'a') {
      square.velocity.x = isKeyDown ? -1 : 0;
    } else if (e.data.keyLabel == 'd') {
      square.velocity.x = isKeyDown ? 1 : 0;
    } else if (e.data.keyLabel == 'w') {
      square.velocity.y = isKeyDown ? -1 : 0;
    } else if (e.data.keyLabel == 's') {
      square.velocity.y = isKeyDown ? 1 : 0;
    }
  }
}
