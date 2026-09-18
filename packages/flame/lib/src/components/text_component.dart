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

  /// The renderer that was set on the component.
  ///
  /// The text is drawn with [paintedTextRenderer], which is derived from this
  /// renderer whenever the [paint] changes, so this renderer is never modified
  /// by opacity or color changes.
  T get textRenderer => _textRenderer;
  T _textRenderer;
  set textRenderer(T textRenderer) {
    _textRenderer = textRenderer;
    _paintedTextRenderer = _hasPaintChanged
        ? textRenderer.copyWithPaint(paint) as T
        : textRenderer;
    updateBounds();
  }

  /// [textRenderer] with the [paint] of the component applied, which is what
  /// the text is drawn with.
  ///
  /// It is derived from [textRenderer] again on every paint change, so the
  /// paint never compounds across changes.
  @internal
  T get paintedTextRenderer => _paintedTextRenderer;
  late T _paintedTextRenderer;
  bool _hasPaintChanged = false;

  late InlineTextElement _textElement;

  void _updateElement() {
    _textElement = _paintedTextRenderer.format(_text);
    _textElement.translate(0, _textElement.metrics.ascent);
  }

  @internal
  void updateBounds() {
    _updateElement();
    final measurements = _textElement.metrics;
    size.setValues(measurements.width, measurements.height);
  }

  @override
  void render(Canvas canvas) {
    _textElement.draw(canvas);
  }

  @override
  void onChanged() {
    _hasPaintChanged = true;
    _paintedTextRenderer = _textRenderer.copyWithPaint(paint) as T;
    _updateElement();
  }
}
