import 'dart:ui';

/// Useful mixin to add to your components if you want to hold a reference to the current screen size.
///
/// This mixin implements the resize method in order to hold an updated reference to the current screen [size].
/// Also, it updates its [children], if any.
class Resizable {
  /// This is the current updated screen size.
  Size size;

  /// Implementation provided by this mixin to the resize hook.
  void resize(Size size) {
    this.size = size;
    resizableChildren().where((e) => e != null).forEach((e) => e.resize(size));
  }

  /// Overwrite this to add children to this [Resizable].
  ///
  /// If a [Resizable] has children, its children as resized as well.
  Iterable<Resizable> resizableChildren() => [];
}
