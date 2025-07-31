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
  final Vector2 _canvasSize = Vector2.zero();
  final Vector2 _maxTranslation = Vector2.zero();

  FlameImageLayer({
    required super.layer,
    required super.parent,
    required super.camera,
    required super.map,
    required super.destTileSize,
    required Image image,
    super.filterQuality,
  }) : _image = image {
    _initImageRepeat();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    _canvasSize.setFrom(canvasSize);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
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
    final visibleWorldRect = camera?.visibleWorldRect ?? Rect.zero;
    final destSize = camera?.viewport.virtualSize ?? _canvasSize;
    final imageW = _image.size.x;
    final imageH = _image.size.y;

    // Track the maximum amount the canvas could have been translated
    // for this layer so we can calculate the wrap point within the
    // paint area.
    _maxTranslation.x = offsetX - (visibleWorldRect.left * parallaxX);
    _maxTranslation.y = offsetY - (visibleWorldRect.top * parallaxY);

    /*
        _maxTranslation.x = offsetX - camera.viewfinder.position.x * parallaxX;
     _maxTranslation.y = offsetY - camera.viewfinder.position.y * parallaxY;
*/

    // When the image is being repeated, make sure the _paintArea rect is
    // big enough that it repeats off the edge of the canvas in both positive
    // and negative directions on that axis (Tiled repeats forever on an axis).
    // Also, make sure the rect's left and top are only moved by exactly the
    // image's length along that axis (width or height) so that with repeats
    // it still matches up with its initial layer offsets.
    if (_repeat == ImageRepeat.repeatX || _repeat == ImageRepeat.repeat) {
      final (left, right) = _calculatePaintRange(
            translation: _maxTranslation.x,
            destSize: destSize.x,
            imageSideLen: imageW,
            layerOffset: cachedLayerOffset.x,
          ) + // Apply camera left/right to range.
          (visibleWorldRect.left, visibleWorldRect.right);

      _paintArea
        ..left = left
        ..right = right;
    } else {
      // Simply draw the full width of the image.
      _paintArea.left = 0;
      _paintArea.right = imageW;
    }
    if (_repeat == ImageRepeat.repeatY || _repeat == ImageRepeat.repeat) {
      final (top, bottom) = _calculatePaintRange(
            translation: _maxTranslation.y,
            destSize: destSize.y,
            imageSideLen: imageH,
            layerOffset: cachedLayerOffset.y,
          ) + // Apply camera top/bottom to range.
          (visibleWorldRect.top, visibleWorldRect.bottom);

      _paintArea
        ..top = top
        ..bottom = bottom;
    } else {
      // Simply draw the full height of the image.
      _paintArea.top = 0;
      _paintArea.bottom = imageH;
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

  // As an optimization, the [_paintArea] rect can be positioned in a
  // particular way that reduces the time spent on computation and clip steps
  // in flutter when drawing infinitely across an axis. This method accounts
  // for the destination canvas size, camera viewport size, and the exact
  // coverage of the image w.r.t. [translation].
  // This is achieved by wrapping the rect coordinates around [destSize]
  // after calculating the image coverage with [imageSideLen] and adding the
  // unseen portion of the image in the span of the wrap range, if any.
  //
  // The return tuple value is the range where its centroid is the wrap point
  // plus the [layerOffset] which shifts the range to account for earlier
  // transformations applied to the canvas.
  (double min, double max) _calculatePaintRange({
    required double translation,
    required double destSize,
    required double imageSideLen,
    required double layerOffset,
  }) {
    // Prevent DBZ error.
    if (imageSideLen < 1) {
      return (0, 0);
    }
    // What portion of the image is seen.
    final seen = destSize / imageSideLen;

    // Integer count of whole images to draw.
    final imageCount = seen.ceil();

    // Calculate unseen part of image(s).
    final unseen = (imageCount - seen) * imageSideLen;

    // Wrap around the target axis w.r.t. parallax.
    final wrapPoint = translation.ceil() % (destSize + unseen).toInt();

    // Partition the _paintArea into two parts.
    final part = (wrapPoint / imageSideLen).ceil();

    return (
      wrapPoint - (imageSideLen * part) - layerOffset,
      wrapPoint + (imageSideLen * (imageCount - part)) - layerOffset,
    );
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
      camera: camera,
      map: map,
      destTileSize: destTileSize,
      filterQuality: filterQuality,
      image: await (images ?? Flame.images).load(layer.image.source!),
    );
  }

  @override
  void refreshCache() {}
}

extension _PrivRangeTupleHelper on (double, double) {
  (double, double) operator +((double, double) other) =>
      ($1 + other.$1, $2 + other.$2);
}
