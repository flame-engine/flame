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

class ParallaxComponent extends PositionComponent {
  final BASE_SPEED = 30;
  final LAYER_DELTA = 40;

  List<Image> images = new List();
  List<double> scrolls = new List();
  Size size;
  bool loaded = false;

  ParallaxComponent(this.size, List<String> filenames) {
    _load(filenames);
  }

  void _load(List<String> filenames) {
    var futures =
        filenames.fold(new List<Future>(), (List<Future> result, filename) {
      result.add(Flame.images.load(filename).then((image) {
        images.add(image);
        scrolls.add(0.0);
      }));
      return result;
    });
    Future.wait(futures).then((r) {
      loaded = true;
    });
  }

  @override
  void render(Canvas canvas) {
    if (!loaded) {
      return;
    }

    prepareCanvas(canvas);
    _drawLayers(canvas);
  }

  void _drawLayers(Canvas canvas) {
    images.asMap().forEach((index, image) {
      var scroll = scrolls[index];

      Rect leftRect =
          new Rect.fromLTWH(0.0, 0.0, (1 - scroll) * size.width, size.height);
      Rect rightRect = new Rect.fromLTWH(
          (1 - scroll) * size.width, 0.0, scroll * size.width, size.height);

      paintImage(
          canvas: canvas,
          image: image,
          rect: leftRect,
          fit: BoxFit.cover,
          alignment: Alignment.centerRight);

      paintImage(
          canvas: canvas,
          image: image,
          rect: rightRect,
          fit: BoxFit.cover,
          alignment: Alignment.centerLeft);
    });
  }

  @override
  void update(double delta) {
    if (!loaded) {
      return;
    }
    for (var i = 0; i < scrolls.length; i++) {
      var scroll = scrolls[i];
      scroll += (BASE_SPEED + i * LAYER_DELTA) * delta / size.width;
      if (scroll > 1) {
        scroll = scroll % 1;
      }
      scrolls[i] = scroll;
    }
  }
}
