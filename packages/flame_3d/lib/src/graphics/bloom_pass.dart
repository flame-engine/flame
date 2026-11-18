import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color, Image, Size;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:meta/meta.dart';

/// Runs soft-knee bright-pass extraction, multi-pass Kawase blur, and unified
/// single-pass composition for [BloomSettings] and [PostProcessSettings] inside
/// an open [GraphicsDevice] frame.
@internal
class BloomPass(final GraphicsDevice _device) {
  static const String _prefilterBundle =
      'packages/flame_3d/assets/shaders/bloom_prefilter.shaderbundle';
  static const String _blurBundle =
      'packages/flame_3d/assets/shaders/bloom_blur.shaderbundle';
  static const String _compositeBundle =
      'packages/flame_3d/assets/shaders/bloom_composite.shaderbundle';

  static final Surface _fullscreenQuad = Surface.fromBuffers(
    vertices: Float32List.fromList(const [
      -1.0, -1.0, 0.0, //
      1.0, -1.0, 0.0, //
      1.0, 1.0, 0.0, //
      -1.0, 1.0, 0.0, //
    ]),
    indices: Uint16List.fromList(const [0, 1, 2, 0, 2, 3]),
    layout: VertexLayout(const [
      VertexAttribute(VertexLayout.positionAttribute, 3),
    ]),
  );

  static const RenderState _fullscreenState = RenderState(
    depthTest: false,
    depthWrite: false,
  );

  late final Shader _prefilterVert = VertexShader.fromAsset(_prefilterBundle);
  late final Shader _prefilterFrag = FragmentShader.fromAsset(
    _prefilterBundle,
    slots: const ['BloomPrefilter', 'sourceTexture'],
  );

  late final Shader _blurVert = VertexShader.fromAsset(_blurBundle);
  late final Shader _blurFrag = FragmentShader.fromAsset(
    _blurBundle,
    slots: const ['BloomBlur', 'sourceTexture'],
  );

  late final Shader _compositeVert = VertexShader.fromAsset(_compositeBundle);
  late final Shader _compositeFrag = FragmentShader.fromAsset(
    _compositeBundle,
    slots: const [
      'BloomComposite',
      'sceneTexture',
      'bloomTexture',
      'depthNormalTexture',
    ],
  );

  final Vector4 _curve = Vector4.zero();
  final Vector4 _texel = Vector4.zero();
  final Vector4 _offset = Vector4.zero();
  final Vector4 _params = Vector4.zero();
  final Vector4 _grading = Vector4.zero();
  final Vector4 _tint = Vector4.zero();
  final Vector4 _ssao = Vector4.zero();
  final Vector4 _dof = Vector4.zero();

