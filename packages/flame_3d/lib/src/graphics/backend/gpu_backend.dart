import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/src/graphics/backend/flutter_gpu/gpu_backend.dart'
    if (dart.library.js_interop) 'package:flame_3d/src/graphics/backend/web_gpu/gpu_backend.dart'
    as backend;
import 'package:flame_3d/src/graphics/backend/gpu_enums.dart';
import 'package:flame_3d/src/graphics/backend/gpu_handles.dart';
import 'package:flame_3d/src/resources/texture/texture_sampler.dart';

/// {@template gpu_backend}
/// A rendering backend: the abstraction over a concrete low-level GPU API.
///
/// `flame_3d` talks to the GPU exclusively through this interface, so the same
/// rendering code can run on different platforms.
///
/// Exactly one backend is active at a time, reachable via [instance]. Each
/// [GpuBackend] implementation sets the [instance] at construction time through
/// it's super constructor.
/// {@endtemplate}
abstract base class GpuBackend() {
  this {
    _instance = this;
  }

  static GpuBackend? _instance;

  /// The active backend.
  ///
  /// Calls [backend.GpuBackend.create] if no instance was set. Certain backends
  /// require async initialization so you are required to call
  /// [GpuBackend.initialize] at the start of your main.dart.
  static GpuBackend get instance {
    return _instance ??=
        backend.GpuBackend.create() ??
        (throw StateError(
          'No GpuBackend has been registered. Call '
          '`await GpuBackend.initialize()` before constructing a '
          'GraphicsDevice.',
        ));
  }

  /// Initialize the [GpuBackend].
  static Future<void> initialize() => backend.GpuBackend.initialize();

  /// Whether the platform's GPU backend can be used in this process.
  ///
  /// It is `false` when Flutter GPU (on native platforms) or WebGPU (on the
  /// web) is unavailable, for example when Impeller is disabled.
  static bool get isAvailable => backend.GpuBackend.isAvailable;

  /// The alignment, in bytes, that the offset of a uniform block binding must
  /// have within a [GpuBuffer].
  int get uniformAlignment => 256;

  /// Creates a [GpuTexture] with [mipLevelCount] mip levels (at most
  /// [maxMipLevelCount]).
  GpuTexture createTexture({
    required GpuStorageMode storageMode,
    required int width,
    required int height,
    required GpuPixelFormat format,
    int mipLevelCount = 1,
  });

  /// The largest number of mip levels a [width]x[height] texture can have,
  /// or `1` when this backend cannot sample mip levels uploaded by hand.
  int maxMipLevelCount(int width, int height) {
    final largest = width > height ? width : height;
    return largest < 1 ? 1 : largest.bitLength;
  }

  /// A [GpuTexture] that shares the GPU memory of [image] without copying it,
  /// or `null` when this backend cannot wrap it.
  GpuTexture? createTextureFromImage(Image image) => null;

  /// Creates a [GpuBuffer] of [sizeInBytes] bytes.
  ///
  /// The buffer can be bound as vertex, index and uniform data.
  GpuBuffer createBuffer({
    required GpuStorageMode storageMode,
    required int sizeInBytes,
  });

  /// Loads a [GpuShaderLibrary] from the asset at [assetName].
  GpuShaderLibrary loadShaderLibrary(String assetName);

  /// Registers the shader library [bytes] (the contents of a shader bundle
  /// asset in this backend's format) under [assetName], so that
  /// [loadShaderLibrary] can return it.
  ///
  /// This allows shaders that are not declared as assets, for example ones
  /// downloaded or compiled at run time.
  Future<void> registerShaderLibrary(String assetName, ByteData bytes) {
    throw UnsupportedError(
      '$runtimeType cannot register shader libraries at run time.',
    );
  }

  /// Links [vertexShader] and [fragmentShader] into a [GpuPipeline] that reads
  /// its vertex inputs as described by [vertexLayout].
  ///
  /// When [vertexLayout] is `null` the backend's default layout for the
  /// vertex shader is used.
  GpuPipeline createPipeline({
    required GpuShader vertexShader,
    required GpuShader fragmentShader,
    GpuVertexLayout? vertexLayout,
  });

  /// Creates a [GpuRenderTarget] of [width]x[height], cleared to [clearValue]
  /// at the start of each pass.
  GpuRenderTarget createRenderTarget({
    required int width,
    required int height,
    required Color clearValue,
    int msaaSampleCount = 1,
  });

  /// Whether this backend can create [GpuTextureTarget]s, see
  /// [createTextureTarget].
  bool get supportsTextureTargets => false;

  /// Whether a [GpuTextureTarget] can render into a
  /// [GpuPixelFormat.r32Float] texture. When it cannot, a depth stored in a
  /// texture is packed into the 8-bit channels of a
  /// [GpuPixelFormat.rgba8888] texture instead.
  bool get supportsFloatTextureTargets => false;

  /// Creates a [GpuTextureTarget] of [width]x[height] whose passes render
  /// into a texture of [format] that later passes sample, cleared to
  /// [clearValue] (and its depth to the far plane) at the start of each pass.
  ///
  /// Throws an [UnsupportedError] when [supportsTextureTargets] is `false`.
  GpuTextureTarget createTextureTarget({
    required int width,
    required int height,
    required GpuPixelFormat format,
    required Color clearValue,
  }) {
    throw UnsupportedError('$runtimeType cannot render into textures.');
  }

  /// Begins a new frame.
  GpuFrame beginFrame();
}

