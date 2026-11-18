import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart' show Game;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/src/embedding/embedded_renderer.dart';
import 'package:flutter/widgets.dart' show MediaQuery;

/// Caching strategy for a [Scene3DComponent]'s GPU render pass.
enum Scene3DCacheMode() {
  /// Renders the 3D scene pass every frame.
  none,

  /// Retains the rendered GPU [Image] in a dedicated target and reuses it with
  /// `0` GPU passes on subsequent frames whenever the scene, shadow casters,
  /// camera projection, canvas transform, and visible clip have not changed.
  retained,
}

/// {@template scene_3d_component}
/// A 2D component that shows a 3D scene as one layer of a 2D game.
/// {@endtemplate}
class Scene3DComponent({
  required Scene3DProjection projection,
  World3D? world,
  Msaa msaa = Msaa.off,
  double? renderScale,
  int maxTextureSize = 4096,
  Scene3DCacheMode cacheMode = Scene3DCacheMode.none,
  BloomSettings? bloom,
  PostProcessSettings? postProcess,
  var int cameraMask = 0xFFFFFFFF,
  super.position,
  super.size,
  super.scale,
  super.angle,
  super.anchor,
  super.children,
  super.priority,
  super.key,
}) extends PositionComponent implements Scene3DHost {
  /// {@macro scene_3d_component}
  this {
    if (renderScale != null) {
      this.world.renderScale = renderScale;
    }
    if (bloom != null) {
      this.world.bloom = bloom;
    }
    if (postProcess != null) {
      this.world.postProcess = postProcess;
    }
    this.maxTextureSize = maxTextureSize;
    add(this.world);
  }

  /// The 3D scene shown by this component, one of its children.
  final World3D world = world ?? World3D();

  /// How the scene maps to the local coordinates of this component.
  Scene3DProjection projection = projection;

  /// The multisample anti-aliasing of the render pass.
  Msaa msaa = msaa;

  /// Caching policy for this layer's GPU output.
  Scene3DCacheMode get cacheMode => _cacheMode;
  Scene3DCacheMode _cacheMode = cacheMode;
  set cacheMode(Scene3DCacheMode value) {
    if (value == _cacheMode) {
      return;
    }
    _cacheMode = value;
    if (value == Scene3DCacheMode.none) {
      _disposeRetained();
    }
  }

  /// Optional GPU bloom post-processing applied to this layer (forwards to
  /// `world.bloom`).
  BloomSettings? get bloom => world.bloom;
  set bloom(BloomSettings? value) => world.bloom = value;

  /// Optional GPU tone-mapping, color-grading, vignette, and FXAA applied to
  /// this layer (forwards to `world.postProcess`).
  PostProcessSettings? get postProcess => world.postProcess;
  set postProcess(PostProcessSettings? value) => world.postProcess = value;

  /// Number of frames satisfied directly from the [Scene3DCacheMode.retained]
  /// image cache without opening a GPU pass.
  int get cacheHitCount => _cacheHitCount;
  int _cacheHitCount = 0;

  int _manualVersion = 0;

  /// Marks this layer's retained image cache (if any) as out of date, forcing a
  /// fresh GPU pass on the next frame (for instance after mutating material
  /// uniforms or `MeshComponent.instanceData` in place).
  void markDirty() {
    _manualVersion++;
    GraphicsDevice.notifyVisualMutation();
  }

  /// The largest width and height in pixels of the render target, at least
  /// 64.
  int get maxTextureSize => _maxTextureSize;
  set maxTextureSize(int value) {
    if (value < _bucket) {
      throw ArgumentError.value(value, 'maxTextureSize', 'Must be at least 64');
    }
    _maxTextureSize = value;
  }

  int _maxTextureSize = 4096;

  /// The fraction of the device pixels the scene is rendered at.
  double get renderScale => world.renderScale;
  set renderScale(double value) => world.renderScale = value;

  /// The filter used to draw the image when it is not rendered at the
  /// device's resolution.
  FilterQuality get scaledFilterQuality => world.scaledFilterQuality;
  set scaledFilterQuality(FilterQuality value) {
    world.scaledFilterQuality = value;
  }

  /// The statistics of the last render pass of this component.
  RenderStats get renderStats => _stats;
  final RenderStats _stats = RenderStats();

  /// The part of the canvas, in the canvas's device coordinates (logical
  /// pixels, without the canvas transform), that the last render covered.
  Rect get renderedRect => _renderedRect;
  Rect _renderedRect = Rect.zero;

  /// The time the last render took on the CPU.
  Duration get lastRenderTime => Duration(microseconds: _renderMicroseconds);
  int _renderMicroseconds = 0;

  /// The local 2D point that [scenePoint] lands on.
  Vector2 scenePointToLocal(Vector3 scenePoint, {Vector2? output}) {
    return projection.scenePointToLocal(scenePoint, output: output);
  }

  /// The ray of the scene points that land on the local 2D point [localPoint].
  Ray localPointToRay(Vector2 localPoint, {Ray? output}) {
    return projection.localPointToRay(localPoint, output: output);
  }

  /// Casts a ray from [localPoint] (in this component's 2D coordinates) against
  /// all [Object3D]s in [world], returning the closest [RayHit3D] or `null`.
  RayHit3D? raycastLocal(
    Vector2 localPoint, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
    bool Function(Object3D object)? filter,
  }) {
    localPointToRay(localPoint, output: _pickRay);
    return world.raycast(
      _pickRay,
      maxDistance: maxDistance,
      cullMode: cullMode,
      filter: filter,
    );
  }

  /// Casts a ray from [localPoint] against all [Object3D]s in [world],
  /// returning all hits sorted from nearest to farthest.
  List<RayHit3D> raycastAllLocal(
    Vector2 localPoint, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
    bool Function(Object3D object)? filter,
  }) {
    localPointToRay(localPoint, output: _pickRay);
    return world.raycastAll(
      _pickRay,
      maxDistance: maxDistance,
      cullMode: cullMode,
      filter: filter,
    );
  }

  /// Renders this layer once into an independent [Image] of [size] logical
  /// pixels (scaled by [pixelRatio]), placing the projection's local origin at
  /// [origin] and scaling by [zoom].
  ///
  /// The caller owns the returned [Image] and should `dispose()` it when done.
  Image renderToImage(
    Size size, {
    Offset origin = Offset.zero,
    double zoom = 1.0,
    double pixelRatio = 1.0,
    Color clearValue = const Color(0x00000000),
  }) {
    final pScale = pixelRatio * world.renderScale;
    final targetW = math.max(1, (size.width * pScale).round());
    final targetH = math.max(1, (size.height * pScale).round());
    _writeCamera(
      zoom,
      0.0,
      0.0,
      zoom,
      origin.dx,
      origin.dy,
      pScale,
      0,
      0,
      targetW,
      targetH,
    );
    return world.renderToImage(
      Size(targetW.toDouble(), targetH.toDouble()),
      view: _viewMatrix,
      projection: _projectionMatrix,
      msaa: msaa,
      clearValue: clearValue,
    );
  }

  static final Ray _pickRay = Ray();

  @override
  GraphicsDevice get device {
    _resolveRenderer();
    return _device!;
  }

  @override
  RenderContext3D get context {
    _resolveRenderer();
    return _context!;
  }

  @override
  int get msaaSampleCount => msaa.sampleCount;

  @override
  double get pixelRatio => _pixelRatioOf(findGame());

  static double _pixelRatioOf(Game? game) {
    final buildContext = game?.buildContext;
    return buildContext == null
        ? 1.0
        : MediaQuery.devicePixelRatioOf(buildContext);
  }

  GraphicsDevice? _device;
  RenderContext3D? _context;
  Game3D? _game3D;
  EmbeddedRenderer? _renderer;

  // Retained GPU cache state.
  GpuRenderTarget? _retainedSceneTarget;
  GpuRenderTarget? _retainedBloomTarget;
  int _retainedTargetW = 0;
  int _retainedTargetH = 0;
  int _retainedMsaa = 0;
  Image? _retainedImage;
  Object? _retainedKey;
  final Float32List _retainedView = Float32List(16);
  final Float32List _retainedProj = Float32List(16);

  void _disposeRetained() {
    _retainedImage?.dispose();
    _retainedImage = null;
    _retainedKey = null;
    _retainedSceneTarget = null;
    _retainedBloomTarget = null;
    _retainedTargetW = 0;
    _retainedTargetH = 0;
    _retainedMsaa = 0;
  }

  void _resolveRenderer() {
    if (_context != null) {
      return;
    }
    final game = findGame();
    if (game case final Game3D game3D) {
      _game3D = game3D;
      _device = game3D.device;
      _context = game3D.context;
    } else {
      final renderer = _renderer = EmbeddedRenderer.of(game ?? this);
      _device = renderer.device;
      _context = renderer.context;
    }
  }

  @override
  void onRemove() {
    _disposeRetained();
    super.onRemove();
    _device = null;
    _context = null;
    _game3D = null;
    _renderer = null;
  }

  @override
  void render(Canvas canvas) {
    _stats.reset();
    _renderedRect = Rect.zero;
    _renderMicroseconds = 0;
    if (!world.isMounted || world.children.isEmpty) {
      return;
    }
    final stopwatch = _stopwatch
      ..reset()
      ..start();
    RenderProfile.start();
    _renderScene(canvas);
    stopwatch.stop();
    _renderMicroseconds = stopwatch.elapsedMicroseconds;
  }

  void _renderScene(Canvas canvas) {
    final transform = canvas.getTransform();
    final a = transform[0];
    final b = transform[1];
    final c = transform[4];
    final d = transform[5];
    final tx = transform[12];
    final ty = transform[13];
    final determinant = a * d - b * c;
    if (!(determinant.abs() > 1e-12)) {
      return;
    }

    var visible = canvas.getDestinationClipBounds();
    final game = findGame();
    if (visible.width > _unclipped || visible.height > _unclipped) {
      if (game == null || !game.hasLayout) {
        return;
      }
      final gameSize = game.canvasSize;
      visible = visible.intersect(Rect.fromLTWH(0, 0, gameSize.x, gameSize.y));
    }
    final width = size.x;
    final height = size.y;
    final bounded = width != 0 || height != 0;
    if (bounded) {
      visible = visible.intersect(
        _deviceBounds(a, b, c, d, tx, ty, width, height),
      );
    }
    if (visible.isEmpty) {
      return;
    }
    final scene = _sceneBounds(a, b, c, d, tx, ty);
    if (scene != null) {
      visible = visible.intersect(scene);
    }
    if (visible.isEmpty || !visible.isFinite) {
      return;
    }

    final fullScale = _pixelRatioOf(game) * world.renderScale;
    var pixelScale = fullScale;
    var left = (visible.left * pixelScale).floor();
    var top = (visible.top * pixelScale).floor();
    var pixelWidth = (visible.right * pixelScale).ceil() - left;
    var pixelHeight = (visible.bottom * pixelScale).ceil() - top;
    final maxSize = _maxTextureSize;
    if (pixelWidth > maxSize || pixelHeight > maxSize) {
      pixelScale *= (maxSize - 2) / math.max(pixelWidth, pixelHeight);
      left = (visible.left * pixelScale).floor();
      top = (visible.top * pixelScale).floor();
      pixelWidth = (visible.right * pixelScale).ceil() - left;
      pixelHeight = (visible.bottom * pixelScale).ceil() - top;
    }
    if (pixelWidth <= 0 || pixelHeight <= 0) {
      return;
    }

    final neededWidth = math.min(_roundUp(pixelWidth), maxSize);
    final neededHeight = math.min(_roundUp(pixelHeight), maxSize);
    if (_targetWidth < neededWidth ||
        _targetHeight < neededHeight ||
        _targetWidth > maxSize ||
        _targetHeight > maxSize ||
        _targetWidth * _targetHeight > 2 * neededWidth * neededHeight) {
      _targetWidth = neededWidth;
      _targetHeight = neededHeight;
    }
    final targetWidth = _targetWidth;
    final targetHeight = _targetHeight;

    _writeCamera(
      a,
      b,
      c,
      d,
      tx,
      ty,
      pixelScale,
      left,
      top,
      targetWidth,
      targetHeight,
    );

    final destination = Rect.fromLTRB(
      left / pixelScale,
      top / pixelScale,
      (left + pixelWidth) / pixelScale,
      (top + pixelHeight) / pixelScale,
    );

    final isRetained = _cacheMode == Scene3DCacheMode.retained;
    Object? nextKey;
    if (isRetained) {
      final bloomSettings = world.bloom;
      final postSettings = world.postProcess;
      nextKey = Object.hashAll([
        world.sceneVersion,
        _manualVersion,
        world.shadowGroup?.castersVersion ?? world.castersVersion,
        left,
        top,
        pixelWidth,
        pixelHeight,
        targetWidth,
        targetHeight,
        pixelScale,
        msaa.sampleCount,
        bloomSettings?.threshold,
        bloomSettings?.softKnee,
        bloomSettings?.intensity,
        bloomSettings?.radius,
        bloomSettings?.passes,
        postSettings?.toneMap,
        postSettings?.exposure,
        postSettings?.contrast,
        postSettings?.saturation,
        postSettings?.vignetteIntensity,
        postSettings?.vignetteSmoothness,
        postSettings?.tint,
        postSettings?.fxaa,
      ]);
      if (_retainedImage != null &&
          _retainedKey == nextKey &&
          _sameFloats(_viewMatrix.storage, _retainedView) &&
          _sameFloats(_projectionMatrix.storage, _retainedProj)) {
        _cacheHitCount++;
        _compositeImage(
          canvas,
          _retainedImage!,
          pixelWidth,
          pixelHeight,
          destination,
          a,
          b,
          c,
          d,
          tx,
          ty,
          determinant,
          bounded,
          width,
          height,
          pixelScale,
          fullScale,
        );
        return;
      }
    }

    _resolveRenderer();
    final device = _device!;
    final context = _context!;
    final game3D = _game3D;
    final bool closeFrame;
    if (game3D != null) {
      closeFrame = !game3D.isRenderingFrame;
      if (closeFrame) {
        device.begin();
      }
    } else {
      closeFrame = _renderer!.open();
    }

    _statsBefore.setFrom(device.stats);
    context
      ..cameraMask = cameraMask
      ..setCamera(_viewMatrix, _projectionMatrix);
    RenderProfile.lap(RenderPhase.setup);
    world
      ..renderShadows(canvas)
      ..renderDepthNormals(canvas, targetWidth, targetHeight);

    final bloomSettings = world.bloom;
    final postSettings = world.postProcess;
    final usePost =
        device.backend.supportsTextureTargets &&
        ((bloomSettings != null &&
                bloomSettings.intensity > 0 &&
                bloomSettings.radius > 0) ||
            (postSettings != null && postSettings.isActive));

    final Image image;
    if (usePost) {
      final texTarget = device.textureTarget(
        targetWidth,
        targetHeight,
        GpuPixelFormat.rgba8888,
        clearValue: device.clearValue,
      );
      device.beginTexturePass(texTarget, frontFace: context.frontFace);
      world.renderScene(canvas);
      context.flush();
      device.endTexturePass();

      if (isRetained) {
        if (_retainedBloomTarget == null ||
            _retainedTargetW != targetWidth ||
            _retainedTargetH != targetHeight) {
          _retainedTargetW = targetWidth;
          _retainedTargetH = targetHeight;
          _retainedBloomTarget = device.backend.createRenderTarget(
            width: targetWidth,
            height: targetHeight,
            clearValue: device.clearValue,
          );
        }
        image = device.applyBloomFromTarget(
          texTarget,
          bloomSettings,
          postProcess: postSettings,
          depthNormalTexture: context.activeDepthNormalTexture,
          outputTarget: _retainedBloomTarget,
        );
      } else {
        image = device.applyBloomFromTarget(
          texTarget,
          bloomSettings,
          postProcess: postSettings,
          depthNormalTexture: context.activeDepthNormalTexture,
        );
      }
    } else {
      if (isRetained) {
        if (_retainedSceneTarget == null ||
            _retainedTargetW != targetWidth ||
            _retainedTargetH != targetHeight ||
            _retainedMsaa != msaa.sampleCount) {
          _retainedTargetW = targetWidth;
          _retainedTargetH = targetHeight;
          _retainedMsaa = msaa.sampleCount;
          _retainedSceneTarget = device.backend.createRenderTarget(
            width: targetWidth,
            height: targetHeight,
            clearValue: device.clearValue,
            msaaSampleCount: msaa.sampleCount,
          );
          _retainedBloomTarget = null;
        }
        device.beginOwnedPass(
          _retainedSceneTarget!,
          frontFace: context.frontFace,
        );
      } else {
        device.beginPass(
          Size(targetWidth.toDouble(), targetHeight.toDouble()),
          msaaSampleCount: msaa.sampleCount,
          frontFace: context.frontFace,
        );
      }
      world.renderScene(canvas);
      context.flush();
      image = device.endPass();
    }

    _subtract(device.stats, _statsBefore, _stats);
    if (closeFrame) {
      if (game3D != null) {
        device.end();
      } else {
        _renderer!.close();
      }
    }
    RenderProfile.lap(RenderPhase.passEnd);

    _compositeImage(
      canvas,
      image,
      pixelWidth,
      pixelHeight,
      destination,
      a,
      b,
      c,
      d,
      tx,
      ty,
      determinant,
      bounded,
      width,
      height,
      pixelScale,
      fullScale,
    );

    if (isRetained) {
      _retainedImage?.dispose();
      _retainedImage = image;
      _retainedKey = nextKey;
      _retainedView.setAll(0, _viewMatrix.storage);
      _retainedProj.setAll(0, _projectionMatrix.storage);
    } else {
      image.dispose();
    }
  }

  void _compositeImage(
    Canvas canvas,
    Image image,
    int pixelWidth,
    int pixelHeight,
    Rect destination,
    double a,
    double b,
    double c,
    double d,
    double tx,
    double ty,
    double determinant,
    bool bounded,
    double width,
    double height,
    double pixelScale,
    double fullScale,
  ) {
    final inverse = _inverseTransform
      ..[0] = d / determinant
      ..[1] = -b / determinant
      ..[4] = -c / determinant
      ..[5] = a / determinant
      ..[12] = (c * ty - d * tx) / determinant
      ..[13] = (b * tx - a * ty) / determinant;
    canvas.save();
    if (bounded && (b != 0 || c != 0)) {
      canvas.clipRect(Rect.fromLTWH(0, 0, width, height));
    }
    canvas.transform(inverse);
    _paint.filterQuality = pixelScale == fullScale && world.renderScale == 1.0
        ? FilterQuality.none
        : world.scaledFilterQuality;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, pixelWidth.toDouble(), pixelHeight.toDouble()),
      destination,
      _paint,
    );
    canvas.restore();
    _renderedRect = destination;
    RenderProfile.lap(RenderPhase.composite);
  }

  static bool _sameFloats(Float32List a, Float32List b) {
    for (var i = 0; i < 16; i++) {
      if ((a[i] - b[i]).abs() > 1e-9) {
        return false;
      }
    }
    return true;
  }

  Rect? _sceneBounds(
    double a,
    double b,
    double c,
    double d,
    double tx,
    double ty,
  ) {
    final box = world.sceneBounds;
    if (box == null) {
      return null;
    }
    final m = projection.sceneToLocalValues;
    final min = box.min;
    final max = box.max;
    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;
    for (var corner = 0; corner < 8; corner++) {
      final x = corner & 1 == 0 ? min.x : max.x;
      final y = corner & 2 == 0 ? min.y : max.y;
      final z = corner & 4 == 0 ? min.z : max.z;
      final w = m[3] * x + m[7] * y + m[11] * z + m[15];
      if (!(w > 0)) {
        return null;
      }
      final localX = (m[0] * x + m[4] * y + m[8] * z + m[12]) / w;
      final localY = (m[1] * x + m[5] * y + m[9] * z + m[13]) / w;
      final deviceX = a * localX + c * localY + tx;
      final deviceY = b * localX + d * localY + ty;
      left = math.min(left, deviceX);
      top = math.min(top, deviceY);
      right = math.max(right, deviceX);
      bottom = math.max(bottom, deviceY);
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }

  int _targetWidth = 0;
  int _targetHeight = 0;

  void _writeCamera(
    double a,
    double b,
    double c,
    double d,
    double tx,
    double ty,
    double pixelScale,
    int left,
    int top,
    int targetWidth,
    int targetHeight,
  ) {
    final sx = 2 * pixelScale / targetWidth;
    final sy = 2 * pixelScale / targetHeight;
    final c00 = sx * a;
    final c01 = sx * c;
    final c03 = 2 * (pixelScale * tx - left) / targetWidth - 1;
    final c10 = -sy * b;
    final c11 = -sy * d;
    final c13 = 1 - 2 * (pixelScale * ty - top) / targetHeight;

    final viewToLocal = projection.viewToLocalValues;
    final p = _projectionMatrix.storage;
    for (var column = 0; column < 4; column++) {
      final i = column * 4;
      final x = viewToLocal[i];
      final y = viewToLocal[i + 1];
      final w = viewToLocal[i + 3];
      p[i] = c00 * x + c01 * y + c03 * w;
      p[i + 1] = c10 * x + c11 * y + c13 * w;
      p[i + 2] = viewToLocal[i + 2];
      p[i + 3] = w;
    }
    _viewMatrix.storage.setAll(0, projection.viewValues);
  }

  final Matrix4 _viewMatrix = Matrix4.identity();
  final Matrix4 _projectionMatrix = Matrix4.identity();
  final Float64List _inverseTransform = Float64List(16)
    ..[10] = 1
    ..[15] = 1;
  final Paint _paint = Paint();
  final RenderStats _statsBefore = RenderStats();
  final Stopwatch _stopwatch = Stopwatch();

  static const int _bucket = 64;
  static const double _unclipped = 1e6;

  static int _roundUp(int pixels) =>
      (pixels + _bucket - 1) ~/ _bucket * _bucket;

  static Rect _deviceBounds(
    double a,
    double b,
    double c,
    double d,
    double tx,
    double ty,
    double width,
    double height,
  ) {
    final x1 = a * width;
    final y1 = b * width;
    final x2 = c * height;
    final y2 = d * height;
    return Rect.fromLTRB(
      tx + math.min(0.0, x1) + math.min(0.0, x2),
      ty + math.min(0.0, y1) + math.min(0.0, y2),
      tx + math.max(0.0, x1) + math.max(0.0, x2),
      ty + math.max(0.0, y1) + math.max(0.0, y2),
    );
  }

  static void _subtract(
    RenderStats after,
    RenderStats before,
    RenderStats out,
  ) {
    out
      ..renderPasses = after.renderPasses - before.renderPasses
      ..drawCalls = after.drawCalls - before.drawCalls
      ..instances = after.instances - before.instances
      ..triangles = after.triangles - before.triangles
      ..pipelineChanges = after.pipelineChanges - before.pipelineChanges
      ..stateChanges = after.stateChanges - before.stateChanges
      ..materialChanges = after.materialChanges - before.materialChanges
      ..uniformUploads = after.uniformUploads - before.uniformUploads
      ..uploadedBytes = after.uploadedBytes - before.uploadedBytes
      ..particles = after.particles - before.particles
      ..shadowPasses = after.shadowPasses - before.shadowPasses
      ..shadowDrawCalls = after.shadowDrawCalls - before.shadowDrawCalls;
  }
}
