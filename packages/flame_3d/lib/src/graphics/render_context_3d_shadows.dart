part of 'render_context_3d.dart';

/// The shadow pass of a [RenderContext3D]: finds the light that casts
/// shadows, fits its shadow map, renders the casters into it with depth-only
/// shaders, and gives the map to the shaders of the main pass.
///
/// The casters are the draws recorded during the pass, whatever their
/// material (as long as it casts shadows): they are drawn with
/// `shaders/shadow_caster.vert`, which reads the position of any vertex
/// layout (and `shadow_caster_skinned.vert` for layouts with joints and
/// joint weights), so draws of one surface batch into one instanced draw even
/// across materials.
class _ShadowPass(final RenderContext3D _context) {
  /// Whether the draws being recorded are those of a shadow map.
  bool recording = false;

  /// Whether the pass whose camera is set receives shadows.
  bool active = false;

  /// Incremented every time a shadow pass renders a map, see
  /// [RenderContext3D.shadowMapVersion].
  int version = 0;

  // The values of the Shadows block of the main pass.
  final Matrix4 _lightViewProjection = Matrix4.identity();
  final Matrix4 _cascadeViewProjection = Matrix4.identity();
  final Vector4 _toLight = Vector4(0, 0, 0, -1);
  final Vector4 _color = Vector4.zero();
  final Vector4 _map = Vector4.zero();
  final Vector4 _bias = Vector4.zero();
  final Vector4 _decode = Vector4.zero();
  final Vector4 _cascadeParams = Vector4(1, 0, 0, 0);
  bool _packDepth = false;

  // Two-cascade CSM & SpotLight shadow helpers.
  final DirectionalShadowProjection _farProjection =
      DirectionalShadowProjection();
  bool _pendingCascade1 = false;
  int _csmResolution = 1024;
  GpuTextureTarget? _csmTarget0;
  GpuTextureTarget? _csmTarget1;
  GpuTextureTarget? _csmAtlasTarget;
  final Matrix4 _spotView = Matrix4.identity();
  final Matrix4 _spotProj = Matrix4.identity();
  final Vector3 _spotTarget = Vector3.zero();
  final Vector3 _spotUp = Vector3(0, 1, 0);

  bool get needsCascade1 => _pendingCascade1;

  // The shadow map, as the texture bound to the receivers.
  GpuTextureTarget? _target;
  Texture? _texture;
  final Expando<_StaticShadowMap> _staticMaps = Expando();

  // The camera of the main pass, set back when the shadow pass ends.
  final Matrix4 _mainView = Matrix4.identity();
  final Matrix4 _mainProjection = Matrix4.identity();
  int _drawCallsBefore = 0;

  static final Vector3 _direction = Vector3.zero();
  static final Vector4 _noShadows = Vector4(0, 0, 0, -1);

  /// Decodes a texel of a packed map, see `packShadowDepth` in
  /// `shaders/flame_3d/shadow_caster_fragment.glsl`: 24 bits of depth in its
  /// red, green and blue channels, most significant first.
  static final Vector4 _packedDecode = Vector4(
    65536 * 255 / 16777215,
    256 * 255 / 16777215,
    255 / 16777215,
    0,
  );

  static const _bundle =
      'packages/flame_3d/assets/shaders/shadow_caster.shaderbundle';
  static const _skinnedBundle =
      'packages/flame_3d/assets/shaders/shadow_caster_skinned.shaderbundle';
  static const _atlasPackBundle =
      'packages/flame_3d/assets/shaders/shadow_atlas_pack.shaderbundle';

  static final Surface _atlasQuad = Surface.fromBuffers(
    vertices: Float32List.fromList(const [
      -1.0, -1.0, 0.0, //
      1.0, -1.0, 0.0, //
      1.0, 1.0, 0.0, //
      -1.0, 1.0, 0.0, //
    ]),
    indices: Uint16List.fromList(const [0, 1, 2, 0, 2, 3]),
    layout: VertexLayout(const [
      VertexAttribute(VertexLayout.positionAttribute, 3),
    ]),
  );

