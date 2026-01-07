import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/renderable_layers/group_layer.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

@internal
class FlameImageLayer extends RenderableLayer<ImageLayer> {
  final Image _image;
  late final ImageRepeat _repeat;
  final MutableRect _paintArea = MutableRect.fromLTRB(0, 0, 0, 0);
  final Vector2 _maxTranslation = Vector2.zero();
  late final Vector2 _mapSize;

  FlameImageLayer({
    required super.layer,
    required super.parent,
    required super.map,
    required super.destTileSize,
    required Image image,
    super.filterQuality,
  }) : _image = image {
    _mapSize = Vector2(
      map.width * destTileSize.x,
      map.height * destTileSize.y,
    );
    _initImageRepeat();
  }

  @override
  void handleResize(Vector2 canvasSize) {}

  @override
  void render(Canvas canvas, CameraComponent? camera) {
    canvas.save();

    canvas.translate(offsetX, offsetY);

    if (camera != null) {
      applyParallaxOffset(canvas, camera);
    }

    _resizePaintArea(camera);

    paintImage(
      canvas: canvas,
      rect: _paintArea,
      image: _image,
      opacity: opacity,
      alignment: Alignment.topLeft,
      repeat: _repeat,
      filterQuality: filterQuality,
    );

    canvas.restore();
  }

  void _resizePaintArea(CameraComponent? camera) {
    // Track the maximum amount the canvas could have been translated
    // for this layer so we can calculate how many extra images to draw
    if (camera != null) {
      _maxTranslation.x =
          offsetX.abs() + camera.viewfinder.position.x.abs() * parallaxX;
      _maxTranslation.y =
          offsetY.abs() + camera.viewfinder.position.y.abs() * parallaxY;
    } else {
      _maxTranslation.x = offsetX.abs();
      _maxTranslation.y = offsetY.abs();
    }

    // When the image is being repeated, make sure the _paintArea rect is
    // big enough that it repeats off the edge of the canvas in both positive
    // and negative directions on that axis (Tiled repeats forever on an axis).
    // Also, make sure the rect's left and top are only moved by exactly the
    // image's length along that axis (width or height) so that with repeats
    // it still matches up with its initial layer offsets.

    if (_repeat == ImageRepeat.repeatX || _repeat == ImageRepeat.repeat) {
      // Calculate images needed for max translation and map size
      final xImages = ((_maxTranslation.x + _mapSize.x) / _image.size.x).ceil();
      _paintArea.left = -_image.size.x * xImages;
      _paintArea.right = _image.size.x * xImages;
    } else {
      _paintArea.left = 0;
      _paintArea.right = _mapSize.x;
    }
    if (_repeat == ImageRepeat.repeatY || _repeat == ImageRepeat.repeat) {
      // Calculate images needed for max translation and map size
      final yImages = ((_maxTranslation.y + _mapSize.y) / _image.size.y).ceil();
      _paintArea.top = -_image.size.y * yImages;
      _paintArea.bottom = _image.size.y * yImages;
    } else {
      _paintArea.top = 0;
      _paintArea.bottom = _mapSize.y;
    }
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
    required CameraComponent? camera,
    required TiledMap map,
    required Vector2 destTileSize,
    FilterQuality? filterQuality,
    Images? images,
  }) async {
    return FlameImageLayer(
      layer: layer,
      parent: parent,
      map: map,
      destTileSize: destTileSize,
      filterQuality: filterQuality,
      image: await (images ?? Flame.images).load(layer.image.source!),
    );
  }

  @override
  void refreshCache() {}

  @override
  void update(double dt) {}
}