/// A single frame of rendering.
///
/// Obtain one via [GpuBackend.beginFrame] and finalize it with [end].
abstract interface class GpuFrame() {
  /// Begins a render pass that draws into [target].
  ///
  /// Every pass starts with the default render state: no blending, depth test
  /// with [CompareFunction.less], depth writes on, no culling and
  /// [WindingOrder.counterClockwise] front faces.
  GpuRenderPass beginRenderPass(GpuRenderTarget target);

  /// Finalizes the frame.
  void end();
}

/// Records the bind, state and draw commands of a single render pass.
///
/// Bindings persist from one draw to the next until [clearBindings] is called
/// or a different pipeline is bound with [bindPipeline], so unchanged resources
/// need not be bound again.
///
/// Obtain one via [GpuFrame.beginRenderPass] and submit it with [submit].
abstract interface class GpuRenderPass() {
  /// Binds the render [pipeline].
  ///
  /// Callers must call [clearBindings] before binding a pipeline whose shaders
  /// differ from the current one, and bind its resources again.
  void bindPipeline(GpuPipeline pipeline);

  /// Sets how the color output of the following draws is blended.
  void setBlendState(BlendState blend);

  /// Sets the depth test of the following draws: [compare] is
  /// [CompareFunction.always] to disable the test.
  void setDepthState({
    required CompareFunction compare,
    required bool writeEnabled,
  });

  /// Sets which faces the following draws cull.
  void setCullMode(CullMode cullMode);

  /// Sets which winding order is front-facing for the following draws.
  void setWindingOrder(WindingOrder windingOrder);

  /// Binds [lengthInBytes] bytes of [buffer] starting at [offsetInBytes] to
  /// the vertex buffer [slot].
  void bindVertexBuffer(
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
    int slot = 0,
  });

  /// Binds [lengthInBytes] bytes of [buffer] starting at [offsetInBytes] as
  /// the index buffer, holding indices of [indexType].
  void bindIndexBuffer(
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
    required GpuIndexType indexType,
  });

  /// Binds [lengthInBytes] bytes of [buffer] starting at [offsetInBytes] to
  /// the uniform block [slot].
  ///
  /// [offsetInBytes] must be a multiple of [GpuBackend.uniformAlignment].
  void bindUniform(
    GpuUniformSlot slot,
    GpuBuffer buffer, {
    required int offsetInBytes,
    required int lengthInBytes,
  });

  /// Binds [texture] to the sampler [slot], sampled as [sampler] says.
  ///
  /// Backends create one sampler object per distinct [sampler] value (see
  /// [TextureSampler.key]) and reuse it.
  void bindTexture(
    GpuUniformSlot slot,
    GpuTexture texture, {
    TextureSampler sampler = TextureSampler.nearest,
  });

  /// Clears all resources bound to this pass.
  void clearBindings();

  /// Draws [vertexCount] vertices of the bound vertex buffers, [instanceCount]
  /// times.
  void draw(int vertexCount, {int instanceCount = 1});

  /// Draws [indexCount] indices of the bound index buffer, [instanceCount]
  /// times.
  void drawIndexed(int indexCount, {int instanceCount = 1});

  /// Finalizes the pass, submits its commands to the GPU and returns the
  /// rendered color as an [Image].
  ///
  /// [onCompleted] is called once the GPU no longer reads any buffer bound
  /// during the pass, after which their contents may be overwritten.
  ///
  /// Passes into a [GpuTextureTarget] end with [commit] instead.
  Image submit({void Function()? onCompleted});

  /// Finalizes the pass and submits its commands to the GPU without
  /// returning an image, as passes into a [GpuTextureTarget] end.
  ///
  /// [onCompleted] is called as for [submit].
  void commit({void Function()? onCompleted});
}
