import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:spine_core/spine_core.dart';
import 'package:spine_flutter/spine_flutter.dart';

class SkeletonRender {
  SkeletonRender({
    required SkeletonAnimation skeleton,
    BoxFit boxFit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    PlayState playState = PlayState.playing,
    bool debugRendering = false,
    bool triangleRendering = true,
    double frameSizeMultiplier = 0.0,
    String? animation,
  }) : _renderObject = SkeletonRenderObject()
          ..skeleton = skeleton
          ..fit = boxFit
          ..alignment = alignment
          ..playState = playState
          ..debugRendering = debugRendering
          ..triangleRendering = triangleRendering
          ..frameSizeMultiplier = frameSizeMultiplier
          ..animation = animation;

  late final SkeletonRenderObject _renderObject;

  SkeletonAnimation get skeleton => _renderObject.skeleton;

  set skeleton(SkeletonAnimation value) {
    _renderObject.skeleton = value;
  }

  Alignment get alignment => _renderObject.alignment as Alignment;

  set alignment(AlignmentGeometry value) {
    _renderObject.alignment = value as Alignment;
  }

  BoxFit get boxFit => _renderObject.fit;

  set boxFit(BoxFit value) {
    _renderObject.fit = value;
  }

  PlayState get playState => _renderObject.playState;

  set playState(PlayState value) {
    _renderObject.playState = value;
  }

  bool get debugRendering => _renderObject.debugRendering;

  set debugRendering(bool value) {
    _renderObject.debugRendering = value;
  }

  bool get triangleRendering => _renderObject.triangleRendering;

  set triangleRendering(bool value) {
    _renderObject.triangleRendering = value;
  }

  /// Нow many percent increase the size of the animation
  /// relative to the size of the first frame.
  double get frameSizeMultiplier => _renderObject.frameSizeMultiplier;

  set frameSizeMultiplier(double value) {
    _renderObject.frameSizeMultiplier = value;
  }

  /// A start animation. We will use it for calculate bounds by frames.
  String? get animation => _renderObject.animation;

  set animation(String? value) {
    _renderObject.animation = value;
  }

  void advance(double dt) {}

  void render(Canvas canvas, Size size) {
    final bound = _renderObject.bounds;

    if (bound == null) {
      throw 'SkeletonRender was rendered but Bounds are not present ';
    }

    _paint(canvas, bound, size);
  }

  void destroy() {
    _renderObject.dispose();
  }

  void _paint(Canvas canvas, Bounds bounds, Size size) {
    final contentHeight = bounds.size.y;
    final contentWidth = bounds.size.x;
    final x = -bounds.offset.x -
        contentWidth / 2.0 -
        (alignment.x * contentWidth / 2.0);
    final y = -bounds.offset.y -
        contentHeight / 2.0 +
        (alignment.y * contentHeight / 2.0);

    var scaleX = 1.0, scaleY = 1.0;

    switch (boxFit) {
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

    _renderObject.draw(canvas);

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
