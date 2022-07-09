import 'package:flame/src/text/styles/background_style.dart';
import 'package:flutter/painting.dart';

class BlockStyle {
  BlockStyle({
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.background,
  });

  EdgeInsets margin;
  EdgeInsets padding;
  BackgroundStyle? background;
}
