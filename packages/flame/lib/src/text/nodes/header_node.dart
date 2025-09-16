import 'dart:ui';

import 'package:flame/text.dart';
import 'package:flutter/rendering.dart' show EdgeInsets;

class HeaderNode extends TextBlockNode {
  HeaderNode(super.child, {required this.level});

  HeaderNode.simple(String text, {required this.level})
    : super(PlainTextNode(text));

  final int level;

  static BlockStyle defaultStyleH1 = BlockStyle(
    text: InlineTextStyle(fontScale: 2.0, fontWeight: FontWeight.bold),
    margin: const EdgeInsets.fromLTRB(0, 24, 0, 12),
  );
  static BlockStyle defaultStyleH2 = BlockStyle(
    text: InlineTextStyle(fontScale: 1.5, fontWeight: FontWeight.bold),
    margin: const EdgeInsets.fromLTRB(0, 24, 0, 8),
  );
  static BlockStyle defaultStyleH3 = BlockStyle(
    text: InlineTextStyle(fontScale: 1.25, fontWeight: FontWeight.bold),
  );
  static BlockStyle defaultStyleH4 = BlockStyle(
    text: InlineTextStyle(fontScale: 1.0, fontWeight: FontWeight.bold),
  );
  static BlockStyle defaultStyleH5 = BlockStyle(
    text: InlineTextStyle(fontScale: 0.875, fontWeight: FontWeight.bold),
  );
  static BlockStyle defaultStyleH6 = BlockStyle(
    text: InlineTextStyle(fontScale: 0.85, fontWeight: FontWeight.bold),
  );

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = switch (level) {
      1 => stylesheet.header1,
      2 => stylesheet.header2,
      3 => stylesheet.header3,
      4 => stylesheet.header4,
      5 => stylesheet.header5,
      _ => stylesheet.header6,
    };
    final textStyle = FlameTextStyle.merge(parentTextStyle, style.text)!;
    super.fillStyles(stylesheet, textStyle);
  }
}
