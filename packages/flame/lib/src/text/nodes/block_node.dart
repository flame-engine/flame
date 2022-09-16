import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/text_style.dart';

/// [BlockNode] is a base class for all nodes with "block" placement rules.
///
/// A block node is a structural piece of text such that the
abstract class BlockNode {

  late BlockStyle style;
  late TextStyle textStyle;

  BlockElement format(double availableWidth);

  void fillStyles(DocumentStyle stylesheet, TextStyle parentTextStyle);
}
