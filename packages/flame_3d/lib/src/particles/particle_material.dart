import 'dart:math' as math;
import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// How the quad of each particle drawn with a [ParticleMaterial] faces the
/// camera.
enum ParticleBillboard() {
  /// Parallel to the screen, upright on screen (turned by the particle's
  /// rotation).
  spherical,

  /// Upright along [ParticleMaterial.axis], turning about it to face the
  /// camera (flames, beams, standing sprites).
  cylindrical,

  /// Stretched along the particle's velocity as seen on screen, the leading
  /// edge half a size ahead of the particle (sparks, rain, streaks), see
  /// [ParticleSystem3D.velocityStretch].
  velocity,

  /// In the plane perpendicular to [ParticleMaterial.axis], whatever the
  /// camera (ripples, shock rings, decals on the ground).
  flat,
}

/// What a [ParticleMaterial] draws on each quad, multiplied by its
/// [ParticleMaterial.texture].
enum ParticleSprite() {
  /// The texture alone (a white texture draws solid quads).
  texture,

  /// A disc with a soft edge, see [ParticleMaterial.softness].
  softCircle,

  /// A soft, lumpy puff whose outline and inside vary from particle to
  /// particle (smoke, dust, clouds), see [ParticleMaterial.lumpiness].
  softBlob,
}

