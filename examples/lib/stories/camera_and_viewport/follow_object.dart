import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../commons/square_component.dart';

class CameraAndViewportExample extends FlameGame
    with HasCollidables, HasTappables, HasKeyboardHandlerComponents {
  static const String description = '''
    Move around with W, A, S, D and notice how the camera follows the white 
    square.\n
    If you collide with the blue squares, the camera reference is changed from
    center to topCenter.\n
    The blue squares can also be clicked to show how the coordinate system
    respects the camera transformation.
  ''';

  late MovableSquare square;

  final Vector2 viewportResolution;

  CameraAndViewportExample({
    required this.viewportResolution,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewport = FixedResolutionViewport(viewportResolution);
    add(Map());

    add(square = MovableSquare());
    camera.speed = 1;
    camera.followComponent(square, worldBounds: Map.bounds);

    for (var i = 0; i < 30; i++) {
      add(Rock(Vector2(Map.genCoord(), Map.genCoord())));
    }
  }
}

class MovableSquare extends SquareComponent
    with Collidable, HasGameRef<CameraAndViewportExample>, KeyboardHandler {
  static const double speed = 300;
  static final TextPaint textRenderer = TextPaint(
    style: const TextStyle(fontSize: 12),
  );

  final Vector2 velocity = Vector2.zero();
  late Timer timer;

  MovableSquare() : super(priority: 1);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    timer = Timer(3.0)
      ..stop()
      ..onTick = () {
        gameRef.camera.setRelativeOffset(Anchor.center);
      };
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);

    final ds = velocity * (speed * dt);
    position.add(ds);
  }

  @override
  void render(Canvas c) {
    final text = '(${x.toInt()}, ${y.toInt()})';
    textRenderer.render(c, text, size / 2, anchor: Anchor.center);
  }

  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    if (other is Rock) {
      gameRef.camera.setRelativeOffset(Anchor.topCenter);
      timer.start();
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      velocity.x = isKeyDown ? -1 : 0;
      return false;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      velocity.x = isKeyDown ? 1 : 0;
      return false;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      velocity.y = isKeyDown ? -1 : 0;
      return false;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      velocity.y = isKeyDown ? 1 : 0;
      return false;
    }

    return super.onKeyEvent(event, keysPressed);
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

  static final _rng = Random();

  Map() : super(priority: 0);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(bounds, _paintBg);
    canvas.drawRect(bounds, _paintBorder);
  }

  static double genCoord() {
    return -S + _rng.nextDouble() * (2 * S);
  }
}

class Rock extends SquareComponent with Collidable, Tappable {
  static final unpressedPaint = Paint()..color = const Color(0xFF2222FF);
  static final pressedPaint = Paint()..color = const Color(0xFF414175);

  Rock(Vector2 position)
      : super(
          position: position,
          size: 50,
          priority: 2,
          paint: unpressedPaint,
        );

  @override
  bool onTapDown(_) {
    paint = pressedPaint;
    return true;
  }

  @override
  bool onTapUp(_) {
    paint = unpressedPaint;
    return true;
  }

  @override
  bool onTapCancel() {
    paint = unpressedPaint;
    return true;
  }
}
