import 'dart:ui';

import '../sprite.dart';
import '../spritesheet.dart';
import 'component.dart';

class SpriteStackComponent extends PositionComponent {
  SpriteSheet spriteSheet;

  static final _sprites = <String, Map<double, Sprite>>{};

  @override
  set angle(double value) {
    if (_sprites[spriteSheet.imageName][value] == null) {
      _generated = false;
    }
    super.angle = value;
  }

  SpriteStackComponent(
      {String imageName,
      int textureWidth,
      int textureHeight,
      int columns,
      int rows}) {
    if (_sprites[imageName] == null) {
      _sprites[imageName] = Map();
    }
    x = 100;
    y = 100;
    width = textureWidth.toDouble();
    height = textureHeight.toDouble();
    spriteSheet = SpriteSheet(
        imageName: imageName,
        textureWidth: textureWidth,
        textureHeight: textureHeight,
        columns: columns,
        rows: rows);
  }

  @override
  void render(Canvas canvas) {
    if (!loaded()) {
      return;
    }
    prepareCanvas(canvas);
    _sprites[spriteSheet.imageName][angle]
        .render(canvas, width: width, height: height);
  }

  bool _generated = false;
  bool _generating = false;

  @override
  bool loaded() {
    // If the instance is already generating or is generated we dont have to check all the sprites.
    if (_generated || _generating) {
      return _generated;
    }

    for (var row = 0; row < spriteSheet.rows; row++) {
      for (var column = 0; column < spriteSheet.columns; column++) {
        var sprite = spriteSheet.getSprite(row, column);
        if (!sprite.loaded()) {
          return false;
        }
      }
    }

    generate();
    return _generated;
  }

  void generate() async {
    if (_generated || _generating) {
      return;
    }

    _generating = true;
    final pictureRecorder = PictureRecorder();
    final canvas =
        Canvas(pictureRecorder, Rect.fromLTWH(0.0, 0.0, width, height));

    double index = 0;
    canvas.rotate(-angle);
    for (var row = 0; row < spriteSheet.rows; row++) {
      for (var column = 0; column < spriteSheet.columns; column++) {
        var spriteComponent = SpriteComponent.fromSprite(
            spriteSheet.textureWidth.toDouble(),
            spriteSheet.textureHeight.toDouble(),
            spriteSheet.getSprite(row, column));
        canvas.save();
        spriteComponent.debugMode = false;
        spriteComponent.angle = angle;
        spriteComponent.y -= index++ - 5;
        spriteComponent.render(canvas);
        canvas.restore();
      }
    }

    final pic = pictureRecorder.endRecording();
    final image = await pic.toImage(width.toInt(), height.toInt());
    final sprite = Sprite.fromImage(
      image,
      x: 0,
      y: 0,
      width: width,
      height: height,
    );
    _sprites[spriteSheet.imageName][angle] = sprite;
    _generating = false;
    _generated = true;
  }

  @override
  void update(double t) {}
}
