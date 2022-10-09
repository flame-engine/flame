import 'package:flame/src/text/elements/block_element.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/document_style.dart';
import 'package:flame/src/text/styles/flame_text_style.dart';

/// [BlockNode] is a base class for all nodes with "block" placement rules; it
/// roughly corresponds to `<div/>` in HTML.
///
/// A block node should be able to find its style in the root stylesheet, via
/// the method [fillStyles], and then based on that style build the
/// corresponding element in the [format] method. Both of these methods must be
/// implemented by subclasses.
abstract class BlockNode {
  /// The runtime style applied to this node, this will be set by [fillStyles].
  late BlockStyle style;

  BlockElement format(double availableWidth);

  void fillStyles(DocumentStyle stylesheet, FlameTextStyle parentTextStyle);
}
