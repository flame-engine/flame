import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';

import 'position.dart';

/// Some utilities that did not fit anywhere else.
///
/// To use this class, access it via [Flame.util].
class Util {
  /// Sets the app to be fullscreen (no buttons bar os notifications on top).
  ///
  /// Most games should probably be this way.
  void fullScreen() {
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  /// Waits for the initial screen dimensions to be avaliable.
  ///
  /// Because of flutter's issue #5259, when the app starts the size might be 0x0.
  /// This waits for the information to be properly updated.
  ///
  /// A best practice would be to implement there resize hooks on your game and components and don't use this at all.
  /// Make sure your components are able to render and update themselves for any possible screen size.
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

  /// Returns a [material.TextPainter] that allows for text rendering and size measuring.
  ///
  /// Rendering text on the Canvas is not as trivial as it should.
  /// This methods puts all exposes all possible parameters you might want to pass to render text, with sensible defaults.
  /// Only the [text] is mandatory.
  /// It returns a [material.TextPainter]. that have the properties: paint, width and height.
  /// Example usage:
  ///
  ///     final tp = Flame.util.text('Score: $score', fontSize: 48.0, fontFamily: 'Awesome Font');
  ///     p.paint(c, Offset(size.width - p.width - 10, size.height - p.height - 10));
  ///
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

  /// TODO verify if this is still needed (I don't think so)
  void enableEvents() {
    window.onPlatformMessage = BinaryMessages.handlePlatformMessage;
  }

  /// This properly binds a gesture recognizer to your game.
  ///
  /// Use this in order to get it to work in case your app also contains other widgets.
  void addGestureRecognizer(GestureRecognizer recognizer) {
    GestureBinding.instance.pointerRouter.addGlobalRoute((PointerEvent e) {
      if (e is PointerDownEvent) {
        recognizer.addPointer(e);
      }
    });
  }

  /// Utility method to render stuff on a specific place.
  ///
  /// Some render methods don't allow to pass a offset.
  /// This method translate the canvas, draw what you want, and then translate back.
  void drawWhere(Canvas c, Position p, void Function(Canvas) fn) {
    c.translate(p.x, p.y);
    fn(c);
    c.translate(-p.x, -p.y);
  }
}
