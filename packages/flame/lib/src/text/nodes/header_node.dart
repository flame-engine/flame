import 'dart:ui';

import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/nodes/text_nodes.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/text_style.dart';

class HeaderNode extends BlockNode {
  HeaderNode(this.child, {required this.level});

  final GroupTextNode child;
  final int level;

  static const defaultStyleH1 = BlockStyle(
    text: TextStyle(fontScale: 2.0, fontWeight: FontWeight.bold),
  );
  static const defaultStyleH2 = BlockStyle(
    text: TextStyle(fontScale: 1.5, fontWeight: FontWeight.bold),
  );
  static const defaultStyleH3 = BlockStyle(
    text: TextStyle(fontScale: 1.25, fontWeight: FontWeight.bold),
  );
  static const defaultStyleH4 = BlockStyle(
    text: TextStyle(fontScale: 1.0, fontWeight: FontWeight.bold),
  );
  static const defaultStyleH5 = BlockStyle(
    text: TextStyle(fontScale: 0.875, fontWeight: FontWeight.bold),
  );
  static const defaultStyleH6 = BlockStyle(
    text: TextStyle(fontScale: 0.85, fontWeight: FontWeight.bold),
  );

}
