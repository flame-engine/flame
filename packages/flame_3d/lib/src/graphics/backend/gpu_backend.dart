import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/src/graphics/backend/flutter_gpu/gpu_backend.dart'
    if (dart.library.js_interop) 'package:flame_3d/src/graphics/backend/web_gpu/gpu_backend.dart'
    as backend;
import 'package:flame_3d/src/graphics/backend/gpu_enums.dart';
import 'package:flame_3d/src/graphics/backend/gpu_handles.dart';

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
abstract base class GpuBackend {
  GpuBackend() {
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

  /// Creates a [GpuTexture].
  GpuTexture createTexture({
    required GpuStorageMode storageMode,
    required int width,
    required int height,
    required GpuPixelFormat format,
  });

  /// Creates a [GpuBuffer] of [sizeInBytes] bytes.
  GpuBuffer createBuffer({
    required GpuStorageMode storageMode,
    required int sizeInBytes,
  });

  /// Loads a [GpuShaderLibrary] from the asset at [assetName].
  GpuShaderLibrary loadShaderLibrary(String assetName);

  /// Links [vertexShader] and [fragmentShader] into a [GpuPipeline].
  GpuPipeline createPipeline({
    required GpuShader vertexShader,
    required GpuShader fragmentShader,
  });

  /// Creates a [GpuRenderTarget] of [width]x[height], cleared to [clearValue]
  /// at the start of each pass.
  GpuRenderTarget createRenderTarget({
    required int width,
    required int height,
    required Color clearValue,
  });

  /// Begins a new frame.
  GpuFrame beginFrame();
}

/// A single frame of rendering.
///
/// Owns the transient uniform storage shared across the frame's render passes.
/// Obtain one via [GpuBackend.beginFrame] and finalize it with [end].
abstract interface class GpuFrame {
  /// Begins a render pass that draws into [target] using [blend] and
  /// [depthStencil] state.
  GpuRenderPass beginRenderPass(
    GpuRenderTarget target, {
    required BlendState blend,
    required DepthStencilState depthStencil,
  });

  /// Finalizes the frame, releasing its transient storage.
  void end();
}

/// Records the bind and draw commands of a single render pass.
///
/// Obtain one via [GpuFrame.beginRenderPass] and submit it with [submit].
abstract interface class GpuRenderPass {
  /// Binds the render [pipeline] and applies [cullMode].
  void bindPipeline(GpuPipeline pipeline, CullMode cullMode);

  /// Binds [view] as the vertex buffer, [vertexCount] vertices will be drawn.
  void bindVertexBuffer(GpuBufferView view, int vertexCount);

  /// Binds [view] as the index buffer of [indexType]; [indexCount] indices
  /// will be drawn.
  void bindIndexBuffer(
    GpuBufferView view,
    GpuIndexType indexType,
    int indexCount,
  );

  /// Binds transient uniform [data] to [slot].
  ///
  /// The [data] gets copied into the frame's transient storage, so the buffer
  /// can be reused afterwards.
  void bindUniform(GpuUniformSlot slot, ByteData data);

  /// Binds [texture] to the sampler [slot].
  void bindTexture(GpuUniformSlot slot, GpuTexture texture);

  /// Clears all resources bound to this pass.
  void clearBindings();

  /// Issues a draw call for the currently bound geometry.
  void draw();

  /// Finalizes the pass and submits its commands to the GPU.
  void submit();
}
