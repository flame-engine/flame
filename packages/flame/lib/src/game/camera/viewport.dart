import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart';

import '../../../extensions.dart';
import '../../../game.dart';
import '../projector.dart';

/// A viewport is a class that potentially translates and resizes the screen.
/// The reason you might want to have a viewport is to make sure you handle any
/// screen size and resolution correctly depending on your needs.
///
/// Not only screens can have endless configurations of width and height with
/// different ratios, you can also embed games as widgets within a Flutter app.
/// In fact, the size of the game can even change dynamically (if the layout
/// changes or in desktop, for example).
///
/// For some simple games, that is not an issue. The game will just adapt
/// to fit the screen, so if the game world is 1:1 with screen it will just
/// be bigger or smaller. But if you want a consistent experience across
/// platforms and players, you should use a viewport.
///
/// When using a viewport, [resize] should be called by the engine with
/// the raw canvas size (on startup and subsequent resizes) and that will
/// configure [getEffectiveSize()] and [getCanvasSize()].
/// The Viewport can also apply an offset to render and clip the canvas adding
/// borders (clipping) when necessary.
/// When rendering, call [render] and put all your rendering inside the lambda
/// so that the correct transformations are applied.
///
/// You can think of a Viewport as mechanism to watch a wide-screen movie on a
/// square monitor. You can stretch the movie to fill the square, but the width
/// and height will be stretched by different amounts, causing distortion. You
/// can fill in the smallest dimension and crop the biggest (that causes
/// cropping). Or you can fill in the biggest and add black bars to cover the
/// unused space on the smallest (this is the [FixedResolutionViewport]).
///
/// The other option is to not use a viewport ([DefaultViewport]) and have
/// your game dynamically render itself to fill in the existing space (basically
/// this means generating either a wide-screen or a square movie on the fly).
/// The disadvantage is that different players on different devices will see
/// different games. For example a hidden door because it's too far away to
/// render in Screen 1 might be visible on Screen 2. Specially if it's an
/// online/competitive game, it can give unfair advantages to users with certain
/// screen resolutions. If you want to "play director" and know exactly what
/// every player is seeing at every time, you should use a Viewport.
abstract class Viewport extends Projector {
  /// This configures the viewport with a new raw canvas size.
  /// It should immediately affect [effectiveSize] and [canvasSize].
  /// This must be called by the engine at startup and also whenever the
  /// size changes.
  void resize(Vector2 newCanvasSize);

  /// This transforms the canvas so that the coordinate system is viewport-
  /// -aware. All your rendering logic should be put inside the lambda.
  void render(Canvas c, void Function(Canvas c) renderGame);

  /// This returns the effective size, after viewport transformation.
  /// This is not the game widget size but for all intents and purposes,
  /// inside your game, this size should be used as the real one.
  Vector2 get effectiveSize;

  /// This returns the real widget size (well actually the logical Flutter
  /// size of your widget). This is the raw canvas size as it would be without
  /// any viewport.
  ///
  /// You probably don't need to care about this if you are using a viewport.
  Vector2? canvasSize;
}

/// This is the default viewport if you want no transformation.
/// The raw canvasSize is just propagated to the effective size and no
/// translation is applied.
/// This basically no-ops the viewport.
class DefaultViewport extends Viewport {
  @override
  void render(Canvas c, void Function(Canvas c) renderGame) {
    renderGame(c);
  }

  @override
  void resize(Vector2 newCanvasSize) {
    canvasSize = newCanvasSize.clone();
  }

  @override
  Vector2 get effectiveSize => canvasSize!;

  @override
  Vector2 projectVector(Vector2 vector) => vector;

  @override
  Vector2 unprojectVector(Vector2 vector) => vector;

  @override
  Vector2 scaleVector(Vector2 vector) => vector;

  @override
  Vector2 unscaleVector(Vector2 vector) => vector;
}

/// This is the most common viewport if you want to have full control of what
/// the game looks like. Basically this viewport makes sure the ratio between
/// width and height is *always* the same in your game, no matter the platform.
///
/// To accomplish this you choose a virtual size that will always match the
/// effective size.
///
/// Under the hood, the Viewport will try to expand (or contract) the virtual
/// size so that it fits the most of the screen as it can. So for example,
/// if the viewport happens to be the same ratio of the screen, it will resize
/// to fit 100%. But if they are different ratios, it will resize the most it
/// can and then will add black (color is configurable) borders.
///
/// Then, inside your game, you can always assume the game size is the fixed
/// dimension that you provided.
///
/// Normally you can pick a virtual size that has the same ratio as the most
/// used device for your game (like a pretty standard mobile ratio if you
/// are doing a mobile game) and then in most cases this will apply no
/// transformation whatsoever, and if the a device with a different ratio is
/// used it will try to adapt the best as possible.
class FixedResolutionViewport extends Viewport {
  @override
  late Vector2 effectiveSize;

  final Vector2 _scaledSize = Vector2.zero();
  Vector2 get scaledSize => _scaledSize.clone();

  final Vector2 _resizeOffset = Vector2.zero();
  Vector2 get resizeOffset => _resizeOffset.clone();

  late double _scale;
  double get scale => _scale;

  /// The matrix used for scaling and translating the canvas
  final Matrix4 _transform = Matrix4.identity();

  /// The Rect that is used to clip the canvas
  late Rect _clipRect;

  FixedResolutionViewport(this.effectiveSize);

  @override
  void resize(Vector2 newCanvasSize) {
    canvasSize = newCanvasSize.clone();

    _scale = math.min(
      canvasSize!.x / effectiveSize.x,
      canvasSize!.y / effectiveSize.y,
    );

    _scaledSize
      ..setFrom(effectiveSize)
      ..scale(_scale);
    _resizeOffset
      ..setFrom(canvasSize!)
      ..sub(_scaledSize)
      ..scale(0.5);

    _clipRect = _resizeOffset & _scaledSize;

    _transform.setIdentity();
    _transform.translate(_resizeOffset.x, _resizeOffset.y);
    _transform.scale(_scale, _scale, 1);
  }

  @override
  void render(Canvas c, void Function(Canvas) renderGame) {
    c.save();
    c.clipRect(_clipRect);
    c.transform(_transform.storage);
    renderGame(c);
    c.restore();
  }

  @override
  Vector2 projectVector(Vector2 viewportCoordinates) {
    return (viewportCoordinates * _scale)..add(_resizeOffset);
  }

  @override
  Vector2 unprojectVector(Vector2 screenCoordinates) {
    return (screenCoordinates - _resizeOffset)..scale(1 / _scale);
  }

  @override
  Vector2 scaleVector(Vector2 viewportCoordinates) {
    return viewportCoordinates * scale;
  }

  @override
  Vector2 unscaleVector(Vector2 screenCoordinates) {
    return screenCoordinates / scale;
  }
}
