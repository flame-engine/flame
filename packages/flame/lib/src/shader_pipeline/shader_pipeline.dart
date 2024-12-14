import 'dart:typed_data';
import 'dart:ui' as ui show Image;
import 'dart:ui' hide Image;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class SPipelineConfiguration {
  SPipelineConfiguration({
    required this.samplingPasses,
  });

  final int samplingPasses;
}

abstract class SPipelineStep extends PositionComponent {
  SPipelineStep({
    required this.program,
    required this.configuration,
    super.position,
    super.size,
    super.scale,
    super.angle,
    double? nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : super(
          nativeAngle: nativeAngle ?? 0,
        );

  final SPipelineConfiguration configuration;
  final FragmentProgram program;
  late final _layer = _SPipelineStepLayer(
    renderTree: super.renderTree,
    canvasFactory: _canvasFactory,
    configuration: configuration,
    renderShader: renderShader,
  );

  double get pixelRatio;

  Canvas _canvasFactory(PictureRecorder recorder, int passIndex) {
    return SamplingCanvas(
      step: this,
      passIndex: passIndex,
      actualCanvas: Canvas(recorder),
    );
  }

  @override
  void renderTree(Canvas canvas) {
    decorator.applyChain(
      (canvas) => _layer.render(canvas, size, pixelRatio),
      canvas,
    );
  }

  void renderShader(List<ui.Image> samples, Size size, Canvas canvas);
}

class _SPipelineStepLayer {
  final Canvas Function(PictureRecorder, int) canvasFactory;
  final void Function(Canvas) renderTree;
  final void Function(List<ui.Image>, Size, Canvas) renderShader;
  final SPipelineConfiguration configuration;

  _SPipelineStepLayer({
    required this.renderTree,
    required this.canvasFactory,
    required this.configuration,
    required this.renderShader,
  });

  ui.Image _renderPass(Vector2 size, int pass, double pixelRatio) {
    final recorder = PictureRecorder();

    final innerCanvas = canvasFactory(recorder, pass);
    renderTree(innerCanvas);
    final picture = recorder.endRecording();

    return picture.toImageSync(
      (pixelRatio * size.x).ceil(),
      (pixelRatio * size.y).ceil(),
    );
  }

  void render(Canvas canvas, Vector2 size, double pixelRatio) {
    final results = List<ui.Image>.generate(
      configuration.samplingPasses,
      (i) {
        return _renderPass(size, i, pixelRatio);
      },
    );

    canvas.save();
    renderShader(results, size.toSize(), canvas);
    canvas.restore();
  }
}

class SamplingCanvas<S extends SPipelineStep> implements Canvas {
  SamplingCanvas({
    required this.step,
    required this.passIndex,
    required this.actualCanvas,
  });

  final S step;
  final int passIndex;

  final Canvas actualCanvas;

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {
    actualCanvas.clipPath(path, doAntiAlias: doAntiAlias);
  }

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {
    return actualCanvas.clipRRect(rrect, doAntiAlias: doAntiAlias);
  }

  @override
  void clipRect(
    Rect rect, {
    ClipOp clipOp = ClipOp.intersect,
    bool doAntiAlias = true,
  }) {
    return actualCanvas.clipRect(
      rect,
      clipOp: clipOp,
      doAntiAlias: doAntiAlias,
    );
  }

  @override
  void drawArc(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    Paint paint,
  ) {
    return actualCanvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      useCenter,
      paint,
    );
  }

  @override
  void drawAtlas(
    ui.Image atlas,
    List<RSTransform> transforms,
    List<Rect> rects,
    List<Color>? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    return actualCanvas.drawAtlas(
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
  void drawCircle(Offset c, double radius, Paint paint) {
    actualCanvas.drawCircle(c, radius, paint);
  }

  @override
  void drawColor(Color color, BlendMode blendMode) {
    actualCanvas.drawColor(color, blendMode);
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    actualCanvas.drawDRRect(outer, inner, paint);
  }

  @override
  void drawImage(ui.Image image, Offset offset, Paint paint) {
    return actualCanvas.drawImage(image, offset, paint);
  }

  @override
  void drawImageNine(ui.Image image, Rect center, Rect dst, Paint paint) {
    return actualCanvas.drawImageNine(image, center, dst, paint);
  }

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) {
    return actualCanvas.drawImageRect(image, src, dst, paint);
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    return actualCanvas.drawLine(p1, p2, paint);
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    return actualCanvas.drawOval(rect, paint);
  }

  @override
  void drawPaint(Paint paint) {
    return actualCanvas.drawPaint(paint);
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    return actualCanvas.drawParagraph(paragraph, offset);
  }

  @override
  void drawPath(Path path, Paint paint) {
    return actualCanvas.drawPath(path, paint);
  }

  @override
  void drawPicture(Picture picture) {
    return actualCanvas.drawPicture(picture);
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    return actualCanvas.drawPoints(pointMode, points, paint);
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    return actualCanvas.drawRRect(rrect, paint);
  }

  @override
  void drawRawAtlas(
    ui.Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    return actualCanvas.drawRawAtlas(
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
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    return actualCanvas.drawRawPoints(pointMode, points, paint);
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    return actualCanvas.drawRect(rect, paint);
  }

  @override
  void drawShadow(
    Path path,
    Color color,
    double elevation,
    bool transparentOccluder,
  ) {
    return actualCanvas.drawShadow(
      path,
      color,
      elevation,
      transparentOccluder,
    );
  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    return actualCanvas.drawVertices(vertices, blendMode, paint);
  }

  @override
  Rect getDestinationClipBounds() {
    return actualCanvas.getDestinationClipBounds();
  }

  @override
  Rect getLocalClipBounds() {
    return actualCanvas.getLocalClipBounds();
  }

  @override
  int getSaveCount() {
    return actualCanvas.getSaveCount();
  }

  @override
  Float64List getTransform() {
    return actualCanvas.getTransform();
  }

  @override
  void restore() {
    return actualCanvas.restore();
  }

  @override
  void restoreToCount(int count) {
    return actualCanvas.restoreToCount(count);
  }

  @override
  void rotate(double radians) {
    return actualCanvas.rotate(radians);
  }

  @override
  void save() {
    return actualCanvas.save();
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    return actualCanvas.saveLayer(bounds, paint);
  }

  @override
  void scale(double sx, [double? sy]) {
    return actualCanvas.scale(sx, sy);
  }

  @override
  void skew(double sx, double sy) {
    return actualCanvas.skew(sx, sy);
  }

  @override
  void transform(Float64List matrix4) {
    return actualCanvas.transform(matrix4);
  }

  @override
  void translate(double dx, double dy) {
    return actualCanvas.translate(dx, dy);
  }
}
