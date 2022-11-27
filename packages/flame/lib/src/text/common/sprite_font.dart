import 'dart:ui';

import 'package:flame/src/text/common/glyph.dart';
import 'package:meta/meta.dart';

/// [SpriteFont] contains information about a custom font stored in an asset
/// file.
///
/// The [source] parameter is the [Image] where the font's characters are
/// located. The layout of this image can be arbitrary, however, all characters
/// for the font must be in the same source image.
///
/// The [size] property describes the font size of the sprite font. This font
/// size must be the same for all characters in the font.
///
/// The [ascent] property measures the distance from the top of a character to
/// its baseline. This property must be equal for all characters in the font.
///
/// The main information about the font is in the `glyphs` list of the
/// constructor. Each [Glyph] in this list describes a single character (or a
/// ligature) within the source image.
///
/// The [SpriteFont] can be either variable-width or monospace. For a monospace
/// font you can pass the `defaultCharWidth` parameter in the constructor so
/// that you wouldn't have to specify the width of each glyph.
class SpriteFont {
  SpriteFont({
    required this.source,
    required this.size,
    required this.ascent,
    required List<Glyph> glyphs,
    double? defaultCharWidth,
  }) : _data = <int, _Chain>{} {
    for (final glyph in glyphs) {
      var data = _data;
      for (var i = 0; i < glyph.char.length - 1; i++) {
        final j = glyph.char.codeUnitAt(i);
        data = (data[j] ??= _Chain()).followOn ??= <int, _Chain>{};
      }
      final j = glyph.char.codeUnitAt(glyph.char.length - 1);
      final chain = data[j] ??= _Chain();
      assert(
        chain.glyph == null,
        'Duplicate definition for glyph "${glyph.char}"',
      );
      glyph.initialize(defaultCharWidth ?? size, size);
      chain.glyph = glyph;
    }
  }

  final Image source;

  /// The font size, i.e. the height of all characters in the font.
  final double size;

  /// The distance from the top of every character to its baseline.
  final double ascent;

  /// Contains information about the characters of the font. The keys in this
  /// map are the characters' code points. If a particular "character" has a
  /// length greater than 1, then the key will be the first code point of this
  /// character, and all subsequent code points will be stored within the
  /// [_Chain].
  final Map<int, _Chain> _data;

  /// Splits the provided [text] into a sequence of [Glyph]s.
  ///
  /// Any ligatures are consumed greedily: at every position the longest
  /// possible sequence of characters will be matched. If the text contains a
  /// character not available in this font, an error will be thrown.
  @internal
  Iterable<Glyph> textToGlyphs(String text) sync* {
    for (var i = 0; i < text.length; i++) {
      var chain = _data[text.codeUnitAt(i)];
      var iNext = i;
      var resolvedGlyph = chain?.glyph;
      for (var j = i + 1; j < text.length; j++) {
        if (chain?.followOn == null) {
          break;
        }
        final jCharCode = text.codeUnitAt(j);
        chain = chain!.followOn![jCharCode];
        if (chain?.glyph != null) {
          iNext = j;
          resolvedGlyph = chain?.glyph;
        }
      }
      if (resolvedGlyph == null) {
        throw ArgumentError('No glyph data for character "${text[i]}"');
      } else {
        i = iNext;
        yield resolvedGlyph;
      }
    }
  }
}

class _Chain {
  Glyph? glyph;
  Map<int, _Chain>? followOn;
}
