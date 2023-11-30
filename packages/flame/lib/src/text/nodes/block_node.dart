import 'package:flame/text.dart';

/// [BlockNode] is a base class for all nodes with "block" placement rules; it
/// roughly corresponds to `<div/>` in HTML.
///
/// A block node should be able to find its style in the root stylesheet, via
/// the method [fillStyles], and then based on that style build the
/// corresponding element in the [format] method. Both of these methods must be
/// implemented by subclasses.
///
/// Implementations include:
/// * ColumnNode
/// * TextBlockNode (which itself can be a HeaderNode or ParagraphNode)
abstract class BlockNode implements TextNode<BlockStyle> {
  /// The runtime style applied to this node, this will be set by [fillStyles].
  @override
  late BlockStyle style;

  BlockElement format(double availableWidth);

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle);
}
