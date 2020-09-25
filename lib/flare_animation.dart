import 'dart:math';
import 'dart:ui';

import "package:flare_flutter/flare.dart";
import "package:flare_flutter/flare_actor.dart";

import "flame.dart";

@Deprecated("Use flame_flare package instead")
class FlareAnimation {
  final FlutterActorArtboard _artboard;

  String _animationName;
  final List<FlareAnimationLayer> _animationLayers = [];

  double _width = 0.0, _height = 0.0, _xScale = 0.0, _yScale = 0.0;

  Picture _picture;

  FlareAnimation(this._artboard);

  static Future<FlareAnimation> load(String fileName) async {
    final actor = FlutterActor();
    await actor.loadFromBundle(Flame.bundle, fileName);
    await actor.loadImages();

    final artboard = actor.artboard.makeInstance();
    artboard.makeInstance();
    artboard.initializeGraphics();
    artboard.advance(0.0);

    return FlareAnimation(artboard);
  }

  double get width {
    return _width;
  }

  double get height {
    return _height;
  }

  set width(double newWidth) {
    _width = newWidth;
    _xScale = _width / _artboard.width;
  }

  set height(double newHeight) {
    _height = newHeight;
    _yScale = _height / _artboard.height;
  }

  void updateAnimation(String animation) {
    _animationName = animation;

    if (_animationName != null && _artboard != null) {
      _animationLayers.clear();

      final ActorAnimation animation = _artboard.getAnimation(_animationName);
      if (animation != null) {
        _animationLayers.add(FlareAnimationLayer()
          ..name = _animationName
          ..animation = animation
          ..mix = 1.0
          ..mixSeconds = 0.2);
        animation.apply(0.0, _artboard, 1.0);
        _artboard.advance(0.0);
      }
    }
  }

  void render(Canvas canvas, {double x = 0.0, double y = 0.0}) {
    if (_picture == null) {
      return;
    }

    canvas.save();
    canvas.translate(x, y);

    canvas.drawPicture(_picture);
    canvas.restore();
  }

  void update(double elapsedSeconds) {
    int lastFullyMixed = -1;
    double lastMix = 0.0;

    final List<FlareAnimationLayer> completed = [];

    for (int i = 0; i < _animationLayers.length; i++) {
      final FlareAnimationLayer layer = _animationLayers[i];
      layer.mix += elapsedSeconds;
      layer.time += elapsedSeconds;

      lastMix = (layer.mixSeconds == null || layer.mixSeconds == 0.0)
          ? 1.0
          : min(1.0, layer.mix / layer.mixSeconds);
      if (layer.animation.isLooping) {
        layer.time %= layer.animation.duration;
      }
      layer.animation.apply(layer.time, _artboard, lastMix);
      if (lastMix == 1.0) {
        lastFullyMixed = i;
      }
      if (layer.time > layer.animation.duration) {
        completed.add(layer);
      }
    }

    if (lastFullyMixed != -1) {
      _animationLayers.removeRange(0, lastFullyMixed);
    }
    if (_animationName == null &&
        _animationLayers.length == 1 &&
        lastMix == 1.0) {
      // Remove remaining animations.
      _animationLayers.removeAt(0);
    }

    if (_artboard != null) {
      _artboard.advance(elapsedSeconds);
    }

    // Memory render frame
    final r = PictureRecorder();
    final c = Canvas(r);

    c.scale(_xScale, _yScale);
    _artboard.draw(c);

    _picture = r.endRecording();
  }
}
