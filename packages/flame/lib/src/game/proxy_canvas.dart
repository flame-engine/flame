import 'dart:typed_data';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// A [Canvas] that forwards every call to an underlying canvas, and that can
/// swap that underlying canvas mid-frame while preserving the current save
/// stack, transforms and clips.
///
/// Flame renders the whole component tree into a single canvas object that is
/// passed down the tree. When a `WidgetComponent` needs to composite a Flutter
/// layer in the middle of that tree, the picture that is being recorded has to
/// be ended and a new one started, which means a new canvas object. This class
/// hides that swap from the rest of the component tree: after [swap], the new
/// canvas is brought to the same state (save count, transforms and clips) that
/// the old one was in, so that pending `restore` calls in the component tree
/// keep balancing.
///
/// Transforms are accumulated into a single matrix per save level, so that
/// recording them does not allocate. Clips are recorded as objects together
/// with the transform that was accumulated before them, so that they can be
/// replayed in the right coordinate space.
///
/// Any transform or clip that the underlying canvas already had when the proxy
/// was created is replayed too. In practice there is none: whenever a widget
/// needs compositing, Flutter also composites the transforms and clips of the
/// ancestors of the game render box through layers instead of drawing them on
/// the shared canvas.
@internal
class ProxyCanvas implements Canvas {
  ProxyCanvas(this._canvas)
    : _baseSaveCount = _canvas.getSaveCount(),
      _initialTransform = _canvas.getTransform(),
      _initialClip = _canvas.getDestinationClipBounds() {
    _levels.add(_SaveLevel.plain());
  }

  Canvas _canvas;
  int _baseSaveCount;
  final Float64List _initialTransform;
  final Rect _initialClip;
  final List<_SaveLevel> _levels = [];
  final Matrix4 _scratch = Matrix4.identity();

  /// The canvas that currently receives all the calls.
  Canvas get inner => _canvas;

  /// Replaces the underlying canvas with [canvas], replaying the current save
  /// stack, transforms and clips onto it first.
  void swap(Canvas canvas) {
    _baseSaveCount = canvas.getSaveCount();
    if (_initialClip.isFinite && _initialClip != Rect.largest) {
      canvas.clipRect(_initialClip);
    }
    if (!_isIdentity(_initialTransform)) {
      canvas.transform(_initialTransform);
    }
    for (var i = 0; i < _levels.length; i++) {
      final level = _levels[i];
      if (i > 0) {
        if (level.isLayer) {
          canvas.saveLayer(level.layerBounds, level.layerPaint!);
        } else {
          canvas.save();
        }
      }
      level.replay(canvas);
    }
    _canvas = canvas;
  }

  _SaveLevel get _current => _levels.last;

  @override
  void save() {
    _canvas.save();
    _levels.add(_SaveLevel.plain());
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    _canvas.saveLayer(bounds, paint);
    _levels.add(_SaveLevel.layer(bounds, paint));
  }

  @override
  void restore() {
    if (_levels.length > 1) {
      _levels.removeLast();
    }
    _canvas.restore();
  }

  @override
  void restoreToCount(int count) {
    _canvas.restoreToCount(count);
    final targetLevels = (count - _baseSaveCount + 1).clamp(1, _levels.length);
    _levels.removeRange(targetLevels, _levels.length);
  }

  @override
  int getSaveCount() => _canvas.getSaveCount();

  @override
  void translate(double dx, double dy) {
    _canvas.translate(dx, dy);
    _current.pendingTransform.translateByDouble(dx, dy, 0, 1);
  }

  @override
  void scale(double sx, [double? sy]) {
    _canvas.scale(sx, sy);
    _current.pendingTransform.scaleByDouble(sx, sy ?? sx, 1, 1);
  }

  @override
  void rotate(double radians) {
    _canvas.rotate(radians);
    _current.pendingTransform.rotateZ(radians);
  }

  @override
  void skew(double sx, double sy) {
    _canvas.skew(sx, sy);
    _scratch.setIdentity();
    _scratch.storage[4] = sx;
    _scratch.storage[1] = sy;
    _current.pendingTransform.multiply(_scratch);
  }

  @override
  void transform(Float64List matrix4) {
    _canvas.transform(matrix4);
    _scratch.storage.setAll(0, matrix4);
    _current.pendingTransform.multiply(_scratch);
  }

  @override
  Float64List getTransform() => _canvas.getTransform();

