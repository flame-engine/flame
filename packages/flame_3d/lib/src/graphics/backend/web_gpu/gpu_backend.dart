import 'dart:convert';
import 'dart:ui';
import 'dart:ui_web';

import 'package:flame_3d/src/graphics/backend/gpu_backend.dart' as base;
import 'package:flame_3d/src/graphics/backend/gpu_enums.dart';
import 'package:flame_3d/src/graphics/backend/gpu_handles.dart';
import 'package:flame_3d/src/graphics/backend/web_gpu/shader_bundle.dart';
import 'package:flame_3d/src/graphics/backend/web_gpu/web_gpu_interop.dart';
import 'package:flame_3d/src/resources/texture/texture_sampler.dart';
import 'package:flutter/services.dart';

/// {@template web_gpu_backend}
/// A [base.GpuBackend] implemented on browser WebGPU (`navigator.gpu`).
/// {@endtemplate}
base class GpuBackend._(
  final GPUDevice _device,
  final Map<String, WebShaderBundle> _bundles,
) extends base.GpuBackend {
  this
    : _zeroBuffer = _device.createBuffer(
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

  /// Whether the browser exposes WebGPU.
  static bool get isAvailable => webGPU != null;

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

  final GPUQueue _queue = _device.queue;

  late final GPUSampler _defaultSampler = _samplerFor(TextureSampler.nearest);

  // The sampler of every distinct sampler value, by key, created once.
  final List<GPUSampler?> _samplers = List.filled(
    TextureSampler.keyCount,
    null,
  );

  /// The sampler object for [sampler], created on first use.
  GPUSampler _samplerFor(TextureSampler sampler) {
    return _samplers[sampler.key] ??= _device.createSampler(
      GPUSamplerDescriptor(
        magFilter: sampler.magFilter.name,
        minFilter: sampler.minFilter.name,
        mipmapFilter: sampler.mipFilter.name,
        addressModeU: _addressMode(sampler.wrapU),
        addressModeV: _addressMode(sampler.wrapV),
      ),
    );
  }

  static String _addressMode(TextureWrap wrap) => switch (wrap) {
    TextureWrap.clamp => 'clamp-to-edge',
    TextureWrap.repeat => 'repeat',
    TextureWrap.mirror => 'mirror-repeat',
  };

  late final GPUTexture _defaultTexture;

  late final GPUTextureView _defaultTextureView = _defaultTexture.createView();

  late final GPUBuffer _zeroBuffer;

  late final _WebGpuFrame _frame;

  final Map<_PipelineKey, GPURenderPipeline> _pipelineCache = {};

  final Map<String, _WebGpuShaderLibrary> _libraries = {};

  @override
  int get uniformAlignment => _uniformAlignment;

  @override
  GpuTexture createTexture({
    required GpuStorageMode storageMode,
    required int width,
    required int height,
    required GpuPixelFormat format,
    int mipLevelCount = 1,
  }) {
    final texture = _device.createTexture(
      GPUTextureDescriptor(
        size: GPUExtent3D(width: width, height: height, depthOrArrayLayers: 1),
        format: _pixelFormat(format),
        usage: GPUTextureUsage.textureBinding | GPUTextureUsage.copyDst,
        mipLevelCount: mipLevelCount,
      ),
    );
    return _WebGpuSampledTexture(
      _queue,
      texture,
      width,
      height,
      mipLevelCount,
      _bytesPerPixel(format),
    );
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
            GPUBufferUsage.uniform |
            GPUBufferUsage.copyDst,
      ),
    );
    return _WebGpuBuffer(_queue, buffer, sizeInBytes);
  }

  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) {
    final key = _wgslBundleKey(assetName);
    final unprefixed = _wgslBundleKey(_withoutPackagePrefix(assetName));
    final bundle = _bundles[key] ?? _bundles[unprefixed];
    if (bundle == null) {
      throw StateError(
        'No web shader bundle found for "$assetName" (expected asset "$key"). '
        'Generate it with `dart run flame_3d:build_shaders --with-web-gpu` '
        'and declare it in pubspec.yaml.',
      );
    }
    return _libraries[_bundles.containsKey(key) ? key : unprefixed] ??=
        _WebGpuShaderLibrary(_device, bundle);
  }

  @override
  Future<void> registerShaderLibrary(String assetName, ByteData bytes) async {
    final key = _wgslBundleKey(assetName);
    _bundles[key] = WebShaderBundle.fromJson(
      jsonDecode(
        utf8.decode(
          bytes.buffer.asUint8List(
            bytes.offsetInBytes,
            bytes.lengthInBytes,
          ),
        ),
      ) as Map<String, dynamic>,
    );
    _libraries.remove(key);
  }

  @override
  GpuPipeline createPipeline({
    required GpuShader vertexShader,
    required GpuShader fragmentShader,
    GpuVertexLayout? vertexLayout,
  }) {
    return _WebGpuPipeline(
      vertexShader as _WebGpuShader,
      fragmentShader as _WebGpuShader,
      vertexLayout == null
          ? [_standardVertexBufferLayout]
          : [
              for (final buffer in vertexLayout.buffers)
                GPUVertexBufferLayout(
                  arrayStride: buffer.strideInBytes,
                  stepMode: buffer.perInstance ? 'instance' : 'vertex',
                  attributes: [
                    for (final attribute in buffer.attributes)
                      GPUVertexAttribute(
                        format: _vertexFormat(attribute.components),
                        offset: attribute.offsetInBytes,
                        shaderLocation: attribute.location,
                      ),
                  ],
                ),
            ],
    );
  }

  @override
  GpuRenderTarget createRenderTarget({
    required int width,
    required int height,
    required Color clearValue,
    int msaaSampleCount = 1,
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
    return _WebGpuRenderTarget(
      width,
      height,
      canvas,
      context,
      depth,
      clearValue,
    );
  }

  @override
  base.GpuFrame beginFrame() => _frame;

  /// Resolves (and caches) the concrete [GPURenderPipeline] for [pipeline]
  /// under the given render state.
  GPURenderPipeline _resolvePipeline(_WebGpuPipeline pipeline, int state) {
    return _pipelineCache.putIfAbsent(
      (pipeline, state),
      () => _device.createRenderPipeline(
        GPURenderPipelineDescriptor(
          layout: 'auto',
          vertex: GPUVertexState(
            module: pipeline.vertexModule,
            entryPoint: 'main',
            buffers: pipeline.vertexBuffers,
          ),
          fragment: GPUFragmentState(
            module: pipeline.fragmentModule,
            entryPoint: 'main',
            targets: [_colorTarget(_StateKey.blend(state))],
          ),
          primitive: GPUPrimitiveState(
            topology: 'triangle-list',
            cullMode: _cullMode(_StateKey.cullMode(state)),
            frontFace: _StateKey.windingOrder(state) == WindingOrder.clockwise
                ? 'cw'
                : 'ccw',
          ),
          depthStencil: GPUDepthStencilState(
            format: _depthFormat,
            depthWriteEnabled: _StateKey.depthWrite(state),
            depthCompare: _depthCompare(_StateKey.depthCompare(state)),
          ),
        ),
      ),
    );
  }

  static String _withoutPackagePrefix(String assetName) {
    if (!assetName.startsWith('packages/')) {
      return assetName;
    }
    final packageEnd = assetName.indexOf('/', 'packages/'.length);
    return packageEnd < 0 ? assetName : assetName.substring(packageEnd + 1);
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

/// The standard vertex buffer layout, matching `Vertex.storage`.
final _standardVertexBufferLayout = GPUVertexBufferLayout(
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

int _bytesPerPixel(GpuPixelFormat format) => switch (format) {
  GpuPixelFormat.rgbaFloat32 => 16,
  _ => 4,
};

String _pixelFormat(GpuPixelFormat format) => switch (format) {
  GpuPixelFormat.rgba8888 => 'rgba8unorm',
  GpuPixelFormat.bgra8888 => 'bgra8unorm',
  GpuPixelFormat.rgbaFloat32 => 'rgba32float',
  GpuPixelFormat.r32Float => 'r32float',
  GpuPixelFormat.depthStencil => _depthFormat,
};

String _cullMode(CullMode mode) => switch (mode) {
  CullMode.none => 'none',
  CullMode.frontFace => 'front',
  CullMode.backFace => 'back',
};

String _depthCompare(CompareFunction compare) => switch (compare) {
  CompareFunction.never => 'never',
  CompareFunction.less => 'less',
  CompareFunction.equal => 'equal',
  CompareFunction.lessEqual => 'less-equal',
  CompareFunction.greater => 'greater',
  CompareFunction.notEqual => 'not-equal',
  CompareFunction.greaterEqual => 'greater-equal',
  CompareFunction.always => 'always',
};

String _vertexFormat(int components) => switch (components) {
  1 => 'float32',
  2 => 'float32x2',
  3 => 'float32x3',
  4 => 'float32x4',
  _ => throw ArgumentError.value(components, 'components', 'Must be 1 to 4'),
};

GPUColorTargetState _colorTarget(BlendState blend) {
  GPUBlendComponent component(String src, String dst) =>
      GPUBlendComponent(operation: 'add', srcFactor: src, dstFactor: dst);
  return switch (blend) {
    BlendState.opaque => GPUColorTargetState(format: _canvasFormat),
    BlendState.alpha => GPUColorTargetState(
      format: _canvasFormat,
      blend: GPUBlendState(
        color: component('src-alpha', 'one-minus-src-alpha'),
        alpha: component('one', 'one-minus-src-alpha'),
      ),
    ),
    BlendState.premultipliedAlpha => GPUColorTargetState(
      format: _canvasFormat,
      blend: GPUBlendState(
        color: component('one', 'one-minus-src-alpha'),
        alpha: component('one', 'one-minus-src-alpha'),
      ),
    ),
    // Added light covers nothing: the alpha of the target is kept.
    BlendState.additive => GPUColorTargetState(
      format: _canvasFormat,
      blend: GPUBlendState(
        color: component('one', 'one'),
        alpha: component('zero', 'one'),
      ),
    ),
    // Depth only: the target keeps its color and alpha.
    BlendState.depthOnly => GPUColorTargetState(
      format: _canvasFormat,
      blend: GPUBlendState(
        color: component('zero', 'one'),
        alpha: component('zero', 'one'),
      ),
    ),
  };
}

/// Cache key for a concrete render pipeline variant: the pipeline and its
/// render state packed by [_StateKey].
typedef _PipelineKey = (_WebGpuPipeline, int);

/// Packs the render state of a draw into one integer.
abstract final class _StateKey() {
  static int pack({
    required BlendState blend,
    required CompareFunction depthCompare,
    required bool depthWrite,
    required CullMode cullMode,
    required WindingOrder windingOrder,
  }) {
    return blend.index |
        depthCompare.index << 4 |
        (depthWrite ? 1 : 0) << 8 |
        cullMode.index << 9 |
        windingOrder.index << 12;
  }

  static BlendState blend(int key) => BlendState.values[key & 0xF];

  static CompareFunction depthCompare(int key) =>
      CompareFunction.values[(key >> 4) & 0xF];

  static bool depthWrite(int key) => (key >> 8) & 1 == 1;

  static CullMode cullMode(int key) => CullMode.values[(key >> 9) & 0x7];

  static WindingOrder windingOrder(int key) =>
      WindingOrder.values[(key >> 12) & 0x1];
}

class _WebGpuShaderLibrary(
  final GPUDevice _device,
  final WebShaderBundle _bundle,
) implements GpuShaderLibrary {
  late final _WebGpuShader _vertex = _WebGpuShader(
    _device,
    _bundle.vertex,
    _bundle.slots,
    _bundle.inputs == null
        ? null
        : [
            for (final input in _bundle.inputs!)
              GpuShaderInput(
                name: input.name,
                location: input.location,
                components: input.components,
              ),
          ],
  );

  late final _WebGpuShader _fragment = _WebGpuShader(
    _device,
    _bundle.fragment,
    _bundle.slots,
    const [],
  );

  @override
  GpuShader operator [](String entryPoint) => switch (entryPoint) {
    'TextureVertex' => _vertex,
    'TextureFragment' => _fragment,
    _ => throw StateError('Unknown shader entry point "$entryPoint".'),
  };
}

class _WebGpuShader(
  final GPUDevice _device,
  final String _wgsl,
  final Map<String, WebShaderSlot> slots,
  @override final List<GpuShaderInput>? inputs,
) implements GpuShader {
  GPUShaderModule? _module;

  GPUShaderModule get module => _module ??= _device.createShaderModule(
    GPUShaderModuleDescriptor(code: _wgsl),
  );

  final Map<String, _WebGpuUniformSlot> _slots = {};

  @override
  GpuUniformSlot getUniformSlot(String slot) {
    return _slots.putIfAbsent(slot, () {
      final reflected = slots[slot];
      if (reflected == null) {
        throw StateError('Shader has no uniform slot "$slot".');
      }
      return _WebGpuUniformSlot(slot, reflected);
    });
  }
}

class const _WebGpuUniformSlot(
  @override final String name,
  final WebShaderSlot slot,
) implements GpuUniformSlot {
  @override
  int? get sizeInBytes => slot.sizeInBytes;

  @override
  int? getMemberOffsetInBytes(String member) => slot.memberOffsets[member];
}

class _WebGpuPipeline(
  final _WebGpuShader _vertex,
  final _WebGpuShader _fragment,
  final List<GPUVertexBufferLayout> vertexBuffers,
) implements GpuPipeline {
  GPUShaderModule get vertexModule => _vertex.module;

  GPUShaderModule get fragmentModule => _fragment.module;

  Map<String, WebShaderSlot> get slots => _vertex.slots;

  /// The slots of the pipeline grouped by bind group, computed once.
  late final Map<int, List<WebShaderSlot>> groups = () {
    final groups = <int, List<WebShaderSlot>>{};
    for (final slot in slots.values) {
      groups.putIfAbsent(slot.group, () => []).add(slot);
    }
    return groups;
  }();
}

class const _WebGpuBuffer(
  final GPUQueue _queue,
  final GPUBuffer raw,
  @override final int sizeInBytes,
) implements GpuBuffer {
  @override
  void write(ByteData data, {int destinationOffsetInBytes = 0}) {
    _queue.writeBuffer(raw, destinationOffsetInBytes, _padded(data));
  }
}

class _WebGpuSampledTexture(
  final GPUQueue _queue,
  final GPUTexture raw,
  final int _width,
  final int _height,
  @override final int mipLevelCount,
  final int _bytesPerPixel,
) implements GpuTexture {
  /// The view bound to shaders, created once.
  late final GPUTextureView view = raw.createView();

  @override
  void write(ByteData data, {int mipLevel = 0}) {
    final width = _width >> mipLevel < 1 ? 1 : _width >> mipLevel;
    final height = _height >> mipLevel < 1 ? 1 : _height >> mipLevel;
    _queue.writeTexture(
      GPUImageCopyTexture(texture: raw, mipLevel: mipLevel),
      _padded(data),
      GPUImageDataLayout(
        offset: 0,
        bytesPerRow: width * _bytesPerPixel,
        rowsPerImage: height,
      ),
      GPUExtent3D(width: width, height: height, depthOrArrayLayers: 1),
    );
  }

  @override
  Image asImage() =>
      throw UnsupportedError('A sampled texture cannot be read as an Image.');
}

class _WebGpuRenderTarget(
  @override final int width,
  @override final int height,
  final OffscreenCanvas canvas,
  final GPUCanvasContext context,
  final GPUTexture depthTexture,
  Color clearValue,
) implements GpuRenderTarget {
  final GPUColor clearColor = GPUColor(
    r: clearValue.r,
    g: clearValue.g,
    b: clearValue.b,
    a: clearValue.a,
  );

  final _WebGpuColorTexture colorTexture = _WebGpuColorTexture(
    canvas,
    canvas.width,
    canvas.height,
  );
}

class _WebGpuColorTexture(final OffscreenCanvas _canvas, int width, int height)
    implements GpuTexture {
  final OffscreenCanvas _blitCanvas = OffscreenCanvas(width, height);

  late final CanvasContext2D _blit = _blitCanvas.context2D();

  /// A retained handle to the previous frame's image, kept alive until its
  /// composite has finished.
  Image? _retained;

  @override
  int get mipLevelCount => 1;

  @override
  void write(ByteData data, {int mipLevel = 0}) =>
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
    // Once it has been recorded through `drawImageRect` we can dispose it.
    //
    // `clone` returns a ref-counted handle, so we are fully in control on when
    // it gets disposed.
    _retained = image.clone();

    // We return the old image and not the retained to guarantee the above.
    return image;
  }
}

class const _WebGpuFrame(final GpuBackend _backend) implements base.GpuFrame {
  @override
  base.GpuRenderPass beginRenderPass(GpuRenderTarget target) {
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
    return _WebGpuRenderPass(_backend, renderTarget, encoder, pass);
  }

  @override
  void end() {}
}

class _WebGpuRenderPass(
  final GpuBackend _backend,
  final _WebGpuRenderTarget _target,
  final GPUCommandEncoder _encoder,
  final GPURenderPassEncoder _pass,
) implements base.GpuRenderPass {
  _WebGpuPipeline? _pipeline;

  GPURenderPipeline? _renderPipeline;

  // The render state, see `GpuFrame.beginRenderPass` for the defaults.
  BlendState _blend = BlendState.opaque;
  CompareFunction _depthCompare = CompareFunction.less;
  bool _depthWrite = true;
  CullMode _cullMode = CullMode.none;
  WindingOrder _windingOrder = WindingOrder.counterClockwise;
  bool _stateChanged = true;

  // Bindings accumulated for the current draw, keyed by `_key(group, binding)`.
  final Map<int, (GPUBuffer buffer, int offset, int size)> _uniforms = {};
  final Map<int, GPUTextureView> _textures = {};
  final Map<int, GPUSampler> _samplers = {};

  static int _key(int group, int binding) => (group << 16) | binding;

  @override
  void bindPipeline(GpuPipeline pipeline) {
    _pipeline = pipeline as _WebGpuPipeline;
    _stateChanged = true;
  }

  @override
  void setBlendState(BlendState blend) {
    _blend = blend;
    _stateChanged = true;
  }

  @override
  void setDepthState({
    required CompareFunction compare,
    required bool writeEnabled,
  }) {
    _depthCompare = compare;
    _depthWrite = writeEnabled;
    _stateChanged = true;
  }

  @override
  void setCullMode(CullMode cullMode) {
    _cullMode = cullMode;
    _stateChanged = true;
  }

  @override
  void setWindingOrder(WindingOrder windingOrder) {
    _windingOrder = windingOrder;
    _stateChanged = true;
  }

  @override
  void bindVertexBuffer(
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
    int slot = 0,
  }) {
    _pass.setVertexBuffer(
      slot,
      (buffer as _WebGpuBuffer).raw,
      offsetInBytes,
      lengthInBytes,
    );
  }

  @override
  void bindIndexBuffer(
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
    required GpuIndexType indexType,
  }) {
    _pass.setIndexBuffer(
      (buffer as _WebGpuBuffer).raw,
      indexType == GpuIndexType.uint16 ? 'uint16' : 'uint32',
      offsetInBytes,
      lengthInBytes,
    );
  }

  @override
  void bindUniform(
    GpuUniformSlot slot,
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
  }) {
    final reflected = (slot as _WebGpuUniformSlot).slot;
    _uniforms[_key(reflected.group, reflected.binding)] = (
      (buffer as _WebGpuBuffer).raw,
      offsetInBytes,
      lengthInBytes,
    );
  }

  @override
  void bindTexture(
    GpuUniformSlot slot,
    GpuTexture texture, {
    TextureSampler sampler = TextureSampler.nearest,
  }) {
    final reflected = (slot as _WebGpuUniformSlot).slot;
    final key = _key(reflected.group, reflected.binding);
    _textures[key] = (texture as _WebGpuSampledTexture).view;
    _samplers[key] = _backend._samplerFor(sampler);
  }

  @override
  void clearBindings() {
    _uniforms.clear();
    _textures.clear();
    _samplers.clear();
  }

  @override
  void draw(int vertexCount, {int instanceCount = 1}) {
    _prepareDraw();
    _pass.draw(vertexCount, instanceCount);
  }

  @override
  void drawIndexed(int indexCount, {int instanceCount = 1}) {
    _prepareDraw();
    _pass.drawIndexed(indexCount, instanceCount);
  }

  void _prepareDraw() {
    final pipeline = _pipeline;
    if (pipeline == null) {
      throw StateError('No pipeline bound');
    }
    if (_stateChanged) {
      final renderPipeline = _backend._resolvePipeline(
        pipeline,
        _StateKey.pack(
          blend: _blend,
          depthCompare: _depthCompare,
          depthWrite: _depthWrite,
          cullMode: _cullMode,
          windingOrder: _windingOrder,
        ),
      );
      if (!identical(renderPipeline, _renderPipeline)) {
        _pass.setPipeline(renderPipeline);
        _renderPipeline = renderPipeline;
      }
      _stateChanged = false;
    }
    final renderPipeline = _renderPipeline!;

    for (final MapEntry(key: group, value: slots) in pipeline.groups.entries) {
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
          final key = _key(slot.group, slot.binding);
          final view = _textures[key] ?? _backend._defaultTextureView;
          entries
            ..add(GPUBindGroupEntry(binding: slot.binding, resource: view))
            ..add(
              GPUBindGroupEntry(
                binding: slot.samplerBinding!,
                resource: _samplers[key] ?? _backend._defaultSampler,
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
  }

  @override
  Image submit({void Function()? onCompleted}) {
    commit(onCompleted: onCompleted);
    return _target.colorTexture.asImage();
  }

  @override
  void commit({void Function()? onCompleted}) {
    _pass.end();
    _backend._queue.submit([_encoder.finish()]);
    // `GPUQueue.writeBuffer` calls are ordered after the submissions that
    // precede them, so the buffers of this pass can be rewritten right away.
    onCompleted?.call();
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
