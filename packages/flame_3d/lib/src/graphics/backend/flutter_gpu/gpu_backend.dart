// ignore_for_file: avoid_redundant_argument_values

import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/src/graphics/backend/gpu_backend.dart' as base;
import 'package:flame_3d/src/graphics/backend/gpu_enums.dart';
import 'package:flame_3d/src/graphics/backend/gpu_handles.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// A [base.GpuBackend] implemented on top of `flutter_gpu`.
base class GpuBackend extends base.GpuBackend {
  static Future<void> initialize() => Future.syncValue(create() as Null);

  static GpuBackend? create() => GpuBackend();

  /// Creates a backend wrapping [gpuContext], defaulting to the global
  /// `flutter_gpu` context.
  GpuBackend({gpu.GpuContext? gpuContext})
    : _context = gpuContext ?? gpu.gpuContext;

  final gpu.GpuContext _context;

  late final gpu.HostBuffer _hostBuffer = _context.createHostBuffer();
  late final _FlutterGpuFrame _frame = _FlutterGpuFrame(this);

  @override
  GpuTexture createTexture({
    required GpuStorageMode storageMode,
    required int width,
    required int height,
    required GpuPixelFormat format,
  }) {
    return _FlutterGpuTexture(
      _context.createTexture(
        _storageMode(storageMode),
        width,
        height,
        format: _pixelFormat(format),
      ),
    );
  }

  @override
  GpuBuffer createBuffer({
    required GpuStorageMode storageMode,
    required int sizeInBytes,
  }) {
    return _FlutterGpuBuffer(
      _context.createDeviceBuffer(_storageMode(storageMode), sizeInBytes),
    );
  }

  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) {
    final library = gpu.ShaderLibrary.fromAsset(assetName);
    if (library == null) {
      throw StateError('Failed to load shader library "$assetName"');
    }
    return _FlutterGpuShaderLibrary(library, assetName);
  }

  @override
  GpuPipeline createPipeline({
    required GpuShader vertexShader,
    required GpuShader fragmentShader,
  }) {
    return _FlutterGpuPipeline(
      _context.createRenderPipeline(
        (vertexShader as _FlutterGpuShader).raw,
        (fragmentShader as _FlutterGpuShader).raw,
      ),
    );
  }

  @override
  GpuRenderTarget createRenderTarget({
    required int width,
    required int height,
    required Color clearValue,
  }) {
    final colorTexture = _FlutterGpuTexture(
      _context.createTexture(
        gpu.StorageMode.devicePrivate,
        width,
        height,
        format: gpu.PixelFormat.r8g8b8a8UNormInt,
      ),
    );
    final depthTexture = _context.createTexture(
      gpu.StorageMode.deviceTransient,
      width,
      height,
      format: _context.defaultDepthStencilFormat,
    );
    return _FlutterGpuRenderTarget(
      colorTexture,
      gpu.RenderTarget.singleColor(
        gpu.ColorAttachment(
          texture: colorTexture.raw,
          clearValue: Vector4Utils.fromColor(clearValue),
        ),
        depthStencilAttachment: gpu.DepthStencilAttachment(
          texture: depthTexture,
          depthClearValue: 1.0,
        ),
      ),
    );
  }

  @override
  base.GpuFrame beginFrame() => _frame;

  gpu.PixelFormat _pixelFormat(GpuPixelFormat format) {
    return switch (format) {
      GpuPixelFormat.rgba8888 => gpu.PixelFormat.r8g8b8a8UNormInt,
      GpuPixelFormat.bgra8888 => gpu.PixelFormat.b8g8r8a8UNormInt,
      GpuPixelFormat.rgbaFloat32 => gpu.PixelFormat.r32g32b32a32Float,
      GpuPixelFormat.depthStencil => _context.defaultDepthStencilFormat,
    };
  }

  static gpu.StorageMode _storageMode(GpuStorageMode mode) {
    return switch (mode) {
      GpuStorageMode.hostVisible => gpu.StorageMode.hostVisible,
      GpuStorageMode.devicePrivate => gpu.StorageMode.devicePrivate,
      GpuStorageMode.deviceTransient => gpu.StorageMode.deviceTransient,
    };
  }
}

class _FlutterGpuTexture implements GpuTexture {
  const _FlutterGpuTexture(this.raw);

  final gpu.Texture raw;

  @override
  void write(ByteData data) => raw.overwrite(data);

  @override
  Image asImage() => raw.asImage();
}

class _FlutterGpuBuffer implements GpuBuffer {
  const _FlutterGpuBuffer(this.raw);

  final gpu.DeviceBuffer raw;

  @override
  void write(ByteData data, {int destinationOffsetInBytes = 0}) {
    raw.overwrite(data, destinationOffsetInBytes: destinationOffsetInBytes);
  }
}

class _FlutterGpuShaderLibrary implements GpuShaderLibrary {
  const _FlutterGpuShaderLibrary(this.raw, this._assetName);

  final gpu.ShaderLibrary raw;