  @override
  void clipRect(
    Rect rect, {
    ClipOp clipOp = ClipOp.intersect,
    bool doAntiAlias = true,
  }) {
    _canvas.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);
    _current.recordClip(
      _ClipRectOperation(rect, clipOp: clipOp, doAntiAlias: doAntiAlias),
    );
  }

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {
    _canvas.clipRRect(rrect, doAntiAlias: doAntiAlias);
    _current.recordClip(_ClipRRectOperation(rrect, doAntiAlias: doAntiAlias));
  }

  @override
  void clipRSuperellipse(
    RSuperellipse shape, {
    bool doAntiAlias = true,
  }) {
    _canvas.clipRSuperellipse(shape, doAntiAlias: doAntiAlias);
    _current.recordClip(
      _ClipRSuperellipseOperation(shape, doAntiAlias: doAntiAlias),
    );
  }

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {
    _canvas.clipPath(path, doAntiAlias: doAntiAlias);
    _current.recordClip(_ClipPathOperation(path, doAntiAlias: doAntiAlias));
  }

  @override
  Rect getLocalClipBounds() => _canvas.getLocalClipBounds();

  @override
  Rect getDestinationClipBounds() => _canvas.getDestinationClipBounds();

  @override
  void drawColor(Color color, BlendMode blendMode) {
    _canvas.drawColor(color, blendMode);
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    _canvas.drawLine(p1, p2, paint);
  }

  @override
  void drawPaint(Paint paint) {
    _canvas.drawPaint(paint);
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    _canvas.drawRect(rect, paint);
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    _canvas.drawRRect(rrect, paint);
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    _canvas.drawDRRect(outer, inner, paint);
  }

  @override
  void drawRSuperellipse(RSuperellipse shape, Paint paint) {
    _canvas.drawRSuperellipse(shape, paint);
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    _canvas.drawOval(rect, paint);
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    _canvas.drawCircle(c, radius, paint);
  }

  @override
  void drawArc(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    Paint paint,
  ) {
    _canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  void drawPath(Path path, Paint paint) {
    _canvas.drawPath(path, paint);
  }

  @override
  void drawImage(Image image, Offset offset, Paint paint) {
    _canvas.drawImage(image, offset, paint);
  }

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {
    _canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {
    _canvas.drawImageNine(image, center, dst, paint);
  }

  @override
  void drawPicture(Picture picture) {
    _canvas.drawPicture(picture);
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    _canvas.drawParagraph(paragraph, offset);
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    _canvas.drawPoints(pointMode, points, paint);
  }

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    _canvas.drawRawPoints(pointMode, points, paint);
  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    _canvas.drawVertices(vertices, blendMode, paint);
  }

  @override
  void drawAtlas(
    Image atlas,
    List<RSTransform> transforms,
    List<Rect> rects,
    List<Color>? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    _canvas.drawAtlas(
      atlas,
      transforms,
      rects,
      colors,
      blendMode,
      cullRect,
      paint,
    );
  }

  @override
  void drawRawAtlas(
    Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    _canvas.drawRawAtlas(
      atlas,
      rstTransforms,
      rects,
      colors,
      blendMode,
      cullRect,
      paint,
    );
  }

  @override
  void drawShadow(
    Path path,
    Color color,
    double elevation,
    bool transparentOccluder,
  ) {
    _canvas.drawShadow(path, color, elevation, transparentOccluder);
  }

  static bool _isIdentity(Float64List matrix) {
    for (var i = 0; i < 16; i++) {
      final expected = i % 5 == 0 ? 1.0 : 0.0;
      if (matrix[i] != expected) {
        return false;
      }
    }
    return true;
  }
}

/// One level of the save stack: the transforms and clips applied since the
/// `save` or `saveLayer` call that opened it.
class _SaveLevel {
  _SaveLevel.plain() : isLayer = false, layerBounds = null, layerPaint = null;

  _SaveLevel.layer(this.layerBounds, this.layerPaint) : isLayer = true;

  final bool isLayer;
  final Rect? layerBounds;
  final Paint? layerPaint;

  /// The transforms accumulated since the last recorded clip, or since the
  /// start of the level when there is none.
  final Matrix4 pendingTransform = Matrix4.identity();

  List<_ClipOperation>? _clips;

  void recordClip(_ClipOperation clip) {
    clip.transformBefore.setFrom(pendingTransform);
    pendingTransform.setIdentity();
    (_clips ??= []).add(clip);
  }

  void replay(Canvas canvas) {
    final clips = _clips;
    if (clips != null) {
      for (final clip in clips) {
        _applyTransform(canvas, clip.transformBefore);
        clip.apply(canvas);
      }
    }
    _applyTransform(canvas, pendingTransform);
  }

  static void _applyTransform(Canvas canvas, Matrix4 transform) {
    if (!transform.isIdentity()) {
      canvas.transform(transform.storage);
    }
  }
}

abstract class _ClipOperation {
  /// The transform that was accumulated between the previous clip (or the
  /// start of the save level) and this clip.
  final Matrix4 transformBefore = Matrix4.identity();

  void apply(Canvas canvas);
}

class _ClipRectOperation extends _ClipOperation {
  _ClipRectOperation(
    this.rect, {
    required this.clipOp,
    required this.doAntiAlias,
  });

  final Rect rect;
  final ClipOp clipOp;
  final bool doAntiAlias;

  @override
  void apply(Canvas canvas) {
    canvas.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);
  }
}

class _ClipRRectOperation extends _ClipOperation {
  _ClipRRectOperation(this.rrect, {required this.doAntiAlias});

  final RRect rrect;
  final bool doAntiAlias;

  @override
  void apply(Canvas canvas) {
    canvas.clipRRect(rrect, doAntiAlias: doAntiAlias);
  }
}

class _ClipRSuperellipseOperation extends _ClipOperation {
  _ClipRSuperellipseOperation(this.shape, {required this.doAntiAlias});

  final RSuperellipse shape;
  final bool doAntiAlias;

  @override
  void apply(Canvas canvas) {
    canvas.clipRSuperellipse(shape, doAntiAlias: doAntiAlias);
  }
}

class _ClipPathOperation extends _ClipOperation {
  _ClipPathOperation(this.path, {required this.doAntiAlias});

  final Path path;
  final bool doAntiAlias;

  @override
  void apply(Canvas canvas) {
    canvas.clipPath(path, doAntiAlias: doAntiAlias);
  }
}