  late final Shader _atlasVert = VertexShader.fromAsset(_atlasPackBundle);
  late final Shader _atlasFrag = FragmentShader.fromAsset(
    _atlasPackBundle,
    slots: const ['cascade0Texture', 'cascade1Texture'],
  );

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
  late final Shader _fragmentShader = FragmentShader.fromAsset(
    _bundle,
    slots: [RenderContext3D.shadowCasterBlock],
  );

  /// Casters write their depth, whatever their material's state: opaque,
  /// depth tested, both faces.
  static const _renderState = RenderState.opaque;

  final Map<VertexLayout, _CasterPipeline> _pipelines = Map.identity();

  bool begin(
    DirectionalShadowProjection projection,
    Aabb3? sceneBounds, {
    Object? castersKey,
  }) {
    if (recording) {
      throw StateError('A shadow pass is already being recorded');
    }
    final context = _context;
    final device = context.device;
    active = false;
    RenderProfile.switchPass(RenderPhase.setup, shadow: true);
    if (sceneBounds == null || !device.backend.supportsTextureTargets) {
      return _none();
    }

    // The first directional light with shadows (matching `cameraMask`), or else
    // the first spot light with shadows.
    final lights = context.lights;
    Light? light;
    ShadowSettings? settings;
    var index = 0;
    var isSpotShadow = false;
    for (var i = 0; i < lights.length; i++) {
      if ((lights[i].lightMask & context.cameraMask) == 0) {
        continue;
      }
      final source = lights[i].source;
      if (source is! DirectionalLight) {
        continue;
      }
      if (index == RenderContext3D.maxDirectionalLights) {
        break;
      }
      final shadows = source.shadows;
      if (shadows != null) {
        light = lights[i];
        settings = shadows;
        break;
      }
      index++;
    }
    if (light == null || settings == null) {
      var spotIdx = 0;
      for (var i = 0; i < lights.length; i++) {
        if ((lights[i].lightMask & context.cameraMask) == 0) {
          continue;
        }
        final source = lights[i].source;
        if (source is! SpotLight || source.intensity <= 0) {
          continue;
        }
        if (spotIdx == RenderContext3D.maxSpotLights) {
          break;
        }
        if (source.shadows != null) {
          light = lights[i];
          settings = source.shadows;
          index = 100 + spotIdx;
          isSpotShadow = true;
          break;
        }
        spotIdx++;
      }
    }
    if (light == null || settings == null) {
      return _none();
    }

    _pendingCascade1 = false;
    _cascadeParams.setValues(1, 0, 0, 0);

    final direction = light.direction(_direction);
    final resolution = settings.resolution;
    final Matrix4 activeLightView;
    final Matrix4 activeLightProj;
    final double texelWorldSize;

    if (isSpotShadow) {
      final spot = light.source as SpotLight;
      final eye = light.position;
      _spotTarget
        ..setFrom(eye)
        ..add(direction);
      _spotUp.setValues(0, 1, 0);
      if (direction.y.abs() > 0.92) {
        _spotUp.setValues(0, 0, 1);
      }
      _spotView.setAsViewMatrix(eye, _spotTarget, _spotUp);
      final fovDeg = (spot.outerConeAngle * 2.0 * 180.0 / math.pi).clamp(
        10.0,
        165.0,
      );
      final zFar = math.max(1.0, spot.range ?? 32.0);
      _spotProj.setAsPerspective(fovDeg, 1.0, 0.12, zFar);
      _lightViewProjection
        ..setFrom(_spotProj)
        ..multiply(_spotView);
      activeLightView = _spotView;
      activeLightProj = _spotProj;
      texelWorldSize =
          (2.0 * math.tan(spot.outerConeAngle.clamp(0.05, 1.4)) * zFar * 0.35) /
          resolution;
    } else if (settings.cascades == 2) {
      final farDist = settings.maxDistance;
      final split = settings.cascadeSplitRatio.clamp(0.08, 0.85);
      if (!_farProjection.update(
        direction: direction,
        casters: sceneBounds,
        receivers: settings.bounds,
        cameraViewProjection: settings.fit == ShadowFit.view
            ? context._viewProjectionMatrix
            : null,
        cameraView: context._viewMatrix,
        maxDistance: farDist,
        resolution: resolution,
        stabilize: settings.stabilize,
      )) {
        return _none();
      }
      final isPerspectiveCam =
          context._projectionMatrix.storage[15].abs() < 0.5;
      var nearFitted = false;
      if (isPerspectiveCam) {
        final nearDist = (farDist ?? 40.0) * split;
        nearFitted = projection.update(
          direction: direction,
          casters: sceneBounds,
          receivers: settings.bounds,
          cameraViewProjection: context._viewProjectionMatrix,
          cameraView: context._viewMatrix,
          maxDistance: nearDist,
          resolution: resolution,
          stabilize: settings.stabilize,
        );
      }
      if (!nearFitted) {
        final fullBox = settings.bounds ?? sceneBounds;
        final c = fullBox.center;
        final half = (fullBox.max - fullBox.min)..scale(0.5 * split);
        final innerBox = Aabb3.minMax(c - half, c + half);
        nearFitted = projection.update(
          direction: direction,
          casters: sceneBounds,
          receivers: innerBox,
          resolution: resolution,
          stabilize: settings.stabilize,
        );
      }
      if (!nearFitted) {
        return _none();
      }
      _lightViewProjection.setFrom(projection.viewProjection);
      _cascadeViewProjection.setFrom(_farProjection.viewProjection);
      _cascadeParams.setValues(
        2.0,
        math.max(_farProjection.texelWidth, _farProjection.texelHeight),
        0,
        0,
      );
      activeLightView = projection.view;
      activeLightProj = projection.projection;
      texelWorldSize = math.max(projection.texelWidth, projection.texelHeight);
    } else {
      if (!projection.update(
        direction: direction,
        casters: sceneBounds,
        receivers: settings.bounds,
        cameraViewProjection: settings.fit == ShadowFit.view
            ? context._viewProjectionMatrix
            : null,
        cameraView: context._viewMatrix,
        maxDistance: settings.maxDistance,
        resolution: resolution,
        stabilize: settings.stabilize,
      )) {
        return _none();
      }
      _lightViewProjection.setFrom(projection.viewProjection);
      activeLightView = projection.view;
      activeLightProj = projection.projection;
      texelWorldSize = math.max(projection.texelWidth, projection.texelHeight);
    }
    RenderProfile.lap(RenderPhase.shadowSetup);

    final float = switch (settings.encoding) {
      ShadowMapEncoding.auto => device.backend.supportsFloatTextureTargets,
      ShadowMapEncoding.float32 => true,
      ShadowMapEncoding.rgba8 => false,
    };

    final format = float ? GpuPixelFormat.r32Float : GpuPixelFormat.rgba8888;
    final size = resolution.toDouble();
    final vpStorage = _lightViewProjection.storage;
    final isTwoCascade = !isSpotShadow && settings.cascades == 2;

    // Static shadow map reuse (`cascades == 1` directional/spot).
    if (!isTwoCascade && settings.cacheWhenStatic && castersKey != null) {
      final cached = _staticMaps[projection];
      if (cached != null &&
          cached.resolution == resolution &&
          cached.packDepth == !float &&
          cached.castersKey == castersKey &&
          _sameMatrix(vpStorage, cached.lightVp)) {
        if (!identical(_texture, cached.texture)) {
          version++;
          _target = cached.target;
          _texture = cached.texture;
        }
        _packDepth = !float;
        if (float) {
          _decode.setValues(1, 0, 0, 0);
        } else {
          _decode.setFrom(_packedDecode);
        }
        _toLight.setValues(
          -direction.x,
          -direction.y,
          -direction.z,
          index.toDouble(),
        );
        final color = settings.color;
        _color.setValues(
          color.r,
          color.g,
          color.b,
          settings.strength.clamp(0, 1).toDouble(),
        );
        _map.setValues(size, size, 1 / size, 1 / size);
        _bias.setValues(
          texelWorldSize,
          settings.depthBias,
          settings.normalBias,
          settings.softness.toDouble(),
        );
        active = true;
        RenderProfile.switchPass(RenderPhase.shadowSetup, shadow: false);
        return false;
      }
    }

    // From here on, a fresh shadow map will be rendered.
    version++;
    final GpuTextureTarget target;
    if (isTwoCascade) {
      _staticMaps[projection] = null;
      _csmResolution = resolution;
      _csmTarget0 = device.textureTarget(
        resolution,
        resolution,
        format,
        clearValue: const Color(0xFFFFFFFE),
      );
      _csmTarget1 = device.textureTarget(
        resolution,
        resolution,
        format,
        clearValue: const Color(0xFFFFFFFD),
      );
      _csmAtlasTarget = device.textureTarget(
        resolution * 2,
        resolution,
        format,
      );
      target = _csmTarget0!;
      _target = _csmAtlasTarget;
      _texture = Texture(
        null,
        width: resolution * 2,
        height: resolution,
        gpuTexture: _csmAtlasTarget!.texture,
      );
      _pendingCascade1 = true;
    } else if (settings.cacheWhenStatic && castersKey != null) {
      var entry = _staticMaps[projection];
      if (entry == null ||
          entry.resolution != resolution ||
          entry.packDepth != !float) {
        final ownedTarget = device.backend.createTextureTarget(
          width: resolution,
          height: resolution,
          format: format,
          clearValue: const Color(0xFFFFFFFF),
        );
        entry = _StaticShadowMap(
          resolution: resolution,
          packDepth: !float,
          target: ownedTarget,
          texture: Texture(
            null,
            width: resolution,
            height: resolution,
            gpuTexture: ownedTarget.texture,
          ),
        );
        _staticMaps[projection] = entry;
      }
      entry.castersKey = castersKey;
      for (var i = 0; i < 16; i++) {
        entry.lightVp[i] = vpStorage[i];
      }
      target = entry.target;
      _target = target;
      _texture = entry.texture;
    } else {
      _staticMaps[projection] = null;
      target = device.textureTarget(resolution, resolution, format);
      if (!identical(target, _target)) {
        _target = target;
        _texture = Texture(
          null,
          width: resolution,
          height: resolution,
          gpuTexture: target.texture,
        );
      }
    }
    _packDepth = !float;
    if (float) {
      _decode.setValues(1, 0, 0, 0);
    } else {
      _decode.setFrom(_packedDecode);
    }
    _toLight.setValues(
      -direction.x,
      -direction.y,
      -direction.z,
      index.toDouble(),
    );
    final color = settings.color;
    _color.setValues(
      color.r,
      color.g,
      color.b,
      settings.strength.clamp(0, 1).toDouble(),
    );
    if (isTwoCascade) {
      final atlasW = size * 2.0;
      _map.setValues(atlasW, size, 1.0 / atlasW, 1.0 / size);
    } else {
      _map.setValues(size, size, 1 / size, 1 / size);
    }
    _bias.setValues(
      texelWorldSize,
      settings.depthBias,
      settings.normalBias,
      settings.softness.toDouble(),
    );

    _mainView.setFrom(context._viewMatrix);
    _mainProjection.setFrom(context._projectionMatrix);
    context.setCamera(activeLightView, activeLightProj);
    recording = true;
    _drawCallsBefore = device.stats.drawCalls;
    device.beginTexturePass(target, frontFace: context.frontFace);
    device.stats.shadowPasses++;
    RenderProfile.lap(RenderPhase.passBegin);
    return true;
  }

