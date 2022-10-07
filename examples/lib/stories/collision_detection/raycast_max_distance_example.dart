import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class RaycastMaxDistanceExample extends FlameGame with HasCollisionDetection {
  static const description = '''
This examples showcases how raycast APIs can be used to detect hits within certain range.
''';

  static const _maxDistance = 50.0;

  late Ray2 _ray;
  late _Character _character;
  final _result = RaycastResult<ShapeHitbox>();

  final _text = TextComponent(
    text: "Hey! Who's there?",
    anchor: Anchor.center,
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 8,
        color: Colors.amber,
      ),
    ),
  )..positionType = PositionType.viewport;

  @override
  Future<void>? onLoad() {
    camera.viewport = FixedResolutionViewport(Vector2(320, 180));

    _addMovingWall();

    add(
      _character = _Character(
        maxDistance: _maxDistance,
        position: size / 2 - Vector2(50, 0),
        anchor: Anchor.center,
      ),
    );

    _text.position = _character.position - Vector2(0, 50);

    _ray = Ray2(
      origin: _character.absolutePosition,
      direction: Vector2(1, 0),
    );

    return super.onLoad();
  }

  void _addMovingWall() {
    add(
      RectangleComponent(
        position: size / 2,
        size: Vector2(20, 40),
        anchor: Anchor.center,
        paint: BasicPalette.red.paint(),
        children: [
          RectangleHitbox(),
          MoveByEffect(
            Vector2(50, 0),
            EffectController(
              duration: 2,
              alternate: true,
              infinite: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    collisionDetection.raycast(_ray, maxDistance: _maxDistance, out: _result);
    if (_result.isActive) {
      if (!camera.shaking) {
        camera.shake(duration: 0.2, intensity: 1);
      }
      if (!_text.isMounted) {
        add(_text);
      }
    } else {
      _text.removeFromParent();
    }
    super.update(dt);
  }
}

class _Character extends PositionComponent {
  _Character({required this.maxDistance, super.position, super.anchor});

  final double maxDistance;

  final _rayOriginPoint = Offset.zero;
  late final _rayEndPoint = Offset(maxDistance, 0);
  final _rayPaint = BasicPalette.gray.paint();

  @override
  Future<void>? onLoad() async {
    add(
      CircleComponent(
        radius: 20,
        anchor: Anchor.center,
        paint: BasicPalette.green.paint(),
      )..scale = Vector2(0.55, 1),
    );
    add(
      CircleComponent(
        radius: 10,
        anchor: Anchor.center,
        paint: _rayPaint,
      ),
    );
    add(
      RectangleComponent(
        size: Vector2(10, 3),
        position: Vector2(12, 5),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawLine(_rayOriginPoint, _rayEndPoint, _rayPaint);
  }
}
