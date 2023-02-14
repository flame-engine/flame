import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

@internal
class FlameImageLayer extends RenderableLayer<ImageLayer> {
  final Image _image;
  late final ImageRepeat _repeat;
  Rect _paintArea = Rect.zero;

  FlameImageLayer({
    required super.layer,
    required super.parent,
    required super.map,
    required super.destTileSize,
    required Image image,
  }) : _image = image {
    _initImageRepeat();
  }

  @override
  void handleResize(Vector2 canvasSize) {
    _paintArea = Rect.fromLTWH(0, 0, canvasSize.x, canvasSize.y);
  }

  @override
  void render(Canvas canvas, Camera? camera) {
    canvas.save();

    canvas.translate(offsetX, offsetY);

    if (camera != null) {
      applyParallaxOffset(canvas, camera);
    }

    paintImage(
      canvas: canvas,
      rect: _paintArea,
      image: _image,
      opacity: opacity,
      alignment: Alignment.topLeft,
      repeat: _repeat,
    );

    canvas.restore();
  }

  void _initImageRepeat() {
    if (layer.repeatX && layer.repeatY) {
      _repeat = ImageRepeat.repeat;
    } else if (layer.repeatX) {
      _repeat = ImageRepeat.repeatX;
    } else if (layer.repeatY) {
      _repeat = ImageRepeat.repeatY;
    } else {
      _repeat = ImageRepeat.noRepeat;
    }
  }

  static Future<FlameImageLayer> load({
    required ImageLayer layer,
    required GroupLayer? parent,
    required Camera? camera,
    required TiledMap map,
    required Vector2 destTileSize,
  }) async {
    return FlameImageLayer(
      layer: layer,
      parent: parent,
      map: map,
      destTileSize: destTileSize,
      image: await Flame.images.load(layer.image.source!),
    );
  }

  @override
  void refreshCache() {}

  @override
  void update(double dt) {}
}
