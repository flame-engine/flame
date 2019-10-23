import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;

import 'animation.dart';
import 'sprite.dart';
import 'components/animation_component.dart';
import 'game.dart';
import 'position.dart';

/// Some utilities that did not fit anywhere else.
///
/// To use this class, access it via [Flame.util].
class Util {
  /// Sets the app to be fullscreen (no buttons bar os notifications on top).
  ///
  /// Most games should probably be this way.
  Future<void> fullScreen() {
    return SystemChrome.setEnabledSystemUIOverlays([]);
  }

  /// Sets the preferred orientation (landscape or portrait) for the app.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible) depending on the physical orientation of the device.
  Future<void> setOrientation(DeviceOrientation orientation) {
    return SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[orientation],
    );
  }

  /// Sets the preferred orientations (landscape left, right, portrait up, or down) for the app.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible) depending on the physical orientation of the device.
  Future<void> setOrientations(List<DeviceOrientation> orientations) {
    return SystemChrome.setPreferredOrientations(orientations);
  }

  /// Sets the preferred orientation of the app to landscape only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setLandscape() {
    return setOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Sets the preferred orientation of the app to `DeviceOrientation.landscapeLeft` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setLandscapeLeftOnly() {
    return setOrientation(DeviceOrientation.landscapeLeft);
  }

  /// Sets the preferred orientation of the app to `DeviceOrientation.landscapeRight` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setLandscapeRightOnly() {
    return setOrientation(DeviceOrientation.landscapeRight);
  }

  /// Sets the preferred orientation of the app to portrait only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setPortrait() {
    return setOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Sets the preferred orientation of the app to `DeviceOrientation.portraitUp` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setPortraitUpOnly() {
    return setOrientation(DeviceOrientation.portraitUp);
  }

  /// Sets the preferred orientation of the app to `DeviceOrientation.portraitDown` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setPortraitDownOnly() {
    return setOrientation(DeviceOrientation.portraitDown);
  }

  /// Waits for the initial screen dimensions to be available.
  ///
  /// Because of flutter's issue #5259, when the app starts the size might be 0x0.
  /// This waits for the information to be properly updated.
  ///
  /// A best practice would be to implement there resize hooks on your game and components and don't use this at all.
  /// Make sure your components are able to render and update themselves for any possible screen size.
  Future<Size> initialDimensions() async {
    // https://github.com/flutter/flutter/issues/5259
    // "In release mode we start off at 0x0 but we don't in debug mode"
    return await Future<Size>(() {
      if (window.physicalSize.isEmpty) {
        final completer = Completer<Size>();
        window.onMetricsChanged = () {
          if (!window.physicalSize.isEmpty && !completer.isCompleted) {
            completer.complete(window.physicalSize / window.devicePixelRatio);
          }
        };
        return completer.future;
      }
      return window.physicalSize / window.devicePixelRatio;
    });
  }

  /// This properly binds a gesture recognizer to your game.
  ///
  /// Use this in order to get it to work in case your app also contains other widgets.
  ///
  /// @Deprecated('This method can lead to confuse behaviour, use the gestures methods provided by the Game class')
  void addGestureRecognizer(GestureRecognizer recognizer) {
    if (GestureBinding.instance == null) {
      throw Exception(
          'GestureBinding is not initialized yet, this probably happened because addGestureRecognizer was called before the runApp method');
    }

    GestureBinding.instance.pointerRouter.addGlobalRoute((PointerEvent e) {
      if (e is PointerDownEvent) {
        recognizer.addPointer(e);
      }
    });
  }

  /// This properly removes the bind of a gesture recognizer to your game.
  ///
  /// Use this in order to clear any added recognizers that you have added before
  void removeGestureRecognizer(GestureRecognizer recognizer) {
    recognizer.dispose();
  }

  /// Utility method to render stuff on a specific place.
  ///
  /// Some render methods don't allow to pass a offset.
  /// This method translate the canvas, draw what you want, and then translate back.
  void drawWhere(Canvas c, Position p, void Function(Canvas) fn) {
    c.translate(p.x, p.y);
    fn(c);
    c.translate(-p.x, -p.y);
  }

  /// Returns a regular Flutter widget representing this animation, rendered with the specified size.
  ///
  /// This actually creates an [EmbeddedGameWidget] with a [SimpleGame] whose only content is an [AnimationComponent] created from the provided [animation].
  /// You can use this implementation as base to easily create your own widgets based on more complex games.
  /// This is intended to be used by non-game apps that want to add a sprite sheet animation.
  widgets.Widget animationAsWidget(Position size, Animation animation) {
    return EmbeddedGameWidget(
        SimpleGame(AnimationComponent(size.x, size.y, animation)),
        size: size);
  }

  /// Returns a regular Flutter widget represeting this sprite, rendered with the specified size.
  ///
  /// This will create a [CustomPaint] widget using a [CustomPainter] for rendering the [Sprite]
  /// Be aware that the Sprite must have been loaded, otherwise it can't be rendered
  widgets.CustomPaint spriteAsWidget(Size size, Sprite sprite) =>
      widgets.CustomPaint(size: size, painter: _SpriteCustomPainter(sprite));
}

class _SpriteCustomPainter extends widgets.CustomPainter {
  final Sprite _sprite;

  _SpriteCustomPainter(this._sprite);

  @override
  void paint(Canvas canvas, Size size) {
    if (_sprite.loaded()) {
      _sprite.render(canvas, width: size.width, height: size.height);
    }
  }

  @override
  bool shouldRepaint(widgets.CustomPainter old) => false;
}