  /// Ends a [begin] that found no shadows to render.
  bool _none() {
    RenderProfile.switchPass(RenderPhase.shadowSetup, shadow: false);
    return false;
  }

  /// Makes the pass whose camera is set receive the map of the last shadow
  /// pass, when it is still the map of [mapVersion].
  bool reuse(int mapVersion) {
    if (recording) {
      throw StateError('A shadow pass is being recorded');
    }
    if (mapVersion != version || _texture == null) {
      return false;
    }
    active = true;
    return true;
  }

  void end() {
    if (!recording) {
      throw StateError('No shadow pass is being recorded');
    }
    final context = _context;
    final device = context.device;
    try {
      RenderProfile.lap(RenderPhase.traversal);
      flushCasters();
    } finally {
      device.endTexturePass();
      device.stats.shadowDrawCalls += device.stats.drawCalls - _drawCallsBefore;
      recording = false;
      RenderProfile.switchPass(RenderPhase.passEnd, shadow: false);
      context.setCamera(_mainView, _mainProjection);
      active = true;
      RenderProfile.lap(RenderPhase.setup);
    }
  }

  /// Draws the recorded draws whose material casts shadows into the shadow
  /// map: grouped by pipeline and surface, front to back from the light, and
  /// batched across materials.
  void flushCasters() {
    final context = _context;
    final count = context._count;
    final order = context._opaque;
    final groupKeys = context._groupKeys;
    final surfaceKeys = context._surfaceKeys;
    final sortDepths = context._sortDepths;
    var casters = 0;
    // Consecutive draws mostly share their layout, and so their caster.
    VertexLayout? lastLayout;
    _CasterPipeline? caster;
    for (var i = 0; i < count; i++) {
      if (!context._materials[i]!.castsShadows) {
        continue;
      }
      final surface = context._surfaces[i]!;
      final layout = surface.layout;
      if (!identical(layout, lastLayout)) {
        lastLayout = layout;
        caster = _casterFor(layout);
      }
      if (caster == null) {
        continue;
      }
      final pipeline = caster.pipeline;
      context._pipelines[i] = pipeline;
      groupKeys[i] = pipeline.id.toDouble();
      // Skinned draws are never batched: keep them apart from the others.
      surfaceKeys[i] = surface.id * 2 + (context._joints[i] == null ? 0 : 1);
      sortDepths[i] = context._depths[i];
      order[casters++] = i;
    }
    context._sort(order, casters);
    RenderProfile.lap(RenderPhase.sort);

    context._boundMaterial = null;
    context._bindingEpoch = -1;
    var start = 0;
    while (start < casters) {
      final first = order[start];
      var end = start + 1;
      // Skinned draws and draws of instances the caller filled (particle
      // systems, `drawInstances`) are drawn on their own.
      if (context._joints[first] == null && context._external[first] == null) {
        while (end < casters && _batchesWith(first, order[end])) {
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
    RenderProfile.lap(RenderPhase.release);
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
    RenderProfile.lap(RenderPhase.batch);

    device.bindPipeline(context._pipelines[first]!);
    if (device.bindingEpoch != context._bindingEpoch) {
      context
        .._bindingEpoch = device.bindingEpoch
        .._bindSlots(vertexShader, RenderContext3D._passScope)
        .._bindSlots(_fragmentShader, RenderContext3D._passScope);
    }
    device
      ..setRenderState(_renderState)
      ..setFrontFace(WindingOrder.counterClockwise);
    RenderProfile.lap(RenderPhase.state);
    context._bindJoints(vertexShader, context._joints[first]);
    device.bindSurface(surface);
    final external = context._external[first];
    if (external != null) {
      final instanceCount = context._externalCounts[first];
      device
        ..bindInstances(external, instanceCount)
        ..drawSurface(surface, instanceCount: instanceCount);
      RenderProfile.lap(RenderPhase.draw);
      return;
    }
    device
      ..bindInstancesOf(context._instances, order, start, count)
      ..drawSurface(surface, instanceCount: count);
    RenderProfile.lap(RenderPhase.draw);
  }

  /// The caster pipeline for surfaces laid out as [layout], or `null` when
  /// they have no position.
  _CasterPipeline? _casterFor(VertexLayout layout) {
    var caster = _pipelines[layout];
    if (caster == null) {
      final position = layout.attribute(VertexLayout.positionAttribute);
      final skinned =
          layout.attribute('vertexJoints')?.components == 4 &&
          layout.attribute('vertexWeights')?.components == 4;
      caster = _pipelines[layout] = _CasterPipeline(
        drawable: position != null && position.components == 3,
        skinned: skinned,
      );
    }
    if (!caster.drawable) {
      return null;
    }
    final vertexShader = caster.skinned ? _skinnedVertexShader : _vertexShader;
    final fragmentShader = _fragmentShader;
    // Resolve the resources first: recreating them bumps their generation.
    vertexShader.resource;
    fragmentShader.resource;
    if (caster._pipeline == null ||
        caster._vertexGeneration != vertexShader.generation ||
        caster._fragmentGeneration != fragmentShader.generation) {
      caster
        .._pipeline = _context.device.pipelineFor(
          vertexShader,
          fragmentShader,
          layout,
        )
        .._vertexGeneration = vertexShader.generation
        .._fragmentGeneration = fragmentShader.generation;
    }
    return caster;
  }

  void beginCascade1() {
    if (!_pendingCascade1) {
      return;
    }
    final context = _context;
    final device = context.device;
    context.setCamera(_farProjection.view, _farProjection.projection);
    recording = true;
    _drawCallsBefore = device.stats.drawCalls;
    device.beginTexturePass(_csmTarget1!, frontFace: context.frontFace);
    device.stats.shadowPasses++;
  }

  void endCascade1() {
    if (!recording || !_pendingCascade1) {
      return;
    }
    _pendingCascade1 = false;
    final context = _context;
    final device = context.device;
    try {
      flushCasters();
    } finally {
      device.endTexturePass();
      device.stats.shadowDrawCalls += device.stats.drawCalls - _drawCallsBefore;
      recording = false;
    }

    // Pack cascade 0 and cascade 1 side-by-side into the `2W x H` shadow atlas.
    final res = _csmResolution;
    final tex0 = Texture(
      null,
      width: res,
      height: res,
      gpuTexture: _csmTarget0!.texture,
    );
    final tex1 = Texture(
      null,
      width: res,
      height: res,
      gpuTexture: _csmTarget1!.texture,
    );
    _atlasVert.resource;
    _atlasFrag
      ..resource
      ..setTexture('cascade0Texture', tex0)
      ..setTexture('cascade1Texture', tex1);
    final pipeline = device.pipelineFor(
      _atlasVert,
      _atlasFrag,
      _atlasQuad.layout,
    );
    device
      ..beginTexturePass(_csmAtlasTarget!)
      ..bindPipeline(pipeline)
      ..setRenderState(
        const RenderState(depthTest: false, depthWrite: false),
      )
      ..bindTexture(_atlasFrag.slot('cascade0Texture'), tex0)
      ..bindTexture(_atlasFrag.slot('cascade1Texture'), tex1)
      ..bindSurface(_atlasQuad)
      ..drawSurface(_atlasQuad)
      ..endTexturePass();

    context.setCamera(_mainView, _mainProjection);
    active = true;
  }

  void writeShadows(UniformBlock block) {
    if (!active) {
      block.setVector4('toLight', _noShadows);
      return;
    }
    block
      ..setMatrix4('lightViewProjection', _lightViewProjection)
      ..setMatrix4('cascadeViewProjection', _cascadeViewProjection)
      ..setVector4('toLight', _toLight)
      ..setVector4('color', _color)
      ..setVector4('map', _map)
      ..setVector4('bias', _bias)
      ..setVector4('decode', _decode)
      ..setVector4('cascadeParams', _cascadeParams);
  }

  /// Writes how the shaders that render shadow maps store depths.
  static void writeCasterUniforms(
    RenderContext3D context,
    UniformBlock block,
  ) {
    block.setFloat('packDepth', context._shadows._packDepth ? 1 : 0);
  }

  /// The shadow map of the pass, or a white texture without shadows.
  static Texture shadowMapTexture(RenderContext3D context) {
    final shadows = context._shadows;
    return shadows.active ? shadows._texture! : Texture.standard;
  }

  static bool _sameMatrix(Float32List a, Float32List b) {
    for (var i = 0; i < 16; i++) {
      if ((a[i] - b[i]).abs() > 1e-9) {
        return false;
      }
    }
    return true;
  }
}

class _StaticShadowMap({
  required final int resolution,
  required final bool packDepth,
  required final GpuTextureTarget target,
  required final Texture texture,
}) {
  Object? castersKey;
  final Float32List lightVp = Float32List(16);
}

/// The pipeline that renders the depth of surfaces of one vertex layout into
/// a shadow map.
class _CasterPipeline({
  /// Whether the layout has a position to draw.
  required final bool drawable,

  /// Whether the layout has joints and joint weights.
  required final bool skinned,
}) {
  DevicePipeline? _pipeline;
  int _vertexGeneration = -1;
  int _fragmentGeneration = -1;

  DevicePipeline get pipeline => _pipeline!;
}
