import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/backend/gpu_backend.dart';
import 'package:flame_3d/src/graphics/backend/gpu_enums.dart';
import 'package:flame_3d/src/graphics/backend/gpu_handles.dart';

/// {@template graphics_device}
/// The [GraphicsDevice] provides a way for developers to interact with the GPU
/// by binding different resources to it.
///
/// A frame starts with [begin] and ends with [end]. Within a frame, one or more
/// render passes can be created with [beginPass]/[endPass], each producing an
/// [Image].
/// {@endtemplate}
class GraphicsDevice {
  /// {@macro graphics_device}
  GraphicsDevice({
    this.clearValue = const Color(0x00000000),
    GpuBackend? backend,
  }) : backend = backend ?? GpuBackend.instance;

  /// The GPU backend this device records its rendering commands through.
  final GpuBackend backend;

  /// The clear value, used to clear out the screen.
  final Color clearValue;

  /// Blend state applied to each render pass.
  BlendState blendState = BlendState.alphaBlend;

  /// Depth/stencil state applied to each render pass.
  DepthStencilState depthStencilState = DepthStencilState.standard;

  late GpuFrame _frame;
  late GpuRenderPass _renderPass;
  late GpuRenderTarget _renderTarget;

  // Render target pool: keyed by (width, height), each entry is a list of
  // targets. _poolIndex tracks how many have been handed out this frame.
  final _pool = <(int, int), List<GpuRenderTarget>>{};
  final _poolIndex = <(int, int), int>{};

  /// Begin a new frame.
  ///
  /// Starts the frame whose transient storage is shared across all render
  /// passes. Call [end] when the frame is complete.
  void begin() {
    // Reset the pool indices, each existing target becomes available again.
    _poolIndex.updateAll((_, __) => 0);
    _frame = backend.beginFrame();
  }

  /// End the frame.
  void end() {
    _frame.end();

    // Ensure stale render targets are removed from the pool by checking
    // how many targets were actually used in the last render.
    _pool.removeWhere((key, targets) {
      final used = _poolIndex[key] ?? 0;
      if (used == 0) {
        _poolIndex.remove(key);
        return true;
      }
      if (used < targets.length) {
        targets.removeRange(used, targets.length);
      }
      return false;
    });
  }

  /// Begin a render pass at the given [size].
  ///
  /// Uses the current [blendState] and [depthStencilState]. After [beginPass]
  /// is called, resources can be bound. Call [endPass] to finalize the pass
  /// and obtain the rendered [Image].
  ///
  /// The graphics device can be used to bind resources like [Mesh]s,
  /// [Material]s and [Texture]s. Once you have executed all your bindings you
  /// can submit the batch to the GPU with [endPass].
  void beginPass(Size size) {
    _renderTarget = _acquireRenderTarget(size);
    _renderPass = _frame.beginRenderPass(
      _renderTarget,
      blend: blendState,
      depthStencil: depthStencilState,
    );
  }

  /// Submit the render pass to the GPU and return the rendered [Image].
  Image endPass() {
    _renderPass.submit();
    return _renderTarget.colorTexture.asImage();
  }

  /// Clear all resources bound to the current render pass.
  void clearBindings() {
    _renderPass.clearBindings();
  }

  /// Bind a render [pipeline] with the given [cullMode].
  void bindPipeline(GpuPipeline pipeline, CullMode cullMode) {
    _renderPass.bindPipeline(pipeline, cullMode);
  }

  /// Bind a [surface]'s geometry (vertex/index buffers) and draw.
  void bindGeometry(Surface surface) {
    _renderPass
      ..bindVertexBuffer(
        GpuBufferView(
          surface.resource,
          offsetInBytes: 0,
          lengthInBytes: surface.verticesBytes,
        ),
        surface.vertexCount,
      )
      ..bindIndexBuffer(
        GpuBufferView(
          surface.resource,
          offsetInBytes: surface.verticesBytes,
          lengthInBytes: surface.indicesBytes,
        ),
        GpuIndexType.uint16,
        surface.indexCount,
      )
      ..draw();
  }

  /// Bind a uniform [slot] to the data in [buffer].
  void bindUniform(GpuUniformSlot slot, ByteBuffer buffer) {
    _renderPass.bindUniform(slot, buffer.asByteData());
  }

  /// Bind a uniform [slot] to the [texture].
  void bindTexture(GpuUniformSlot slot, Texture texture) {
    _renderPass.bindTexture(slot, texture.resource);
  }

  /// Acquire a render target from the pool, creating one if needed.
  ///
  /// Multiple passes at the same size within a frame get distinct targets.
  /// Targets are reused across frames.
  GpuRenderTarget _acquireRenderTarget(Size size) {
    final key = (size.width.toInt(), size.height.toInt());
    final targets = _pool.putIfAbsent(key, () => []);
    final index = _poolIndex.putIfAbsent(key, () => 0);

    if (index < targets.length) {
      _poolIndex[key] = index + 1;
      return targets[index];
    }

    // Pool exhausted for this size — create a new target.
    final target = backend.createRenderTarget(
      width: key.$1,
      height: key.$2,
      clearValue: clearValue,
    );

    targets.add(target);
    _poolIndex[key] = index + 1;
    return target;
  }
}
