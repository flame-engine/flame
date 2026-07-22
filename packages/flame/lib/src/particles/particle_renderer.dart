import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/src/particles/particle_buffer.dart';

/// Draws the live particles of an emitter component.
///
/// Extend [TextureParticleRenderer] for batched texture rendering, or extend
/// this class (or use [CallbackParticleRenderer]) for full canvas access.
abstract class ParticleRenderer {
  /// Called once when the owning component loads. Override to prepare
  /// textures or other resources.
  FutureOr<void> onLoad() {}

  /// Renders all live particles in [particles]. The canvas is already
  /// transformed to the emitter component's local coordinate system.
  void render(Canvas canvas, ParticleBuffer particles);
}

/// A renderer that delegates to a callback, for effects that need direct
/// canvas access.
///
/// Nothing is batched, so this is slower than the texture renderers; prefer
/// those for large particle counts.
class CallbackParticleRenderer extends ParticleRenderer {
  /// Creates a renderer that calls [renderCallback] every frame.
  CallbackParticleRenderer(this.renderCallback);

  /// Called every frame with the canvas, already transformed to the emitter
  /// component's local coordinate system, and the live particles.
  final void Function(Canvas canvas, ParticleBuffer particles) renderCallback;

  @override
  void render(Canvas canvas, ParticleBuffer particles) {
    renderCallback(canvas, particles);
  }
}

/// Base class for renderers that draw every particle as a transformed,
/// tinted copy of a single texture region, batched into one
/// [Canvas.drawRawAtlas] call.
///
/// Each particle is drawn centered on its position, rotated by its rotation,
/// and uniformly scaled so the texture region's width matches the particle's
/// current size. The particle's color tints the texture through
/// [BlendMode.modulate], so white texture pixels take on the particle color
/// exactly.
abstract class TextureParticleRenderer extends ParticleRenderer {
  /// Creates a texture renderer.
  ///
  /// [blendMode] controls how particles composite onto the canvas; use
  /// [BlendMode.plus] for additive glow effects. [paint] can be provided to
  /// customize other paint properties.
  TextureParticleRenderer({BlendMode? blendMode, Paint? paint})
    : paint = paint ?? Paint() {
    if (blendMode != null) {
      this.paint.blendMode = blendMode;
    }
  }

  /// The paint used for the batched draw call.
  final Paint paint;

  /// The texture to draw, or null while the renderer has not loaded yet.
  Image? get texture;

  /// The region of [texture] to draw, in texture pixels.
  Rect get srcRect;

  Float32List _transforms = Float32List(0);
  Float32List _rects = Float32List(0);

  @override
  void render(Canvas canvas, ParticleBuffer particles) {
    final texture = this.texture;
    final count = particles.length;
    if (texture == null || count == 0) {
      return;
    }
    if (_transforms.length < count * 4) {
      _transforms = Float32List(particles.capacity * 4);
      _rects = Float32List(particles.capacity * 4);
    }
    final src = srcRect;
    final anchorX = src.width / 2;
    final anchorY = src.height / 2;
    final invWidth = 1 / src.width;
    for (var i = 0; i < count; i++) {
      final scale = particles.size[i] * invWidth;
      final rotation = particles.rotation[i];
      final scos = cos(rotation) * scale;
      final ssin = sin(rotation) * scale;
      final j = i * 4;
      _transforms[j] = scos;
      _transforms[j + 1] = ssin;
      _transforms[j + 2] = particles.posX[i] - scos * anchorX + ssin * anchorY;
      _transforms[j + 3] = particles.posY[i] - ssin * anchorX - scos * anchorY;
      _rects[j] = src.left;
      _rects[j + 1] = src.top;
      _rects[j + 2] = src.right;
      _rects[j + 3] = src.bottom;
    }
    canvas.drawRawAtlas(
      texture,
      Float32List.sublistView(_transforms, 0, count * 4),
      Float32List.sublistView(_rects, 0, count * 4),
      Int32List.sublistView(particles.color, 0, count),
      BlendMode.modulate,
      null,
      paint,
    );
  }
}
