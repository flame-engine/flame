
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';
import 'camera.dart';
import 'viewfinder.dart';

abstract class Viewport extends Component {
  /// Position of the viewport's center in the parent's coordinate frame.
  Vector2 get position => _position;
  final Vector2 _position = Vector2.zero();
  set position(Vector2 value) {
    _position.setFrom(value);
  }

  /// Size of the viewport, i.e. width and height.
  ///
  /// This property represents the bounding box of the viewport. If the viewport
  /// is rectangular in shape, then [size] describes the dimensions of that
  /// rectangle. If the viewport has any other shape (for example, circular),
  /// then [size] describes the dimensions of the bounding box of the viewport.
  ///
  /// Changing the size at runtime triggers the [handleResize] event.
  Vector2 get size => _size;
  final Vector2 _size = Vector2.zero();
  set size(Vector2 value) {
    _size.setFrom(value);
    handleResize();
  }

  @override
  void renderTree(Canvas canvas) {
    canvas.save();
    canvas.translate(_position.x, _position.y);
    canvas.save();
    clip(canvas);
    (parent! as Camera2).viewfinder.renderFromViewport(canvas);
    canvas.restore();
    // Render viewport's children
    super.renderTree(canvas);
    canvas.restore();
  }

  @protected
  void clip(Canvas canvas);

  /// Override in order to perform a custom action upon resize.
  ///
  /// A typical use-case would be to adjust the viewport's clip mask to match
  /// the new size.
  @protected
  void handleResize() {}
}
