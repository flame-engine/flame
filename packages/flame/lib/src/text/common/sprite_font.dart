import 'dart:ui';

import 'package:flame/src/text/common/glyph.dart';
import 'package:meta/meta.dart';

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
  final double size;
  final double ascent;
  final Map<int, _Chain> _data;

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
