import 'dart:convert';

import 'package:flame/src/text/block/group_text_block.dart';
import 'package:flame/src/text/block/plain_text_block.dart';
import 'package:flame/src/text/block/text_block.dart';
import 'package:flame/src/text/inline/group_text_element.dart';
import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/text.dart';
import 'package:flutter/rendering.dart';

class TextParser {
  late final normalStyle = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontFamily: 'Arial',
      fontSize: 18,
    ),
  );
  late final boldStyle = normalStyle.copyWith(
    (style) => style.copyWith(fontWeight: FontWeight.bold, fontSize: 30),
  );

  TextBlock parse(String text) {
    final blocks = <TextBlock>[];
    final lines = const LineSplitter().convert(text);
    var i0 = -1;
    for (var i = 0; i < lines.length; i++) {
      final thisLineIsEmpty = lines[i].isEmpty;
      if (thisLineIsEmpty) {
        if (i0 >= 0) {
          blocks.add(_parseParagraph(lines.getRange(i0, i).join(' ')));
          i0 = -1;
        }
      } else {
        if (i0 == -1) {
          i0 = i;
        }
      }
    }
    if (i0 >= 0) {
      blocks.add(_parseParagraph(lines.getRange(i0, lines.length).join(' ')));
    }
    return GroupTextBlock(blocks);
  }

  TextBlock _parseParagraph(String text) {
    final words = <TextElement>[];
    for (final word in text.split(' ')) {
      if (word.startsWith('**') && word.endsWith('**')) {
        words.add(boldStyle.forge(word.substring(2, word.length - 2)));
      } else {
        words.add(normalStyle.forge(word));
      }
      words.add(normalStyle.forge(' '));
    }
    words.removeLast(); // remove last space
    return PlainTextBlock(GroupTextElement(words));
  }
}
