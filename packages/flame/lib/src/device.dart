import 'dart:async';

import 'package:flutter/services.dart';

/// Provides methods for controlling the device (e.g. setting the screen to
/// full-screen).
///
/// To use this class, access it via Flame.device.
class Device {
  /// Sets the app to be full-screen (no buttons, bar or notifications on top).
  Future<void> fullScreen() {
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Sets the app to be in a window mode. (The inverse of fullScreen).
  Future<void> windowed() {
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// Sets the preferred orientation (landscape or portrait) for the app.
  ///
  /// When it opens, it will automatically change orientation to the preferred
  /// one (if possible) depending on the physical orientation of the device.
  Future<void> setOrientation(DeviceOrientation orientation) {
    return SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[orientation],
    );
  }

  /// Sets the preferred orientations (landscape left, right, portrait up, or
  /// down) for the app.
  ///
  /// When it opens, it will automatically change orientation to the preferred
  /// one (if possible) depending on the physical orientation of the device.
  Future<void> setOrientations(List<DeviceOrientation> orientations) {
    return SystemChrome.setPreferredOrientations(orientations);
  }

  /// Sets the preferred orientation of the app to landscape only.
  ///
  /// When it opens, it will automatically change orientation to the preferred
  /// one (if possible).
  Future<void> setLandscape() {
    return setOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Sets the preferred orientation of the app to
  /// `DeviceOrientation.landscapeLeft` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred
  /// one (if possible).
  Future<void> setLandscapeLeftOnly() {
    return setOrientation(DeviceOrientation.landscapeLeft);
  }

  /// Sets the preferred orientation of the app to
  /// `DeviceOrientation.landscapeRight` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred
  /// one (if possible).
  Future<void> setLandscapeRightOnly() {
    return setOrientation(DeviceOrientation.landscapeRight);
  }

  /// Sets the preferred orientation of the app to portrait only.
  ///
  /// When it opens, it will automatically change orientation to the preferred
  /// one (if possible).
  Future<void> setPortrait() {
    return setOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Sets the preferred orientation of the app to
  /// `DeviceOrientation.portraitUp` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred
  /// one (if possible).
  Future<void> setPortraitUpOnly() {
    return setOrientation(DeviceOrientation.portraitUp);
  }

  /// Sets the preferred orientation of the app to
  /// `DeviceOrientation.portraitDown` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred
  /// one (if possible).
  Future<void> setPortraitDownOnly() {
    return setOrientation(DeviceOrientation.portraitDown);
  }
}
