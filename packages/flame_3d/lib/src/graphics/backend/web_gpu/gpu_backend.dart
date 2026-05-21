import 'dart:convert';
import 'dart:ui';
import 'dart:ui_web';

import 'package:flame_3d/src/graphics/backend/gpu_backend.dart' as base;
import 'package:flame_3d/src/graphics/backend/gpu_enums.dart';
import 'package:flame_3d/src/graphics/backend/gpu_handles.dart';
import 'package:flame_3d/src/graphics/backend/web_gpu/shader_bundle.dart';
import 'package:flame_3d/src/graphics/backend/web_gpu/web_gpu_interop.dart';
import 'package:flutter/services.dart';

/// {@template web_gpu_backend}
/// A [base.GpuBackend] implemented on browser WebGPU (`navigator.gpu`).
/// {@endtemplate}
base class GpuBackend extends base.GpuBackend {
  GpuBackend._(this._device, this._bundles)
    : _queue = _device.queue,
      _defaultSampler = _device.createSampler(
        GPUSamplerDescriptor(
          magFilter: 'linear',
          minFilter: 'linear',
          addressModeU: 'repeat',
          addressModeV: 'repeat',
        ),
      ),
      _zeroBuffer = _device.createBuffer(
        GPUBufferDescriptor(
          size: _maxUniformSize(_bundles),
          usage: GPUBufferUsage.uniform,
        ),
      ) {
    _defaultTexture = _solidTexture(0xFFFFFFFF);
    _frame = _WebGpuFrame(this);
  }

  /// {@macro web_gpu_backend}
  ///
  /// Throws [UnsupportedError] if WebGPU is unavailable in this browser.
  static Future<void> initialize() async {
    final gpu = webGPU;
    if (gpu == null) {
      throw UnsupportedError('WebGPU is not available in this browser.');
    }

    var adapter = await gpu.requestAdapter();
    adapter ??= await gpu.requestAdapter(
      GPURequestAdapterOptions(forceFallbackAdapter: true),
    );

    if (adapter == null) {
      throw UnsupportedError('No WebGPU adapter is available.');
    }

    final device = await adapter.requestDevice()
      ..addEventListener(
        'uncapturederror',
        (GPUUncapturedErrorEvent event) {
          final error = event.error;
          // ignore: avoid_print
          print('[WebGPU] uncaptured error: ${error.message}');
        },
      );

    GpuBackend._(device, await _loadShaderBundles());
  }

  /// Web has no synchronous backend: WebGPU device acquisition is async, so
  /// callers must `await initialize()` first. Returning `null` lets the base
  /// `GpuBackend.instance` surface that with a clear error.
  static GpuBackend? create() => null;

  /// Loads every `.wgslbundle` shader asset declared by the app.
  ///
  /// Bundles are discovered through [AssetManifest], so a game's own custom
  /// shaders are picked up automatically alongside flame_3d's built-ins.
  static Future<Map<String, WebShaderBundle>> _loadShaderBundles() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final bundles = <String, WebShaderBundle>{};
    for (final key in manifest.listAssets()) {
      if (key.endsWith('.wgslbundle')) {
        final source = await rootBundle.loadString(key);
        bundles[key] = WebShaderBundle.fromJson(
          jsonDecode(source) as Map<String, dynamic>,
        );
      }
    }
    return bundles;
  }

  final GPUDevice _device;

  final GPUQueue _queue;

  final Map<String, WebShaderBundle> _bundles;

  late final GPUSampler _defaultSampler;

  late final GPUTexture _defaultTexture;

  late final GPUTextureView _defaultTextureView = _defaultTexture.createView();

  late final GPUBuffer _zeroBuffer;

  late final _WebGpuFrame _frame;

  final Map<_PipelineKey, GPURenderPipeline> _pipelineCache = {};

  @override
  GpuTexture createTexture({
    required GpuStorageMode storageMode,
    required int width,
    required int height,
    required GpuPixelFormat format,
  }) {
    final texture = _device.createTexture(
      GPUTextureDescriptor(
        size: GPUExtent3D(width: width, height: height, depthOrArrayLayers: 1),
        format: _pixelFormat(format),
        usage: GPUTextureUsage.textureBinding | GPUTextureUsage.copyDst,
      ),
    );
    return _WebGpuSampledTexture(_queue, texture, width, height);
  }

  @override
  GpuBuffer createBuffer({
    required GpuStorageMode storageMode,
    required int sizeInBytes,
  }) {
    final buffer = _device.createBuffer(
      GPUBufferDescriptor(
        size: _align(sizeInBytes, 4),
        usage:
            GPUBufferUsage.vertex |
            GPUBufferUsage.index |
            GPUBufferUsage.copyDst,
      ),
    );
    return _WebGpuBuffer(_queue, buffer);
  }

  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) {
    final key = _wgslBundleKey(assetName);
    final bundle = _bundles[key];
    if (bundle == null) {
      throw StateError(
        'No web shader bundle found for "$assetName" (expected asset "$key"). '
        'Generate it with `dart run flame_3d:build_shaders --with-web-gpu` '
        'and declare it in pubspec.yaml.',
      );
    }
    return _WebGpuShaderLibrary(_device, bundle);
  }

  @override
  GpuPipeline createPipeline({
    required GpuShader vertexShader,
    required GpuShader fragmentShader,
  }) {
    return _WebGpuPipeline(
      vertexShader as _WebGpuShader,
      fragmentShader as _WebGpuShader,
    );
  }

  @override
  GpuRenderTarget createRenderTarget({
    required int width,
    required int height,
    required Color clearValue,
  }) {
    final canvas = OffscreenCanvas(width, height);
    final context = canvas.contextGPU()
      ..configure(
        GPUCanvasConfiguration(
          device: _device,
          format: _canvasFormat,
          usage: GPUTextureUsage.renderAttachment,
          alphaMode: 'premultiplied',
        ),
      );
    final depth = _device.createTexture(
      GPUTextureDescriptor(
        size: GPUExtent3D(width: width, height: height, depthOrArrayLayers: 1),
        format: _depthFormat,
        usage: GPUTextureUsage.renderAttachment,
      ),
    );
    return _WebGpuRenderTarget(canvas, context, depth, clearValue);
  }

  @override
  base.GpuFrame beginFrame() => _frame..begin();

  /// Resolves (and caches) the concrete [GPURenderPipeline] for [pipeline]
  /// under the given [blend], [depthStencil] and [cullMode] state.
  GPURenderPipeline _resolvePipeline(
    _WebGpuPipeline pipeline,
    BlendState blend,
    DepthStencilState depthStencil,
    CullMode cullMode,
  ) {
    return _pipelineCache.putIfAbsent(
      (pipeline, blend, depthStencil, cullMode),
      () => _device.createRenderPipeline(
        GPURenderPipelineDescriptor(
          layout: 'auto',
          vertex: GPUVertexState(
            module: pipeline.vertexModule,
            entryPoint: 'main',
            buffers: [_vertexBufferLayout],
          ),
          fragment: GPUFragmentState(
            module: pipeline.fragmentModule,
            entryPoint: 'main',
            targets: [_colorTarget(blend)],
          ),
          primitive: GPUPrimitiveState(
            topology: 'triangle-list',
            cullMode: _cullMode(cullMode),
            frontFace: 'ccw',
          ),
          depthStencil: GPUDepthStencilState(
            format: _depthFormat,
            depthWriteEnabled: depthStencil == DepthStencilState.standard,
            depthCompare: _depthCompare(depthStencil),
          ),
        ),
      ),
    );
  }

  GPUTexture _solidTexture(int argb) {
    final texture = _device.createTexture(
      GPUTextureDescriptor(
        size: GPUExtent3D(width: 1, height: 1, depthOrArrayLayers: 1),
        format: 'rgba8unorm',
        usage: GPUTextureUsage.textureBinding | GPUTextureUsage.copyDst,
      ),
    );
    final pixel = Uint8List.fromList([
      (argb >> 16) & 0xFF,
      (argb >> 8) & 0xFF,
      argb & 0xFF,
      (argb >> 24) & 0xFF,
    ]);
    _queue.writeTexture(
      GPUImageCopyTexture(texture: texture),
      pixel,
      GPUImageDataLayout(offset: 0, bytesPerRow: 4, rowsPerImage: 1),
      GPUExtent3D(width: 1, height: 1, depthOrArrayLayers: 1),
    );
    return texture;
  }

  /// The largest uniform block across [bundles].
  static int _maxUniformSize(Map<String, WebShaderBundle> bundles) {
    var max = _uniformAlignment;
    for (final bundle in bundles.values) {
      for (final slot in bundle.slots.values) {
        final size = slot.sizeInBytes;
        if (size != null && size > max) {
          max = size;
        }
      }
    }
    return _align(max, 4);
  }
}