/// {@template particle_material}
/// The material of billboard particles: each particle of a [ParticleSystem3D]
/// is a quad facing the camera (see [billboard]) built in the vertex shader,
/// and all the particles of a system are drawn with one instanced draw.
///
/// Particles are depth tested against the scene, so they pass behind and in
/// front of models. The [renderState] decides how they blend: by default
/// with premultiplied alpha, without depth writes, sorted back to front.
/// [RenderState.additive] suits glowing particles (sparks, embers), which
/// need no sorting; an opaque state with an [alphaCutoff] draws cut-out
/// particles that write depth.
///
/// A quad shows the [sprite] (a soft circle or blob computed in the shader,
/// no texture needed) multiplied by the [texture], by [color] and by the
/// particle's color. A texture can be a flipbook: a grid of
/// [flipbookColumns] by [flipbookRows] frames, read left to right and top to
/// bottom, of which the system picks one per particle (see
/// [ParticleSystem3D.flipbook]). Textures hold premultiplied alpha, as the
/// images Flutter decodes do; give them a [TextureSampler.linear] sampler for
/// smooth particles.
///
/// Soft particles (fading where a particle meets geometry) are not
/// supported: they need the depth of the scene in the fragment shader, and
/// Flutter GPU can neither sample a depth attachment in the pass that uses
/// it nor sample the depth of its depth-stencil textures.
///
/// Not available on the web yet: there are no WebGPU shaders for it.
/// {@endtemplate}
class ParticleMaterial({
  ParticleSprite? sprite,
  Texture? texture,

  /// The tint of every particle.
  var Color color = const Color(0xFFFFFFFF),

  /// The width of the soft edge of [ParticleSprite.softCircle] and
  /// [ParticleSprite.softBlob], as a fraction of the radius.
  var double softness = 0.5,

  /// How lumpy [ParticleSprite.softBlob] puffs are, from 0 (round) to 1.
  var double lumpiness = 0.6,

  /// How quads face the camera.
  var ParticleBillboard billboard = ParticleBillboard.spherical,
  Vector3? axis,

  /// The number of columns of flipbook frames in the [texture].
  final int flipbookColumns = 1,

  /// The number of rows of flipbook frames in the [texture].
  final int flipbookRows = 1,
  int? frameCount,

  /// Whether the frames of a flipbook blend into each other as they play.
  var bool frameBlending = false,

  /// Fragments whose alpha is below this are discarded, for cut-out
  /// particles drawn with an opaque [renderState].
  var double alphaCutoff = 0,

  /// Clip-depth fade span (`> 0` smoothly fades particles near opaque scene
  /// geometry when `World3D.depthPrepassEnabled` is active).
  var double softDepthFade = 0,
  RenderState renderState = RenderState.premultipliedAlphaBlend,
}) extends Material {
  /// {@macro particle_material}
  this
    : assert(flipbookColumns > 0, 'flipbookColumns must be positive'),
      assert(flipbookRows > 0, 'flipbookRows must be positive'),
      assert(
        frameCount == null ||
            (frameCount > 0 && frameCount <= flipbookColumns * flipbookRows),
        'frameCount must be between 1 and flipbookColumns * flipbookRows',
      ),
      super(
        vertexShader: VertexShader.fromAsset(
          _bundle,
          slots: [RenderContext3D.cameraMatricesBlock, 'ParticleBillboard'],
        ),
        fragmentShader: FragmentShader.fromAsset(
          _bundle,
          slots: [
            'particleTexture',
            RenderContext3D.depthNormalSampler,
            RenderContext3D.depthNormalBlock,
            'ParticleLook',
          ],
        ),
      ) {
    if (kIsWeb) {
      throw UnsupportedError(
        'ParticleMaterial is not available on the web yet: it has no WebGPU '
        'shaders.',
      );
    }
    this.renderState = renderState;
  }

  static const _bundle =
      'packages/flame_3d/assets/shaders/particle_material.shaderbundle';

  /// What each quad shows: [ParticleSprite.texture] when a [texture] is
  /// given, [ParticleSprite.softCircle] otherwise, unless set.
  ParticleSprite sprite =
      sprite ??
      (texture == null ? ParticleSprite.softCircle : ParticleSprite.texture);

  /// The texture each quad is multiplied by, white by default.
  Texture texture = texture ?? Texture.standard;

  /// The axis of [ParticleBillboard.cylindrical] billboards, and the normal
  /// of the plane of [ParticleBillboard.flat] ones; `+y` by default.
  final Vector3 axis = axis?.clone() ?? Vector3(0, 1, 0);

  /// The number of flipbook frames in the [texture]: all the cells of the
  /// grid unless set.
  final int frameCount = frameCount ?? flipbookColumns * flipbookRows;

  /// Whether particles drawn with this material are blended in an order
  /// dependent way, so that the system sorts them back to front.
  bool get needsSorting => blendsInOrder(renderState);

  /// Whether draws with [state] blend in an order dependent way (alpha or
  /// premultiplied alpha blending), so that their particles are sorted back
  /// to front.
  static bool blendsInOrder(RenderState state) =>
      state.translucent &&
      (state.blend == BlendState.alpha ||
          state.blend == BlendState.premultipliedAlpha);

  final Vector3 _right = Vector3.zero();
  final Vector3 _up = Vector3.zero();
  final Vector3 _flatX = Vector3.zero();
  final Vector3 _flatY = Vector3.zero();
  final Vector3 _axis = Vector3.zero();
  final Vector4 _value = Vector4.zero();

  @override
  void apply(RenderContext context) {
    _writeBillboard(context as RenderContext3D);
    final blend = renderState.blend;
    final premultiplied =
        blend == BlendState.premultipliedAlpha || blend == BlendState.additive;
    fragmentShader
      ..setTexture('particleTexture', texture)
      ..setColor('ParticleLook.color', color)
      ..setVector4(
        'ParticleLook.shape',
        _value..setValues(
          sprite.index.toDouble(),
          softness,
          lumpiness,
          premultiplied ? 1 : 0,
        ),
      )
      ..setVector4(
        'ParticleLook.options',
        _value..setValues(
          alphaCutoff,
          frameBlending ? 1 : 0,
          softDepthFade,
          0,
        ),
      );
  }

  void _writeBillboard(RenderContext3D context) {
    final view = context.view.storage;
    final m = context.viewProjection.storage;
    // The camera's axes, from the rows of the view matrix, turned so that
    // they point right and up on screen even when the projection mirrors the
    // scene.
    final right = _right..setValues(view[0], view[4], view[8]);
    if (m[0] * right.x + m[4] * right.y + m[8] * right.z < 0) {
      right.negate();
    }
    final up = _up..setValues(view[1], view[5], view[9]);
    if (m[1] * up.x + m[5] * up.y + m[9] * up.z < 0) {
      up.negate();
    }
    final projection = context.projection.storage;
    final perspective =
        projection[3] != 0 || projection[7] != 0 || projection[11] != 0;
    final eye = context.cameraPosition;

    final axis = _axis..setFrom(this.axis);
    if (axis.length2 == 0) {
      axis.setValues(0, 1, 0);
    }
    axis.normalize();
    // The plane of flat billboards: x along the screen's right projected on
    // the plane when possible, so that a rotation of zero looks upright.
    final flatX = _flatX
      ..setFrom(right)
      ..addScaled(axis, -right.dot(axis));
    if (flatX.length2 < 1e-8) {
      flatX
        ..setFrom(up)
        ..addScaled(axis, -up.dot(axis));
    }
    flatX.normalize();
    final flatY = _flatY;
    axis.crossInto(flatX, flatY);
    // y should point away from the viewer on screen, as the top of a sprite
    // lying on the ground.
    if (flatY.dot(up) < 0) {
      flatY.negate();
    }

    final mode = billboard.index.toDouble();
    final frames = frameCount;
    vertexShader
      ..setVector4(
        'ParticleBillboard.right',
        _value..setValues(right.x, right.y, right.z, mode),
      )
      ..setVector4(
        'ParticleBillboard.up',
        _value..setValues(up.x, up.y, up.z, perspective ? 1 : 0),
      )
      ..setVector4(
        'ParticleBillboard.back',
        _value..setValues(view[2], view[6], view[10], 0),
      )
      ..setVector4(
        'ParticleBillboard.eye',
        _value..setValues(eye.x, eye.y, eye.z, 0),
      )
      ..setVector4(
        'ParticleBillboard.axis',
        _value..setValues(axis.x, axis.y, axis.z, 0),
      )
      ..setVector4(
        'ParticleBillboard.flatX',
        _value..setValues(flatX.x, flatX.y, flatX.z, 0),
      )
      ..setVector4(
        'ParticleBillboard.flatY',
        _value..setValues(flatY.x, flatY.y, flatY.z, 0),
      )
      ..setVector4(
        'ParticleBillboard.flipbook',
        _value..setValues(
          flipbookColumns.toDouble(),
          flipbookRows.toDouble(),
          math.max(frames, 1).toDouble(),
          frameBlending ? 1 : 0,
        ),
      );
  }
}
