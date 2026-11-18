part of 'render_context_3d.dart';

/// Half-resolution clip-depth + view-space normal prepass enabling mobile SSAO,
/// 3D Depth of Field, Soft Particles (`ParticleMaterial.softDepthFade`), and
/// shoreline intersection foam (`WaterMaterial.shoreFoamDepth`) on every
/// Flutter GPU backend without sampling depth-stencil attachments.
class _DepthNormalPass(final RenderContext3D _context) {
  bool recording = false;
  bool active = false;

  GpuTextureTarget? _target;
  Texture? _texture;
  int _width = 1;
  int _height = 1;

  static const _bundle =
      'packages/flame_3d/assets/shaders/depth_normal_prepass.shaderbundle';
  static const _skinnedBundle =
      'packages/flame_3d/assets/shaders/'
      'depth_normal_prepass_skinned.shaderbundle';

  late final Shader _vertexShader = VertexShader.fromAsset(
    _bundle,
    slots: [RenderContext3D.cameraMatricesBlock],
  );
  late final Shader _skinnedVertexShader = VertexShader.fromAsset(
    _skinnedBundle,
    slots: [
      RenderContext3D.cameraMatricesBlock,
      RenderContext3D.jointMatricesBlock,
    ],
  );
  late final Shader _fragmentShader = FragmentShader.fromAsset(_bundle);

  static const _renderState = RenderState.opaque;
  final Map<VertexLayout, _CasterPipeline> _pipelines = Map.identity();

  bool begin(int sceneWidth, int sceneHeight) {
    if (recording) {
      throw StateError('A depth-normal prepass is already being recorded');
    }
    final context = _context;
    final device = context.device;
    active = false;
    if (!device.backend.supportsTextureTargets) {
      return false;
    }

    _width = math.max(1, sceneWidth >> 1);
    _height = math.max(1, sceneHeight >> 1);
    final target = device.textureTarget(
      _width,
      _height,
      GpuPixelFormat.rgba8888,
      clearValue: const Color(0xFFFF8080),
    );
    if (!identical(target, _target)) {
      _target = target;
      _texture = Texture(
        null,
        width: _width,
        height: _height,
        sampler: TextureSampler.linear,
        gpuTexture: target.texture,
      );
    }

    recording = true;
    device.beginTexturePass(target, frontFace: context.frontFace);
    return true;
  }

  void end() {
    if (!recording) {
      throw StateError('No depth-normal prepass is being recorded');
    }
    final context = _context;
    final device = context.device;
    try {
      _flushOpaqueDepthNormals();
    } finally {
      device.endTexturePass();
      recording = false;
      active = true;
    }
  }

  void clear() {
    active = false;
  }

  void _flushOpaqueDepthNormals() {
    final context = _context;
    final count = context._count;
    final order = context._opaque;
    final groupKeys = context._groupKeys;
    final surfaceKeys = context._surfaceKeys;
    final sortDepths = context._sortDepths;
    var opaqueCount = 0;

    VertexLayout? lastLayout;
    _CasterPipeline? pipe;
    for (var i = 0; i < count; i++) {
      final mat = context._materials[i]!;
      if (mat.renderState.translucent || !mat.renderState.depthWrite) {
        continue;
      }
      final surface = context._surfaces[i]!;
      final layout = surface.layout;
      if (!identical(layout, lastLayout)) {
        lastLayout = layout;
        pipe = _pipelineFor(layout);
      }
      if (pipe == null) {
        continue;
      }
      final pipeline = pipe.pipeline;
      context._pipelines[i] = pipeline;
      groupKeys[i] = pipeline.id.toDouble();
      surfaceKeys[i] = surface.id * 2 + (context._joints[i] == null ? 0 : 1);
      sortDepths[i] = context._depths[i];
      order[opaqueCount++] = i;
    }

    context._sort(order, opaqueCount);
    context._boundMaterial = null;
    context._bindingEpoch = -1;

    var start = 0;
    while (start < opaqueCount) {
      final first = order[start];
      var end = start + 1;
      if (context._joints[first] == null && context._external[first] == null) {
        while (end < opaqueCount && _batchesWith(first, order[end])) {
          end++;
        }
      }
      _submit(order, start, end - start);
      start = end;
    }

    context
      .._releaseDraws(count)
      .._jointTransforms = null;
    context._lastDrawCount = count;
    context._count = 0;
  }

  bool _batchesWith(int first, int other) {
    final context = _context;
    return identical(context._surfaces[first], context._surfaces[other]) &&
        identical(context._pipelines[first], context._pipelines[other]) &&
        context._joints[other] == null &&
        context._external[other] == null;
  }

  void _submit(Int32List order, int start, int count) {
    final context = _context;
    final device = context.device;
    final first = order[start];
    final surface = context._surfaces[first]!;
    final vertexShader = _pipelines[surface.layout]!.skinned
        ? _skinnedVertexShader
        : _vertexShader;

    device.bindPipeline(context._pipelines[first]!);
    if (device.bindingEpoch != context._bindingEpoch) {
      context
        .._bindingEpoch = device.bindingEpoch
        .._bindSlots(vertexShader, RenderContext3D._passScope);
    }
    device
      ..setRenderState(_renderState)
      ..setFrontFace(context.frontFace);
    context._bindJoints(vertexShader, context._joints[first]);
    device.bindSurface(surface);

    final external = context._external[first];
    if (external != null) {
      final instanceCount = context._externalCounts[first];
      device
        ..bindInstances(external, instanceCount)
        ..drawSurface(surface, instanceCount: instanceCount);
      return;
    }
    device
      ..bindInstancesOf(context._instances, order, start, count)
      ..drawSurface(surface, instanceCount: count);
  }

  _CasterPipeline? _pipelineFor(VertexLayout layout) {
    var entry = _pipelines[layout];
    if (entry == null) {
      final position = layout.attribute(VertexLayout.positionAttribute);
      final skinned =
          layout.attribute('vertexJoints')?.components == 4 &&
          layout.attribute('vertexWeights')?.components == 4;
      entry = _pipelines[layout] = _CasterPipeline(
        drawable: position != null && position.components == 3,
        skinned: skinned,
      );
    }
    if (!entry.drawable) {
      return null;
    }
    final vertexShader = entry.skinned ? _skinnedVertexShader : _vertexShader;
    final fragmentShader = _fragmentShader;
    vertexShader.resource;
    fragmentShader.resource;
    if (entry._pipeline == null ||
        entry._vertexGeneration != vertexShader.generation ||
        entry._fragmentGeneration != fragmentShader.generation) {
      entry
        .._pipeline = _context.device.pipelineFor(
          vertexShader,
          fragmentShader,
          layout,
        )
        .._vertexGeneration = vertexShader.generation
        .._fragmentGeneration = fragmentShader.generation;
    }
    return entry;
  }

  static final Vector4 _scratchParams = Vector4.zero();

  static void writeUniforms(RenderContext3D context, UniformBlock block) {
    final dn = context._depthNormal;
    block.setVector4(
      'params',
      _scratchParams..setValues(
        dn.active ? 1.0 : 0.0,
        1.0 / dn._width,
        1.0 / dn._height,
        0.0,
      ),
    );
  }

  static Texture passTexture(RenderContext3D context) {
    final dn = context._depthNormal;
    return dn.active ? dn._texture! : Texture.standard;
  }
}
