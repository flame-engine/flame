import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/parent_is_a.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:meta/meta.dart';

/// [Viewport] is a part of a [CameraComponent] system.
///
/// The viewport describes a "window" through which the underlying game world
/// is observed. At the same time, the viewport is agnostic of the game world,
/// and only contain properties that describe the "window" itself. These
/// properties are: the window's size, shape, and position on the screen.
///
/// There are several implementations of [Viewport], which differ by their
/// shape, and also by their behavior in response to changes to the canvas size.
/// Users may also create their own implementations.
///
/// A viewport establishes its own local coordinate system, with the origin at
/// the top left corner of the viewport's bounding box.
abstract class Viewport extends Component
    with ParentIsA<CameraComponent>
    implements AnchorProvider, PositionProvider, SizeProvider {
  Viewport({super.children});

  final Vector2 _size = Vector2.zero();
  bool _isInitialized = false;

  /// Position of the viewport's anchor in the parent's coordinate frame.
  ///
  /// Changing this position will move the viewport around the screen, but will
  /// not affect which portion of the game world is visible. Thus, the game
  /// world will appear as a static picture inside the viewport.
  @override
  Vector2 get position => _position;
  final Vector2 _position = Vector2.zero();
  @override
  set position(Vector2 value) => _position.setFrom(value);

  /// The logical "center" of the viewport.
  ///
  /// This point will be used to establish the placement of the viewport in the
  /// parent's coordinate frame.
  @override
  Anchor anchor = Anchor.topLeft;

  /// Size of the viewport, i.e. its width and height.
  ///
  /// This property represents the bounding box of the viewport. If the viewport
  /// is rectangular in shape, then [size] describes the dimensions of that
  /// rectangle. If the viewport has any other shape (for example, circular),
  /// then [size] describes the dimensions of the bounding box of the viewport.
  ///
  /// Changing the size at runtime triggers the [onViewportResize] event. The
  /// size cannot be negative.
  @override
  Vector2 get size {
    if (!_isInitialized && camera.parent is FlameGame) {
      // This is so that the size can be accessed before the viewport is fully
      // mounted.
      onGameResize((camera.parent! as FlameGame).canvasSize);
    }
    return _size;
  }

  Vector2 get virtualSize => size;

  @override
  set size(Vector2 value) {
    assert(
      value.x >= 0 && value.y >= 0,
      "Viewport's size cannot be negative: $value",
    );
    _size.setFrom(value);
    _isInitialized = true;
    if (isLoaded) {
      camera.viewfinder.onViewportResize();
    }
    onViewportResize();
    if (hasChildren) {
      children.forEach((child) => child.onParentResize(_size));
    }
  }

  /// Reference to the parent camera.
  CameraComponent get camera => parent;

  /// Apply clip mask to the [canvas].
  ///
  /// The mask must be in the viewport's local coordinate system, where the
  /// top left corner  of the viewport has coordinates (0, 0). The overall size
  /// of the clip mask's shape must match the [size] of the viewport.
  ///
  /// This API must be implemented by all viewports.
  void clip(Canvas canvas);

  /// Tests whether the given point lies within the viewport.
  ///
  /// This method must be consistent with the action of [clip], in the sense
  /// that [containsLocalPoint] must return true if and only if that point on
  /// the canvas is not clipped by [clip].
  @override
  bool containsLocalPoint(Vector2 point);

  /// Called after the size of the viewport has changed.
  ///
  /// The new size will be stored in the [size] property. This method could be
  /// invoked either when the user explicitly changes the size of the viewport,
  /// or when the size changes automatically in response to the change in game
  /// canvas size.
  ///
  /// A typical implementation would need to adjust the viewport's clip mask to
  /// match the new size.
  @protected
  void onViewportResize();

  /// Converts a point from the global coordinate system to the local
  /// coordinate system of the viewport.
  ///
  /// Use [output] to send in a Vector2 object that will be used to avoid
  /// creating a new Vector2 object in this method.
  ///
  /// Opposite of [localToGlobal].
  Vector2 globalToLocal(Vector2 point, {Vector2? output}) {
    final x = point.x - position.x + anchor.x * size.x;
    final y = point.y - position.y + anchor.y * size.y;
    return (output?..setValues(x, y)) ?? Vector2(x, y);
  }

  /// Converts a point from the local coordinate system of the viewport to the
  /// global coordinate system.
  ///
  /// Use [output] to send in a Vector2 object that will be used to avoid
  /// creating a new Vector2 object in this method.
  ///
  /// Opposite of [globalToLocal].
  Vector2 localToGlobal(Vector2 point, {Vector2? output}) {
    final x = point.x + position.x - anchor.x * size.x;
    final y = point.y + position.y - anchor.y * size.y;
    return (output?..setValues(x, y)) ?? Vector2(x, y);
  }

  void transformCanvas(Canvas canvas) {}
}
