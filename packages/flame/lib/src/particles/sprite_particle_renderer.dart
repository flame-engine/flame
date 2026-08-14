import 'dart:ui';

import 'package:flame/src/particles/particle_renderer.dart';
import 'package:flame/src/sprite.dart';

/// Renders each particle as a [Sprite] (a region of an image), batched into
/// a single draw call.
///
/// The sprite is drawn centered on the particle, scaled so its width matches
/// the particle's current size, and tinted by the emitter's `colorOverLife`
/// ramp (untinted when unset).
class SpriteParticleRenderer extends TextureParticleRenderer {
  /// Renders every particle as [sprite].
  SpriteParticleRenderer(this.sprite, {super.blendMode, super.paint});

  /// Renders every particle as the full [image].
  SpriteParticleRenderer.fromImage(
    Image image, {
    BlendMode? blendMode,
    Paint? paint,
  }) : this(Sprite(image), blendMode: blendMode, paint: paint);

  /// The sprite drawn for every particle.
  final Sprite sprite;

  @override
  Image get texture => sprite.image;

  @override
  Rect get srcRect => sprite.src;
}
