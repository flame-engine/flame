import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';
import 'camera.dart';

/// [Viewport] is a part of a [Camera2] system.
///
/// The viewport describes a "window" through which the underlying game world
/// is observed. At the same time, the viewport is agnostic of the game world,
/// and only contain properties that describe the "window". These properties
/// are: the window's size, shape, and position on the screen.
///
/// There are several implementations of [Viewport], which differ by their
/// shape, and also by their behavior in response to changes to the canvas size.
/// Users may also create their own implementations.
abstract class Viewport extends Component {
  /// Position of the viewport's center in the parent's coordinate frame.
  ///
  /// Changing this position will move the viewport around the screen, but will
  /// not affect which portion of the game world is visible. Thus, the game
  /// world will appear as a static picture inside the viewport.
  Vector2 get position => _position;
  final Vector2 _position = Vector2.zero();
  set position(Vector2 value) => _position.setFrom(value);

  /// Size of the viewport, i.e. the width and the height.
  ///
  /// This property represents the bounding box of the viewport. If the viewport
  /// is rectangular in shape, then [size] describes the dimensions of that
  /// rectangle. If the viewport has any other shape (for example, circular),
  /// then [size] describes the dimensions of the bounding box of the viewport.
  ///
  /// Changing the size at runtime triggers the [handleResize] event. The size
  /// cannot be negative.
  Vector2 get size => _size;
  final Vector2 _size = Vector2.zero();
  set size(Vector2 value) {
    assert(
      value.x >= 0 && value.y >= 0,
      "Viewport's size cannot be negative: $value",
    );
    _size.setFrom(value);
    handleResize();
  }

  /// Apply clip mask to the [canvas].
  ///
  /// The mask must be in the viewport's local coordinate system, where the
  /// center of the viewport has coordinates (0, 0). The overall size of the
  /// clip mask's shape must match the [size] of the viewport.
  ///
  /// This API must be implemented by all viewports.
  @protected
  void clip(Canvas canvas);

  /// Override in order to perform a custom action upon resize.
  ///
  /// A typical use-case would be to adjust the viewport's clip mask to match
  /// the new size.
  @protected
  void handleResize();

  @mustCallSuper
  @override
  void onMount() {
    assert(parent! is Camera2, 'A Viewport may only be attached to a Camera2');
  }

  @override
  void renderTree(Canvas canvas) {
    final camera = parent! as Camera2;
    canvas.save();
    canvas.translate(_position.x, _position.y);
    canvas.save();
    clip(canvas);
    camera.viewfinder.renderFromViewport(canvas);
    canvas.restore();
    // Render viewport's children
    super.renderTree(canvas);
    canvas.restore();
  }

}
