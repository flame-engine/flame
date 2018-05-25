import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';

import 'position.dart';

class Util {
  void fullScreen() {
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  Future<Size> initialDimensions() async {
    // https://github.com/flutter/flutter/issues/5259
    // "In release mode we start off at 0x0 but we don't in debug mode"
    return await new Future<Size>(() {
      if (window.physicalSize.isEmpty) {
        final completer = new Completer<Size>();
        window.onMetricsChanged = () {
          if (!window.physicalSize.isEmpty) {
            completer.complete(window.physicalSize / window.devicePixelRatio);
          }
        };
        return completer.future;
      }
      return window.physicalSize / window.devicePixelRatio;
    });
  }

  material.TextPainter text(
    String text, {
    double fontSize: 24.0,
    Color color: material.Colors.black,
    String fontFamily: 'Arial',
    TextAlign textAlign: TextAlign.left,
    TextDirection textDirection: TextDirection.ltr,
  }) {
    material.TextStyle style = new material.TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
    );
    material.TextSpan span = new material.TextSpan(
      style: style,
      text: text,
    );
    material.TextPainter tp = new material.TextPainter(
      text: span,
      textAlign: textAlign,
      textDirection: textDirection,
    );
    tp.layout();
    return tp;
  }

  void enableEvents() {
    window.onPlatformMessage = BinaryMessages.handlePlatformMessage;
  }

  void addGestureRecognizer(GestureRecognizer recognizer) {
    GestureBinding.instance.pointerRouter.addGlobalRoute((PointerEvent e) {
      if (e is PointerDownEvent) {
        recognizer.addPointer(e);
      }
    });
  }

  void drawWhere(Canvas c, Position p, void Function(Canvas) fn) {
    c.translate(p.x, p.y);
    fn(c);
    c.translate(-p.x, -p.y);
  }
}