/// The fixed vertex buffer layout, matching `Vertex.storage`.
final _vertexBufferLayout = GPUVertexBufferLayout(
  arrayStride: 80,
  stepMode: 'vertex',
  attributes: [
    GPUVertexAttribute(format: 'float32x3', offset: 0, shaderLocation: 0),
    GPUVertexAttribute(format: 'float32x2', offset: 12, shaderLocation: 1),
    GPUVertexAttribute(format: 'float32x4', offset: 20, shaderLocation: 2),
    GPUVertexAttribute(format: 'float32x3', offset: 36, shaderLocation: 3),
    GPUVertexAttribute(format: 'float32x4', offset: 48, shaderLocation: 4),
    GPUVertexAttribute(format: 'float32x4', offset: 64, shaderLocation: 5),
  ],
);

String _pixelFormat(GpuPixelFormat format) => switch (format) {
  GpuPixelFormat.rgba8888 => 'rgba8unorm',
  GpuPixelFormat.bgra8888 => 'bgra8unorm',
  GpuPixelFormat.rgbaFloat32 => 'rgba32float',
  GpuPixelFormat.depthStencil => _depthFormat,
};

String _cullMode(CullMode mode) => switch (mode) {
  CullMode.none => 'none',
  CullMode.frontFace => 'front',
  CullMode.backFace => 'back',
};

