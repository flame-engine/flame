import 'dart:ui';

import 'package:flame/src/text/nodes/block_node.dart';
import 'package:flame/src/text/nodes/header_node.dart';
import 'package:flame/src/text/nodes/paragraph_node.dart';
import 'package:flame/src/text/styles/background_style.dart';
import 'package:flame/src/text/styles/block_style.dart';
import 'package:flame/src/text/styles/overflow.dart';
import 'package:flame/src/text/styles/style.dart';
import 'package:flame/src/text/styles/text_style.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:meta/meta.dart';

/// [DocumentStyle] is a user-facing description of how to render an entire
/// body of text; it roughly corresponds to a stylesheet in HTML.
///
/// This class represents a top-level style sheet, comprised of properties that
/// describe the document as a whole (as opposed to lower-level styles that
/// represent more granular elements such as paragraphs, headers, etc).
///
/// All styles that collectively describe how to render text are organized into
/// a tree, with [DocumentStyle] at the root.
class DocumentStyle extends Style {
  const DocumentStyle({
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.background,
    this.paragraph = _defaultParagraphStyle,
    this.header1 = _defaultHeader1Style,
    this.header2 = _defaultHeader2Style,
    this.header3 = _defaultHeader3Style,
    this.header4 = _defaultHeader4Style,
    this.header5 = _defaultHeader5Style,
    this.header6 = _defaultHeader6Style,
  });

  /// Outer width of the document page.
  ///
  /// This width is the distance between the left edge of the left border, and
  /// the right edge of the right border. Thus, it corresponds to the
  /// "border-box" box sizing model in HTML.
  ///
  /// If this property is `null`, then the page width must be provided when
  /// formatting a document.
  final double? width;

  /// Outer height of the document page.
  ///
  /// If the [overflow] property is [Overflow.expand], then the height parameter
  /// is treated as a minimum height, in other cases the height is obeyed
  /// strictly.
  ///
  /// If this property is `null`, then the page height must be provided when
  /// formatting a document (except for the overflow-expand mode, when the
  /// value of [height] defaults to 0).
  final double? height;

  /// Behavior of the document when the amount of content that needs to be laid
  /// out exceeds the provided [height]. See the [Overflow] enum description for
  /// more details.
  Overflow get overflow => Overflow.expand;

  /// The distance from the outer edges of the page to the inner content box of
  /// the document.
  ///
  /// Note that the padding is computed from the outer edge of the page, unlike
  /// HTML where it is computed from the inner edge of the border box.
  ///
  /// If the document's horizontal padding exceeds its width, an exception will
  /// be thrown.
  final EdgeInsets padding;

  /// If present, describes what kind of background and borders to draw for the
  /// document page(s).
  final BackgroundStyle? background;

  /// Style for paragraph nodes in the document.
  final BlockStyle paragraph;

  /// Styles for headers of levels 1 to 6.
  final BlockStyle header1;
  final BlockStyle header2;
  final BlockStyle header3;
  final BlockStyle header4;
  final BlockStyle header5;
  final BlockStyle header6;

  static const _defaultParagraphStyle = BlockStyle();
  static const _defaultHeader1Style = BlockStyle(
    text: TextStyle(fontScale: 2.0, fontWeight: FontWeight.bold),
  );
  static const BlockStyle _defaultHeader2Style = BlockStyle(
    text: TextStyle(fontScale: 1.5, fontWeight: FontWeight.bold),
  );
  static const BlockStyle _defaultHeader3Style = BlockStyle(
    text: TextStyle(fontScale: 1.25, fontWeight: FontWeight.bold),
  );
  static const BlockStyle _defaultHeader4Style = BlockStyle(
    text: TextStyle(fontScale: 1.0, fontWeight: FontWeight.bold),
  );
  static const BlockStyle _defaultHeader5Style = BlockStyle(
    text: TextStyle(fontScale: 0.875, fontWeight: FontWeight.bold),
  );
  static const BlockStyle _defaultHeader6Style = BlockStyle(
    text: TextStyle(fontScale: 0.85, fontWeight: FontWeight.bold),
  );

  DocumentStyle copyWith({
    double? width,
    double? height,
    EdgeInsets? padding,
    BackgroundStyle? background,
    BlockStyle? paragraph,
    BlockStyle? header1,
    BlockStyle? header2,
    BlockStyle? header3,
    BlockStyle? header4,
    BlockStyle? header5,
    BlockStyle? header6,
  }) {
    return DocumentStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      background: background ?? this.background,
      paragraph: paragraph ?? this.paragraph,
      header1: header1 ?? this.header1,
      header2: header2 ?? this.header2,
      header3: header3 ?? this.header3,
      header4: header4 ?? this.header4,
      header5: header5 ?? this.header5,
      header6: header6 ?? this.header6,
    );
  }

  @internal
  BlockStyle styleFor(BlockNode node) {
    if (node is ParagraphNode) {
      return paragraph;
    }
    if (node is HeaderNode) {
      switch (node.level) {
        case 1:
          return header1;
        case 2:
          return header2;
        case 3:
          return header3;
        case 4:
          return header4;
        case 5:
          return header5;
        default:
          return header6;
      }
    }
    return const BlockStyle();
  }
}
