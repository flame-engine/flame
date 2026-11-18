// ignore_for_file: avoid_redundant_argument_values

import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/src/graphics/backend/flutter_gpu/shader_bundle_reflection.dart';
import 'package:flame_3d/src/graphics/backend/gpu_backend.dart' as base;
import 'package:flame_3d/src/graphics/backend/gpu_enums.dart';
import 'package:flame_3d/src/graphics/backend/gpu_handles.dart';
import 'package:flame_3d/src/resources/texture/texture_sampler.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:meta/meta.dart';

/// A [base.GpuBackend] implemented on top of `flutter_gpu`.
///
/// Creates a backend wrapping `gpuContext`, defaulting to the global
/// `flutter_gpu` context.
base class GpuBackend({gpu.GpuContext? gpuContext}) extends base.GpuBackend {
  static Future<void> initialize() async {
    await create()?._preloadShaderLibraries();
  }

  static GpuBackend? create() => GpuBackend();

  /// Whether Flutter GPU can be used: it needs Impeller and the Flutter GPU
  /// flag (`--enable-flutter-gpu` or `FLTEnableFlutterGPU`).
  static bool get isAvailable {
    try {
      return gpu.gpuContext.minimumUniformByteAlignment > 0;
      // Flutter GPU reports a missing Impeller backend with a plain Exception.
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return false;
    }
  }

  final gpu.GpuContext _context = gpuContext ?? gpu.gpuContext;

  late final _FlutterGpuFrame _frame = _FlutterGpuFrame(this);

  @override
  late final int uniformAlignment = _context.minimumUniformByteAlignment;

  @override
  GpuTexture createTexture({
    required GpuStorageMode storageMode,
    required int width,
    required int height,
    required GpuPixelFormat format,
    int mipLevelCount = 1,
  }) {
    return _FlutterGpuTexture(
      _context.createTexture(
        _storageMode(storageMode),
        width,
        height,
        format: _pixelFormat(format),
        mipLevelCount: mipLevelCount,
      ),
    );
  }

  @override
  int maxMipLevelCount(int width, int height) {
    // Mip levels uploaded by hand sample as black on some OpenGL ES devices.
    if (!_supportsManualMipmaps) {
      return 1;
    }
    return gpu.Texture.fullMipCount(width, height);
  }

  late final bool _supportsManualMipmaps =
      _context.doesSupportManuallyMippedTextures;

  @override
  GpuTexture? createTextureFromImage(Image image) {
    try {
      return _FlutterGpuTexture(gpu.Texture.fromImage(_context, image));
      // Flutter GPU reports images without a compatible texture with a plain
      // Exception.
    } on Exception {
      return null;
    }
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

  final Map<String, _FlutterGpuShaderLibrary> _shaderLibraries = {};

  /// Loads every `.shaderbundle` shader asset declared by the app.
  ///
  /// Bundles are discovered through [AssetManifest], so a game's own custom
  /// shaders are picked up automatically alongside flame_3d's built-ins.
  /// Loading is done up front because `flutter_gpu` can only load shader
  /// bundles asynchronously, while [loadShaderLibrary] is synchronous.
  Future<void> _preloadShaderLibraries() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    for (final assetName in manifest.listAssets()) {
      if (assetName.endsWith('.shaderbundle')) {
        final library = await gpu.ShaderLibrary.fromAsset(assetName);
        if (library != null) {
          final bytes = await rootBundle.load(assetName);
          _shaderLibraries[assetName] = _FlutterGpuShaderLibrary(
            library,
            assetName,
            reflectShaderBundleInputs(bytes),
          );
        }
      }
    }
  }

  @override
  Future<void> registerShaderLibrary(String assetName, ByteData bytes) async {
    final library = await gpu.ShaderLibrary.fromBytes(bytes);
    if (library == null) {
      throw StateError('"$assetName" is not a valid shader bundle.');
    }
    _shaderLibraries[assetName] = _FlutterGpuShaderLibrary(
      library,
      assetName,
      reflectShaderBundleInputs(bytes),
    );
  }

  @override
  GpuShaderLibrary loadShaderLibrary(String assetName) {
    final library =
        _shaderLibraries[assetName] ??
        _shaderLibraries[_withoutPackagePrefix(assetName)];
    if (library == null) {
      throw StateError(
        'Shader library "$assetName" has not been loaded. Make sure to '
        '`await GpuBackend.initialize()` at the start of your main, and that '
        'the asset is declared in pubspec.yaml.',
      );
    }
    return library;
  }

  @override
  GpuPipeline createPipeline({
    required GpuShader vertexShader,
    required GpuShader fragmentShader,
    GpuVertexLayout? vertexLayout,
  }) {
    return _FlutterGpuPipeline(
      _context.createRenderPipeline(
        (vertexShader as _FlutterGpuShader).raw,
        (fragmentShader as _FlutterGpuShader).raw,
        vertexLayout: vertexLayout == null ? null : _vertexLayout(vertexLayout),
      ),
    );
  }

  @override
  GpuRenderTarget createRenderTarget({
    required int width,
    required int height,
    required Color clearValue,
    int msaaSampleCount = 1,
  }) {
    // Silently ignore the request for MSAA if the device does not support it.
    final sampleCount = msaaSampleCount > 1 && _context.doesSupportOffscreenMSAA
        ? msaaSampleCount
        : 1;

    final multisampleColorTexture = sampleCount > 1
        ? _context.createTexture(
            gpu.StorageMode.deviceTransient,
            width,
            height,
            format: _colorFormat,
            sampleCount: sampleCount,
            enableShaderReadUsage: false,
          )
        : null;

    final depthTexture = _context.createTexture(
      gpu.StorageMode.deviceTransient,
      width,
      height,
      format: _context.defaultDepthStencilFormat,
      sampleCount: sampleCount,
      enableShaderReadUsage: sampleCount == 1,
    );

    return _FlutterGpuRenderTarget(
      _context,
      width,
      height,
      multisampleColorTexture,
      depthTexture,
      Vector4Utils.fromColor(clearValue),
    );
  }

  @override
  bool get supportsTextureTargets => true;

  // Flutter GPU has no query for the formats a texture can be rendered into.
  // Metal and Vulkan render into 32-bit float textures (Vulkan requires it of
  // every device), OpenGL ES only with an extension; framebuffer render
  // mipmaps are documented as supported on Metal and Vulkan and not on
  // OpenGL ES, which tells the backends apart.
  @override
  late final bool supportsFloatTextureTargets =
      _context.doesSupportFramebufferRenderMipmap;

  @override
  GpuTextureTarget createTextureTarget({
    required int width,
    required int height,
    required GpuPixelFormat format,
    required Color clearValue,
  }) {
    final texture = _context.createTexture(
      gpu.StorageMode.devicePrivate,
      width,
      height,
      format: _pixelFormat(format),
    );
    final depthTexture = _context.createTexture(
      gpu.StorageMode.deviceTransient,
      width,
      height,
      format: _context.defaultDepthStencilFormat,
      enableShaderReadUsage: false,
    );
    return _FlutterGpuTextureTarget(
      width,
      height,
      format,
      _FlutterGpuTexture(texture),
      gpu.RenderTarget.singleColor(
        gpu.ColorAttachment(
          texture: texture,
          clearValue: Vector4Utils.fromColor(clearValue),
        ),
        depthStencilAttachment: gpu.DepthStencilAttachment(
          texture: depthTexture,
          depthClearValue: 1.0,
        ),
      ),
    );
  }

  /// The number of frames Flutter has drawn since the backend started
  /// counting them, see [_FlutterGpuRenderTarget].
  static int get _drawnFrames {
    if (!_countingFrames) {
      try {
        // Persistent callbacks run after every frame's layout and paint, and
        // do not schedule frames.
        SchedulerBinding.instance.addPersistentFrameCallback(
          (_) => _frameCount++,
        );
        _countingFrames = true;
        // Without a binding, frames are not counted.
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {}
    }
    return _frameCount;
  }

  static bool _countingFrames = false;
  static int _frameCount = 0;

  @override
  base.GpuFrame beginFrame() => _frame;

  gpu.PixelFormat _pixelFormat(GpuPixelFormat format) {
    return switch (format) {
      GpuPixelFormat.rgba8888 => gpu.PixelFormat.r8g8b8a8UNormInt,
      GpuPixelFormat.bgra8888 => gpu.PixelFormat.b8g8r8a8UNormInt,
      GpuPixelFormat.rgbaFloat32 => gpu.PixelFormat.r32g32b32a32Float,
      GpuPixelFormat.r32Float => gpu.PixelFormat.r32Float,
      GpuPixelFormat.depthStencil => _context.defaultDepthStencilFormat,
    };
  }

  static const _colorFormat = gpu.PixelFormat.r8g8b8a8UNormInt;

  static gpu.StorageMode _storageMode(GpuStorageMode mode) {
    return switch (mode) {
      GpuStorageMode.hostVisible => gpu.StorageMode.hostVisible,
      GpuStorageMode.devicePrivate => gpu.StorageMode.devicePrivate,
      GpuStorageMode.deviceTransient => gpu.StorageMode.deviceTransient,
    };
  }

  static gpu.VertexLayout _vertexLayout(GpuVertexLayout layout) {
    return gpu.VertexLayout(
      buffers: [
        for (final buffer in layout.buffers)
          gpu.VertexBuffer(
            strideInBytes: buffer.strideInBytes,
            stepMode: buffer.perInstance
                ? gpu.VertexStepMode.instance
                : gpu.VertexStepMode.vertex,
            attributes: [
              for (final attribute in buffer.attributes)
                gpu.VertexAttribute(
                  name: attribute.name,
                  offsetInBytes: attribute.offsetInBytes,
                  format: switch (attribute.components) {
                    1 => gpu.VertexFormat.float32,
                    2 => gpu.VertexFormat.float32x2,
                    3 => gpu.VertexFormat.float32x3,
                    4 => gpu.VertexFormat.float32x4,
                    final components => throw ArgumentError.value(
                      components,
                      'components',
                      'Vertex attribute "${attribute.name}" must have 1 to 4 '
                          'components',
                    ),
                  },
                ),
            ],
          ),
      ],
    );
  }

  /// When an app (or a package's own tests) is the root package, its assets
  /// are listed without the `packages/<name>/` prefix other packages use to
  /// refer to them.
  static String _withoutPackagePrefix(String assetName) {
    if (!assetName.startsWith('packages/')) {
      return assetName;
    }
    final packageEnd = assetName.indexOf('/', 'packages/'.length);
    return packageEnd < 0 ? assetName : assetName.substring(packageEnd + 1);
  }
}

class const _FlutterGpuTexture(final gpu.Texture raw) implements GpuTexture {
  @override
  int get mipLevelCount => raw.mipLevelCount;

  @override
  void write(ByteData data, {int mipLevel = 0}) {
    raw.overwrite(data, mipLevel: mipLevel);
  }

  @override
  Image asImage() => raw.asImage();
}

class _FlutterGpuBuffer(final gpu.DeviceBuffer raw) implements GpuBuffer {
  @override
  int get sizeInBytes => raw.sizeInBytes;

  @override
  void write(ByteData data, {int destinationOffsetInBytes = 0}) {
    raw.overwrite(data, destinationOffsetInBytes: destinationOffsetInBytes);
  }

  // `flutter_gpu` takes buffer ranges as `BufferView` objects. Ranges recur
  // from frame to frame (a surface's vertices, the same slices of a transient
  // block), so their views are kept instead of allocated on every bind.
  final Map<int, gpu.BufferView> _views = {};

  gpu.BufferView view(int offsetInBytes, int lengthInBytes) {
    final view = _views[offsetInBytes];
    if (view != null && view.lengthInBytes == lengthInBytes) {
      return view;
    }
    if (_views.length >= _maxViews) {
      _views.clear();
    }
    return _views[offsetInBytes] = gpu.BufferView(
      raw,
      offsetInBytes: offsetInBytes,
      lengthInBytes: lengthInBytes,
    );
  }

  static const _maxViews = 4096;
}

class _FlutterGpuShaderLibrary(
  final gpu.ShaderLibrary raw,
  final String _assetName,
  final Map<String, List<GpuShaderInput>>? _inputs,
) implements GpuShaderLibrary {
  final Map<String, _FlutterGpuShader> _shaders = {};

  @override
  GpuShader operator [](String entryPoint) {
    return _shaders.putIfAbsent(entryPoint, () {
      final shader = raw[entryPoint];
      if (shader == null) {
        throw StateError(
          'Shader "$entryPoint" not found in library "$_assetName"',
        );
      }
      return _FlutterGpuShader(shader, _inputs?[entryPoint]);
    });
  }
}

class _FlutterGpuShader(
  final gpu.Shader raw,
  @override final List<GpuShaderInput>? inputs,
) implements GpuShader {
  final Map<String, _FlutterGpuUniformSlot> _slots = {};

  @override
  GpuUniformSlot getUniformSlot(String slot) {
    return _slots.putIfAbsent(
      slot,
      () => _FlutterGpuUniformSlot(raw.getUniformSlot(slot)),
    );
  }
}

class _FlutterGpuUniformSlot(final gpu.UniformSlot raw)
    implements GpuUniformSlot {
  @override
  String get name => raw.uniformName;

  @override
  late final int? sizeInBytes = raw.sizeInBytes;

  final Map<String, int?> _offsets = {};

  @override
  int? getMemberOffsetInBytes(String member) {
    return _offsets.putIfAbsent(
      member,
      () => raw.getMemberOffsetInBytes(member),
    );
  }
}

class const _FlutterGpuPipeline(final gpu.RenderPipeline raw)
    implements GpuPipeline;

/// The number of color textures [target] (a render target of the Flutter
/// GPU backend) has created, for tests.
@visibleForTesting
int debugColorTextureCount(GpuRenderTarget target) {
  return (target as _FlutterGpuRenderTarget)._buffers.length;
}

/// A render target: a depth texture, a multisample color texture with MSAA,
/// and the color textures its passes render into and whose images Flutter
/// draws.
///
/// A color texture is rendered into again only once Flutter can no longer
/// sample the image of its previous pass: Flutter rasterizes at most two
/// frames at a time (the one being built and the one before it), so once two
/// more frames have been drawn the frame that showed an image has been
/// rasterized, and its draws have been submitted to the GPU before any new
/// pass is. Up to [_maxColorTextures] are created; past that, when Flutter
/// draws no frames (passes rendered outside of frames, in tests for
/// instance), the texture rendered the longest ago is reused.
///
/// Every texture, and what it takes to render into it, is created once:
/// unlike `GpuImageSurface`, whose textures can only be reused once the Dart
/// garbage collector has collected the wrappers of the passes that rendered
/// into them, and which therefore allocates a texture for most passes.
class _FlutterGpuRenderTarget(
  final gpu.GpuContext _context,
  @override final int width,
  @override final int height,
  final gpu.Texture? _multisampleColorTexture,
  final gpu.Texture _depthTexture,
  final Vector4 _clearValue,
) implements GpuRenderTarget {
  static const _maxColorTextures = 3;

  final List<_ColorBuffer> _buffers = [];

  /// The color buffer for a new pass.
  _ColorBuffer acquire() {
    final drawnFrames = GpuBackend._drawnFrames;
    _ColorBuffer? oldest;
    for (final buffer in _buffers) {
      final presented = buffer.presentedFrame;
      if (presented == null || drawnFrames >= presented + 2) {
        return buffer;
      }
      if (oldest == null || buffer.presentedSerial < oldest.presentedSerial) {
        oldest = buffer;
      }
    }
    if (oldest != null && _buffers.length >= _maxColorTextures) {
      return oldest;
    }
    final texture = _context.createTexture(
      gpu.StorageMode.devicePrivate,
      width,
      height,
      format: GpuBackend._colorFormat,
    );
    final multisample = _multisampleColorTexture;
    final buffer = _ColorBuffer(
      texture,
      gpu.RenderTarget.singleColor(
        gpu.ColorAttachment(
          texture: multisample ?? texture,
          resolveTexture: multisample == null ? null : texture,
          storeAction: multisample == null
              ? gpu.StoreAction.store
              : gpu.StoreAction.multisampleResolve,
          clearValue: _clearValue,
        ),
        depthStencilAttachment: gpu.DepthStencilAttachment(
          texture: _depthTexture,
          depthClearValue: 1.0,
        ),
      ),
    );
    _buffers.add(buffer);
    return buffer;
  }

  /// Records that the image of [buffer] was handed out.
  void present(_ColorBuffer buffer) {
    buffer
      ..presentedFrame = GpuBackend._drawnFrames
      ..presentedSerial = _presentations++;
  }

  int _presentations = 0;
}

/// A color texture of a [_FlutterGpuRenderTarget] and the render target that
/// renders into it.
class _ColorBuffer(
  final gpu.Texture texture,
  final gpu.RenderTarget renderTarget,
) {
  /// The number of frames Flutter had drawn when the image of this texture
  /// was last handed out, or `null` if it never was.
  int? presentedFrame;

  /// Orders the presentations of the buffers of a render target.
  int presentedSerial = 0;
}

/// A [GpuTextureTarget] of the Flutter GPU backend: one color texture, which
/// later passes sample, and a transient depth texture, created once.
class _FlutterGpuTextureTarget(
  @override final int width,
  @override final int height,
  @override final GpuPixelFormat format,
  @override final _FlutterGpuTexture texture,
  final gpu.RenderTarget renderTarget,
) implements GpuTextureTarget;

class const _FlutterGpuFrame(final GpuBackend _backend)
    implements base.GpuFrame {
  @override
  base.GpuRenderPass beginRenderPass(GpuRenderTarget target) {
    final commandBuffer = _backend._context.createCommandBuffer();
    if (target is _FlutterGpuTextureTarget) {
      return _FlutterGpuRenderPass(
        null,
        null,
        commandBuffer,
        _begin(commandBuffer, target.renderTarget),
      );
    }
    final renderTarget = target as _FlutterGpuRenderTarget;
    final buffer = renderTarget.acquire();
    return _FlutterGpuRenderPass(
      renderTarget,
      buffer,
      commandBuffer,
      _begin(commandBuffer, buffer.renderTarget),
    );
  }

  static gpu.RenderPass _begin(
    gpu.CommandBuffer commandBuffer,
    gpu.RenderTarget renderTarget,
  ) {
    return commandBuffer.createRenderPass(renderTarget)
      // The default state documented on `GpuFrame.beginRenderPass`.
      ..setWindingOrder(gpu.WindingOrder.counterClockwise)
      ..setCullMode(gpu.CullMode.none)
      ..setColorBlendEnable(false)
      ..setDepthWriteEnable(true)
      ..setDepthCompareOperation(gpu.CompareFunction.less);
  }

  @override
  void end() {}
}

/// A render pass; [_target] and [_buffer] are those of a pass whose image is
/// returned by [submit], and `null` for a pass into a texture target.
class _FlutterGpuRenderPass(
  final _FlutterGpuRenderTarget? _target,
  final _ColorBuffer? _buffer,
  final gpu.CommandBuffer _commandBuffer,
  final gpu.RenderPass _renderPass,
) implements base.GpuRenderPass {
  @override
  void bindPipeline(GpuPipeline pipeline) {
    _renderPass.bindPipeline((pipeline as _FlutterGpuPipeline).raw);
  }

  @override
  void setBlendState(BlendState blend) {
    if (blend == BlendState.opaque) {
      _renderPass.setColorBlendEnable(false);
      return;
    }
    _renderPass
      ..setColorBlendEnable(true)
      ..setColorBlendEquation(switch (blend) {
        BlendState.opaque || BlendState.premultipliedAlpha => _premultiplied,
        BlendState.alpha => _straightAlpha,
        BlendState.additive => _additive,
        BlendState.depthOnly => _keepTarget,
      });
  }

  @override
  void setDepthState({
    required CompareFunction compare,
    required bool writeEnabled,
  }) {
    _renderPass
      ..setDepthCompareOperation(switch (compare) {
        CompareFunction.never => gpu.CompareFunction.never,
        CompareFunction.less => gpu.CompareFunction.less,
        CompareFunction.equal => gpu.CompareFunction.equal,
        CompareFunction.lessEqual => gpu.CompareFunction.lessEqual,
        CompareFunction.greater => gpu.CompareFunction.greater,
        CompareFunction.notEqual => gpu.CompareFunction.notEqual,
        CompareFunction.greaterEqual => gpu.CompareFunction.greaterEqual,
        CompareFunction.always => gpu.CompareFunction.always,
      })
      ..setDepthWriteEnable(writeEnabled);
  }

  @override
  void setCullMode(CullMode cullMode) {
    _renderPass.setCullMode(switch (cullMode) {
      CullMode.none => gpu.CullMode.none,
      CullMode.frontFace => gpu.CullMode.frontFace,
      CullMode.backFace => gpu.CullMode.backFace,
    });
  }

  @override
  void setWindingOrder(WindingOrder windingOrder) {
    _renderPass.setWindingOrder(switch (windingOrder) {
      WindingOrder.clockwise => gpu.WindingOrder.clockwise,
      WindingOrder.counterClockwise => gpu.WindingOrder.counterClockwise,
    });
  }

  @override
  void bindVertexBuffer(
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
    int slot = 0,
  }) {
    _renderPass.bindVertexBuffer(
      (buffer as _FlutterGpuBuffer).view(offsetInBytes, lengthInBytes),
      slot: slot,
    );
  }

  @override
  void bindIndexBuffer(
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
    required GpuIndexType indexType,
  }) {
    _renderPass.bindIndexBuffer(
      (buffer as _FlutterGpuBuffer).view(offsetInBytes, lengthInBytes),
      switch (indexType) {
        GpuIndexType.uint16 => gpu.IndexType.int16,
        GpuIndexType.uint32 => gpu.IndexType.int32,
      },
    );
  }

  @override
  void bindUniform(
    GpuUniformSlot slot,
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
  }) {
    _renderPass.bindUniform(
      (slot as _FlutterGpuUniformSlot).raw,
      (buffer as _FlutterGpuBuffer).view(offsetInBytes, lengthInBytes),
    );
  }

  @override
  void bindTexture(
    GpuUniformSlot slot,
    GpuTexture texture, {
    TextureSampler sampler = TextureSampler.nearest,
  }) {
    _renderPass.bindTexture(
      (slot as _FlutterGpuUniformSlot).raw,
      (texture as _FlutterGpuTexture).raw,
      // Passed explicitly: `flutter_gpu` allocates default options otherwise.
      sampler: _samplerFor(sampler),
    );
  }

  // The sampler options of every distinct sampler, by key, created once.
  static final _samplers = List<gpu.SamplerOptions?>.filled(
    TextureSampler.keyCount,
    null,
  );

  static gpu.SamplerOptions _samplerFor(TextureSampler sampler) {
    return _samplers[sampler.key] ??= gpu.SamplerOptions(
      minFilter: _filter(sampler.minFilter),
      magFilter: _filter(sampler.magFilter),
      mipFilter: switch (sampler.mipFilter) {
        TextureFilter.nearest => gpu.MipFilter.nearest,
        TextureFilter.linear => gpu.MipFilter.linear,
      },
      widthAddressMode: _addressMode(sampler.wrapU),
      heightAddressMode: _addressMode(sampler.wrapV),
    );
  }

  static gpu.MinMagFilter _filter(TextureFilter filter) {
    return switch (filter) {
      TextureFilter.nearest => gpu.MinMagFilter.nearest,
      TextureFilter.linear => gpu.MinMagFilter.linear,
    };
  }

  static gpu.SamplerAddressMode _addressMode(TextureWrap wrap) {
    return switch (wrap) {
      TextureWrap.clamp => gpu.SamplerAddressMode.clampToEdge,
      TextureWrap.repeat => gpu.SamplerAddressMode.repeat,
      TextureWrap.mirror => gpu.SamplerAddressMode.mirror,
    };
  }

  @override
  void clearBindings() => _renderPass.clearBindings();

  @override
  void draw(int vertexCount, {int instanceCount = 1}) {
    _renderPass.draw(vertexCount, instanceCount: instanceCount);
  }

  @override
  void drawIndexed(int indexCount, {int instanceCount = 1}) {
    _renderPass.drawIndexed(indexCount, instanceCount: instanceCount);
  }

  @override
  Image submit({void Function()? onCompleted}) {
    final target = _target;
    final buffer = _buffer;
    if (target == null || buffer == null) {
      throw StateError('A pass into a texture target ends with commit');
    }
    commit(onCompleted: onCompleted);
    target.present(buffer);
    return buffer.texture.asImage();
  }

  @override
  void commit({void Function()? onCompleted}) {
    _commandBuffer.submit(
      completionCallback: onCompleted == null ? null : (_) => onCompleted(),
    );
  }

  static final _premultiplied = gpu.ColorBlendEquation(
    sourceColorBlendFactor: gpu.BlendFactor.one,
    destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
    sourceAlphaBlendFactor: gpu.BlendFactor.one,
    destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
  );

  static final _straightAlpha = gpu.ColorBlendEquation(
    sourceColorBlendFactor: gpu.BlendFactor.sourceAlpha,
    destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
    sourceAlphaBlendFactor: gpu.BlendFactor.one,
    destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
  );

  // Added light covers nothing: the alpha of the target is kept.
  static final _additive = gpu.ColorBlendEquation(
    sourceColorBlendFactor: gpu.BlendFactor.one,
    destinationColorBlendFactor: gpu.BlendFactor.one,
    sourceAlphaBlendFactor: gpu.BlendFactor.zero,
    destinationAlphaBlendFactor: gpu.BlendFactor.one,
  );

  // Depth only: the target keeps its color and alpha.
  static final _keepTarget = gpu.ColorBlendEquation(
    sourceColorBlendFactor: gpu.BlendFactor.zero,
    destinationColorBlendFactor: gpu.BlendFactor.one,
    sourceAlphaBlendFactor: gpu.BlendFactor.zero,
    destinationAlphaBlendFactor: gpu.BlendFactor.one,
  );
}
