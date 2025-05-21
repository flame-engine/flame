import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/joints_info.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

enum BlendState {
  additive,
  alphaBlend,
  opaque,
}

enum DepthStencilState {
  standard,
  depthRead,
  none,
}

/// {@template graphics_device}
/// The Graphical Device provides a way for developers to interact with the GPU
/// by binding different resources to it.
///
/// A single render call starts with a call to [begin] and only ends when [end]
/// is called. Any resource that gets bound to the device in between these two
/// method calls will be uploaded to the GPU and returns as an [Image] in [end].
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

  late gpu.CommandBuffer _commandBuffer;
  late gpu.HostBuffer _hostBuffer;
  late gpu.RenderPass _renderPass;
  late gpu.RenderTarget _renderTarget;

  Matrix4 get model => _modelMatrix;
  final Matrix4 _modelMatrix = Matrix4.zero();

  Matrix4 get view => _viewMatrix;
  final Matrix4 _viewMatrix = Matrix4.zero();

  Matrix4 get projection => _projectionMatrix;
  final Matrix4 _projectionMatrix = Matrix4.zero();

  Size _previousSize = Size.zero;

  /// Must be set by the rendering pipeline before elements are bound.
  /// Can be accessed by elements in their bind method.
  final JointsInfo jointsInfo = JointsInfo();

  /// Must be set by the rendering pipeline before elements are bound.
  /// Can be accessed by elements in their bind method.
  final LightingInfo lightingInfo = LightingInfo();

  /// Begin a new rendering batch.
  ///
  /// After [begin] is called the graphics device can be used to bind resources
  /// like [Mesh]s, [Material]s and [Texture]s.
  ///
  /// Once you have executed all your bindings you can submit the batch to the
  /// GPU with [end].
  void begin(
    Size size, {
    // TODO(wolfenrain): unused at the moment
    BlendState blendState = BlendState.alphaBlend,
    // TODO(wolfenrain): used incorrectly
    DepthStencilState depthStencilState = DepthStencilState.depthRead,
  }) {
    _commandBuffer = _gpuContext.createCommandBuffer();
    _hostBuffer = _gpuContext.createHostBuffer();

    _renderPass = _commandBuffer.createRenderPass(_getRenderTarget(size))
      ..setColorBlendEnable(true)
      ..setColorBlendEquation(
        gpu.ColorBlendEquation(
          sourceAlphaBlendFactor: blendState == BlendState.alphaBlend
              ? gpu.BlendFactor.oneMinusSourceAlpha
              : gpu.BlendFactor.one,
        ),
      )
      ..setDepthWriteEnable(depthStencilState == DepthStencilState.depthRead)
      ..setDepthCompareOperation(
        switch (depthStencilState) {
          DepthStencilState.none => gpu.CompareFunction.never,
          DepthStencilState.standard => gpu.CompareFunction.lessEqual,
          DepthStencilState.depthRead => gpu.CompareFunction.less,
        },
      );
  }

  /// Submit the rendering batch and it's the commands to the GPU and return
  /// the result.
  Image end() {
    _commandBuffer.submit();
    return _renderTarget.colorAttachments[0].texture.asImage();
  }

  void clearBindings() {
    _renderPass.clearBindings();
  }

  /// Bind a [mesh].
  void bindMesh(Mesh mesh) {
    mesh.bind(this);
  }

  /// Bind a [surface].
  void bindSurface(Surface surface) {
    _renderPass.clearBindings();
    if (surface.material != null) {
      bindMaterial(surface.material!);
    }

    _renderPass.bindVertexBuffer(
      gpu.BufferView(
        surface.resource!,
        offsetInBytes: 0,
        lengthInBytes: surface.verticesBytes,
      ),
      surface.vertexCount,
    );

    _renderPass.bindIndexBuffer(
      gpu.BufferView(
        surface.resource!,
        offsetInBytes: surface.verticesBytes,
        lengthInBytes: surface.indicesBytes,
      ),
      gpu.IndexType.int16,
      surface.indexCount,
    );

    _renderPass.draw();
  }

  /// Bind a [material] and set up the buffer correctly.
  void bindMaterial(Material material) {
    _renderPass.bindPipeline(material.resource);

    material.bind(this);
    material.vertexShader.bind(this);
    material.fragmentShader.bind(this);
  }

  /// Bind a uniform [slot] to the [buffer].
  void bindUniform(gpu.UniformSlot slot, ByteBuffer buffer) {
    _renderPass.bindUniform(slot, _hostBuffer.emplace(buffer.asByteData()));
  }

  /// Bind a uniform [slot] to the [texture].
  void bindTexture(gpu.UniformSlot slot, Texture texture) {
    _renderPass.bindTexture(slot, texture.resource);
  }

  gpu.RenderTarget _getRenderTarget(Size size) {
    if (_previousSize != size) {
      _previousSize = size;

      final colorTexture = _gpuContext.createTexture(
        gpu.StorageMode.devicePrivate,
        size.width.toInt(),
        size.height.toInt(),
      );

      final depthTexture = _gpuContext.createTexture(
        gpu.StorageMode.deviceTransient,
        size.width.toInt(),
        size.height.toInt(),
        format: _gpuContext.defaultDepthStencilFormat,
      );

      _renderTarget = gpu.RenderTarget.singleColor(
        gpu.ColorAttachment(
          texture: colorTexture,
          clearValue: Vector4Utils.fromColor(clearValue),
        ),
        depthStencilAttachment: gpu.DepthStencilAttachment(
          texture: depthTexture,
          depthClearValue: 1.0,
        ),
      );
    }

    return _renderTarget;
  }
}