String _depthCompare(DepthStencilState state) => switch (state) {
  DepthStencilState.standard => 'less',
  DepthStencilState.depthRead => 'less-equal',
  DepthStencilState.none => 'always',
};

GPUColorTargetState _colorTarget(BlendState blend) {
  GPUBlendComponent component(String src, String dst) =>
      GPUBlendComponent(operation: 'add', srcFactor: src, dstFactor: dst);
  return switch (blend) {
    BlendState.opaque => GPUColorTargetState(format: _canvasFormat),
    BlendState.alphaBlend => GPUColorTargetState(
      format: _canvasFormat,
      blend: GPUBlendState(
        color: component('one', 'one-minus-src-alpha'),
        alpha: component('one', 'one-minus-src-alpha'),
      ),
    ),
    BlendState.additive => GPUColorTargetState(
      format: _canvasFormat,
      blend: GPUBlendState(
        color: component('one', 'one'),
        alpha: component('one', 'one'),
      ),
    ),
  };
}

/// Cache key for a concrete render pipeline variant.
typedef _PipelineKey = (
  _WebGpuPipeline,
  BlendState,
  DepthStencilState,
  CullMode,
);

class _WebGpuShaderLibrary implements GpuShaderLibrary {
  const _WebGpuShaderLibrary(this._device, this._bundle);

  final GPUDevice _device;

  final WebShaderBundle _bundle;

  @override
  GpuShader operator [](String entryPoint) => switch (entryPoint) {
    'TextureVertex' => _WebGpuShader(_device, _bundle.vertex, _bundle.slots),
    'TextureFragment' => _WebGpuShader(
      _device,
      _bundle.fragment,
      _bundle.slots,
    ),
    _ => throw StateError('Unknown shader entry point "$entryPoint".'),
  };
}

class _WebGpuShader implements GpuShader {
  _WebGpuShader(this._device, this._wgsl, this.slots);

  final GPUDevice _device;

  final String _wgsl;

  final Map<String, WebShaderSlot> slots;

  GPUShaderModule? _module;

  GPUShaderModule get module => _module ??= _device.createShaderModule(
    GPUShaderModuleDescriptor(code: _wgsl),
  );

