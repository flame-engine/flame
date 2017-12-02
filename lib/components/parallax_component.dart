import 'dart:async';
import 'dart:ui';

import 'component.dart';
import '../flame.dart';

import 'package:flutter/src/painting/images.dart';

class ParallaxRenderer {
  String filename;
  Future future;

  Image image;
  double scroll = 0.0;

  ParallaxRenderer(this.filename) {
    this.future = _load();
  }

  Future _load() {
    return Flame.images.load(filename).then((image) {
      this.image = image;
    });
  }

  bool get loaded => image != null;

  void render(Canvas canvas, Rect rect) {
    if (image == null) {
      return;
    }

    var imageHeight = image.height / window.devicePixelRatio;
    var imageWidth =
        (rect.height / imageHeight) * (image.width / window.devicePixelRatio);
    var count = rect.width / imageWidth;

    Rect fullRect = new Rect.fromLTWH(
        -scroll * imageWidth, rect.top, (count + 1) * imageWidth, rect.height);

    paintImage(
        canvas: canvas,
        image: image,
        rect: fullRect,
        repeat: ImageRepeat.repeatX);
  }
}

class ParallaxComponent extends PositionComponent {
  final BASE_SPEED = 30;
  final LAYER_DELTA = 40;

  List<ParallaxRenderer> layers = new List();
  Size size;
  bool _loaded = false;

  ParallaxComponent(this.size);

  /**
   * Loads the images defined by this list of filenames. All images
   * are positioned at its scroll center.
   *
   * @param filenames Image filenames
   */
  void load(List<String> filenames) {
    var futures =
    filenames.fold(new List<Future>(), (List<Future> result, filename) {
      var layer = new ParallaxRenderer(filename);
      layers.add(layer);
      result.add(layer.future);
      return result;
    });
    Future.wait(futures).then((r) {
      _loaded = true;
    });
  }

  void updateScroll(int layerIndex, scroll) {
    layers[layerIndex].scroll = scroll;
  }

  @override
  bool loaded() {
    return _loaded;
  }

  @override
  void render(Canvas canvas) {
    if (!this.loaded()) {
      return;
    }

    canvas.save();
    prepareCanvas(canvas);
    _drawLayers(canvas);
    canvas.restore();
  }

  void _drawLayers(Canvas canvas) {
    Rect rect = new Rect.fromPoints(
        new Offset(0.0, 0.0), new Offset(size.width, size.height));
    layers.forEach((layer) {
      layer.render(canvas, rect);
    });
  }

  @override
  void update(double delta) {
    if (!this.loaded()) {
      return;
    }
    for (var i = 0; i < layers.length; i++) {
      var scroll = layers[i].scroll;
      scroll += (BASE_SPEED + i * LAYER_DELTA) * delta / size.width;
      if (scroll > 1) {
        scroll = scroll % 1;
      }
      layers[i].scroll = scroll;
    }
  }
}