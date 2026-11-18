import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';

/// {@template scene_3d_host}
/// What a [World3D] renders with: the [GraphicsDevice] and the
/// [RenderContext3D] that record its draws, the number of samples per pixel
/// and the density of device pixels.
///
/// A [World3D] uses the nearest ancestor that is a [Scene3DHost]: a
/// [Scene3DComponent] that embeds it in a 2D game, or the [Game3D] game whose
/// camera looks at it (such as a [FlameGame3D]).
/// {@endtemplate}
abstract interface class Scene3DHost() {
  /// The device the hosted scenes render with.
  GraphicsDevice get device;

  /// The context that records and submits the draws of the hosted scenes.
  RenderContext3D get context;

  /// The number of samples per pixel of the render passes, `1` or `4`, see
  /// [Msaa].
  int get msaaSampleCount;

  /// The number of device pixels per logical pixel.
  double get pixelRatio;
}