  @override
  GpuUniformSlot getUniformSlot(String slot) {
    final reflected = slots[slot];
    if (reflected == null) {
      throw StateError('Shader has no uniform slot "$slot".');
    }
    return _WebGpuUniformSlot(reflected);
  }
}

class _WebGpuUniformSlot implements GpuUniformSlot {
  const _WebGpuUniformSlot(this.slot);

  final WebShaderSlot slot;

  @override
  int? get sizeInBytes => slot.sizeInBytes;

  @override
  int? getMemberOffsetInBytes(String member) => slot.memberOffsets[member];
}

class _WebGpuPipeline implements GpuPipeline {
  const _WebGpuPipeline(this._vertex, this._fragment);

  final _WebGpuShader _vertex;

  final _WebGpuShader _fragment;

  GPUShaderModule get vertexModule => _vertex.module;

  GPUShaderModule get fragmentModule => _fragment.module;

  Map<String, WebShaderSlot> get slots => _vertex.slots;
}

class _WebGpuBuffer implements GpuBuffer {
  const _WebGpuBuffer(this._queue, this.raw);

  final GPUQueue _queue;

  final GPUBuffer raw;

  @override
  void write(ByteData data, {int destinationOffsetInBytes = 0}) {
    _queue.writeBuffer(raw, destinationOffsetInBytes, _padded(data));
  }
}

class _WebGpuSampledTexture implements GpuTexture {
  const _WebGpuSampledTexture(this._queue, this.raw, this._width, this._height);

  final GPUQueue _queue;

  final GPUTexture raw;

  final int _width;

  final int _height;

  @override
  void write(ByteData data) {
    _queue.writeTexture(
      GPUImageCopyTexture(texture: raw),
      _padded(data),
      GPUImageDataLayout(
        offset: 0,
        bytesPerRow: _width * 4,
        rowsPerImage: _height,
      ),
      GPUExtent3D(width: _width, height: _height, depthOrArrayLayers: 1),
    );
  }

  @override
  Image asImage() =>
      throw UnsupportedError('A sampled texture cannot be read as an Image.');
}

class _WebGpuRenderTarget implements GpuRenderTarget {
  _WebGpuRenderTarget(
    this.canvas,
    this.context,
    this.depthTexture,
    Color clearValue,
  ) : clearColor = GPUColor(
        r: clearValue.r,
        g: clearValue.g,
        b: clearValue.b,
        a: clearValue.a,
      ),
      _colorTexture = _WebGpuColorTexture(
        canvas,
        canvas.width,
        canvas.height,
      );

  final OffscreenCanvas canvas;

  final GPUCanvasContext context;

  final GPUTexture depthTexture;

  final GPUColor clearColor;

  final _WebGpuColorTexture _colorTexture;

  @override
  GpuTexture get colorTexture => _colorTexture;
}

class _WebGpuColorTexture implements GpuTexture {
  _WebGpuColorTexture(this._canvas, int width, int height)
    : _blitCanvas = OffscreenCanvas(width, height);

  final OffscreenCanvas _canvas;

  final OffscreenCanvas _blitCanvas;

  late final CanvasContext2D _blit = _blitCanvas.context2D();

  /// A retained handle to the previous frame's image, kept alive until its
  /// composite has finished.
  Image? _retained;

  @override
  void write(ByteData data) =>
      throw UnsupportedError('A render-target texture cannot be written to.');

  @override
  Image asImage() {
    // Release last frame's retained handle: its `drawImageRect` has
    // composited by now, so the underlying `ImageBitmap` is no longer needed.
    _retained?.dispose();

    // Blit the WebGPU canvas onto a plain 2D canvas and snapshot it as an
    // `ImageBitmap`: a WebGPU-canvas bitmap crashes the CanvasKit compositor,
    // a 2D-canvas one composites cleanly.
    _blit.drawImage(_canvas, 0, 0);

    // Create the image from the bitmap, this is guaranteed to be fully
    // synchronous (and lazy).
    final bitmap = _blitCanvas.transferToImageBitmap();
    final image = createImageFromImageBitmap(bitmap) as Image;

    // We retain a clone of the image as `createImageFromImageBitmap` is lazy.
    // Once it has been recorded through `drawImageRect` we can dipose it.
    //
    // `clone` returns a ref-counted handle, so we are fully in control on when
    // it gets disposed.
    _retained = image.clone();

    // We return the old image and not the retained to guarantee the above.
    return image;
  }
}

