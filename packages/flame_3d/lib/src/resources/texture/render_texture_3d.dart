import 'dart:math' as math;
import 'dart:ui' show Canvas, Color, PictureRecorder;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/embedding/embedded_renderer.dart';

/// {@template render_texture_3d}
/// Live offscreen GPU render-to-texture resource backed by a
/// [GpuTextureTarget].
///
/// Unlike [World3D.renderToImage], [RenderTexture3D] keeps the rendered output
/// on the GPU as a sampleable [texture] with **zero CPU readback** and **zero
/// `dart:ui.Image` round-trips**, making it ideal for live 3D security
/// monitors, portals, rear-view mirrors, and planar floor reflections.
/// {@endtemplate}
class RenderTexture3D({
  int width = 512,
  int height = 512,
  var Color clearValue = const Color(0xFF000000),
  TextureSampler sampler = TextureSampler.linear,
}) {
  /// {@macro render_texture_3d}
  this {
    _resizeIfNeeded(width, height, sampler);
  }

  int _width = 0;
  int _height = 0;
  GpuTextureTarget? _target;
  Texture? _texture;
  int _renderCount = 0;
  bool _isRendering = false;

  /// Width of the backing GPU texture, in pixels.
  int get width => _width;

  /// Height of the backing GPU texture, in pixels.
  int get height => _height;

  /// Number of offscreen passes rendered into this texture.
  int get renderCount => _renderCount;

  /// Sampleable [Texture] handle bindable on any [Material] (`albedoTexture`,
  /// `emissiveTexture`, etc.).
  Texture get texture => _texture!;

  /// Resizes the offscreen target on the next [renderWorld] call.
  void resize(int width, int height) {
    _resizeIfNeeded(width, height, _texture?.sampler ?? TextureSampler.linear);
  }

  void _resizeIfNeeded(int w, int h, TextureSampler sampler) {
    final clampedW = math.max(1, w);
    final clampedH = math.max(1, h);
    if (clampedW == _width && clampedH == _height && _texture != null) {
      return;
    }
    _width = clampedW;
    _height = clampedH;
    _target = null;
    _texture = Texture.standard;
    _pendingSampler = sampler;
  }

  TextureSampler _pendingSampler = TextureSampler.linear;

  void _ensureTarget(GraphicsDevice device) {
    if (_target != null) {
      return;
    }
    final owned = device.backend.createTextureTarget(
      width: _width,
      height: _height,
      format: GpuPixelFormat.rgba8888,
      clearValue: clearValue,
    );
    _target = owned;
    _texture = Texture(
      null,
      width: _width,
      height: _height,
      sampler: _pendingSampler,
      gpuTexture: owned.texture,
    );
  }

  /// Renders [world] from [view] and [projection] (filtering by [cameraMask])
  /// directly into this GPU [texture].
  ///
  /// Includes a re-entrancy guard so a mesh inside [world] displaying this
  /// [texture] never triggers infinite recursion during its own capture pass.
  bool renderWorld(
    World3D world, {
    required Matrix4 view,
    required Matrix4 projection,
    int cameraMask = 0xFFFFFFFF,
    bool renderShadows = false,
    GraphicsDevice? device,
    RenderContext3D? context,
  }) {
    if (_isRendering) {
      return false;
    }
    GraphicsDevice resolvedDevice;
    RenderContext3D resolvedContext;
    var closeFrame = false;
    var closeEmbedded = false;

    if (device != null && context != null) {
      resolvedDevice = device;
      resolvedContext = context;
    } else {
      final game = world.findGame();
      if (game case final Game3D g3d) {
        resolvedDevice = g3d.device;
        resolvedContext = g3d.context;
        if (!g3d.isRenderingFrame) {
          resolvedDevice.begin();
          closeFrame = true;
        }
      } else {
        final embedded = EmbeddedRenderer.of(game ?? world);
        resolvedDevice = embedded.device;
        resolvedContext = embedded.context;
        closeEmbedded = embedded.open();
      }
    }

    if (!resolvedDevice.backend.supportsTextureTargets) {
      if (closeFrame) {
        resolvedDevice.end();
      } else if (closeEmbedded) {
        EmbeddedRenderer.of(world.findGame() ?? world).close();
      }
      return false;
    }

    _ensureTarget(resolvedDevice);
    final target = _target!;
    final recorder = PictureRecorder();
    final dummyCanvas = Canvas(recorder);

    final savedView = resolvedContext.view.clone();
    final savedProj = resolvedContext.projection.clone();
    final savedMask = resolvedContext.cameraMask;

    _isRendering = true;
    try {
      resolvedContext
        ..cameraMask = cameraMask
        ..setCamera(view, projection);
      if (renderShadows) {
        world.renderShadows(dummyCanvas, overrideContext: resolvedContext);
      }
      resolvedDevice.beginTexturePass(
        target,
        frontFace: resolvedContext.frontFace,
      );
      world.renderScene(dummyCanvas, overrideContext: resolvedContext);
      resolvedContext.flush();
      resolvedDevice.endTexturePass();
      _renderCount++;
      return true;
    } finally {
      _isRendering = false;
      resolvedContext
        ..cameraMask = savedMask
        ..setCamera(savedView, savedProj);
      recorder.endRecording().dispose();
      if (closeFrame) {
        resolvedDevice.end();
      } else if (closeEmbedded) {
        EmbeddedRenderer.of(world.findGame() ?? world).close();
      }
    }
  }

  /// Releases the underlying GPU texture resource.
  void dispose() {
    _texture?.dispose();
    _target = null;
  }
}
