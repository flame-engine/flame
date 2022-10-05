import 'package:flame/src/text/styles/background_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flutter/painting.dart' hide TextStyle;
import 'package:meta/meta.dart';

/// [BlockStyle] is a generic descriptor for a visual appearance of a block-
/// level element.
@immutable
class BlockStyle extends Style {
  const BlockStyle({
    EdgeInsets? margin,
    EdgeInsets? padding,
    this.background,
    this.text,
  })  : _margin = margin,
        _padding = padding;

  final EdgeInsets? _margin;
  final EdgeInsets? _padding;
  final BackgroundStyle? background;
  final FlameTextStyle? text;

  EdgeInsets get margin => _margin ?? EdgeInsets.zero;
  EdgeInsets get padding => _padding ?? EdgeInsets.zero;

  @override
  BlockStyle copyWith(BlockStyle other) {
    return BlockStyle(
      margin: other._margin ?? _margin,
      padding: other._padding ?? _padding,
      background: other.background ?? background,
      text: Style.merge(text, other.text),
    );
  }
}
