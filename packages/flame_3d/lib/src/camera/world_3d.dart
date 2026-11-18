import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart' as flame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/embedding/embedded_renderer.dart';
import 'package:meta/meta.dart';

part 'shadow_group.dart';

/// {@template world_3d}
/// The root component for all 3D world elements.
///
/// The primary feature of this component is that it allows [Component3D]s to
/// render directly to a [GraphicsDevice] instead of the regular rendering.
/// {@endtemplate}
class World3D({
  super.children,
  super.priority,
  double renderScale = 1.0,
  FogSettings? fog,
  BloomSettings? bloom,
  PostProcessSettings? postProcess,
  var bool spatialIndex3DEnabled = false,
  var bool prioritizeNearestLights = false,
  var bool depthPrepassEnabled = false,
}) extends flame.World {
  /// {@macro world_3d}
  this;

  final List<Light> _lights = [];

  /// Lazy flat AABB BVH accelerating AABB, frustum, and raycast queries when
  /// [spatialIndex3DEnabled] is `true` (or when queried directly).
  final SceneSpatialIndex3D spatialIndex3D = SceneSpatialIndex3D();

  int _sceneVersion = 0;
  int _castersVersion = 0;

  /// Monotonically increasing counter incremented whenever components, lights,
  /// animations, active particles, [fog], or [bloom] mutate the visual output
  /// of this world (or when [markSceneDirty] is called manually).
  int get sceneVersion => _sceneVersion;

  /// Monotonically increasing counter incremented whenever shadow-casting
  /// components change, used by [ShadowSettings.cacheWhenStatic].
  int get castersVersion => _castersVersion;

  /// Marks this world's rendered output (and optionally its static shadow map)
  /// as changed, waking idle-throttled game loops and invalidating retained
  /// `Scene3DComponent` caches.
  void markSceneDirty({bool shadows = true}) {
    _sceneVersion++;
    if (shadows) {
      _castersVersion++;
    }
    GraphicsDevice.notifyVisualMutation();
  }

  /// Marks this world's shadow casters as changed so a cached static shadow map
  /// ([ShadowSettings.cacheWhenStatic]) re-renders on the next pass.
  void markShadowsDirty() => markSceneDirty();

  /// Atmospheric distance/height fog applied to materials in this world (`null`
  /// disables fog).
  FogSettings? get fog => _fog;
  FogSettings? _fog = fog;
  set fog(FogSettings? value) {
    if (identical(value, _fog)) {
      return;
    }
    _fog = value;
    markSceneDirty(shadows: false);
  }

  /// Optional GPU bloom post-processing applied to this world's rendered pass
  /// (`null` disables bloom).
  BloomSettings? get bloom => _bloom;
  BloomSettings? _bloom = bloom;
  set bloom(BloomSettings? value) {
    if (identical(value, _bloom)) {
      return;
    }
    _bloom = value;
    markSceneDirty(shadows: false);
  }

  /// Optional GPU tone-mapping, color-grading, vignette, and FXAA settings
  /// fused into the final composite pass (`null` disables post-processing).
  PostProcessSettings? get postProcess => _postProcess;
  PostProcessSettings? _postProcess = postProcess;
  set postProcess(PostProcessSettings? value) {
    if (identical(value, _postProcess)) {
      return;
    }
    _postProcess = value;
    markSceneDirty(shadows: false);
  }

  /// The [Scene3DHost] this world renders with: the nearest ancestor that is
  /// one, such as a [Scene3DComponent] or a [Game3D] game.
  Scene3DHost get host => _host ??= _findHost();
  Scene3DHost? _host;

  /// The render context that records the draws of this world, the one of
  /// its [host].
  RenderContext3D get context => host.context;

  /// Whether this world is being rendered: [Object3D]s record their draws
  /// into [context] only while this is true.
  bool get isRendering => _rendering;
  bool _rendering = false;

  /// The fraction of the device pixels the world is rendered at.
  double get renderScale => _renderScale;
  double _renderScale = _checkRenderScale(renderScale);
  set renderScale(double value) {
    final checked = _checkRenderScale(value);
    if (checked == _renderScale) {
      return;
    }
    _renderScale = checked;
    markSceneDirty(shadows: false);
  }

  /// The filter used to scale the rendered image to the viewport when
  /// [renderScale] is not `1`.
  FilterQuality scaledFilterQuality = FilterQuality.low;

  /// The union of the world-space bounds ([Component3D.aabb]) of the
  /// [Component3D]s of this world, lights excepted, or `null` when there are
  /// none.
  Aabb3? get sceneBounds => _sceneBounds.value;
  final ComponentBounds _sceneBounds = ComponentBounds();

  @override
  void onChildrenChanged(flame.Component child, flame.ChildrenChangeType type) {
    super.onChildrenChanged(child, type);
    markSceneDirty(shadows: child is! LightComponent);
    if (child is! Component3D || child is LightComponent) {
      return;
    }
    switch (type) {
      case flame.ChildrenChangeType.added:
        _sceneBounds.add(child);
      case flame.ChildrenChangeType.removed:
        _sceneBounds.remove(child);
    }
  }

  /// Register a [light] with this world.
  @internal
  void addLight(Light light) {
    _lights.add(light);
    markSceneDirty();
  }

  /// Unregister a [light] from this world.
  @internal
  void removeLight(Light light) {
    _lights.remove(light);
    markSceneDirty();
  }

  @override
  void onRemove() {
    super.onRemove();
    _host = null;
  }

  /// The render context of this world's host, or `null` while it has none.
  RenderContext3D? get _contextOrNull {
    if (!isMounted) {
      return null;
    }
    var host = _host;
    if (host == null) {
      for (final ancestor in ancestors()) {
        if (ancestor case final Scene3DHost found) {
          host = _host = found;
          break;
        }
      }
    }
    return host?.context;
  }

  Scene3DHost _findHost() {
    for (final ancestor in ancestors()) {
      if (ancestor case final Scene3DHost host) {
        return host;
      }
    }
    throw StateError(
      'A World3D needs a Scene3DHost ancestor: a Scene3DComponent, or a '
      'Game3D game such as FlameGame3D.',
    );
  }

  /// The projection of the shadow map of this world, fitted by
  /// [renderShadows] before each main pass when a light casts shadows.
  DirectionalShadowProjection get shadowProjection => _shadowProjection;
  final DirectionalShadowProjection _shadowProjection =
      DirectionalShadowProjection();

  /// The group of worlds this world shares its shadow map with, or `null`
  /// when it renders a shadow map of its own; see [ShadowGroup].
  ShadowGroup? get shadowGroup => _shadowGroup;
  set shadowGroup(ShadowGroup? group) {
    if (identical(group, _shadowGroup)) {
      return;
    }
    _shadowGroup?._worlds.remove(this);
    _shadowGroup = group;
    group?._worlds.add(this);
    markSceneDirty();
  }

  ShadowGroup? _shadowGroup;

  /// Renders (or reuses) the shadow map of this world, returning whether the
  /// upcoming main pass receives shadows.
  bool renderShadows(Canvas canvas, {RenderContext3D? overrideContext}) {
    final ctx = (overrideContext ?? context)
      ..lights = _lights
      ..fog = _fog;
    final group = _shadowGroup;
    if (group != null && overrideContext == null) {
      return group._renderFor(this, ctx, canvas);
    }
    if (!ctx.beginShadowPass(
      projection: _shadowProjection,
      sceneBounds: sceneBounds,
      castersKey: _shadowCasterKey(this, _castersVersion, _lights),
    )) {
      return ctx.hasActiveShadows;
    }
    try {
      _recordCasters(canvas);
    } finally {
      ctx.endShadowPass();
    }
    if (ctx.needsShadowCascade1) {
      ctx.beginShadowCascade1();
      try {
        _recordCasters(canvas);
      } finally {
        ctx.endShadowCascade1();
      }
    }
    return true;
  }

  /// Renders the half-resolution clip-depth + view-normal prepass when
  /// [depthPrepassEnabled] or [PostProcessSettings.needsDepthNormal] is active.
  bool renderDepthNormals(
    Canvas canvas,
    int width,
    int height, {
    RenderContext3D? overrideContext,
  }) {
    final ctx = overrideContext ?? context;
    final needed =
        depthPrepassEnabled || (_postProcess?.needsDepthNormal ?? false);
    if (!needed) {
      ctx.clearDepthNormalPass();
      return false;
    }
    if (!ctx.beginDepthNormalPass(width, height)) {
      return false;
    }
    try {
      _recordCasters(canvas);
    } finally {
      ctx.endDepthNormalPass();
    }
    return true;
  }

  static Object _shadowCasterKey(
    Object owner,
    int castersVersion,
    List<Light> lights,
  ) {
    for (var i = 0; i < lights.length; i++) {
      final source = lights[i].source;
      if (source is DirectionalLight && source.shadows != null) {
        final s = source.shadows!;
        final d = lights[i].direction(_keyDir);
        return Object.hash(
          owner,
          castersVersion,
          i,
          d.x,
          d.y,
          d.z,
          s.resolution,
          s.fit,
          s.maxDistance,
          s.stabilize,
        );
      }
    }
    return (owner, castersVersion);
  }

  static final Vector3 _keyDir = Vector3.zero();

  /// Traverses the components into the shadow pass being recorded.
  void _recordCasters(Canvas canvas) {
    _rendering = true;
    try {
      for (final child in children) {
        child.renderTree(canvas);
      }
    } finally {
      _rendering = false;
    }
  }

  /// Records the draws of every component of this world into [context], with
  /// the lights and [fog] of this world.
  void renderScene(Canvas canvas, {RenderContext3D? overrideContext}) {
    final ctx = overrideContext ?? context;
    ctx
      ..lights = _lights
      ..fog = _fog
      ..prioritizeNearestLights = prioritizeNearestLights;
    _rendering = true;
    try {
      for (final child in children) {
        child.renderTree(canvas);
      }
    } finally {
      _rendering = false;
    }
  }

  /// Renders this world once at [size] physical pixels from [view] and
  /// [projection] into an independent [Image] whose backing GPU texture is
  /// never overwritten by subsequent passes.
  ///
  /// Works even when this [World3D] is not mounted inside a [Game3D] or
  /// [Scene3DComponent], making it ideal for offscreen thumbnails, inventory
  /// icons, and snapshots. The caller owns the returned [Image] and should
  /// `dispose()` it when no longer needed.
  Image renderToImage(
    Size size, {
    required Matrix4 view,
    required Matrix4 projection,
    Msaa msaa = Msaa.off,
    Color clearValue = const Color(0x00000000),
    GraphicsDevice? device,
    RenderContext3D? context,
  }) {
    final width = math.max(1, size.width.round());
    final height = math.max(1, size.height.round());

    GraphicsDevice resolvedDevice;
    RenderContext3D resolvedContext;
    var closeFrame = false;

    if (device != null && context != null) {
      resolvedDevice = device;
      resolvedContext = context;
      if (resolvedDevice.frame == 0 || !resolvedDevice.isInPass) {
        // Open a frame only if the caller has not already opened one.
      }
    } else {
      final hostRef = _contextOrNull != null ? host : null;
      if (hostRef is Game3D) {
        resolvedDevice = hostRef.device;
        resolvedContext = hostRef.context;
        if (!hostRef.isRenderingFrame) {
          resolvedDevice.begin();
          closeFrame = true;
        }
      } else {
        final embedded = EmbeddedRenderer.of(findGame() ?? this);
        resolvedDevice = embedded.device;
        resolvedContext = embedded.context;
        closeFrame = embedded.open();
      }
    }

    final dummyRecorder = PictureRecorder();
    final dummyCanvas = Canvas(dummyRecorder);
    final prevHost = _host;
    final tempHost = _SnapshotHost(resolvedDevice, resolvedContext, msaa);
    if (_contextOrNull == null) {
      _host = tempHost;
    }

    try {
      resolvedContext
        ..lights = _lights
        ..fog = _fog
        ..setCamera(view, projection);
      renderShadows(dummyCanvas, overrideContext: resolvedContext);
      renderDepthNormals(
        dummyCanvas,
        width,
        height,
        overrideContext: resolvedContext,
      );

      final bloomSettings = _bloom;
      final postSettings = _postProcess;
      final hasBloom =
          bloomSettings != null &&
          bloomSettings.intensity > 0 &&
          bloomSettings.radius > 0;
      final hasPost = postSettings != null && postSettings.isActive;
      final usePostPass =
          (hasBloom || hasPost) &&
          resolvedDevice.backend.supportsTextureTargets;

      final Image image;
      if (usePostPass) {
        final texTarget = resolvedDevice.textureTarget(
          width,
          height,
          GpuPixelFormat.rgba8888,
          clearValue: clearValue,
        );
        resolvedDevice.beginTexturePass(
          texTarget,
          frontFace: resolvedContext.frontFace,
        );
        renderScene(dummyCanvas, overrideContext: resolvedContext);
        resolvedContext.flush();
        resolvedDevice.endTexturePass();

        final bloomTarget = resolvedDevice.backend.createRenderTarget(
          width: width,
          height: height,
          clearValue: const Color(0x00000000),
        );
        image = resolvedDevice.applyBloomFromTarget(
          texTarget,
          bloomSettings,
          postProcess: postSettings,
          depthNormalTexture: resolvedContext.activeDepthNormalTexture,
          outputTarget: bloomTarget,
        );
      } else {
        final sceneTarget = resolvedDevice.backend.createRenderTarget(
          width: width,
          height: height,
          clearValue: clearValue,
          msaaSampleCount: msaa.sampleCount,
        );
        resolvedDevice.beginOwnedPass(
          sceneTarget,
          frontFace: resolvedContext.frontFace,
        );
        renderScene(dummyCanvas, overrideContext: resolvedContext);
        resolvedContext.flush();
        image = resolvedDevice.endPass();
      }
      return image;
    } finally {
      _host = prevHost;
      dummyRecorder.endRecording().dispose();
      if (closeFrame) {
        if (_contextOrNull != null && host is Game3D) {
          resolvedDevice.end();
        } else {
          EmbeddedRenderer.of(findGame() ?? this).close();
        }
      }
    }
  }

  /// Casts [ray] (in world space) against all [Object3D]s in this world within
  /// [maxDistance], returning the closest [RayHit3D] or `null` when missed.
  ///
  /// Whole subtrees whose world [Component3D.aabb] misses [ray] are skipped in
  /// `O(1)` before testing any surface BVH.
  RayHit3D? raycast(
    Ray ray, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
    bool Function(Object3D object)? filter,
  }) {
    if (!(maxDistance > 0)) {
      return null;
    }
    final dirLen = ray.direction.length;
    if (dirLen <= 1e-12) {
      return null;
    }
    _unitRay.origin.setFrom(ray.origin);
    _unitRay.direction
      ..setFrom(ray.direction)
      ..scale(1.0 / dirLen);

    if (spatialIndex3DEnabled) {
      return spatialIndex3D.raycast(
        this,
        _unitRay,
        maxDistance: maxDistance,
        cullMode: cullMode,
        filter: filter,
      );
    }

    RayHit3D? best;
    var limit = maxDistance;

    void visit(flame.Component component) {
      if (component is Component3D) {
        if (!_rayHitsAabb(_unitRay, component.aabb, limit)) {
          return;
        }
        if (component is Object3D && (filter == null || filter(component))) {
          final hit = component.raycast(
            _unitRay,
            maxDistance: limit,
            cullMode: cullMode,
          );
          if (hit != null && hit.distance < limit) {
            limit = hit.distance;
            best = hit;
          }
        }
      }
      for (final child in component.children) {
        visit(child);
      }
    }

    for (final child in children) {
      visit(child);
    }
    return best;
  }

  /// Casts [ray] against all [Object3D]s in this world within [maxDistance],
  /// returning every hit sorted from nearest to farthest.
  List<RayHit3D> raycastAll(
    Ray ray, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
    bool Function(Object3D object)? filter,
  }) {
    final hits = <RayHit3D>[];
    if (!(maxDistance > 0)) {
      return hits;
    }
    final dirLen = ray.direction.length;
    if (dirLen <= 1e-12) {
      return hits;
    }
    _unitRay.origin.setFrom(ray.origin);
    _unitRay.direction
      ..setFrom(ray.direction)
      ..scale(1.0 / dirLen);

    if (spatialIndex3DEnabled) {
      return spatialIndex3D.raycastAll(
        this,
        _unitRay,
        maxDistance: maxDistance,
        cullMode: cullMode,
        filter: filter,
      );
    }

    void visit(flame.Component component) {
      if (component is Component3D) {
        if (!_rayHitsAabb(_unitRay, component.aabb, maxDistance)) {
          return;
        }
        if (component is Object3D && (filter == null || filter(component))) {
          final hit = component.raycast(
            _unitRay,
            maxDistance: maxDistance,
            cullMode: cullMode,
          );
          if (hit != null) {
            hits.add(hit);
          }
        }
      }
      for (final child in component.children) {
        visit(child);
      }
    }

    for (final child in children) {
      visit(child);
    }
    hits.sort((a, b) => a.distance.compareTo(b.distance));
    return hits;
  }

  static bool _rayHitsAabb(Ray ray, Aabb3 box, double maxT) {
    var tMin = 0.0;
    var tMax = maxT;
    final ox = ray.origin.x;
    final oy = ray.origin.y;
    final oz = ray.origin.z;
    final dx = ray.direction.x;
    final dy = ray.direction.y;
    final dz = ray.direction.z;

    bool slab(double o, double d, double lo, double hi) {
      final minVal = lo - 1e-5;
      final maxVal = hi + 1e-5;
      if (d.abs() < 1e-12) {
        return o >= minVal && o <= maxVal;
      }
      final inv = 1.0 / d;
      var t1 = (minVal - o) * inv;
      var t2 = (maxVal - o) * inv;
      if (t1 > t2) {
        final s = t1;
        t1 = t2;
        t2 = s;
      }
      if (t1 > tMin) {
        tMin = t1;
      }
      if (t2 < tMax) {
        tMax = t2;
      }
      return tMin <= tMax;
    }

    return slab(ox, dx, box.min.x, box.max.x) &&
        slab(oy, dy, box.min.y, box.max.y) &&
        slab(oz, dz, box.min.z, box.max.z);
  }

  static final Ray _unitRay = Ray();

  @internal
  @override
  void renderFromCamera(Canvas canvas) {
    final camera = CameraComponent3D.currentCamera!;
    final Viewport(virtualSize: size) = camera.viewport;

    final host = this.host;
    final scale = host.pixelRatio * _renderScale;
    final renderSize = Size(size.x * scale, size.y * scale);

    final context = host.context
      ..lights = _lights
      ..fog = _fog
      ..cameraMask = camera.cameraMask
      ..setCamera(camera.viewMatrix, camera.projectionMatrix);
    renderShadows(canvas);
    final wPx = math.max(1, renderSize.width.round());
    final hPx = math.max(1, renderSize.height.round());
    renderDepthNormals(canvas, wPx, hPx);

    final device = host.device;
    final bloomSettings = _bloom;
    final postSettings = _postProcess;
    final usePost =
        device.backend.supportsTextureTargets &&
        ((bloomSettings != null &&
                bloomSettings.intensity > 0 &&
                bloomSettings.radius > 0) ||
            (postSettings != null && postSettings.isActive));

    final Image image;
    if (usePost) {
      final texTarget = device.textureTarget(
        wPx,
        hPx,
        GpuPixelFormat.rgba8888,
        clearValue: device.clearValue,
      );
      device.beginTexturePass(texTarget, frontFace: context.frontFace);
      _rendering = true;
      try {
        super.renderFromCamera(canvas);
      } finally {
        _rendering = false;
      }
      context.flush();
      device.endTexturePass();
      image = device.applyBloomFromTarget(
        texTarget,
        bloomSettings,
        postProcess: postSettings,
        depthNormalTexture: context.activeDepthNormalTexture,
      );
    } else {
      device.beginPass(
        renderSize,
        msaaSampleCount: host.msaaSampleCount,
        frontFace: context.frontFace,
      );
      _rendering = true;
      try {
        super.renderFromCamera(canvas);
      } finally {
        _rendering = false;
      }
      context.flush();
      image = device.endPass();
    }

    _paint.filterQuality = _renderScale == 1.0
        ? FilterQuality.none
        : scaledFilterQuality;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(-size.x / 2, -size.y / 2, size.x, size.y),
      _paint,
    );
    image.dispose();
  }

  final Paint _paint = Paint();

  static double _checkRenderScale(double value) {
    if (!(value > 0) || value.isInfinite) {
      throw ArgumentError.value(value, 'renderScale', 'Must be above 0');
    }
    return value;
  }
}

class _SnapshotHost(this.device, this.context, final Msaa _msaa)
    implements Scene3DHost {
  @override
  final GraphicsDevice device;

  @override
  final RenderContext3D context;

  @override
  int get msaaSampleCount => _msaa.sampleCount;

  @override
  double get pixelRatio => 1.0;
}
