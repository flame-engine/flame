// ignore_for_file: avoid_redundant_argument_values

import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/gpu_context_wrapper.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// Color blending mode for the render pass output.
enum BlendState {
  /// No blending, source overwrites destination.
  opaque,

  /// Standard premultiplied-alpha blending:
  /// `color = src * 1 + dst * (1 - srcAlpha)`
  alphaBlend,

  /// Additive blending: `color = src * 1 + dst * 1`.
  additive,
}

/// Depth buffer behavior for the render pass.
enum DepthStencilState {
  /// Depth test and write enabled (normal opaque 3D rendering).
  /// Fragments closer than the stored depth pass and update the buffer.
  standard,

  /// Depth test enabled, write disabled (transparent objects).
  /// Fragments are tested against existing depth but don't update it.
  depthRead,

  /// No depth testing, all fragments pass regardless of depth.
  none,
}

/// Face culling mode. Controls which triangle faces are discarded before
/// rasterization.
///
/// Assign to [Material.cullMode] to control per-material culling.
enum CullMode {
  /// No culling, both front and back faces are rendered.
  none,

  /// Cull front-facing triangles (render only back faces).
  frontFace,

  /// Cull back-facing triangles (render only front faces).
  backFace,
}

/// {@template graphics_device}
/// The Graphical Device provides a way for developers to interact with the GPU
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
    gpu.GpuContext? gpuContext,
  }) : _gpuContext = gpuContext ?? gpu.gpuContext;

  final gpu.GpuContext _gpuContext;

  /// The clear value, used to clear out the screen.
  final Color clearValue;

  /// Blend state applied to each render pass.
  BlendState blendState = BlendState.alphaBlend;

  /// Depth/stencil state applied to each render pass.
  DepthStencilState depthStencilState = DepthStencilState.depthRead;

  late final gpu.HostBuffer _hostBuffer = _gpuContext.createHostBuffer();
  late gpu.CommandBuffer _commandBuffer;

  late gpu.RenderPass _renderPass;
  late gpu.RenderTarget _renderTarget;

  // Render target pool: keyed by (width, height), each entry is a list of
  // targets. _poolIndex tracks how many have been handed out this frame.
  final _pool = <(int, int), List<gpu.RenderTarget>>{};
  final _poolIndex = <(int, int), int>{};

  /// Begin a new frame.
  ///
  /// Creates the host buffer shared across all render passes this frame.
  /// Call [end] when the frame is complete.
  void begin() {
    // Reset the pool indices, each existing target becomes available again.
    _poolIndex.updateAll((_, __) => 0);
  }

  /// End the frame.
  void end() {
    _hostBuffer.reset();

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
  ///
  /// After [begin] is called the graphics device can be used to bind resources
  /// like [Mesh]s, [Material]s and [Texture]s.
  ///
  /// Once you have executed all your bindings you can submit the batch to the
  /// GPU with [end].
  void beginPass(Size size) {
    _commandBuffer = _gpuContext.createCommandBuffer();
    _renderTarget = _acquireRenderTarget(size);
    _renderPass = _commandBuffer.createRenderPass(_renderTarget)
      ..setWindingOrder(gpu.WindingOrder.counterClockwise)
      ..setColorBlendEnable(blendState != BlendState.opaque)
      ..setColorBlendEquation(
        switch (blendState) {
          BlendState.opaque => gpu.ColorBlendEquation(
            sourceColorBlendFactor: gpu.BlendFactor.one,
            destinationColorBlendFactor: gpu.BlendFactor.zero,
            sourceAlphaBlendFactor: gpu.BlendFactor.one,
            destinationAlphaBlendFactor: gpu.BlendFactor.zero,
          ),
          BlendState.alphaBlend => gpu.ColorBlendEquation(
            sourceColorBlendFactor: gpu.BlendFactor.one,
            destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
            sourceAlphaBlendFactor: gpu.BlendFactor.one,
            destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
          ),
          BlendState.additive => gpu.ColorBlendEquation(
            sourceColorBlendFactor: gpu.BlendFactor.one,
            destinationColorBlendFactor: gpu.BlendFactor.one,
            sourceAlphaBlendFactor: gpu.BlendFactor.one,
            destinationAlphaBlendFactor: gpu.BlendFactor.one,
          ),
        },
      )
      ..setDepthWriteEnable(depthStencilState == DepthStencilState.standard)
      ..setDepthCompareOperation(
        switch (depthStencilState) {
          DepthStencilState.standard => gpu.CompareFunction.less,
          DepthStencilState.depthRead => gpu.CompareFunction.lessEqual,
          DepthStencilState.none => gpu.CompareFunction.always,
        },
      );
  }

  /// Submit the render pass to the GPU and return the rendered [Image].
  Image endPass() {
    _commandBuffer.submit();
    return _renderTarget.colorAttachments[0].texture.asImage();
  }

  void clearBindings() {
    _renderPass.clearBindings();
  }

  /// Bind a render [pipeline] with the given [cullMode].
  void bindPipeline(gpu.RenderPipeline pipeline, CullMode cullMode) {
    _renderPass
      ..bindPipeline(pipeline)
      ..setCullMode(gpu.CullMode.values[cullMode.index]);
  }

  /// Bind a [surface]'s geometry (vertex/index buffers) and draw.
  void bindGeometry(Surface surface) {
    _renderPass.bindVertexBuffer(
      gpu.BufferView(
        surface.resource,
        offsetInBytes: 0,
        lengthInBytes: surface.verticesBytes,
      ),
      surface.vertexCount,
    );

    _renderPass.bindIndexBuffer(
      gpu.BufferView(
        surface.resource,
        offsetInBytes: surface.verticesBytes,
        lengthInBytes: surface.indicesBytes,
      ),
      gpu.IndexType.int16,
      surface.indexCount,
    );

    _renderPass.draw();
  }

  /// Bind a uniform [slot] to the [buffer].
  void bindUniform(gpu.UniformSlot slot, ByteBuffer buffer) {
    _renderPass.bindUniform(slot, _hostBuffer.emplace(buffer.asByteData()));
  }

  /// Bind a uniform [slot] to the [texture].
  void bindTexture(gpu.UniformSlot slot, Texture texture) {
    _renderPass.bindTexture(slot, texture.resource);
  }

  /// Acquire a render target from the pool, creating one if needed.
  ///
  /// Multiple passes at the same size within a frame get distinct targets.
  /// Targets are reused across frames.
  gpu.RenderTarget _acquireRenderTarget(Size size) {
    final key = (size.width.toInt(), size.height.toInt());
    final targets = _pool.putIfAbsent(key, () => []);
    final index = _poolIndex.putIfAbsent(key, () => 0);

    if (index < targets.length) {
      _poolIndex[key] = index + 1;
      return targets[index];
    }

    // Pool exhausted for this size — create a new target.
    final gpuContext = GpuContextWrapper(_gpuContext);
    final colorTexture = gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      key.$1,
      key.$2,
    );

    final depthTexture = gpuContext.createTexture(
      gpu.StorageMode.deviceTransient,
      key.$1,
      key.$2,
      format: _gpuContext.defaultDepthStencilFormat,
    );

    final target = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(
        texture: colorTexture,
        clearValue: Vector4Utils.fromColor(clearValue),
      ),
      depthStencilAttachment: gpu.DepthStencilAttachment(
        texture: depthTexture,
        depthClearValue: 1.0,
      ),
    );

    targets.add(target);
    _poolIndex[key] = index + 1;
    return target;
  }
}
