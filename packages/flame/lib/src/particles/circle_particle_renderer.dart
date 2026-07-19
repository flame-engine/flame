import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/src/particles/particle_renderer.dart';

/// Renders each particle as a circle, batched into a single draw call.
///
/// A circle texture is rasterized once when the renderer loads; every
/// particle is then a transformed, tinted copy of it. The circle's color
/// comes from the emitter's `colorOverLife` ramp (white when unset).
class CircleParticleRenderer extends TextureParticleRenderer {
  /// Creates a circle renderer.
  ///
  /// [softness] goes from 0 (a crisp edge) to 1 (fully faded from the
  /// center), which suits smoke and glow, especially combined with
  /// `blendMode: BlendMode.plus`.
  CircleParticleRenderer({
    this.softness = 0,
    super.blendMode,
    super.paint,
  }) : assert(
         softness >= 0 && softness <= 1,
         'softness must be between 0 and 1',
       );

  /// How much the circle fades out towards its edge, from 0 (crisp) to 1
  /// (fully soft).
  final double softness;

  static const int _textureSize = 64;

  Image? _texture;

  @override
  Image? get texture => _texture;

  @override
  Rect get srcRect =>
      Rect.fromLTWH(0, 0, _textureSize.toDouble(), _textureSize.toDouble());

  @override
  Future<void> onLoad() async {
    if (_texture != null) {
      return;
    }
    const white = Color(0xffffffff);
    const transparent = Color(0x00ffffff);
    const radius = _textureSize / 2;
    const center = Offset(radius, radius);
    final paint = Paint();
    if (softness > 0) {
      paint.shader = Gradient.radial(
        center,
        radius,
        const [white, white, transparent],
        [0, (1 - softness).clamp(0.0, 0.99), 1],
      );
    } else {
      paint.color = white;
    }
    final recorder = PictureRecorder();
    Canvas(recorder).drawCircle(center, radius, paint);
    _texture = await recorder.endRecording().toImageSafe(
      _textureSize,
      _textureSize,
    );
  }
}
