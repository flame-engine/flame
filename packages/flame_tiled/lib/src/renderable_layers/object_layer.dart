part of '../renderable_tile_map.dart';

class _UnrenderableLayer extends _RenderableLayer {
  _UnrenderableLayer(super.layer, super.parent);

  @override
  void render(Canvas canvas, Camera? camera) {
    // nothing to do
  }

  // ignore unrenderable layers when looping over the layers to render
  @override
  bool get visible => false;

  static Future<_RenderableLayer> load(Layer layer) async {
    return _UnrenderableLayer(layer, null);
  }
}
