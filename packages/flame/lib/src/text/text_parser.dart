
import 'dart:convert';

import 'package:flame/src/text/block/group_text_block.dart';
import 'package:flame/src/text/block/plain_text_block.dart';
import 'package:flame/src/text/block/text_block.dart';
import 'package:flame/src/text/inline/group_text_element.dart';
import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/text.dart';

class TextParser {
  TextBlock parse(String text) {
    final blocks = <TextBlock>[];
    final lines = const LineSplitter().convert(text);
    var i0 = -1;
    for (var i = 0; i < lines.length; i++) {
      final isEmpty = lines[i].isEmpty;
      if (isEmpty) {
        if (i0 >= 0) {
           blocks.add(_parseParagraph(lines.getRange(i0, i).join(' ')));
           i0 = -1;
        }
      }
    }
    return GroupTextBlock(blocks);
  }

  TextBlock _parseParagraph(String text) {
    final renderer = TextPaint();
    final words = <TextElement>[];
    for (final word in text.split(' ')) {
      words.add(renderer.forge(word));
      words.add(renderer.forge(' '));
    }
    words.removeLast(); // remove last space
    return PlainTextBlock(GroupTextElement(words));
  }
}