  final String _assetName;

  @override
  GpuShader operator [](String entryPoint) {
    final shader = raw[entryPoint];
    if (shader == null) {
      throw StateError(
        'Shader "$entryPoint" not found in library "$_assetName"',
      );
    }
    return _FlutterGpuShader(shader);
  }
}

class _FlutterGpuShader implements GpuShader {
  const _FlutterGpuShader(this.raw);

  final gpu.Shader raw;

  @override
  GpuUniformSlot getUniformSlot(String slot) {
    return _FlutterGpuUniformSlot(raw.getUniformSlot(slot));
  }
}

class _FlutterGpuUniformSlot implements GpuUniformSlot {
  const _FlutterGpuUniformSlot(this.raw);

  final gpu.UniformSlot raw;

  @override
  int? get sizeInBytes => raw.sizeInBytes;

  @override
  int? getMemberOffsetInBytes(String member) {
    return raw.getMemberOffsetInBytes(member);
  }
}

class _FlutterGpuPipeline implements GpuPipeline {
  const _FlutterGpuPipeline(this.raw);

  final gpu.RenderPipeline raw;
}

class _FlutterGpuRenderTarget implements GpuRenderTarget {
  const _FlutterGpuRenderTarget(this._colorTexture, this.raw);

  final _FlutterGpuTexture _colorTexture;

  final gpu.RenderTarget raw;

  @override
  GpuTexture get colorTexture => _colorTexture;
}

class _FlutterGpuFrame implements base.GpuFrame {
  const _FlutterGpuFrame(this._backend);

  final GpuBackend _backend;

  @override
  base.GpuRenderPass beginRenderPass(
    GpuRenderTarget target, {
    required BlendState blend,
    required DepthStencilState depthStencil,
  }) {
    final commandBuffer = _backend._context.createCommandBuffer();
    final renderPass =
        commandBuffer.createRenderPass((target as _FlutterGpuRenderTarget).raw)
          ..setWindingOrder(gpu.WindingOrder.counterClockwise)
          ..setColorBlendEnable(blend != BlendState.opaque)
          ..setColorBlendEquation(_blendEquation(blend))
          ..setDepthWriteEnable(depthStencil == DepthStencilState.standard)
          ..setDepthCompareOperation(_depthCompare(depthStencil));
    return _FlutterGpuRenderPass(_backend, commandBuffer, renderPass);
  }

  @override
  void end() => _backend._hostBuffer.reset();

  static gpu.ColorBlendEquation _blendEquation(BlendState blend) {
    return switch (blend) {
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
    };
  }

  static gpu.CompareFunction _depthCompare(DepthStencilState state) {
    return switch (state) {
      DepthStencilState.standard => gpu.CompareFunction.less,
      DepthStencilState.depthRead => gpu.CompareFunction.lessEqual,
      DepthStencilState.none => gpu.CompareFunction.always,
    };
  }
}

class _FlutterGpuRenderPass implements base.GpuRenderPass {
  const _FlutterGpuRenderPass(
    this._backend,
    this._commandBuffer,
    this._renderPass,
  );

  final GpuBackend _backend;

  final gpu.CommandBuffer _commandBuffer;

  final gpu.RenderPass _renderPass;

  @override
  void bindPipeline(GpuPipeline pipeline, CullMode cullMode) {
    _renderPass
      ..bindPipeline((pipeline as _FlutterGpuPipeline).raw)
      ..setCullMode(gpu.CullMode.values[cullMode.index]);
  }

  @override
  void bindVertexBuffer(GpuBufferView view, int vertexCount) {
    _renderPass.bindVertexBuffer(_bufferView(view), vertexCount);
  }

  @override
  void bindIndexBuffer(
    GpuBufferView view,
    GpuIndexType indexType,
    int indexCount,
  ) {
    _renderPass.bindIndexBuffer(
      _bufferView(view),
      switch (indexType) {
        GpuIndexType.uint16 => gpu.IndexType.int16,
        GpuIndexType.uint32 => gpu.IndexType.int32,
      },
      indexCount,
    );
  }

  @override
  void bindUniform(GpuUniformSlot slot, ByteData data) {
    _renderPass.bindUniform(
      (slot as _FlutterGpuUniformSlot).raw,
      _backend._hostBuffer.emplace(data),
    );
  }

  @override
  void bindTexture(GpuUniformSlot slot, GpuTexture texture) {
    _renderPass.bindTexture(
      (slot as _FlutterGpuUniformSlot).raw,
      (texture as _FlutterGpuTexture).raw,
    );
  }

  @override
  void clearBindings() => _renderPass.clearBindings();

  @override
  void draw() => _renderPass.draw();

  @override
  void submit() => _commandBuffer.submit();

  static gpu.BufferView _bufferView(GpuBufferView view) {
    return gpu.BufferView(
      (view.buffer as _FlutterGpuBuffer).raw,
      offsetInBytes: view.offsetInBytes,
      lengthInBytes: view.lengthInBytes,
    );
  }
}
