import 'package:flame/text.dart';
import 'package:flutter/painting.dart' hide TextStyle;
import 'package:meta/meta.dart';

/// [BlockStyle] is a generic descriptor for a visual appearance of a block-
/// level element.
@immutable
class BlockStyle extends FlameTextStyle {
  const BlockStyle({
    EdgeInsets? margin,
    EdgeInsets? padding,
    this.background,
    this.text,
    this.textAlign,
  }) : _margin = margin,
       _padding = padding;

  final EdgeInsets? _margin;
  final EdgeInsets? _padding;
  final BackgroundStyle? background;
  final InlineTextStyle? text;
  final TextAlign? textAlign;

  EdgeInsets get margin => _margin ?? EdgeInsets.zero;
  EdgeInsets get padding => _padding ?? EdgeInsets.zero;

  @override
  BlockStyle copyWith(BlockStyle other) {
    return BlockStyle(
      margin: other._margin ?? _margin,
      padding: other._padding ?? _padding,
      background: other.background ?? background,
      text: FlameTextStyle.merge(text, other.text),
      textAlign: other.textAlign ?? textAlign,
    );
  }
}
