import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;

import 'package:padracing/padracing_game.dart';

List<Wall> createWalls(Vector2 size) {
  final topCenter = Vector2(size.x / 2, 0);
  final bottomCenter = Vector2(size.x / 2, size.y);
  final leftCenter = Vector2(0, size.y / 2);
  final rightCenter = Vector2(size.x, size.y / 2);

  final filledSize = size.clone() + Vector2.all(5);
  return [
    Wall(topCenter, Vector2(filledSize.x, 5)),
    Wall(leftCenter, Vector2(5, filledSize.y)),
    Wall(Vector2(52.5, 240), Vector2(5, 380)),
    Wall(Vector2(200, 50), Vector2(300, 5)),
    Wall(Vector2(72.5, 300), Vector2(5, 400)),
    Wall(Vector2(180, 100), Vector2(220, 5)),
    Wall(Vector2(350, 105), Vector2(5, 115)),
    Wall(Vector2(310, 160), Vector2(240, 5)),
    Wall(Vector2(211.5, 400), Vector2(283, 5)),
    Wall(Vector2(351, 312.5), Vector2(5, 180)),
    Wall(Vector2(430, 302.5), Vector2(5, 290)),
    Wall(Vector2(292.5, 450), Vector2(280, 5)),
    Wall(bottomCenter, Vector2(filledSize.y, 5)),
    Wall(rightCenter, Vector2(5, filledSize.y)),
  ];
}

class Wall extends BodyComponent<PadRacingGame> {
  Wall(this._position, this.size) : super(priority: 3);

  final Vector2 _position;
  final Vector2 size;

  final Random rng = Random();
  late final Image _image;

  final scale = 10.0;
  late final _renderPosition = -size.toOffset() / 2;
  late final _scaledRect = (size * scale).toRect();
  late final _renderRect = _renderPosition & size.toSize();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    paint.color = ColorExtension.fromRGBHexString('#14F596');

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);
    final drawSize = _scaledRect.size.toVector2();
    final center = (drawSize / 2).toOffset();
    const step = 1.0;

    canvas.drawRect(
      Rect.fromCenter(center: center, width: drawSize.x, height: drawSize.y),
      BasicPalette.black.paint(),
    );
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = step;
    for (var x = 0; x < 30; x++) {
      canvas.drawRect(
        Rect.fromCenter(center: center, width: drawSize.x, height: drawSize.y),
        paint,
      );
      paint.color = paint.color.darken(0.07);
      drawSize.x -= step;
      drawSize.y -= step;
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage(
      _scaledRect.width.toInt(),
      _scaledRect.height.toInt(),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(
      _image,
      _scaledRect,
      _renderRect,
      paint,
    );
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.static
      ..position = _position;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape)..restitution = 0.5;
    return body..createFixture(fixtureDef);
  }

  late Rect asRect = Rect.fromCenter(
    center: _position.toOffset(),
    width: size.x,
    height: size.y,
  );
}
