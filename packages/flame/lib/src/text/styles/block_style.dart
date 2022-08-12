import 'package:flame/src/text/styles/background_style.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flutter/painting.dart';

class BlockStyle extends Style {
  BlockStyle({
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.background,
  });

  EdgeInsets margin;
  EdgeInsets padding;
  BackgroundStyle? background;

  @override
  BlockStyle clone() => copyWith();

  BlockStyle copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    BackgroundStyle? background,
  }) {
    return BlockStyle(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      background: background ?? this.background,
    );
  }
}
