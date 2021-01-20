import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  /// Utility method to render stuff on a specific place.
  ///
  /// Some render methods don't allow to pass a offset.
  /// This method translate the canvas before rendering your fn.
  /// The changes are reset after the fn is run.
  void renderAt(Canvas c, Vector2 p, void Function(Canvas) fn) {
    c.save();
    c.translate(p.x, p.y);
    fn(c);
    c.restore();
  }

  /// Utility method to render stuff rotated at specific angle.
  ///
  /// It rotates the canvas around the center of rotation.
  /// The changes are reset after the fn is run.
  void renderRotated(
    Canvas c,
    double angle,
    Vector2 rotationCenter,
    void Function(Canvas) fn,
  ) {
    c.save();
    c.translate(-rotationCenter.x, -rotationCenter.y);
    c.rotate(angle);
    c.translate(rotationCenter.x, rotationCenter.y);
    fn(c);
    c.restore();
  }
}
