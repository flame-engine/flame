import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flare_flutter/asset_provider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/provider/asset_flare.dart';

import 'package:flare_dart/math/aabb.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';

class FlareActorPipelineOwner extends PipelineOwner {

}

class FlareActorComponent extends PositionComponent {

  final pipelineOwner = FlareActorPipelineOwner(); // todo: review this


  FlareActorComponent(
      this.filename, {
        this.animation,
        this.alignment = Alignment.center,
        this.isPaused = false,
        this.snapToEnd = false,
        this.controller,
        this.callback,
        this.color,
        this.shouldClip = true,
        this.sizeFromArtboard = false,
        this.artboard,
        this.boundsNode,
        this.fit = BoxFit.contain
      }) : flareProvider = null;

  FlareActorRenderObject _renderObject;


  // fields ported from flare actor widget
  final String filename;
  final AssetProvider flareProvider; //
  final String artboard;
  final String animation; //
  final bool snapToEnd; //
  final BoxFit fit;
  final Alignment alignment; //
  final bool isPaused; //
  final bool shouldClip;
  final FlareController controller;
  final FlareCompletedCallback callback; //
  final Color color; //
  final String boundsNode; //
  final bool sizeFromArtboard; //




  @override
  void onMount() {
    super.onMount();
    _renderObject =  FlareActorRenderObject()
      ..assetProvider =
          flareProvider ?? AssetFlare(bundle: rootBundle, name: filename)
      ..alignment = alignment
      ..animationName = animation
      ..snapToEnd = snapToEnd
      ..isPaused = isPaused
      ..controller = controller
      ..completed = callback
      ..color = color
      ..shouldClip = shouldClip
      ..boundsNodeName = boundsNode
      ..useIntrinsicSize = sizeFromArtboard
      ..artboardName = artboard;
    loadRenderBox();

  }

  void loadRenderBox() {
    _renderObject.attach(pipelineOwner);
    if (!_renderObject.warmLoad()) {
      _renderObject.coldLoad();
    }
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    c.save();
    final bounds = _renderObject.aabb;
    if (bounds != null) {
      _paintActor(c, bounds);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _renderObject.advance(dt);
  }


  // Paint procedures ported from FlareRenderBox.paint with some changes that
  // makes sense on a flame context
  void _paintActor(Canvas c, AABB bounds) {
    final size = toSize().toSize();
    final offset = toPosition().toOffset();


    double contentWidth = bounds[2] - bounds[0];
    double contentHeight = bounds[3] - bounds[1];
    double x = -1 * bounds[0] - contentWidth / 2.0;
    double y = -1 * bounds[1] - contentHeight / 2.0;

    double scaleX = 1.0, scaleY = 1.0;

    // pre paint
    if (shouldClip) {
      c.clipRect(offset & size);
    }

    // boxfit
    switch (fit) {
      case BoxFit.fill:
        scaleX = size.width / contentWidth;
        scaleY = size.height / contentHeight;
        break;
      case BoxFit.contain:
        double minScale =
        min(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = minScale;
        break;
      case BoxFit.cover:
        double maxScale =
        max(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = maxScale;
        break;
      case BoxFit.fitHeight:
        double minScale = size.height / contentHeight;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.fitWidth:
        double minScale = size.width / contentWidth;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.none:
        scaleX = scaleY = 1.0;
        break;
      case BoxFit.scaleDown:
        double minScale =
        min(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
        break;
    }

    final transform = Mat2D();
    transform[4] = offset.dx + size.width / 2.0;
    transform[5] = offset.dy + size.height / 2.0;
    Mat2D.scale(transform, transform, Vec2D.fromValues(scaleX, scaleY));
    final center = Mat2D();
    center[4] = x;
    center[5] = y;
    Mat2D.multiply(transform, transform, center);

    c.scale(scaleX, scaleY);

    _renderObject.paintFlare(c, transform);
    c.restore();
    _renderObject.postPaint(c, offset);
  }

  @override
  void onDestroy() {
    _renderObject.dispose();
    super.onDestroy();
  }
}