import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:meta/meta.dart';

mixin Game3D on Game {
  @internal
  final GraphicsDevice device = GraphicsDevice();

  @internal
  late final RenderContext3D context = RenderContext3D(device);

  @override
  void render(Canvas canvas) {
    device.begin();
    super.render(canvas);
    device.end();
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
}
