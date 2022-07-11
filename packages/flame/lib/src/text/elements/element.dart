import 'dart:ui';

/// An [Element] is a basic building block of a rich-text document.
///
/// Elements are concrete and "physical": they are objects that are ready to be
/// rendered on a canvas. This property distinguishes them from Nodes (which are
/// structured pieces of text), and from Styles (which are descriptors for how
/// arbitrary pieces of text ought to be rendered).
///
/// Elements are at the final stage of the text rendering pipeline, they are
/// created during the layout step.
abstract class Element {
  void translate(double dx, double dy);
  void render(Canvas canvas);
}
