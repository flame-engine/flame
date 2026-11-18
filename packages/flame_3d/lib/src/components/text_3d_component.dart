import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/painting.dart'
    show EdgeInsets, TextPainter, TextSpan, TextStyle;

/// Depth-tested 3D world-space text badge / floating label rendered on the GPU
/// via [BillboardMaterial3D] so 3D geometry accurately occludes it.
class Text3DComponent({
  required String text,
  TextStyle style = const TextStyle(
    color: ui.Color(0xFFFFFFFF),
    fontSize: 28,
    fontWeight: ui.FontWeight.w700,
  ),
  var double worldHeight = 0.55,
  var ui.Color? backgroundColor = const ui.Color(0xB30F172A),
  var ui.Color? borderColor = const ui.Color(0xFF38BDF8),
  var double cornerRadius = 10.0,
  var EdgeInsets padding = const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 6,
  ),
  var BillboardOrientation3D orientation = BillboardOrientation3D.spherical,
  Vector3? upAxis,
  super.position,
}) extends Object3D {
  this : super(castsShadows: false) {
    _upAxis = upAxis?.clone() ?? Vector3(0, 1, 0);
    _rebuildTexture();
  }

  String _text = text;
  String get text => _text;
  set text(String value) {
    if (value == _text) {
      return;
    }
    _text = value;
    _rebuildTexture();
    worldOrNull?.markSceneDirty(shadows: false);
  }

  TextStyle _style = style;
  TextStyle get style => _style;
  set style(TextStyle value) {
    _style = value;
    _rebuildTexture();
    worldOrNull?.markSceneDirty(shadows: false);
  }

  late Vector3 _upAxis;

  late final BillboardMaterial3D _material = BillboardMaterial3D(
    shadeWeight: 0.0,
    translucent: true,
  );

  late final BillboardBatch3D _batch = BillboardBatch3D(
    material: _material,
    initialCapacity: 1,
  );

  double _aspect = 2.0;
  double get worldWidth => worldHeight * _aspect;

  void _rebuildTexture() {
    final painter = TextPainter(
      text: TextSpan(text: _text, style: _style),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final texW = math.max(
      8,
      (painter.width + padding.horizontal).ceil(),
    );
    final texH = math.max(
      8,
      (painter.height + padding.vertical).ceil(),
    );
    _aspect = texW / texH;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final rect = ui.Rect.fromLTWH(0, 0, texW.toDouble(), texH.toDouble());
    final rrect = ui.RRect.fromRectAndRadius(
      rect.deflate(1.5),
      ui.Radius.circular(cornerRadius),
    );
    if (backgroundColor != null) {
      canvas.drawRRect(rrect, ui.Paint()..color = backgroundColor!);
    }
    if (borderColor != null) {
      canvas.drawRRect(
        rrect,
        ui.Paint()
          ..color = borderColor!
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
    painter.paint(canvas, ui.Offset(padding.left, padding.top));
    painter.dispose();

    final picture = recorder.endRecording();
    final img = picture.toImageSync(texW, texH);
    picture.dispose();

    GpuTexture? gpuTex;
    if (GpuBackend.isAvailable) {
      try {
        gpuTex = GpuBackend.instance.createTextureFromImage(img);
      } on Object {
        gpuTex = null;
      }
    }
    if (gpuTex != null) {
      _material.albedoTexture = ImageTexture(
        null,
        width: texW,
        height: texH,
        sampler: TextureSampler.linear,
        gpuTexture: gpuTex,
      );
      img.dispose();
    } else {
      // Fallback for non-GPU unit test environments.
      _material.albedoTexture = ColorTexture(const ui.Color(0xFFFFFFFF));
      img.dispose();
    }
  }

  @override
  Aabb3? computeLocalAabb() {
    final hw = worldWidth * 0.5;
    final hh = worldHeight * 0.5;
    return Aabb3.minMax(Vector3(-hw, -hh, -hw), Vector3(hw, hh, hw));
  }

  final Vector3 _worldPos = Vector3.zero();

  @override
  void draw(covariant RenderContext3D context) {
    if (context.isShadowPass) {
      return;
    }
    final m = worldTransformMatrix.storage;
    _worldPos.setValues(m[12], m[13], m[14]);
    _batch.clear();
    _batch.addBillboard(
      position: _worldPos,
      width: worldWidth,
      height: worldHeight,
      orientation: orientation,
      upAxis: _upAxis,
      anchorY: 0.0,
      unlit: 1.0,
    );
    _batch.draw(context);
  }
}
