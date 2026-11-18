import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flutter/widgets.dart' show MediaQuery;
import 'package:meta/meta.dart';

/// {@template game_3d}
/// Adds a [GraphicsDevice] and a [RenderContext3D] to a [Game], shared by all
/// of its 3D scenes: the [World3D] its cameras look at (see [FlameGame3D]) and
/// the [Scene3DComponent]s that embed 3D scenes in its 2D worlds.
///
/// The device frame spans the whole [render] call, so [renderStats] counts
/// every render pass of a frame.
/// {@endtemplate}
mixin Game3D on Game implements Scene3DHost {
  @override
  final GraphicsDevice device = GraphicsDevice();

  @override
  late final RenderContext3D context = RenderContext3D(device);

  /// The GPU statistics of the last rendered frame: draw calls, instances,
  /// triangles, pipeline and state changes, uploads.
  RenderStats get renderStats => device.lastFrameStats;

  /// Whether a frame of [device] is open, which is the case during [render].
  @internal
  bool get isRenderingFrame => _renderingFrame;
  bool _renderingFrame = false;

  @override
  void render(Canvas canvas) {
    device.begin();
    _renderingFrame = true;
    try {
      super.render(canvas);
    } finally {
      _renderingFrame = false;
      device.end();
    }
  }

  /// Gets the multisample anti-aliasing configuration.
  ///
  /// Either one sample per pixel (no msaa) or four samples per pixel are
  /// supported.
  ///
  /// A subset of OpenGLES-only devices do not support this functionality and
  /// will silently fall back to [Msaa.off].
  ///
  /// **Four sample MSAA is currently only supported in the mobile and desktop
  /// backends, it is silently ignored for the web.**
  Msaa msaa() => Msaa.off;

  @override
  int get msaaSampleCount => msaa().sampleCount;

  /// The device pixel ratio of the view the game is shown in, or `1` while
  /// the game is not attached to a widget.
  @override
  double get pixelRatio {
    final buildContext = this.buildContext;
    return buildContext == null
        ? 1.0
        : MediaQuery.devicePixelRatioOf(buildContext);
  }
}
