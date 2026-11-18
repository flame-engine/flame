import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/bloom_pass.dart';
import 'package:meta/meta.dart';

/// {@template graphics_device}
/// The [GraphicsDevice] provides a way for developers to interact with the GPU
/// by binding different resources to it.
///
/// A frame starts with [begin] and ends with [end]. Within a frame, one or more
/// render passes can be created with [beginPass]/[endPass], each producing an
/// [Image].
///
/// The device remembers what is bound: binding the pipeline, render state,
/// surface or uniform data that is already bound costs nothing, so callers can
/// bind everything a draw needs without tracking it themselves.
///
/// Uniform and instance data is staged in CPU memory and uploaded to GPU
/// buffers once per render pass. Those buffers are recycled once the GPU has
/// finished the frames that read them.
/// {@endtemplate}
class GraphicsDevice({
  /// The clear value, used to clear out the screen.
  final Color clearValue = const Color(0x00000000),
  GpuBackend? backend,
}) {
  /// The GPU backend this device records its rendering commands through.
  final GpuBackend backend = backend ?? GpuBackend.instance;

  /// The counters of the frame being recorded.
  ///
  /// They are reset by [begin]; read [lastFrameStats] for a complete frame.
  final RenderStats stats = RenderStats();

  /// The counters of the last frame that ended.
  final RenderStats lastFrameStats = RenderStats();

  /// A number identifying the current frame, incremented by every [begin].
  int get frame => _frame;
  int _frame = 0;

  GpuFrame? _gpuFrame;
  GpuRenderPass? _renderPass;
  late GpuRenderTarget _renderTarget;

  /// The render target of the current (or last) render pass.
  GpuRenderTarget get renderTarget => _renderTarget;

  late final _TransientArena _arena = _TransientArena(backend);

  // Render target pool: keyed by (width, height, MSAA sample count), each
  // entry is a list of targets. _poolIndex tracks how many have been handed
  // out this frame, _poolLastUsed the last frame a key was used in.
  final _pool = <(int, int, int), List<GpuRenderTarget>>{};
  final _poolIndex = <(int, int, int), int>{};
  final _poolLastUsed = <(int, int, int), int>{};

  /// The number of frames a render target size that is no longer used stays
  /// pooled, so that a scene whose size changes back and forth, or that skips
  /// a few frames, keeps its targets instead of creating new ones.
  static const int targetRetainFrames = 30;

  static int _visualMutationCount = 0;

  /// Monotonically increasing counter bumped whenever a 3D scene, particle
  /// system, trail, or retained layer mutates visual output, allowing host
  /// loops that throttle idle frames to detect when a repaint is needed.
  static int get visualMutationCount => _visualMutationCount;

  /// Records that a 3D component or scene mutated visual output.
  static void notifyVisualMutation() {
    _visualMutationCount++;
  }

  // Pipelines, keyed by vertex shader, fragment shader and surface layout.
  final _pipelines = <(GpuShader, GpuShader, VertexLayout), DevicePipeline>{};

  // What is currently bound to the render pass.
  GpuPipeline? _pipeline;
  Surface? _surface;
  int _bindingEpoch = 0;
  BlendState _blend = BlendState.opaque;
  CompareFunction _depthCompare = CompareFunction.less;
  bool _depthWrite = true;
  CullMode _cullMode = CullMode.none;
  WindingOrder _frontFace = WindingOrder.counterClockwise;

  /// Incremented whenever the pass's bindings are cleared (by [clearBindings]
  /// or by binding a different pipeline), after which every resource of the
  /// next draw must be bound again.
  int get bindingEpoch => _bindingEpoch;

  /// The winding order of front faces for the following draws.
  WindingOrder get frontFace => _frontFace;

  /// Whether a render pass is being recorded.
  bool get isInPass => _renderPass != null;

  /// Begin a new frame.
  ///
  /// Starts the frame whose transient storage is shared across all render
  /// passes. Call [end] when the frame is complete.
  void begin() {
    _frame++;
    stats.reset();
    // Reset the pool indices, each existing target becomes available again.
    _poolIndex.updateAll((_, _) => 0);
    _gpuFrame = backend.beginFrame();
  }

  /// End the frame.
  void end() {
    _gpuFrame?.end();
    _gpuFrame = null;
    _arena.endFrame();
    lastFrameStats.setFrom(stats);

    // Release the targets of sizes unused for a while, and the targets of a
    // size beyond how many were used in this frame.
    _pool.removeWhere((key, targets) {
      final used = _poolIndex[key] ?? 0;
      if (used == 0) {
        if (_frame - (_poolLastUsed[key] ?? _frame) < targetRetainFrames) {
          return false;
        }
        _poolIndex.remove(key);
        _poolLastUsed.remove(key);
        return true;
      }
      _poolLastUsed[key] = _frame;
      if (used < targets.length) {
        targets.removeRange(used, targets.length);
      }
      return false;
    });
    _textureTargetsLastUsed.removeWhere((key, lastUsed) {
      if (_frame - lastUsed < targetRetainFrames) {
        return false;
      }
      _textureTargets.remove(key);
      return true;
    });
  }

  /// Begin a render pass at the given [size], in physical pixels.
  ///
  /// The size is rounded to the nearest whole pixel (at least one). After
  /// [beginPass] is called, resources can be bound. Call [endPass] to finalize
  /// the pass and obtain the rendered [Image].
  ///
  /// [frontFace] is the winding order of front faces the pass starts with;
  /// pass [WindingOrder.clockwise] when the camera mirrors the scene. It can be
  /// changed per draw with [setFrontFace].
  ///
  /// Supported values for [msaaSampleCount] are `1` or `4`.
  void beginPass(
    Size size, {
    int msaaSampleCount = 1,
    WindingOrder frontFace = WindingOrder.counterClockwise,
  }) {
    final frame = _gpuFrame;
    if (frame == null) {
      throw StateError('beginPass must be called between begin and end');
    }
    RenderProfile.lap(RenderPhase.setup);
    _renderTarget = _acquireRenderTarget(size, msaaSampleCount);
    _startPass(frame.beginRenderPass(_renderTarget), frontFace);
    RenderProfile.lap(RenderPhase.passBegin);
  }

  /// Begins a render pass into a caller-owned [target] (created with
  /// [GpuBackend.createRenderTarget]) instead of the shared rotating pool.
  ///
  /// The [Image] returned by [endPass] is backed by [target]'s own color
  /// texture and is never overwritten by subsequent passes on other targets.
  void beginOwnedPass(
    GpuRenderTarget target, {
    WindingOrder frontFace = WindingOrder.counterClockwise,
  }) {
    final frame = _gpuFrame;
    if (frame == null) {
      throw StateError('beginOwnedPass must be called between begin and end');
    }
    RenderProfile.lap(RenderPhase.setup);
    _renderTarget = target;
    _startPass(frame.beginRenderPass(target), frontFace);
    RenderProfile.lap(RenderPhase.passBegin);
  }

  late final BloomPass _bloom = BloomPass(this);

  /// Applies GPU [BloomSettings] (and optional [PostProcessSettings]) to
  /// [sceneTarget] inside the active frame and returns the composited [Image].
  Image applyBloomFromTarget(
    GpuTextureTarget sceneTarget,
    BloomSettings? settings, {
    PostProcessSettings? postProcess,
    Texture? depthNormalTexture,
    GpuRenderTarget? outputTarget,
  }) {
    return _bloom.applyFromTarget(
      sceneTarget,
      settings,
      postProcess: postProcess,
      depthNormalTexture: depthNormalTexture,
      outputTarget: outputTarget,
    );
  }

  /// Number of compiled [DevicePipeline] instances cached on this device.
  int get cachedPipelineCount => _pipelines.length;

  /// Estimated GPU render-target memory (color + depth attachments, in bytes)
  /// currently pooled by this device.
  int get estimatedTargetVramBytes {
    var total = 0;
    for (final entry in _pool.entries) {
      final (w, h, samples) = entry.key;
      // Triple-buffered color + depth-stencil estimate.
      final perTarget = w * h * 4 * (3 + samples);
      total += perTarget * entry.value.length;
    }
    for (final key in _textureTargets.keys) {
      final (w, h, _, _) = key;
      total += w * h * 8;
    }
    return total;
  }

  /// Pre-compiles and caches the GPU [DevicePipeline] for [material] and
  /// [layout] (`VertexLayout.standard` by default) so its first draw in
  /// gameplay incurs zero shader-compilation stutter.
  DevicePipeline warmupMaterial(
    Material material, {
    VertexLayout? layout,
  }) {
    final resolvedLayout = layout ?? VertexLayout.standard;
    final vert = material.vertexShaderFor(resolvedLayout);
    return pipelineFor(vert, material.fragmentShader, resolvedLayout);
  }

  void _startPass(GpuRenderPass renderPass, WindingOrder frontFace) {
    _renderPass = renderPass;
    stats.renderPasses++;

    // The state every pass starts with, see `GpuFrame.beginRenderPass`.
    _pipeline = null;
    _surface = null;
    _bindingEpoch++;
    _blend = BlendState.opaque;
    _depthCompare = CompareFunction.less;
    _depthWrite = true;
    _cullMode = CullMode.none;
    _frontFace = WindingOrder.counterClockwise;
    if (frontFace != _frontFace) {
      renderPass.setWindingOrder(frontFace);
      _frontFace = frontFace;
      stats.stateChanges++;
    }
  }

  /// Submit the render pass to the GPU and return the rendered [Image].
  ///
  /// The caller owns the image and should dispose it once it has been drawn.
  Image endPass() {
    final renderPass = _pass;
    RenderProfile.lap(RenderPhase.release);
    _arena.flush();
    RenderProfile.lap(RenderPhase.upload);
    _renderPass = null;
    final image = renderPass.submit(onCompleted: _arena.passCompletion());
    RenderProfile.lap(RenderPhase.passEnd);
    return image;
  }

  /// The render target of [width]x[height] pixels that renders into a
  /// texture of [format] for later passes to sample (a shadow map, for
  /// instance), see [GpuTextureTarget].
  ///
  /// It is created on first use and kept: every call with the same size and
  /// format returns the same target, until a frame ends in which it was not
  /// used for [targetRetainFrames] frames. Throws an [UnsupportedError] when
  /// the backend cannot render into textures, see
  /// [GpuBackend.supportsTextureTargets].
  GpuTextureTarget textureTarget(
    int width,
    int height,
    GpuPixelFormat format, {
    Color clearValue = const Color(0xFFFFFFFF),
  }) {
    final key = (width, height, format, clearValue);
    final target = _textureTargets[key] ??= backend.createTextureTarget(
      width: width,
      height: height,
      format: format,
      clearValue: clearValue,
    );
    _textureTargetsLastUsed[key] = _frame;
    return target;
  }

  final _textureTargets =
      <(int, int, GpuPixelFormat, Color), GpuTextureTarget>{};
  final _textureTargetsLastUsed = <(int, int, GpuPixelFormat, Color), int>{};

  /// Marks [target] as used in the current frame so [targetRetainFrames] does
  /// not evict a cached texture target (such as a static shadow map).
  @internal
  void touchTextureTarget(GpuTextureTarget target) {
    for (final entry in _textureTargets.entries) {
      if (identical(entry.value, target)) {
        _textureTargetsLastUsed[entry.key] = _frame;
        return;
      }
    }
  }

  /// Begin a render pass into [target], whose texture later passes sample.
  ///
  /// The texture and the depth are cleared first. Bind and draw as in any
  /// pass, then call [endTexturePass]. [frontFace] is as for [beginPass].
  void beginTexturePass(
    GpuTextureTarget target, {
    WindingOrder frontFace = WindingOrder.counterClockwise,
  }) {
    final frame = _gpuFrame;
    if (frame == null) {
      throw StateError('beginTexturePass must be called between begin and end');
    }
    _renderTarget = target;
    _startPass(frame.beginRenderPass(target), frontFace);
  }

  /// Submit the pass begun by [beginTexturePass] to the GPU.
  ///
  /// The passes of a device run on the GPU in the order they end, so the
  /// passes that follow can sample the texture of its target.
  void endTexturePass() {
    final renderPass = _pass;
    RenderProfile.lap(RenderPhase.release);
    _arena.flush();
    RenderProfile.lap(RenderPhase.upload);
    _renderPass = null;
    renderPass.commit(onCompleted: _arena.passCompletion());
  }

  GpuRenderPass get _pass {
    return _renderPass ??
        (throw StateError('No render pass, call beginPass first'));
  }

  /// The [DevicePipeline] that draws surfaces with [layout] using
  /// [vertexShader] and [fragmentShader], created on first use.
  DevicePipeline pipelineFor(
    Shader vertexShader,
    Shader fragmentShader,
    VertexLayout layout,
  ) {
    final vertex = vertexShader.resource;
    final fragment = fragmentShader.resource;
    return _pipelines[(vertex, fragment, layout)] ??= DevicePipeline._create(
      backend,
      vertex,
      fragment,
      layout,
      _pipelines.length,
    );
  }

  /// Bind [pipeline].
  ///
  /// Binding a different pipeline clears every binding of the pass first, see
  /// [bindingEpoch]. Returns whether the pipeline changed.
  bool bindPipeline(DevicePipeline pipeline) {
    final gpuPipeline = pipeline.pipeline;
    if (identical(gpuPipeline, _pipeline)) {
      return false;
    }
    final renderPass = _pass;
    if (_pipeline != null) {
      renderPass.clearBindings();
    }
    renderPass.bindPipeline(gpuPipeline);
    _pipeline = gpuPipeline;
    _surface = null;
    _bindingEpoch++;
    stats.pipelineChanges++;
    return true;
  }

  /// Apply the blending, depth and culling of [state] to the following draws.
  ///
  /// Only the parts that differ from the current state are changed.
  void setRenderState(RenderState state) {
    final renderPass = _pass;
    if (state.blend != _blend) {
      renderPass.setBlendState(state.blend);
      _blend = state.blend;
      stats.stateChanges++;
    }
    final compare = state.effectiveDepthCompare;
    if (compare != _depthCompare || state.depthWrite != _depthWrite) {
      renderPass.setDepthState(
        compare: compare,
        writeEnabled: state.depthWrite,
      );
      _depthCompare = compare;
      _depthWrite = state.depthWrite;
      stats.stateChanges++;
    }
    if (state.cullMode != _cullMode) {
      renderPass.setCullMode(state.cullMode);
      _cullMode = state.cullMode;
      stats.stateChanges++;
    }
  }

  /// Set the winding order of front faces for the following draws.
  void setFrontFace(WindingOrder frontFace) {
    if (frontFace != _frontFace) {
      _pass.setWindingOrder(frontFace);
      _frontFace = frontFace;
      stats.stateChanges++;
    }
  }

  /// Clear all resources bound to the current render pass.
  void clearBindings() {
    _pass.clearBindings();
    _surface = null;
    _bindingEpoch++;
  }

  /// Bind the vertex and index buffers of [surface].
  void bindSurface(Surface surface) {
    if (identical(surface, _surface)) {
      return;
    }
    final buffer = surface.resource;
    _pass
      ..bindVertexBuffer(
        buffer,
        offsetInBytes: 0,
        lengthInBytes: surface.verticesBytes,
      )
      ..bindIndexBuffer(
        buffer,
        offsetInBytes: surface.indicesOffsetInBytes,
        lengthInBytes: surface.indicesBytes,
        indexType: surface.indexType,
      );
    _surface = surface;
    RenderProfile.lap(RenderPhase.binding);
  }

  /// Upload the first [count] instances of [instances] (each
  /// [VertexLayout.instanceStrideInFloats] floats) and bind them as the
  /// instance buffer.
  void bindInstances(Float32List instances, int count) {
    final floats = count * VertexLayout.instanceStrideInFloats;
    final block = _arena.allocate(floats * 4, _instanceAlignment);
    final offset = block.lastOffset;
    block.floats.setRange(offset ~/ 4, offset ~/ 4 + floats, instances);
    stats.uploadedBytes += floats * 4;
    RenderProfile.lap(RenderPhase.upload);
    _pass.bindVertexBuffer(
      block.buffer,
      offsetInBytes: offset,
      lengthInBytes: floats * 4,
      slot: 1,
    );
    RenderProfile.lap(RenderPhase.binding);
  }

  /// Upload the instances `order[start]` to `order[start + count - 1]` of
  /// [instances] (each [VertexLayout.instanceStrideInFloats] floats), in that
  /// order, and bind them as the instance buffer.
  ///
  /// It is [bindInstances] of the instances gathered together, without
  /// gathering them first.
  @internal
  void bindInstancesOf(
    Float32List instances,
    Int32List order,
    int start,
    int count,
  ) {
    const stride = VertexLayout.instanceStrideInFloats;
    final floats = count * stride;
    final block = _arena.allocate(floats * 4, _instanceAlignment);
    final offset = block.lastOffset;
    final target = block.floats;
    var at = offset ~/ 4;
    for (var i = start; i < start + count; i++) {
      final source = order[i] * stride;
      target.setRange(at, at + stride, instances, source);
      at += stride;
    }
    stats.uploadedBytes += floats * 4;
    RenderProfile.lap(RenderPhase.gather);
    _pass.bindVertexBuffer(
      block.buffer,
      offsetInBytes: offset,
      lengthInBytes: floats * 4,
      slot: 1,
    );
    RenderProfile.lap(RenderPhase.binding);
  }

  /// Draw the bound [surface] [instanceCount] times.
  void drawSurface(Surface surface, {int instanceCount = 1}) {
    _pass.drawIndexed(surface.indexCount, instanceCount: instanceCount);
    stats
      ..drawCalls += 1
      ..instances += instanceCount
      ..triangles += surface.indexCount ~/ 3 * instanceCount;
  }

  /// Bind a [surface]'s geometry (vertex/index buffers) and draw it once.
  void bindGeometry(Surface surface) {
    bindSurface(surface);
    drawSurface(surface);
  }

  /// Upload [data] and bind it to the uniform block [slot].
  void bindUniform(GpuUniformSlot slot, ByteData data) {
    final block = _uploadUniform(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    _pass.bindUniform(
      slot,
      block.buffer,
      offsetInBytes: block.lastOffset,
      lengthInBytes: data.lengthInBytes,
    );
  }

  /// Bind [block] to its slot, uploading it first unless its current contents
  /// were already uploaded during this frame.
  void bindUniformBlock(UniformBlock block) {
    RenderProfile.lap(RenderPhase.binding);
    if (block.isDirty || block.uploadFrame != _frame) {
      final upload = _uploadUniform(block.byteList);
      block.markUploaded(_frame, upload.buffer, upload.lastOffset);
      RenderProfile.lap(RenderPhase.upload);
    }
    _pass.bindUniform(
      block.slot,
      block.uploadBuffer!,
      offsetInBytes: block.uploadOffset,
      lengthInBytes: block.bytes.lengthInBytes,
    );
    RenderProfile.lap(RenderPhase.binding);
  }

  /// Bind a uniform [slot] to the [texture], sampled with its
  /// [Texture.sampler].
  void bindTexture(GpuUniformSlot slot, Texture texture) {
    _pass.bindTexture(slot, texture.resource, sampler: texture.sampler);
    RenderProfile.lap(RenderPhase.binding);
  }

  _TransientBlock _uploadUniform(Uint8List data) {
    final length = data.length;
    final block = _arena.allocate(length, backend.uniformAlignment);
    block.staging.setRange(block.lastOffset, block.lastOffset + length, data);
    stats
      ..uniformUploads += 1
      ..uploadedBytes += length;
    return block;
  }

  /// Acquire a render target from the pool, creating one if needed.
  ///
  /// Multiple passes at the same size within a frame get distinct targets.
  /// Targets are reused across frames.
  GpuRenderTarget _acquireRenderTarget(Size size, int msaaSampleCount) {
    final key = (
      _pixels(size.width),
      _pixels(size.height),
      msaaSampleCount,
    );
    final targets = _pool.putIfAbsent(key, () => []);
    final index = _poolIndex.putIfAbsent(key, () => 0);

    if (index < targets.length) {
      _poolIndex[key] = index + 1;
      return targets[index];
    }

    // Pool exhausted for this size — create a new target.
    final target = backend.createRenderTarget(
      width: key.$1,
      height: key.$2,
      clearValue: clearValue,
      msaaSampleCount: key.$3,
    );

    targets.add(target);
    _poolIndex[key] = index + 1;
    return target;
  }

  /// Rounds a size in pixels to a whole number of at least one pixel.
  static int _pixels(double size) {
    final pixels = size.round();
    return pixels < 1 ? 1 : pixels;
  }

  static const _instanceAlignment = 16;
}

/// {@template device_pipeline}
/// A render pipeline built by a [GraphicsDevice] for one vertex shader,
/// fragment shader and surface [VertexLayout], with what the device learned
/// about how it reads its inputs.
/// {@endtemplate}
class DevicePipeline._(
  /// The backend pipeline.
  final GpuPipeline pipeline, {

  /// A number identifying this pipeline within its device, usable to sort
  /// draws by pipeline.
  required final int id,

  /// Whether the vertex shader reads per-instance data, so an instance buffer
  /// must be bound for every draw.
  required final bool usesInstanceData,

  /// Whether the vertex shader reads its model matrix from the instance data,
  /// so draws of the same surface and material can be batched into one
  /// instanced draw.
  required final bool instanced,
}) {
  factory DevicePipeline._create(
    GpuBackend backend,
    GpuShader vertexShader,
    GpuShader fragmentShader,
    VertexLayout layout,
    int id,
  ) {
    final vertexAttributes = <GpuVertexAttribute>[];
    final instanceAttributes = <GpuVertexAttribute>[];
    final inputs = vertexShader.inputs;

    void addInstanceAttribute(int index, String name, int location) {
      instanceAttributes.add(
        GpuVertexAttribute(
          name: name,
          location: location,
          components: VertexLayout.instanceAttributes[index].components,
          offsetInBytes: index * 16,
        ),
      );
    }

    if (inputs == null) {
      // Without reflection, assume the shader reads the whole layout and every
      // instance input, in that order (as the built-in shaders do).
      for (final (index, attribute) in layout.attributes.indexed) {
        vertexAttributes.add(
          GpuVertexAttribute(
            name: attribute.name,
            location: index,
            components: attribute.components,
            offsetInBytes: layout.offsetOf(attribute.name)! * 4,
          ),
        );
      }
      for (final (index, attribute)
          in VertexLayout.instanceAttributes.indexed) {
        addInstanceAttribute(
          index,
          attribute.name,
          layout.attributes.length + index,
        );
      }
    } else {
      for (final input in inputs) {
        final attribute = layout.attribute(input.name);
        if (attribute != null) {
          vertexAttributes.add(
            GpuVertexAttribute(
              name: input.name,
              location: input.location,
              components: attribute.components,
              offsetInBytes: layout.offsetOf(input.name)! * 4,
            ),
          );
          continue;
        }
        final instanceIndex = VertexLayout.instanceAttributes.indexWhere(
          (a) => a.name == input.name,
        );
        if (instanceIndex < 0) {
          final instanceInputs = VertexLayout.instanceAttributes
              .map((a) => a.name)
              .join(', ');
          throw StateError(
            'The vertex shader input "${input.name}" is not provided by the '
            'surface vertex layout $layout, nor is it an instance input '
            '($instanceInputs)',
          );
        }
        addInstanceAttribute(instanceIndex, input.name, input.location);
      }
    }

    final modelColumns = instanceAttributes
        .where((a) => a.name.startsWith('instanceModel'))
        .length;
    if (modelColumns != 0 && modelColumns != 4) {
      throw StateError(
        'A vertex shader must declare all four instanceModel columns or none',
      );
    }

    final pipeline = backend.createPipeline(
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      vertexLayout: GpuVertexLayout([
        GpuVertexBufferLayout(
          strideInBytes: layout.strideInBytes,
          attributes: vertexAttributes,
        ),
        if (instanceAttributes.isNotEmpty)
          GpuVertexBufferLayout(
            strideInBytes: VertexLayout.instanceStrideInFloats * 4,
            attributes: instanceAttributes,
            perInstance: true,
          ),
      ]),
    );
    return DevicePipeline._(
      pipeline,
      id: id,
      usesInstanceData: instanceAttributes.isNotEmpty,
      instanced: modelColumns == 4,
    );
  }
}

/// A host-visible GPU buffer and its CPU staging copy.
class _TransientBlock(final GpuBuffer buffer, final int capacity) {
  late final Uint8List staging = Uint8List(capacity);
  late final Float32List floats = staging.buffer.asFloat32List();

  /// Bytes allocated this frame.
  int used = 0;

  /// Bytes already uploaded to [buffer].
  int flushed = 0;

  /// The offset of the latest allocation.
  int lastOffset = 0;

  void flush() {
    if (used > flushed) {
      buffer.write(
        ByteData.sublistView(staging, flushed, used),
        destinationOffsetInBytes: flushed,
      );
      flushed = used;
    }
  }
}

/// The transient blocks used by one frame.
class _FrameUploads() {
  final List<_TransientBlock> blocks = [];

  /// The number of passes submitted but not completed yet.
  int pendingPasses = 0;

  /// Whether the frame ended, so no more passes will use its blocks.
  bool ended = false;
}

/// Sub-allocates the uniform and instance data of a frame from a pool of
/// [_TransientBlock]s, uploads it once per pass and recycles the blocks once
/// the GPU completed every pass of the frame that used them.
class _TransientArena(final GpuBackend _backend) {
  static const _blockSize = 256 * 1024;
  static const _maxFreeBlocks = 8;

  final List<_TransientBlock> _free = [];
  _FrameUploads _frame = _FrameUploads();
  _TransientBlock? _current;

  /// Reserves [size] bytes aligned to [alignment] and returns the block they
  /// are in, with [_TransientBlock.lastOffset] set to their offset.
  _TransientBlock allocate(int size, int alignment) {
    var block = _current;
    if (block != null) {
      final offset = _align(block.used, alignment);
      if (offset + size <= block.capacity) {
        block
          ..lastOffset = offset
          ..used = offset + size;
        return block;
      }
    }
    block = _current = _takeBlock(size);
    _frame.blocks.add(block);
    return block
      ..lastOffset = 0
      ..used = size;
  }

  _TransientBlock _takeBlock(int size) {
    for (var i = 0; i < _free.length; i++) {
      final block = _free[i];
      if (block.capacity >= size) {
        _free.removeAt(i);
        return block
          ..used = 0
          ..flushed = 0;
      }
    }
    var capacity = _blockSize;
    while (capacity < size) {
      capacity *= 2;
    }
    return _TransientBlock(
      _backend.createBuffer(
        storageMode: GpuStorageMode.hostVisible,
        sizeInBytes: capacity,
      ),
      capacity,
    );
  }

  /// Uploads the data allocated since the last flush.
  void flush() {
    for (final block in _frame.blocks) {
      block.flush();
    }
  }

  /// The callback a pass calls once the GPU completed it.
  void Function() passCompletion() {
    final frame = _frame;
    frame.pendingPasses++;
    return () {
      frame.pendingPasses--;
      if (frame.ended && frame.pendingPasses == 0) {
        _release(frame);
      }
    };
  }

  /// Ends the frame: its blocks are recycled once all its passes completed.
  void endFrame() {
    final frame = _frame..ended = true;
    if (frame.pendingPasses == 0) {
      _release(frame);
    }
    _frame = _FrameUploads();
    _current = null;
  }

  void _release(_FrameUploads frame) {
    for (final block in frame.blocks) {
      if (_free.length < _maxFreeBlocks) {
        _free.add(block);
      }
    }
    frame.blocks.clear();
  }

  static int _align(int value, int alignment) {
    final remainder = value % alignment;
    return remainder == 0 ? value : value + alignment - remainder;
  }
}
