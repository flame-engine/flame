import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../commons/ember.dart';

class FollowComponentExample extends FlameGame
    with HasCollidables, HasTappables, HasKeyboardHandlerComponents {
  static const String description = '''
    Move around with W, A, S, D and notice how the camera follows the ember 
    sprite.\n
    If you collide with the gray squares, the camera reference is changed from
    center to topCenter.\n
    The gray squares can also be clicked to show how the coordinate system
    respects the camera transformation.
  ''';

  late MovableEmber ember;
  final Vector2 viewportResolution;

  FollowComponentExample({
    required this.viewportResolution,
  });

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(viewportResolution);
    add(Map());

    add(ember = MovableEmber());
    camera.speed = 1;
    camera.followComponent(ember, worldBounds: Map.bounds);

    for (var i = 0; i < 30; i++) {
      add(Rock(Vector2(Map.genCoord(), Map.genCoord())));
    }
  }
}

class MovableEmber extends Ember<FollowComponentExample>
    with HasHitboxes, Collidable, KeyboardHandler {
  static const double speed = 300;
  static final TextPaint textRenderer = TextPaint(
    style: const TextStyle(color: Colors.white70, fontSize: 12),
  );

  final Vector2 velocity = Vector2.zero();
  late final TextComponent positionText;
  late final Vector2 textPosition;

  MovableEmber() : super(priority: 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    positionText = TextComponent(
      textRenderer: textRenderer,
      position: (size / 2)..y = size.y / 2 + 30,
      anchor: Anchor.center,
    );
    add(positionText);
    addHitbox(HitboxCircle());
  }

  @override
  void update(double dt) {
    super.update(dt);
    final deltaPosition = velocity * (speed * dt);
    position.add(deltaPosition);
    positionText.text = '(${x.toInt()}, ${y.toInt()})';
  }

  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    if (other is Rock) {
      gameRef.camera.setRelativeOffset(Anchor.topCenter);
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    super.onCollisionEnd(other);
    if (other is Rock) {
      gameRef.camera.setRelativeOffset(Anchor.center);
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;

    final bool handled;
    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      velocity.x = isKeyDown ? -1 : 0;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      velocity.x = isKeyDown ? 1 : 0;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      velocity.y = isKeyDown ? -1 : 0;
      handled = true;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      velocity.y = isKeyDown ? 1 : 0;
      handled = true;
    } else {
      handled = false;
    }

    if (handled) {
      angle = -velocity.angleToSigned(Vector2(1, 0));
      return false;
    } else {
      return super.onKeyEvent(event, keysPressed);
    }
  }
}

class Map extends Component {
  static const double size = 1500;
  static const Rect bounds = Rect.fromLTWH(-size, -size, 2 * size, 2 * size);

  static final Paint _paintBorder = Paint()
    ..color = Colors.white12
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;
  static final Paint _paintBg = Paint()..color = const Color(0xFF333333);

  static final _rng = Random();

  late final List<Paint> _paintPool;
  late final List<Rect> _rectPool;

  Map() : super(priority: 0) {
    _paintPool = List<Paint>.generate(
      (size / 50).ceil(),
      (_) => PaintExtension.random(rng: _rng)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      growable: false,
    );
    _rectPool = List<Rect>.generate(
      (size / 50).ceil(),
      (i) => Rect.fromCircle(center: Offset.zero, radius: size - i * 50),
      growable: false,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(bounds, _paintBg);
    canvas.drawRect(bounds, _paintBorder);
    for (var i = 0; i < (size / 50).ceil(); i++) {
      canvas.drawCircle(Offset.zero, size - i * 50, _paintPool[i]);
      canvas.drawRect(_rectPool[i], _paintBorder);
    }
  }

  static double genCoord() {
    return -size + _rng.nextDouble() * (2 * size);
  }
}

class Rock extends SpriteComponent
    with HasGameRef, HasHitboxes, Collidable, Tappable {
  Rock(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(50),
          priority: 1,
        );

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('nine-box.png');
    paint = Paint()..color = Colors.white;
    addHitbox(HitboxRectangle());
  }

  @override
  bool onTapDown(_) {
    add(
      ScaleEffect.by(
        Vector2.all(10),
        EffectController(duration: 0.3),
      ),
    );
    return true;
  }
}
