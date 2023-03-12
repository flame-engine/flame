import 'package:flame_forge2d/flame_forge2d.dart';

class Box extends BodyComponent {
  final Vector2 _position;
  final double _width;
  final double _height;

  Box(this._position, this._width, this._height);

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(_width / 2, _height / 2, Vector2.zero(), 0);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: _position,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
