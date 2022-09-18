part of '../renderable_tile_map.dart';

abstract class _RenderableLayer<T extends Layer> {
  final T layer;

  /// The parent [Group] layer (if it exists)
  final _GroupLayer? parent;

  _RenderableLayer(this.layer, this.parent);

  bool get visible => layer.visible;

  void render(Canvas canvas, Camera? camera);

  void handleResize(Vector2 canvasSize) {}

  void refreshCache() {}

  double get offsetX {
    return layer.offsetX + (parent?.offsetX ?? 0);
  }

  double get offsetY {
    return layer.offsetY + (parent?.offsetY ?? 0);
  }

  double get opacity {
    if (parent != null) {
      return parent!.opacity * layer.opacity;
    } else {
      return layer.opacity;
    }
  }

  double get parallaxX {
    if (parent != null) {
      return parent!.parallaxX * layer.parallaxX;
    } else {
      return layer.parallaxX;
    }
  }

  double get parallaxY {
    if (parent != null) {
      return parent!.parallaxY * layer.parallaxY;
    } else {
      return layer.parallaxY;
    }
  }

  /// Calculates the offset we need to apply to the canvas to compensate for
  /// parallax positioning and scroll for the layer and the current camera
  /// position
  /// https://doc.mapeditor.org/en/latest/manual/layers/#parallax-scrolling-factor
  void _applyParallaxOffset(Canvas canvas, Camera camera) {
    final cameraX = camera.position.x;
    final cameraY = camera.position.y;
    final vpCenterX = camera.viewport.effectiveSize.x / 2;
    final vpCenterY = camera.viewport.effectiveSize.y / 2;

    // Due to how Tiled treats the center of the view as the reference
    // point for parallax positioning (see Tiled docs), we need to offset the
    // entire layer
    var x = (1 - parallaxX) * vpCenterX;
    var y = (1 - parallaxY) * vpCenterY;
    // compensate the offset for zoom
    x /= camera.zoom;
    y /= camera.zoom;

    // Now add the scroll for the current camera position
    x += cameraX - (cameraX * parallaxX);
    y += cameraY - (cameraY * parallaxY);

    canvas.translate(x, y);
  }
}
