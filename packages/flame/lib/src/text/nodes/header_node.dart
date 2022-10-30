import 'dart:ui';

import 'package:flame/src/text/nodes/plain_text_node.dart';
import 'package:flame/src/text/nodes/text_block_node.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flutter/rendering.dart' show EdgeInsets;

class HeaderNode extends TextBlockNode {
  HeaderNode(super.child, {required this.level});

  HeaderNode.simple(String text, {required this.level})
      : super(PlainTextNode(text));

  final int level;

  static BlockStyle defaultStyleH1 = BlockStyle(
    text: FlameTextStyle(fontScale: 2.0, fontWeight: FontWeight.bold),
    margin: const EdgeInsets.fromLTRB(0, 24, 0, 12),
  );
  static BlockStyle defaultStyleH2 = BlockStyle(
    text: FlameTextStyle(fontScale: 1.5, fontWeight: FontWeight.bold),
    margin: const EdgeInsets.fromLTRB(0, 24, 0, 8),
  );
  static BlockStyle defaultStyleH3 = BlockStyle(
    text: FlameTextStyle(fontScale: 1.25, fontWeight: FontWeight.bold),
  );
  static BlockStyle defaultStyleH4 = BlockStyle(
    text: FlameTextStyle(fontScale: 1.0, fontWeight: FontWeight.bold),
  );
  static BlockStyle defaultStyleH5 = BlockStyle(
    text: FlameTextStyle(fontScale: 0.875, fontWeight: FontWeight.bold),
  );
  static BlockStyle defaultStyleH6 = BlockStyle(
    text: FlameTextStyle(fontScale: 0.85, fontWeight: FontWeight.bold),
  );

  @override
  void fillStyles(DocumentStyle stylesheet, FlameTextStyle parentTextStyle) {
    style = level == 1
        ? stylesheet.header1
        : level == 2
            ? stylesheet.header2
            : level == 3
                ? stylesheet.header3
                : level == 4
                    ? stylesheet.header4
                    : level == 5
                        ? stylesheet.header5
                        : stylesheet.header6;
    final textStyle = Style.merge(parentTextStyle, style.text)!;
    super.fillStyles(stylesheet, textStyle);
  }
}
