import 'dart:convert';
import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:spine_core/spine_core.dart';
import 'package:spine_flutter/spine_flutter.dart';

class SkeletonRender {
  SkeletonRender({
    required this.skeleton,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.playState = PlayState.playing,
    this.debugRendering = false,
    this.triangleRendering = true,
    this.frameSizeMultiplier = 0.0,
    this.animation,
  });

  final SkeletonAnimation skeleton;
  final BoxFit fit;
  final Alignment alignment;
  final PlayState playState;
  final bool debugRendering;
  final bool triangleRendering;

  /// Нow many percent increase the size of the animation
  /// relative to the size of the first frame.
  final double frameSizeMultiplier;

  /// A start animation. We will use it for calculate bounds by frames.
  late String? animation;

  SkeletonRenderObject? _renderObject;

  void init() {
    _renderObject = _generateRenderObject();
  }

  SkeletonRenderObject _generateRenderObject() {
    final renderObject = SkeletonRenderObject()
      ..skeleton = skeleton
      ..fit = fit
      ..alignment = alignment
      ..playState = playState
      ..debugRendering = debugRendering
      ..triangleRendering = triangleRendering
      ..frameSizeMultiplier = frameSizeMultiplier
      ..animation = animation;

    return renderObject;
  }

  void advance(double dt) {
    final renderObject = _renderObject;
    if (renderObject == null) {
      throw 'SkeletonRender was advanced before initialization. '
          'Run SkeletonRender.init() before calling .advance';
    }
    applyState();
  }

  void updateAnimation(String animation) {
    final renderObject = _renderObject;
    if (renderObject == null) {
      throw 'SkeletonRender was advanced before initialization. '
          'Run SkeletonRender.init() before calling .advance';
    }

    renderObject.animation = animation;

    // applyState();
  }

  void applyState() {
    skeleton
      ..applyState()
      ..updateWorldTransform();
  }

  void render(Canvas canvas, Size size) {
    /// paint here on canvas
    final renderObject = _renderObject;
    if (renderObject == null) {
      throw 'SkeletonRender was rendered before initialization. '
          'Run SkeletonRender.init() before rendering it';
    }

    final bound = _renderObject!.bounds;

    if (bound == null) {
      throw 'SkeletonRender was rendered but Bounds are not present ';
    }

    _paint(canvas, bound, size);
  }

  void destroy() {
    final renderObject = _renderObject;
    if (renderObject == null) {
      throw 'SkeletonRender was destroyed before initialization. '
          'Run SkeletonRender.init() before destroying it';
    }
    renderObject.dispose();
  }

  void _paint(Canvas canvas, Bounds bounds, Size size) {
    final renderObject = _renderObject;
    if (renderObject == null) {
      throw 'SkeletonRender was rendered before initialization. '
          'Run SkeletonRender.init() before rendering it';
    }

    /// draw

    final contentHeight = bounds.size.y;
    final contentWidth = bounds.size.x;
    final x = -bounds.offset.x -
        contentWidth / 2.0 -
        (alignment.x * contentWidth / 2.0);
    final y = -bounds.offset.y -
        contentHeight / 2.0 +
        (alignment.y * contentHeight / 2.0);

    var scaleX = 1.0, scaleY = 1.0;

    // boxfit
    switch (fit) {
      case BoxFit.fill:
        scaleX = size.width / contentWidth;
        scaleY = size.height / contentHeight;
        break;
      case BoxFit.contain:
        final double minScale =
            math.min(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = minScale;
        break;
      case BoxFit.cover:
        final double maxScale =
            math.max(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = maxScale;
        break;
      case BoxFit.fitHeight:
        final minScale = size.height / contentHeight;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.fitWidth:
        final minScale = size.width / contentWidth;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.none:

      case BoxFit.scaleDown:
        final double minScale =
            math.min(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
        break;

      default:
        scaleX = scaleY = 1.0;
        break;
    }

    canvas
      ..translate(
        size.width / 2.0 + (alignment.x * size.width / 2.0),
        size.height / 2.0 + (alignment.y * size.height / 2.0),
      )
      ..scale(scaleX, -scaleY)
      ..translate(x, y);

    _renderObject!.draw(canvas);

    canvas.restore();
  }
}

Future<SkeletonAnimation> loadSkeleton(String name) async {
  const pathPrefix = 'assets/';
  return SkeletonAnimation.createWithFiles(name, pathBase: pathPrefix);
}

Future<Set<String>> loadAnimations(String name) async {
  final skeletonFile = '$name.json';
  const pathPrefix = 'assets/';
  final s = await rootBundle.loadString('$pathPrefix$name/$skeletonFile');
  final data = json.decode(s) as Map<String, dynamic>;

  return ((data['animations'] ?? <String, dynamic>{}) as Map<String, dynamic>)
      .keys
      .toSet();
}
