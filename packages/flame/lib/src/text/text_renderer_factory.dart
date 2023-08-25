import 'package:flame/text.dart';

class TextRendererFactory {
  /// A registry containing default providers for every [TextRenderer] subclass;
  /// used by [createDefault] to create default parameter values.
  ///
  /// If you add a new [TextRenderer] child, you can register it by adding it,
  /// together with a provider lambda, to this map.
  static Map<Type, TextRenderer Function()> defaultRegistry = {
    TextRenderer: TextPaint.new,
    TextPaint: TextPaint.new,
  };

  /// Given a generic type [T], creates a default renderer of that type.
  static T createDefault<T extends TextRenderer>() {
    final creator = defaultRegistry[T];
    if (creator != null) {
      return creator() as T;
    } else {
      throw 'Unknown implementation of TextRenderer: $T. Please register it '
          'under [TextRendererFactory.defaultRegistry].';
    }
  }
}
