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
///
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
    _hostBuffer = gpu.HostBuffer();
    _renderPass = _commandBuffer.createRenderPass(_getRenderTarget(size))
      ..setColorBlendEnable(true)
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

  /// Bind a [mesh] and apply the [mvp] to transform it relative to the known
  /// transform matrix.
  void bindMesh(Mesh mesh, Matrix4 mvp) {
    _renderPass.clearBindings();
    bindMaterial(mesh.material, _transformMatrix.multiplied(mvp));
    bindGeometry(mesh.geometry);
    mesh.bind(this);
    _renderPass.draw();
  }

  /// Bind a [material] and set up the buffer correctly.
  void bindMaterial(Material material, Matrix4 mvp) {
    _renderPass.bindPipeline(material.resource);
    bindUniform(material.vertexShader, 'mvp', mvp.storage.buffer.asByteData());
    material.bind(this);
  }

  /// Bind a [geometry] and set up the vertices correctly.
  void bindGeometry(Geometry geometry) {
    geometry.bind(_renderPass);
  }

  /// Bind a uniform slot of [name] with the [data] on the [shader].
  void bindUniform(gpu.Shader shader, String name, ByteData data) {
    _renderPass.bindUniform(
      shader.getUniformSlot(name)!,
      _hostBuffer.emplace(data),
    );
  }

  void bindTexture(gpu.Shader shader, String name, Texture texture) {
    _renderPass.bindTexture(shader.getUniformSlot(name)!, texture.resource);
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
