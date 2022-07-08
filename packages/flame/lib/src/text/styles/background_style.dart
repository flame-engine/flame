import 'dart:ui';

import 'package:flame/src/text/elements/element.dart';
import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/elements/rect_element.dart';
import 'package:flame/src/text/elements/rrect_element.dart';
import 'package:flutter/rendering.dart';

class BackgroundStyle {
  BackgroundStyle({
    Color? color,
    Paint? paint,
    Color? borderColor,
    double? borderRadius,
    double? borderWidth,
  })  : assert(
          paint == null || color == null,
          'Parameters `paint` and `color` are exclusive',
        ),
        _borderWidth = borderWidth ?? 0,
        _borderRadius = borderRadius ?? 0 {
    if (paint != null) {
      _backgroundPaint = paint;
    } else if (color != null) {
      _backgroundPaint = Paint()..color = color;
    } else {
      _backgroundPaint = null;
    }
    if (borderColor != null) {
      _borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth;
    } else {
      _borderPaint = null;
    }
  }

  late final Paint? _backgroundPaint;
  late final Paint? _borderPaint;
  late final double _borderWidth;
  final double _borderRadius;

  Element? format(double width, double height) {
    final elements = <Element>[];
    if (_backgroundPaint != null) {
      if (_borderRadius == 0) {
        elements.add(RectElement(width, height, _backgroundPaint!));
      } else {
        elements.add(RRectElement(width, height, _borderRadius, _borderPaint!));
      }
    }
    if (_borderPaint != null) {
      if (_borderRadius == 0) {
        elements.add(
          RectElement(
            width - _borderWidth,
            height - _borderWidth,
            _borderPaint!,
          )..translate(_borderWidth / 2, _borderWidth / 2),
        );
      } else {
        elements.add(
          RRectElement(
            width - _borderWidth,
            height - _borderWidth,
            _borderRadius,
            _borderPaint!,
          )..translate(_borderWidth / 2, _borderWidth / 2),
        );
      }
    }
    if (elements.isEmpty) {
      return null;
    }
    if (elements.length == 1) {
      return elements.first;
    } else {
      return GroupElement(elements);
    }
  }
}
