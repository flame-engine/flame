part of '../renderable_tile_map.dart';

class _RenderableGroupLayer extends _RenderableLayer<Group> {
  /// The child layers of this [Group] to be rendered recursively.
  ///
  /// NOTE: This is set externally instead of via constructor params because
  ///       there are cyclic dependencies when loading the renderable layers.
  late final List<_RenderableLayer> children;

  _RenderableGroupLayer(
    super.layer,
    super.parent,
  );

  @override
  void refreshCache() {
    for (final child in children) {
      child.refreshCache();
    }
  }

  @override
  void handleResize(Vector2 canvasSize) {
    for (final child in children) {
      child.handleResize(canvasSize);
    }
  }

  @override
  void render(ui.Canvas canvas, Camera? camera) {
    for (final child in children) {
      child.render(canvas, camera);
    }
  }
}
