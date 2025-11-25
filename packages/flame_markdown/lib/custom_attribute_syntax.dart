import 'package:markdown/markdown.dart';

// cSpell:ignore charcode.dart (file name from another package)
// NOTE: values obtained from file `charcode.dart` from the markdown package
class _Chars {
  /// Character `[`.
  static const int leftBracket = 0x5B;

  /// Character `{`.
  static const int leftBrace = 0x7B;

  /// Character `}`.
  static const int rightBrace = 0x7D;
}

/// Allows for a toned-down version of custom attributes extension for markdown,
/// inspired by the markdown-it-attrs package.
///
/// This allows users to specify a custom class name to a span of text:
///
/// ```markdown
/// [This is a custom class]{.my-custom-class}
/// This word will be [red]{.red} and this one will be [blue]{.blue}.
/// ```
///
/// This is based on the standard Link markdown parser (which matches the
/// `[text](url)` and `[text][ref]` syntaxes).
class CustomAttributeSyntax extends LinkSyntax {
  /// Creates a new custom attribute syntax.
  CustomAttributeSyntax()
    : super(
        pattern: r'\[',
        startCharacter: _Chars.leftBracket,
      );

  @override
  Iterable<Node>? close(
    InlineParser parser,
    covariant SimpleDelimiter opener,
    Delimiter? closer, {
    required List<Node> Function() getChildren,
    String? tag,
  }) {
    final text = parser.source.substring(opener.endPos, parser.pos);

    // The current character is the `]` that closed the span text.
    // The next character must be a `{`:
    parser.advanceBy(1);
    if (parser.isDone) {
      return null; // not valid syntax - skip
    }
    final char = parser.charAt(parser.pos);
    if (char != _Chars.leftBrace) {
      return null; // not valid syntax - skip
    }

    final attributes = _parseAttributes(parser) ?? {};
    final node = _createNode(text, attributes, getChildren: getChildren);
    return [node];
  }

  /// Create this node represented by a span with custom attributes.
  Node _createNode(
    String text,
    Map<String, String> attributes, {
    required List<Node> Function() getChildren,
  }) {
    final children = getChildren();
    final element = Element('span', children);
    for (final attr in attributes.entries) {
      element.attributes[attr.key] = attr.value;
    }
    return element;
  }

  /// At this point, we have parsed a custom tag opening `[`, and then a
  /// matching closing `]`, and now [parser] is pointing at an opening `{`.
  Map<String, String>? _parseAttributes(InlineParser parser) {
    // Start walking to the character just after the opening `{`.
    parser.advanceBy(1);

    final buffer = StringBuffer();

    while (true) {
      final char = parser.charAt(parser.pos);
      if (char == _Chars.rightBrace) {
        final attributes = buffer.toString();
        return _parseAttributeList(attributes);
      }

      buffer.writeCharCode(char);
      parser.advanceBy(1);
      if (parser.isDone) {
        return null; // not valid syntax - skip
      }
    }
  }

  Map<String, String>? _parseAttributeList(String attributes) {
    // Currently we only support one attribute being the class name.
    // More support can be added in the future following the syntax from
    // the markdown-it library.
    final regex = RegExp(r'\.([a-zA-Z0-9_-]+)'); // matches `.class-name`
    final content = attributes.trim();
    final className = regex.firstMatch(content)?.group(1);
    if (className == null) {
      return null; // not valid syntax - skip
    }
    return {'class': className};
  }
}
