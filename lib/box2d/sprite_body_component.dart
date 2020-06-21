import 'dart:ui';

import 'dart:math' as math;
import 'package:box2d_flame/box2d.dart';
import 'package:flame/anchor.dart';
import 'package:flame/position.dart' as flame;

import '../components/component.dart';
import '../sprite.dart';
import 'body_component.dart';
import 'box2d_game.dart';

abstract class SpriteBodyComponent extends BodyComponent {
  SpriteComponent spriteComponent;
  final double initialWidth;
  final double initialHeight;

  /// Make sure that your width and height matches the one of the body created
  /// by createBody()
  SpriteBodyComponent(
      this.initialWidth,
      this.initialHeight,
      Box2DGame game,
      ) : super(game) {
    final sprite = createSprite();
    spriteComponent = SpriteComponent.fromSprite(initialWidth, initialHeight, sprite)
      ..anchor = Anchor.center;

    game.addLater(spriteComponent);
  }

  double get width => initialWidth * viewport.scale;
  double get height => initialHeight * viewport.scale;

  Vector2 get visualCenter {
    Fixture fixture = body.getFixtureList();
    assert(fixture != null, "Fixture list can't be empty");
    Vector2 center;
    void updateCenter(Vector2 shapeCenter) {
      center ??= shapeCenter;
      center = (center + shapeCenter)/2;
    }
    do {
      final shape = fixture.getShape();
      if (shape is PolygonShape) {
        updateCenter(shape.centroid);
      } else if (shape is CircleShape) {
        updateCenter(shape.p);
      }
      fixture = fixture.getNext();
    } while(fixture != null);
    return center;
  }

  Sprite createSprite();

  @override
  bool loaded() => body.isActive() && spriteComponent.loaded();

  @override
  void update(double t) {
    super.update(t);
    //final screenPosition = viewport.getWorldToScreen(visualCenter);
    //final screenPosition = visualCenter;
    //final screenPosition = viewport.getWorldToScreen(body.position);
    //spriteComponent
    //  ..angle = -body.getAngle()
    //  ..x = screenPosition.x
    //  ..y = screenPosition.y
    //  ..width = width
    //  ..height = height;
  }


  @override
  void render(Canvas c) {
    super.render(c);
    final sprite = spriteComponent.sprite;

    if (sprite.loaded()) {
      final scale = initialHeight * viewport.scale / sprite.image.height;
      final screenPosition = viewport.getWorldToScreen(body.position);
      c.save();
      c.translate(screenPosition.x, screenPosition.y);
      c.rotate(-body.getAngle());
      sprite.renderScaled(c, flame.Position(-width/2, -height/2), scale: scale);
      c.translate(-screenPosition.x, -screenPosition.y);
      c.restore();
    }
  }
}
