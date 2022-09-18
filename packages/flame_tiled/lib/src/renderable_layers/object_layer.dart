part of '../renderable_tile_map.dart';

class _ObjectLayer extends _RenderableLayer {
  _ObjectLayer(super.layer, super.parent);

  @override
  void render(Canvas canvas, Camera? camera) {
    // nothing to do
  }

  // ignore unrenderable layers when looping over the layers to render
  @override
  bool get visible => false;

  static Future<_RenderableLayer> load(Layer layer) async {
    return _ObjectLayer(layer, null);
  }
}