  /// Applies optional [bloom] and optional [postProcess] to [sceneTarget]
  /// (into which the 3D scene pass has just ended via `endTexturePass`),
  /// writing the composited [Image] into [outputTarget] (when given) or a
  /// pooled render target of the same size.
  Image applyFromTarget(
    GpuTextureTarget sceneTarget,
    BloomSettings? bloom, {
    PostProcessSettings? postProcess,
    Texture? depthNormalTexture,
    GpuRenderTarget? outputTarget,
  }) {
    final fullWidth = sceneTarget.width;
    final fullHeight = sceneTarget.height;
    final sceneTexture = Texture(
      null,
      width: fullWidth,
      height: fullHeight,
      sampler: TextureSampler.linear,
      gpuTexture: sceneTarget.texture,
    );

    Texture bloomReadTex = Texture.empty;
    final runBloom = bloom != null && bloom.intensity > 0 && bloom.radius > 0;

    if (runBloom) {
      final halfWidth = math.max(1, fullWidth >> 1);
      final halfHeight = math.max(1, fullHeight >> 1);

      final ping = _device.textureTarget(
        halfWidth,
        halfHeight,
        GpuPixelFormat.rgba8888,
        clearValue: const Color(0x00000002),
      );
      final pong = _device.textureTarget(
        halfWidth,
        halfHeight,
        GpuPixelFormat.rgba8888,
        clearValue: const Color(0x00000003),
      );

      final pingTex = Texture(
        null,
        width: halfWidth,
        height: halfHeight,
        sampler: TextureSampler.linear,
        gpuTexture: ping.texture,
      );
      final pongTex = Texture(
        null,
        width: halfWidth,
        height: halfHeight,
        sampler: TextureSampler.linear,
        gpuTexture: pong.texture,
      );

      final threshold = math.max(0.0, bloom.threshold);
      final knee = threshold * bloom.softKnee.clamp(0.0, 1.0) + 1e-4;
      _curve.setValues(threshold, threshold - knee, 2.0 * knee, 0.25 / knee);
      _texel.setValues(1.0 / fullWidth, 1.0 / fullHeight, 0, 0);
      _prefilterFrag
        ..setTexture('sourceTexture', sceneTexture)
        ..setVector4('BloomPrefilter.curve', _curve)
        ..setVector4('BloomPrefilter.texel', _texel);

      _device.beginTexturePass(ping);
      _drawQuad(_prefilterVert, _prefilterFrag);
      _device.endTexturePass();

      var readTex = pingTex;
      var writeTarget = pong;
      for (var i = 0; i < bloom.passes; i++) {
        final spread = (i + 0.5) * bloom.radius;
        _offset.setValues(spread / halfWidth, spread / halfHeight, 0, 0);
        _blurFrag
          ..setTexture('sourceTexture', readTex)
          ..setVector4('BloomBlur.offset', _offset);
        _device.beginTexturePass(writeTarget);
        _drawQuad(_blurVert, _blurFrag);
        _device.endTexturePass();

        if (identical(writeTarget, pong)) {
          readTex = pongTex;
          writeTarget = ping;
        } else {
          readTex = pingTex;
          writeTarget = pong;
        }
      }
      bloomReadTex = readTex;
    }

    final bloomIntensity = runBloom ? bloom.intensity : 0.0;
    final exposure = postProcess?.exposure ?? 1.0;
    final contrast = postProcess?.contrast ?? 1.0;
    final saturation = postProcess?.saturation ?? 1.0;
    final toneMap = (postProcess?.toneMap ?? ToneMapMode.none).index.toDouble();
    final vigIntensity = postProcess?.vignetteIntensity ?? 0.0;
    final vigSmooth = postProcess?.vignetteSmoothness ?? 0.5;
    final fxaa = (postProcess?.fxaa ?? false) ? 1.0 : 0.0;
    final c = postProcess?.tint ?? const Color(0xFFFFFFFF);

    final ssaoIntensity = postProcess?.ssaoIntensity ?? 0.0;
    final ssaoRadius = postProcess?.ssaoRadius ?? 1.5;
    final dofBlur = postProcess?.dofBlurStrength ?? 0.0;
    final dofFocus = postProcess?.dofFocusDepth ?? 0.5;
    final dofRange = postProcess?.dofFocusRange ?? 0.15;
    final hasDn = depthNormalTexture != null ? 1.0 : 0.0;

    _params.setValues(bloomIntensity, exposure, contrast, saturation);
    _grading.setValues(toneMap, vigIntensity, vigSmooth, fxaa);
    _tint.setValues(c.r, c.g, c.b, 1.0);
    _texel.setValues(1.0 / fullWidth, 1.0 / fullHeight, 0, 0);
    _ssao.setValues(ssaoIntensity, ssaoRadius, hasDn, 0);
    _dof.setValues(dofBlur, dofFocus, dofRange, 0);

    _compositeFrag
      ..setTexture('sceneTexture', sceneTexture)
      ..setTexture('bloomTexture', bloomReadTex)
      ..setTexture('depthNormalTexture', depthNormalTexture ?? Texture.standard)
      ..setVector4('BloomComposite.params', _params)
      ..setVector4('BloomComposite.grading', _grading)
      ..setVector4('BloomComposite.tint', _tint)
      ..setVector4('BloomComposite.texel', _texel)
      ..setVector4('BloomComposite.ssao', _ssao)
      ..setVector4('BloomComposite.dof', _dof);

    if (outputTarget != null) {
      _device.beginOwnedPass(outputTarget);
    } else {
      _device.beginPass(Size(fullWidth.toDouble(), fullHeight.toDouble()));
    }
    _drawQuad(_compositeVert, _compositeFrag);
    return _device.endPass();
  }

  void _drawQuad(Shader vert, Shader frag) {
    vert.resource;
    frag.resource;
    final pipeline = _device.pipelineFor(vert, frag, _fullscreenQuad.layout);
    _device
      ..bindPipeline(pipeline)
      ..setRenderState(_fullscreenState);
    for (final slotName in frag.slots) {
      final slot = frag.slot(slotName);
      if (slot.sizeInBytes == null) {
        _device.bindTexture(slot, frag.texture(slotName) ?? Texture.standard);
      } else {
        _device.bindUniformBlock(frag.block(slotName));
      }
    }
    _device
      ..bindSurface(_fullscreenQuad)
      ..drawSurface(_fullscreenQuad);
  }
}
