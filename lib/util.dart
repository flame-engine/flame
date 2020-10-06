import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'extensions/size.dart';
import 'extensions/vector2.dart';

/// Some utilities that did not fit anywhere else.
///
/// To use this class, access it via [Flame.util].
class Util {
  /// Sets the app to be fullscreen (no buttons bar os notifications on top).
  ///
  /// Most games should probably be this way.
  Future<void> fullScreen() {
    if (kIsWeb) {
      return Future.value();
    }
    return SystemChrome.setEnabledSystemUIOverlays([]);
  }

  /// Sets the preferred orientation (landscape or portrait) for the app.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible) depending on the physical orientation of the device.
  Future<void> setOrientation(DeviceOrientation orientation) {
    if (kIsWeb) {
      return Future.value();
    }
    return SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[orientation],
    );
  }

  /// Sets the preferred orientations (landscape left, right, portrait up, or down) for the app.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible) depending on the physical orientation of the device.
  Future<void> setOrientations(List<DeviceOrientation> orientations) {
    if (kIsWeb) {
      return Future.value();
    }
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
  /// Because of flutter's issue [#5259](https://github.com/flutter/flutter/issues/5259), when the app starts the size might be 0x0.
  /// This waits for the information to be properly updated.
  ///
  /// A best practice would be to implement there resize hooks on your game and components and don't use this at all.
  /// Make sure your components are able to render and update themselves for any possible screen size.
  Future<Vector2> initialDimensions() async {
    // https://github.com/flutter/flutter/issues/5259
    // "In release mode we start off at 0x0 but we don't in debug mode"
    return await Future<Vector2>(() {
      if (window.physicalSize.isEmpty) {
        final completer = Completer<Vector2>();
        window.onMetricsChanged = () {
          if (!window.physicalSize.isEmpty && !completer.isCompleted) {
            completer.complete(
                (window.physicalSize / window.devicePixelRatio).toVector2());
          }
        };
        return completer.future;
      }
      return (window.physicalSize / window.devicePixelRatio).toVector2();
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
  void drawWhere(Canvas c, Vector2 p, void Function(Canvas) fn) {
    c.translate(p.x, p.y);
    fn(c);
    c.translate(-p.x, -p.y);
  }
}
