import 'dart:math';

import 'package:examples/commons/ember.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FollowComponentExample extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  static const String description = '''
    Move around with W, A, S, D and notice how the camera follows the ember 
    sprite.\n
    If you collide with the gray squares, the camera reference is changed from
    center to topCenter.\n
    The gray squares can also be clicked to show how the coordinate system
    respects the camera transformation.
  ''';

  FollowComponentExample({required this.viewportResolution})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: viewportResolution.x,
            height: viewportResolution.y,
          ),
        );

  late MovableEmber ember;
  final Vector2 viewportResolution;

  @override
  Future<void> onLoad() async {
    world.add(Map());
    world.add(ember = MovableEmber());
    camera.setBounds(Map.bounds);
    camera.follow(ember, maxSpeed: 250);

    world.addAll(
      List.generate(30, (_) => Rock(Map.generateCoordinates())),
    );
  }
}

class MovableEmber extends Ember<FollowComponentExample>
    with CollisionCallbacks, KeyboardHandler {
  static const double speed = 300;
  static final TextPaint textRenderer = TextPaint(
    style: const TextStyle(color: Colors.white70, fontSize: 12),
  );

  final Vector2 velocity = Vector2.zero();
  late final TextComponent positionText;
  late final Vector2 textPosition;
  late final maxPosition = Vector2.all(Map.size - size.x / 2);
  late final minPosition = -maxPosition;

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
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    final deltaPosition = velocity * (speed * dt);
    position.add(deltaPosition);
    position.clamp(minPosition, maxPosition);
    positionText.text = '(${x.toInt()}, ${y.toInt()})';
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Rock) {
      other.add(
        ScaleEffect.to(
          Vector2.all(1.5),
          EffectController(duration: 0.2, alternate: true),
        ),
      );
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;

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
  static const Rect _bounds = Rect.fromLTRB(-size, -size, size, size);
  static final Rectangle bounds = Rectangle.fromLTRB(-size, -size, size, size);

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
    canvas.drawRect(_bounds, _paintBg);
    canvas.drawRect(_bounds, _paintBorder);
    for (var i = 0; i < (size / 50).ceil(); i++) {
      canvas.drawCircle(Offset.zero, size - i * 50, _paintPool[i]);
      canvas.drawRect(_rectPool[i], _paintBorder);
    }
  }

  static Vector2 generateCoordinates() {
    return Vector2.random()
      ..scale(2 * size)
      ..sub(Vector2.all(size));
  }
}

class Rock extends SpriteComponent with HasGameRef, TapCallbacks {
  Rock(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(50),
          priority: 1,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('nine-box.png');
    paint = Paint()..color = Colors.white;
    add(RectangleHitbox());
  }

  @override
  void onTapDown(_) {
    add(
      ScaleEffect.to(
        Vector2.all(scale.x >= 2.0 ? 1 : 2),
        EffectController(duration: 0.3),
      ),
    );
  }
}
