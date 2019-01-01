import 'dart:ui';
import 'dart:async';

import 'package:flame/position.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show Colors;

class Sprite {
  Paint paint = whitePaint;
  Image image;
  Rect src;

  static final Paint whitePaint = new Paint()..color = Colors.white;

  Sprite(
    String fileName, {
    double x = 0.0,
    double y = 0.0,
    double width = null,
    double height = null,
  }) {
    Flame.images.load(fileName).then((img) {
      if (width == null) {
        width = img.width.toDouble();
      }
      if (height == null) {
        height = img.height.toDouble();
      }
      this.image = img;
      this.src = new Rect.fromLTWH(x, y, width, height);
    });
  }

  Sprite.fromImage(
    this.image, {
    double x = 0.0,
    double y = 0.0,
    double width = null,
    double height = null,
  }) {
    if (width == null) {
      width = image.width.toDouble();
    }
    if (height == null) {
      height = image.height.toDouble();
    }
    this.src = new Rect.fromLTWH(x, y, width, height);
  }

  static Future<Sprite> loadSprite(
    String fileName, {
    double x = 0.0,
    double y = 0.0,
    double width = null,
    double height = null,
  }) async {
    Image image = await Flame.images.load(fileName);
    return new Sprite.fromImage(
      image,
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }

  bool loaded() {
    return image != null && src != null;
  }

  double get _imageWidth => this.image.width.toDouble();
  double get _imageHeight => this.image.height.toDouble();

  Position get originalSize {
    if (!loaded()) {
      return null;
    }
    return new Position(_imageWidth, _imageHeight);
  }

  Position get size {
    return new Position(src.width, src.height);
  }

  /// Renders this Sprite on the position [p], scaled by the [scale] factor provided.
  ///
  /// It renders with src size multiplied by [scale] in both directions.
  /// Anchor is on top left as default.
  /// If not loaded, does nothing.
  void renderScaled(Canvas canvas, Position p, [double scale = 1.0]) {
    if (!this.loaded()) {
      return;
    }
    renderPosition(canvas, p, size.times(scale));
  }

  void renderPosition(Canvas canvas, Position p, [Position size]) {
    if (!this.loaded()) {
      return;
    }
    size ??= this.size;
    renderRect(canvas, Position.rectFrom(p, size));
  }

  void render(Canvas canvas, [double width, double height]) {
    if (!this.loaded()) {
      return;
    }
    width ??= this.size.x;
    height ??= this.size.y;
    renderRect(canvas, new Rect.fromLTWH(0.0, 0.0, width, height));
  }

  void renderRect(Canvas canvas, Rect dst) {
    if (!this.loaded()) {
      return;
    }
    canvas.drawImageRect(image, src, dst, paint);
  }

  /// Renders this sprite centered in the position [p], i.e., on [p] - [size] / 2.
  ///
  /// If [size] is not provided, the original size of the src image is used.
  /// If the asset is not yet loaded, it does nothing.
  void renderCentered(Canvas canvas, Position p, [Position size]) {
    if (!this.loaded()) {
      return;
    }
    size ??= this.size;
    renderRect(canvas,
        new Rect.fromLTWH(p.x - size.x / 2, p.y - size.y / 2, size.x, size.y));
  }
}
