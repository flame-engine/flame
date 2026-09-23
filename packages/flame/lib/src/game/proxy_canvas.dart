import 'dart:typed_data';
import 'dart:ui';

import 'package:meta/meta.dart';

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
@internal
class ProxyCanvas implements Canvas {
  ProxyCanvas(this._canvas) : _baseSaveCount = _canvas.getSaveCount() {
    _levels.add(_SaveLevel.plain());
  }

  Canvas _canvas;
  int _baseSaveCount;
  final List<_SaveLevel> _levels = [];

  /// The canvas that currently receives all the calls.
  Canvas get inner => _canvas;

  /// Replaces the underlying canvas with [canvas], replaying the current save
  /// stack, transforms and clips onto it first.
  void swap(Canvas canvas) {
    _baseSaveCount = canvas.getSaveCount();
    for (var i = 0; i < _levels.length; i++) {
      final level = _levels[i];
      if (i > 0) {
        if (level.isLayer) {
          canvas.saveLayer(level.layerBounds, level.layerPaint!);
        } else {
          canvas.save();
        }
      }
      for (final op in level.ops) {
        op.apply(canvas);
      }
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
    _current.ops.add(_TranslateOp(dx, dy));
  }

  @override
  void scale(double sx, [double? sy]) {
    _canvas.scale(sx, sy);
    _current.ops.add(_ScaleOp(sx, sy));
  }

  @override
  void rotate(double radians) {
    _canvas.rotate(radians);
    _current.ops.add(_RotateOp(radians));
  }

  @override
  void skew(double sx, double sy) {
    _canvas.skew(sx, sy);
    _current.ops.add(_SkewOp(sx, sy));
  }

  @override
  void transform(Float64List matrix4) {
    _canvas.transform(matrix4);
    _current.ops.add(_TransformOp(Float64List.fromList(matrix4)));
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
    _current.ops.add(
      _ClipRectOp(rect, clipOp: clipOp, doAntiAlias: doAntiAlias),
    );
  }

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {
    _canvas.clipRRect(rrect, doAntiAlias: doAntiAlias);
    _current.ops.add(_ClipRRectOp(rrect, doAntiAlias: doAntiAlias));
  }

  @override
  void clipRSuperellipse(
    RSuperellipse shape, {
    bool doAntiAlias = true,
  }) {
    _canvas.clipRSuperellipse(shape, doAntiAlias: doAntiAlias);
    _current.ops.add(
      _ClipRSuperellipseOp(shape, doAntiAlias: doAntiAlias),
    );
  }

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {
    _canvas.clipPath(path, doAntiAlias: doAntiAlias);
    _current.ops.add(_ClipPathOp(path, doAntiAlias: doAntiAlias));
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
}

class _SaveLevel {
  _SaveLevel.plain() : isLayer = false, layerBounds = null, layerPaint = null;

  _SaveLevel.layer(this.layerBounds, this.layerPaint) : isLayer = true;

  final bool isLayer;
  final Rect? layerBounds;
  final Paint? layerPaint;
  final List<_CanvasOp> ops = [];
}

abstract class _CanvasOp {
  void apply(Canvas canvas);
}

class _TranslateOp implements _CanvasOp {
  _TranslateOp(this.dx, this.dy);
  final double dx;
  final double dy;

  @override
  void apply(Canvas canvas) => canvas.translate(dx, dy);
}

class _ScaleOp implements _CanvasOp {
  _ScaleOp(this.sx, this.sy);
  final double sx;
  final double? sy;

  @override
  void apply(Canvas canvas) => canvas.scale(sx, sy);
}

class _RotateOp implements _CanvasOp {
  _RotateOp(this.radians);
  final double radians;

  @override
  void apply(Canvas canvas) => canvas.rotate(radians);
}

class _SkewOp implements _CanvasOp {
  _SkewOp(this.sx, this.sy);
  final double sx;
  final double sy;

  @override
  void apply(Canvas canvas) => canvas.skew(sx, sy);
}

class _TransformOp implements _CanvasOp {
  _TransformOp(this.matrix4);
  final Float64List matrix4;

  @override
  void apply(Canvas canvas) => canvas.transform(matrix4);
}

class _ClipRectOp implements _CanvasOp {
  _ClipRectOp(this.rect, {required this.clipOp, required this.doAntiAlias});
  final Rect rect;
  final ClipOp clipOp;
  final bool doAntiAlias;

  @override
  void apply(Canvas canvas) {
    canvas.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);
  }
}

class _ClipRRectOp implements _CanvasOp {
  _ClipRRectOp(this.rrect, {required this.doAntiAlias});
  final RRect rrect;
  final bool doAntiAlias;

  @override
  void apply(Canvas canvas) {
    canvas.clipRRect(rrect, doAntiAlias: doAntiAlias);
  }
}

class _ClipRSuperellipseOp implements _CanvasOp {
  _ClipRSuperellipseOp(this.shape, {required this.doAntiAlias});
  final RSuperellipse shape;
  final bool doAntiAlias;

  @override
  void apply(Canvas canvas) {
    canvas.clipRSuperellipse(shape, doAntiAlias: doAntiAlias);
  }
}

class _ClipPathOp implements _CanvasOp {
  _ClipPathOp(this.path, {required this.doAntiAlias});
  final Path path;
  final bool doAntiAlias;

  @override
  void apply(Canvas canvas) {
    canvas.clipPath(path, doAntiAlias: doAntiAlias);
  }
}
