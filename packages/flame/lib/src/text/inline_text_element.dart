import 'dart:ui';

import 'package:flame/src/text/text_line.dart';

/// Base class describing a span of text that has "inline" placement rules.
///
/// Concrete implementations of this class must know how to lay themselves out
/// (i.e. determine the exact placement and size of each internal piece), and
/// then render on a canvas after the layout.
///
/// The layout mechanism used by this class works as follows:
/// - initially, [isLaidOut] is false, and [numLinesLaidOut] is 0;
/// - the owner of the text will call [layOutNextLine], requesting the text to
///   be placed on the specified baseline between coordinates `x0` and `x1`;
/// - if the text can be fit between the requested coordinates, then
///   [LayoutResult.done] is returned, and [isLaidOut] becomes true;
/// - if the text can only fit partially between `x0` and `x1`, then the method
///   will return [LayoutResult.unfinished], and [numLinesLaidOut] increase. At
///   this moment the caller should call [layOutNextLine] again, to continue the
///   layout process;
/// - if the text cannot fit between `x0` and `x1` at all, even partially, then
///   [LayoutResult.didNotAdvance] is returned. The caller needs to either
///   supply more horizontal distance next time, or apply other mitigation
///   strategies;
/// - at any point the caller can call [lines] in order to obtain access to the
///   lines that were already laid out.
///
/// An inline text can potentially span multiple lines, be adjacent to other
/// [InlineTextElement]s, or contain other [InlineTextElement]s inside.
abstract class InlineTextElement {
  /// True iff the text has been completely laid out.
  bool get isLaidOut;

  /// The number of lines of text that have been laid out so far.
  ///
  /// This should start at 0 before the beginning of the layout process, and
  /// then increase by 1 after each call to [layOutNextLine] (except when it
  /// returns [LayoutResult.didNotAdvance]).
  int get numLinesLaidOut;

  /// Performs layout of a single line of text.
  ///
  /// Vertically, the text should be placed on the provided [baseline].
  /// Horizontally, it should start at [x0] and do not go beyond [x1]. The
  /// implementation should attempt to put as much text as possible within these
  /// bounds, and then increase the [numLinesLaidOut] counter.
  ///
  /// The return status can be one of the following:
  /// - [LayoutResult.done]: the layout is finished;
  /// - [LayoutResult.unfinished]: more calls to [layOutNextLine] are needed;
  /// - [LayoutResult.didNotAdvance]: the amount of space provided is too small
  ///   to place any amount of text. The caller should supply a larger value of
  ///   `x1 - x0` next time. The counter [numLinesLaidOut] did not increase.
  LayoutResult layOutNextLine(double x0, double x1, double baseline);

  /// Returns information about the lines laid out so far.
  Iterable<TextLine> get lines;

  /// Access to the last laid out line. This property is accessed very often
  /// during the lay out algorithm, so it should be more efficient than
  /// `lines().last`.
  TextLine get lastLine;

  /// Renders the text on the [canvas], at positions determined during the
  /// layout.
  ///
  /// This method can only be invoked if [isLaidOut] is true.
  ///
  /// In order to render the text at a different location, consider applying a
  /// translation transform to the canvas.
  void render(Canvas canvas);

  /// Clears all current layout information. After this call [isLaidOut] should
  /// return false, and the text should be ready to be laid out again.
  void resetLayout();
}

enum LayoutResult {
  didNotAdvance,
  unfinished,
  done,
}
