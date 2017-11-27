import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';

import 'flame.dart';

abstract class Component {
  void update(double t);

  void render(Canvas c);
}

abstract class PositionComponent extends Component {
  double x = 0.0, y = 0.0, angle = 0.0;

  double angleBetween(PositionComponent c) {
    return (atan2(c.x - this.x, this.y - c.y) - PI / 2) % (2 * PI);
  }

  double distance(PositionComponent c) {
    return sqrt(pow(this.y - c.y, 2) + pow(this.x - c.x, 2));
  }

  void prepareCanvas(Canvas canvas) {
    canvas.translate(x, y);
    canvas.rotate(angle); // TODO: rotate around center
  }
}

abstract class SpriteComponent extends PositionComponent {
  double width, height;
  Image image;

  final Paint paint = new Paint()..color = new Color(0xffffffff);

  SpriteComponent.square(double size, String imagePath)
      : this.rectangle(size, size, imagePath);

  SpriteComponent.rectangle(this.width, this.height, String imagePath) {
    Flame.images.load(imagePath).then((image) {
      this.image = image;
    });
  }

  render(Canvas canvas) {
    if (image != null) {
      prepareCanvas(canvas);
      _drawImage(canvas);
    }
  }

  void _drawImage(Canvas canvas) {
    final Rect outputRect = new Rect.fromLTWH(0.0, 0.0, width, height);
    final Size imageSize =
        new Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes sizes =
        applyBoxFit(BoxFit.cover, imageSize, outputRect.size);
    final Rect inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final Rect outputSubrect =
        Alignment.center.inscribe(sizes.destination, outputRect);
    canvas.drawImageRect(image, inputSubrect, outputSubrect, paint);
  }

  update(double t) {}
}

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
  bool loaded = false;

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
      loaded = true;
    });
  }

  void updateScroll(int layerIndex, scroll) {
    layers[layerIndex].scroll = scroll;
  }

  @override
  void render(Canvas canvas) {
    if (!loaded) {
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
    if (!loaded) {
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
