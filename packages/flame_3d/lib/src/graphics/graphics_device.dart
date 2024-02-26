import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
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
/// is called. Anything that gets binded to the device in between will be
/// uploaded to the GPU and returns as an [Image] in [end].
/// {@endtemplate}
class GraphicsDevice {
  /// {@macro graphics_device}
  GraphicsDevice({this.clearValue = const Color(0x00000000)});

  /// The clear value, used to clear out the screen.
  final Color clearValue;

  late gpu.CommandBuffer _commandBuffer;
  late gpu.HostBuffer _hostBuffer;
  late gpu.RenderPass _renderPass;
  late gpu.RenderTarget _renderTarget;
  final _transformMatrix = Matrix4.identity();
  final _viewModelMatrix = Matrix4.identity();

  Size _previousSize = Size.zero;

  /// Begin a new rendering batch.
  ///
  /// After [begin] is called the graphics device can be used to bind resources
  /// like [Mesh]s, [Material]s and [Texture]s.
  ///
  /// Once you have executed all your bindings you can submit the batch to the
  /// GPU with [end].
  void begin(
    Size size, {
    // TODO(wolfen): unused at the moment
    BlendState blendState = BlendState.alphaBlend,
    // TODO(wolfen): used incorrectly
    DepthStencilState depthStencilState = DepthStencilState.depthRead,
    Matrix4? transformMatrix,
  }) {
    _commandBuffer = gpu.gpuContext.createCommandBuffer();
    _hostBuffer = gpu.gpuContext.createHostBuffer();
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
        // TODO(wolfen): this is not correctly implemented AT all.
        switch (depthStencilState) {
          DepthStencilState.none => gpu.CompareFunction.never,
          DepthStencilState.standard => gpu.CompareFunction.always,
          DepthStencilState.depthRead => gpu.CompareFunction.less,
        },
      );
    _transformMatrix.setFrom(transformMatrix ?? Matrix4.identity());
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

  void setViewModel(Matrix4 mvp) => _viewModelMatrix.setFrom(mvp);

  /// Bind a [mesh].
  void bindMesh(Mesh mesh) {
    _renderPass.clearBindings();
    mesh.bind(this);
    _renderPass.draw();
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
    material.vertexBuffer
      ..clear()
      ..addMatrix4(_transformMatrix.multiplied(_viewModelMatrix));
    material.fragmentBuffer.clear();
    material.bind(this);
  }

  /// Bind a [shader] with the given [buffer].
  void bindShader(gpu.Shader shader, ShaderBuffer buffer) {
    bindUniform(
      shader,
      buffer.slot,
      buffer.bytes.asByteData(),
    );
  }

  /// Bind a uniform slot of [name] with the [data] on the [shader].
  void bindUniform(gpu.Shader shader, String name, ByteData data) {
    _renderPass.bindUniform(
      shader.getUniformSlot(name),
      _hostBuffer.emplace(data),
    );
  }

  void bindTexture(gpu.Shader shader, String name, Texture texture) {
    _renderPass.bindTexture(shader.getUniformSlot(name), texture.resource);
  }

  gpu.RenderTarget _getRenderTarget(Size size) {
    if (_previousSize != size) {
      _previousSize = size;

      final colorTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.devicePrivate,
        size.width.toInt(),
        size.height.toInt(),
      );

      final depthTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.deviceTransient,
        size.width.toInt(),
        size.height.toInt(),
        format: gpu.gpuContext.defaultDepthStencilFormat,
      );

      _renderTarget = gpu.RenderTarget.singleColor(
        gpu.ColorAttachment(texture: colorTexture!, clearValue: clearValue),
        depthStencilAttachment: gpu.DepthStencilAttachment(
          texture: depthTexture!,
          depthClearValue: 1.0,
        ),
      );
    }

    return _renderTarget;
  }
}
