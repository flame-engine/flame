import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart';

import '../../game.dart';
import '../../extensions.dart';
import '../../palette.dart';

abstract class Viewport {
  void resize(Vector2 newRawSize);
  void render(Canvas c, void Function(Canvas c) renderGame);
  Vector2 getEffectiveSize();
  Vector2 getRawSize();
}

class DefaultViewport extends Viewport {
  Vector2 _size;

  @override
  void render(Canvas c, void Function(Canvas c) renderGame) {
    renderGame(c);
  }

  @override
  void resize(Vector2 newRawSize) {
    _size = newRawSize;
  }

  @override
  Vector2 getEffectiveSize() => _size;

  @override
  Vector2 getRawSize() => _size;
}

class FixedRatioViewport extends Viewport {
  Paint borderColor;

  Vector2 rawSize;
  Vector2 scaledSize;
  Vector2 resizeOffset;
  Vector2 fixedSize;
  double scale;

  FixedRatioViewport(
    this.fixedSize, {
    Paint borderColor,
  }) {
    this.borderColor = borderColor ?? BasicPalette.black.paint;
  }

  @override
  Vector2 getEffectiveSize() => fixedSize;

  @override
  Vector2 getRawSize() => rawSize;

  @override
  void resize(Vector2 newRawSize) {
    rawSize = newRawSize;

    final scaleVector = rawSize.clone()..divide(fixedSize);
    scale = math.min(scaleVector.x, scaleVector.y);

    scaledSize = fixedSize.clone()..scale(scale);
    resizeOffset = (rawSize - scaledSize) / 2;
  }

  @override
  void render(Canvas c, void Function(Canvas) renderGame) {
    c.save();
    c.translate(resizeOffset.x, resizeOffset.y);
    c.scale(scale, scale);

    renderGame(c);

    c.restore();
    c.drawRect(
      Rect.fromLTWH(0.0, 0.0, rawSize.x, resizeOffset.y),
      borderColor,
    );
    c.drawRect(
      Rect.fromLTWH(
        0.0,
        resizeOffset.y + scaledSize.y,
        rawSize.x,
        resizeOffset.y,
      ),
      borderColor,
    );
    c.drawRect(
      Rect.fromLTWH(0.0, 0.0, resizeOffset.x, rawSize.y),
      borderColor,
    );
    c.drawRect(
      Rect.fromLTWH(
        resizeOffset.x + scaledSize.x,
        0.0,
        resizeOffset.x,
        rawSize.y,
      ),
      borderColor,
    );
  }
}
