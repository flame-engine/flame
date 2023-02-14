import 'dart:ui';
import 'package:flame/src/text/styles/style.dart';

/// An [Element] is a basic rendering block of a rich-text document.
///
/// Elements are concrete and "physical": they are objects that are ready to be
/// rendered on a canvas. This property distinguishes them from Nodes (which are
/// structured pieces of text), and from [Style]s (which are descriptors for how
/// arbitrary pieces of text ought to be rendered).
///
/// Elements are at the final stage of the text rendering pipeline, they are
/// created during the layout step.
abstract class Element {
  /// Moves the element by ([dx], [dy]) relative to its current location.
  void translate(double dx, double dy);

  /// Renders the element on the [canvas], at coordinates determined during the
  /// layout.
  ///
  /// In order to render the element at a different location, consider either
  /// calling the [translate] method, or applying a translation transform to the
  /// canvas itself.
  void render(Canvas canvas);
}
