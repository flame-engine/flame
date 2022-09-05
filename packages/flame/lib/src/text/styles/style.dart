import 'package:flame/src/text/styles/document_style.dart';
import 'package:meta/meta.dart';

/// A [Style] is a base class for several classes that collectively describe
/// the desired visual appearance of a "rich-text" document.
///
/// The style classes mostly are collections of properties that describe how a
/// potential document should be formatted. However, they have little logic
/// beyond that. The style classes are then passed to document `Node`s so that
/// the content of a document can be formatted.
///
/// Various [Style] classes are organized into a tree, with [DocumentStyle] at
/// the root.
///
/// The tree of [Style]s is roughly equivalent to a CSS stylesheet.
abstract class Style {
  /// The owner of the current style.
  ///
  /// Usually, styles are organized into a tree, and this property allows
  /// traversing up this tree. This property can be null when the style hasn't
  /// been put into a tree yet, or when it is the root of the tree.
  Style? get parent => _parent;
  Style? _parent;

  /// Creates and returns a copy of the current object.
  Style clone();

  /// Marks [style] as being owned by the current object and returns it.
  /// However, if the [style] is already owned by some other object, then clones
  /// the [style], marks the copy as being owned, and returns it.
  @protected
  S? acquire<S extends Style>(S? style) {
    if (style == null) {
      return null;
    }
    final useStyle = style._parent == null ? style : style.clone() as S;
    useStyle._parent = this;
    return useStyle;
  }
}
