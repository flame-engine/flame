import 'package:flame/text.dart';

/// A [FlameTextStyle] is a base class for several classes that collectively
/// describe the desired visual appearance of a "rich-text" document.
///
/// The style classes mostly are collections of properties that describe how a
/// potential document should be formatted. However, they have little logic
/// beyond that. The style classes are then passed to document `Node`s so that
/// the content of a document can be formatted.
///
/// Various [FlameTextStyle] classes are organized into a tree, with
/// [DocumentStyle] at the root.
///
/// The tree of [FlameTextStyle]s is roughly equivalent to a CSS stylesheet.
abstract class FlameTextStyle {
  const FlameTextStyle();

  FlameTextStyle copyWith(covariant FlameTextStyle other);

  static T? merge<T extends FlameTextStyle>(T? style1, T? style2) {
    if (style1 == null) {
      return style2;
    } else if (style2 == null) {
      return style1;
    } else {
      assert(style1.runtimeType == style2.runtimeType);
      return style1.copyWith(style2) as T;
    }
  }
}
