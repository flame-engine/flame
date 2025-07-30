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
import 'dart:math';

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
    // Track the maximum amount the canvas could have been translated
    // for this layer so we can calculate how many extra images to draw
    if (camera != null) {
      _maxTranslation.x = offsetX - camera.viewfinder.position.x * parallaxX;
      _maxTranslation.y = offsetY - camera.viewfinder.position.y * parallaxY;
    } else {
      _maxTranslation.x = offsetX;
      _maxTranslation.y = offsetY;
    }

    final virtualSize = camera?.viewport.virtualSize;
    final destSize = virtualSize ?? _canvasSize;
    final imageW = _image.size.x;
    final imageH = _image.size.y;

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
      );
      _paintArea
        ..left = left
        ..right = right;

      // The canvas will already be shifted by the parent component's
      // render step. Account for this offset to match expectations while
      // also respect camera bounds, if any. This prevents scaling the
      // painted image down when the window resizes to small values.
      final worldRect = camera?.viewfinder.visibleWorldRect ?? Rect.zero;
      _paintArea.left += worldRect.left - super.cachedLayerOffset.x;
      _paintArea.right += worldRect.right - super.cachedLayerOffset.x;
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
      );
      _paintArea
        ..top = top
        ..bottom = bottom;
      // The canvas will already be shifted by the parent component's
      // render step. Account for this offset to match expectations while
      // also respect camera bounds, if any. This prevents scaling the
      // painted image down when the window resizes to small values.
      final worldRect = camera?.viewfinder.visibleWorldRect ?? Rect.zero;
      _paintArea.top += worldRect.top - super.cachedLayerOffset.y;
      _paintArea.bottom += worldRect.bottom - super.cachedLayerOffset.y;
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
  (double min, double max) _calculatePaintRange({
    required double translation,
    required double destSize,
    required double imageSideLen,
  }) {
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

    // Return the range where the centroid is the wrap point.
    return (
      wrapPoint - (part * imageSideLen),
      wrapPoint + (imageSideLen * (imageCount - part)),
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