class _WebGpuFrame implements base.GpuFrame {
  _WebGpuFrame(this._backend);

  final GpuBackend _backend;

  final List<List<GPUBuffer>> _uniformPools = [[], [], []];
  int _frameIndex = 0;

  // Allocation cursor into the current frame's pool.
  int _bufferIndex = 0;
  int _cursor = 0;

  /// Resets the transient uniform allocator for a new frame.
  void begin() {
    _bufferIndex = 0;
    _cursor = 0;
  }

  /// Sub-allocates [data] into this frame's uniform pool, returning the buffer
  /// it landed in and the (256-aligned) offset it was written at.
  ///
  /// The pool grows by a buffer whenever a frame's uniforms outgrow the
  /// current one, so there is no fixed per-frame uniform budget.
  (GPUBuffer, int) allocateUniform(ByteData data) {
    final stride = _align(data.lengthInBytes, _uniformAlignment);
    if (_cursor + stride > _uniformPoolSize) {
      _bufferIndex++;
      _cursor = 0;
    }

    final pool = _uniformPools[_frameIndex];
    if (_bufferIndex == pool.length) {
      pool.add(
        _backend._device.createBuffer(
          GPUBufferDescriptor(
            size: _uniformPoolSize,
            usage: GPUBufferUsage.uniform | GPUBufferUsage.copyDst,
          ),
        ),
      );
    }

    final buffer = pool[_bufferIndex];
    final offset = _cursor;
    _backend._queue.writeBuffer(buffer, offset, _padded(data));
    _cursor += stride;
    return (buffer, offset);
  }

  @override
  base.GpuRenderPass beginRenderPass(
    GpuRenderTarget target, {
    required BlendState blend,
    required DepthStencilState depthStencil,
  }) {
    final renderTarget = target as _WebGpuRenderTarget;
    final encoder = _backend._device.createCommandEncoder();
    final pass = encoder.beginRenderPass(
      GPURenderPassDescriptor(
        colorAttachments: [
          GPURenderPassColorAttachment(
            view: renderTarget.context.getCurrentTexture().createView(),
            clearValue: renderTarget.clearColor,
            loadOp: 'clear',
            storeOp: 'store',
          ),
        ],
        depthStencilAttachment: GPURenderPassDepthStencilAttachment(
          view: renderTarget.depthTexture.createView(),
          depthClearValue: 1,
          depthLoadOp: 'clear',
          depthStoreOp: 'store',
        ),
      ),
    );
    return _WebGpuRenderPass(
      _backend,
      this,
      blend,
      depthStencil,
      encoder,
      pass,
    );
  }

  @override
  void end() {
    _frameIndex = (_frameIndex + 1) % _uniformPools.length;
  }
}

class _WebGpuRenderPass implements base.GpuRenderPass {
  _WebGpuRenderPass(
    this._backend,
    this._frame,
    this._blend,
    this._depthStencil,
    this._encoder,
    this._pass,
  );

  final GpuBackend _backend;

  final _WebGpuFrame _frame;

  final BlendState _blend;

  final DepthStencilState _depthStencil;

  final GPUCommandEncoder _encoder;

  final GPURenderPassEncoder _pass;

  late _WebGpuPipeline _pipeline;

  late GPURenderPipeline _renderPipeline;

  int _indexCount = 0;

  // Bindings accumulated for the current draw, keyed by `_key(group, binding)`.
  final Map<int, (GPUBuffer buffer, int offset, int size)> _uniforms = {};
  final Map<int, GPUTextureView> _textures = {};

  static int _key(int group, int binding) => (group << 16) | binding;

  @override
  void bindPipeline(GpuPipeline pipeline, CullMode cullMode) {
    _pipeline = pipeline as _WebGpuPipeline;
    _renderPipeline = _backend._resolvePipeline(
      _pipeline,
      _blend,
      _depthStencil,
      cullMode,
    );
    _pass.setPipeline(_renderPipeline);
  }

