import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame_tiled/src/mutable_rect.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

@internal
class FlameImageLayer({
  required super.layer,
  required super.map,
  required super.destTileSize,
  required final Image _image,
  super.filterQuality,
}) extends RenderableLayer<ImageLayer> {
  late final ImageRepeat _repeat;
  final MutableRect _paintArea = MutableRect.fromLTRB(0, 0, 0, 0);

  this {
    _initImageRepeat();
  }

  @override
  void render(Canvas canvas) {
    _resizePaintArea();

    paintImage(
      canvas: canvas,
      rect: _paintArea,
      image: _image,
      opacity: opacity,
      alignment: Alignment.topLeft,
      fit: BoxFit.none,
      repeat: _repeat,
      filterQuality: filterQuality,
    );
  }

  /// The image is drawn at its natural size, starting at the origin of the
  /// layer. On an axis that repeats, the paint area is extended to cover the
  /// whole [visibleRect] with a whole number of images, so that the repetition
  /// stays aligned with the origin of the layer no matter how far the camera
  /// has scrolled (Tiled repeats forever on such an axis).
  void _resizePaintArea() {
    final imageWidth = _image.width.toDouble();
    final imageHeight = _image.height.toDouble();
    final visibleRect = this.visibleRect;

    if (_repeat == ImageRepeat.repeatX || _repeat == ImageRepeat.repeat) {
      _paintArea.left = (visibleRect.left / imageWidth).floor() * imageWidth;
      _paintArea.right = (visibleRect.right / imageWidth).ceil() * imageWidth;
    } else {
      _paintArea.left = 0;
      _paintArea.right = imageWidth;
    }
    if (_repeat == ImageRepeat.repeatY || _repeat == ImageRepeat.repeat) {
      _paintArea.top = (visibleRect.top / imageHeight).floor() * imageHeight;
      _paintArea.bottom =
          (visibleRect.bottom / imageHeight).ceil() * imageHeight;
    } else {
      _paintArea.top = 0;
      _paintArea.bottom = imageHeight;
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
    required TiledMap map,
    required Vector2 destTileSize,
    FilterQuality? filterQuality,
    Images? images,
    String? package,
    String imagesDirectory = 'assets/images/',
  }) async {
    return FlameImageLayer(
      layer: layer,
      map: map,
      destTileSize: destTileSize,
      filterQuality: filterQuality,
      image: await (images ?? Flame.images).load(
        '$imagesDirectory${layer.image.source!}',
        package: package,
      ),
    );
  }

  @override
  void refreshCache() {}
}
