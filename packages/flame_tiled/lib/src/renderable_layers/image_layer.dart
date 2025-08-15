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

  FlameImageLayer({
    required super.layer,
    required super.parent,
    required super.camera,
    required super.map,
    required super.destTileSize,
    required Image image,
    required super.layerPaintFactory,
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
  }

  void _resizePaintArea(CameraComponent? camera) {
    final visibleWorldRect = camera?.visibleWorldRect ?? Rect.zero;
    final destSize = camera?.viewport.virtualSize ?? _canvasSize;
    final imageW = _image.size.x;
    final imageH = _image.size.y;

    // In order to recover the displacement w.r.t. the canvas translation,
    // subtract the center view vector to this accumulated offset vector.
    // B/c we will wrap the image along the axis infinitely, add the negative
    // of the accumulated offset in order to cancel out the layer translation
    // and bake the offset value into the total parallax term instead.
    final center = visibleWorldRect.center.toVector2();
    final displacement = absoluteParallax - center - absoluteOffset;
    final parallax = absoluteOffset + absoluteParallax;

    /// [_calculatePaintRange] ensures the _paintArea rect is
    /// big enough that it repeats off the edge of the canvas in both positive
    /// and negative directions on that axis (Tiled repeats forever on an axis).
    if (_repeat == ImageRepeat.repeatX || _repeat == ImageRepeat.repeat) {
      final (left, right) =
          _calculatePaintRange(
            destSize: destSize.x,
            imageSideLen: imageW.toInt(),
            parallax: parallax.x.round(),
            displacement: displacement.x.round(),
          ) +
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
      final (top, bottom) =
          _calculatePaintRange(
            destSize: destSize.y,
            imageSideLen: imageH.toInt(),
            parallax: (absoluteOffset + absoluteParallax).y.round(),
            displacement: displacement.y.round(),
          ) +
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
  // coverage of the image w.r.t. translation.
  // This is achieved by wrapping the rect coordinates around [destSize]
  // after calculating the image coverage with [imageSideLen] and adding the
  // unseen portion of the image in the span of the wrap range, if any.
  //
  // The return tuple value is the range where its centroid is the wrap point
  // plus the [displacement] which is the accumulation of all translations
  // applied to this layer earlier in the render pipeline.
  (double min, double max) _calculatePaintRange({
    required double destSize,
    required int imageSideLen,
    required int parallax,
    required int displacement,
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

    // Wrap around the target axis w.r.t. negative parallax.
    final coverage = (destSize + unseen).ceil();
    final wrapPoint = coverage - (parallax % coverage) - 1;

    // Partition the _paintArea into two parts.
    final part = (wrapPoint / imageSideLen).ceil();

    // Add displacement to the wrap range to account for the
    // canvas translations pushing the layer further away from
    // where this wrap is expected to be seen in the viewport.
    final min = wrapPoint - (imageSideLen * part) + displacement;
    final max = wrapPoint + (imageSideLen * (imageCount - part)) + displacement;

    return (min.toDouble(), max.toDouble());
  }

  static Future<FlameImageLayer> load({
    required ImageLayer layer,
    required GroupLayer? parent,
    required CameraComponent? camera,
    required TiledMap map,
    required Vector2 destTileSize,
    required Paint Function(double opacity) layerPaintFactory,
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
      layerPaintFactory: layerPaintFactory,
      image: await (images ?? Flame.images).load(layer.image.source!),
    );
  }

  @override
  void refreshCache() {}
}

/// Provide tuples with addition.
extension _PrivRangeTupleDouble on (double, double) {
  (double, double) operator +((double, double) other) =>
      ($1 + other.$1, $2 + other.$2);
}