  @override
  void bindVertexBuffer(GpuBufferView view, int vertexCount) {
    _pass.setVertexBuffer(
      0,
      (view.buffer as _WebGpuBuffer).raw,
      view.offsetInBytes,
      view.lengthInBytes,
    );
  }

  @override
  void bindIndexBuffer(
    GpuBufferView view,
    GpuIndexType indexType,
    int indexCount,
  ) {
    _pass.setIndexBuffer(
      (view.buffer as _WebGpuBuffer).raw,
      indexType == GpuIndexType.uint16 ? 'uint16' : 'uint32',
      view.offsetInBytes,
      view.lengthInBytes,
    );
    _indexCount = indexCount;
  }

  @override
  void bindUniform(GpuUniformSlot slot, ByteData data) {
    final reflected = (slot as _WebGpuUniformSlot).slot;
    final (buffer, offset) = _frame.allocateUniform(data);
    _uniforms[_key(reflected.group, reflected.binding)] = (
      buffer,
      offset,
      data.lengthInBytes,
    );
  }

  @override
  void bindTexture(
    covariant _WebGpuUniformSlot slot,
    covariant _WebGpuSampledTexture texture,
  ) {
    final reflected = slot.slot;
    _textures[_key(reflected.group, reflected.binding)] = texture.raw
        .createView();
  }

  @override
  void clearBindings() {
    _uniforms.clear();
    _textures.clear();
  }

  @override
  void draw() {
    final pipeline = _pipeline;
    final renderPipeline = _renderPipeline;

    final groups = <int, List<WebShaderSlot>>{};
    for (final slot in pipeline.slots.values) {
      groups.putIfAbsent(slot.group, () => []).add(slot);
    }

    for (final MapEntry(key: group, value: slots) in groups.entries) {
      final entries = <GPUBindGroupEntry>[];
      for (final slot in slots) {
        if (slot.sizeInBytes != null) {
          final bound = _uniforms[_key(slot.group, slot.binding)];
          entries.add(
            GPUBindGroupEntry(
              binding: slot.binding,
              resource: GPUBufferBinding(
                buffer: bound?.$1 ?? _backend._zeroBuffer,
                offset: bound?.$2 ?? 0,
                size: bound?.$3 ?? slot.sizeInBytes!,
              ),
            ),
          );
        } else {
          final view =
              _textures[_key(slot.group, slot.binding)] ??
              _backend._defaultTextureView;
          entries
            ..add(GPUBindGroupEntry(binding: slot.binding, resource: view))
            ..add(
              GPUBindGroupEntry(
                binding: slot.samplerBinding!,
                resource: _backend._defaultSampler,
              ),
            );
        }
      }
      _pass.setBindGroup(
        group,
        _backend._device.createBindGroup(
          GPUBindGroupDescriptor(
            layout: renderPipeline.getBindGroupLayout(group),
            entries: entries,
          ),
        ),
      );
    }

    _pass.drawIndexed(_indexCount);
  }

  @override
  void submit() {
    _pass.end();
    _backend._queue.submit([_encoder.finish()]);
  }
}

/// Returns [data] as a byte list, zero-padded to a multiple of 4 bytes.
Uint8List _padded(ByteData data) {
  final source = data.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );
  if (source.length % 4 == 0) {
    return source;
  }
  return Uint8List(_align(source.length, 4))
    ..setRange(0, source.length, source);
}

/// Color format of the render-target canvas and pipeline color targets.
const _canvasFormat = 'rgba8unorm';

/// Depth attachment format.
const _depthFormat = 'depth24plus';

/// Size, in bytes, of each per-frame uniform buffer.
const _uniformPoolSize = 1 << 20;

/// WebGPU minimum uniform buffer offset alignment.
const _uniformAlignment = 256;

int _align(int value, int alignment) =>
    ((value + alignment - 1) ~/ alignment) * alignment;

String _wgslBundleKey(String assetName) {
  if (assetName.endsWith('.wgslbundle')) {
    return assetName;
  }

  final dot = assetName.lastIndexOf('.');
  final stem = dot == -1 ? assetName : assetName.substring(0, dot);
  return '$stem.wgslbundle';
}
