part of '../renderable_tile_map.dart';

class _RenderableImageLayer extends _RenderableLayer<ImageLayer> {
  final Image _image;
  late final ImageRepeat _repeat;
  Rect _paintArea = Rect.zero;

  _RenderableImageLayer(super.layer, super.parent, this._image) {
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
      _applyParallaxOffset(canvas, camera);
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

  static Future<_RenderableLayer> load(
    ImageLayer layer,
    _RenderableGroupLayer? parent,
    Camera? camera,
  ) async {
    return _RenderableImageLayer(
      layer,
      parent,
      await Flame.images.load(layer.image.source!),
    );
  }
}
