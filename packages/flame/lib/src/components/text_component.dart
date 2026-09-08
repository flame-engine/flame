import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

class TextComponent<T extends TextRenderer> extends PositionComponent
    with HasPaint {
  TextComponent({
    String? text,
    T? textRenderer,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : _text = text ?? '',
       _textRenderer = textRenderer ?? TextRendererFactory.createDefault<T>() {
    _paintedTextRenderer = _textRenderer;
    _seedPaintColor();
    updateBounds();
  }

  String get text => _text;
  String _text;
  set text(String text) {
    if (_text != text) {
      _text = text;
      updateBounds();
    }
  }

  /// The renderer as given by the user. Setting it also starts [paint] from
  /// the style's own color, see [paintedTextRenderer].
  T get textRenderer => _textRenderer;
  T _textRenderer;
  set textRenderer(T textRenderer) {
    _textRenderer = textRenderer;
    _paintedTextRenderer = textRenderer;
    _seedPaintColor();
    updateBounds();
  }

  /// [textRenderer] with the component's [paint] applied, which is what the
  /// text is drawn with. It is derived from [textRenderer] again on every
  /// paint change, so the paint never compounds across changes.
  @internal
  T get paintedTextRenderer => _paintedTextRenderer;
  late T _paintedTextRenderer;

  /// Starts [paint] from the style's own color, so that the first paint change
  /// (for example an `OpacityEffect`) fades the text in its color instead of
  /// replacing it with the default white paint.
  void _seedPaintColor() {
    final renderer = _textRenderer;
    if (renderer is TextPaint) {
      final color = renderer.style.color;
      if (color != null) {
        paint.color = color;
      }
    }
  }

  late InlineTextElement _textElement;

  void _updateElement() {
    _textElement = _paintedTextRenderer.format(_text);
  }

  @internal
  void updateBounds() {
    _updateElement();
    final measurements = _textElement.metrics;
    _textElement.translate(0, measurements.ascent);
    size.setValues(measurements.width, measurements.height);
  }

  @override
  void render(Canvas canvas) {
    _textElement.draw(canvas);
  }

  @override
  void onChanged() {
    _paintedTextRenderer = _textRenderer.copyWithPaint(paint) as T;
    _updateElement();
  }
}
