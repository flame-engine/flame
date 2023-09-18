import 'dart:ui';

import 'package:flame/src/camera/behaviors/bounded_position_behavior.dart';
import 'package:flame/src/camera/behaviors/follow_behavior.dart';
import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/camera/viewport.dart';
import 'package:flame/src/camera/viewports/fixed_aspect_ratio_viewport.dart';
import 'package:flame/src/camera/viewports/max_viewport.dart';
import 'package:flame/src/camera/world.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/move_by_effect.dart';
import 'package:flame/src/effects/move_effect.dart';
import 'package:flame/src/effects/move_to_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/experimental/geometry/shapes/shape.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:vector_math/vector_math_64.dart';

/// [CameraComponent] is a component through which a [World] is observed.
///
/// A camera consists of two parts: a [Viewport], and a [Viewfinder]. It also
/// references a [World] component, which is not mounted to the camera, but the
/// camera still knows about it. The world must be mounted somewhere else in
/// the game tree.
///
/// A camera is a regular component that can be placed anywhere in the game
/// tree. Most games will have at least one "main" camera for displaying the
/// main game world. However, additional cameras may also be used for some
/// special effects. These extra cameras may be placed either in parallel with
/// the main camera, or within the world. It is even possible to create a camera
/// that looks at itself. [FlameGame] has one [CameraComponent] added by default
/// which is called just [FlameGame.camera].
///
/// Since [CameraComponent] is a [Component], it is possible to attach other
/// components to it. In particular, adding components directly to the camera is
/// equivalent to adding them to the camera's parent. Components added to the
/// viewport will be affected by the viewport's position, but not by its clip
/// mask. Such components will be rendered on top of the viewport. Components
/// added to the viewfinder will be rendered as if they were part of the world.
/// That is, they will be affected both by the viewport and the viewfinder.
class CameraComponent extends Component {
  CameraComponent({
    this.world,
    Viewport? viewport,
    Viewfinder? viewfinder,
    List<Component>? hudComponents,
  })  : _viewport = (viewport ?? MaxViewport())..addAll(hudComponents ?? []),
        _viewfinder = viewfinder ?? Viewfinder(),
        // The priority is set to the max here to avoid some bugs for the users,
        // if they for example would add any components that modify positions
        // before the CameraComponent, since it then will render the positions
        // of the last tick each tick.
        super(priority: 0x7fffffff) {
    addAll([_viewport, _viewfinder]);
  }

  /// Create a camera that shows a portion of the game world of fixed size
  /// [width] x [height].
  ///
  /// The viewport will be centered within the canvas, expanding as much as
  /// possible on all sides while maintaining the [width]:[height] aspect ratio.
  /// The zoom level will be set such in such a way that exactly [width] x
  /// [height] pixels are visible within the viewport. The viewfinder will be
  /// initially set up to show world coordinates (0, 0) at the center of the
  /// viewport.
  factory CameraComponent.withFixedResolution({
    required double width,
    required double height,
    World? world,
    List<Component>? hudComponents,
  }) {
    return CameraComponent(
      world: world,
      viewport: FixedAspectRatioViewport(aspectRatio: width / height)
        ..addAll(hudComponents ?? []),
      viewfinder: Viewfinder()..visibleGameSize = Vector2(width, height),
    );
  }

  /// The [viewport] is the "window" through which the game world is observed.
  ///
  /// Imagine that the world is covered with an infinite sheet of paper, but
  /// there is a hole in it. That hole is the viewport: through that aperture
  /// the world can be observed. The viewport's size is equal to or smaller
  /// than the size of the game canvas. If it is smaller, then the viewport's
  /// position specifies where exactly it is placed on the canvas.
  Viewport get viewport => _viewport;
  set viewport(Viewport newViewport) {
    _viewport.removeFromParent();
    _viewport = newViewport;
    add(_viewport);
    _viewfinder.updateTransform();
  }

  Viewport _viewport;

  /// The [viewfinder] controls which part of the world is seen through the
  /// viewport.
  ///
  /// Thus, viewfinder's `position` is the world point which is seen at the
  /// center of the viewport. In addition, viewfinder controls the zoom level
  /// (i.e. how much of the world is seen through the viewport), and,
  /// optionally, rotation.
  Viewfinder get viewfinder => _viewfinder;
  set viewfinder(Viewfinder newViewfinder) {
    _viewfinder.removeFromParent();
    _viewfinder = newViewfinder;
    add(_viewfinder);
  }

  Viewfinder _viewfinder;

  /// Special component that is designed to be the root of a game world.
  ///
  /// Multiple cameras can observe the same [world] simultaneously, and the
  /// world may itself contain cameras that look into other worlds, or even into
  /// itself.
  ///
  /// The [world] component is generally mounted externally to the camera, and
  /// this variable is a mere reference to it.
  World? world;

  /// The axis-aligned bounding rectangle of a [world] region which is currently
  /// visible through the viewport.
  ///
  /// This property can be useful in order to determine which components within
  /// the game's world are currently visible to the player, and which aren't.
  ///
  /// If the viewport is non-rectangular, or if the world's view is rotated,
  /// then the [visibleWorldRect] will be larger than the actual viewing area.
  /// Thus, this property is "conservative": everything outside of this rect
  /// is definitely not visible, while the points inside may or may not be
  /// visible.
  ///
  /// This property is cached, and is recalculated whenever the camera moves
  /// or the viewport is resized. At the same time, it may only be accessed
  /// after the camera was fully mounted.
  Rect get visibleWorldRect {
    assert(
      parent != null,
      "This property can't be accessed before the camera is added to the game. "
      'If you are using visibleWorldRect from another component (for example '
      'the World), make sure that the CameraComponent is added before that '
      'Component.',
    );
    return viewfinder.visibleWorldRect;
  }

  /// Renders the [world] as seen through this camera.
  ///
  /// If the world is not mounted yet, only the viewport HUD elements will be
  /// rendered.
  @override
  void renderTree(Canvas canvas) {
    canvas.save();
    canvas.translate(
      viewport.position.x - viewport.anchor.x * viewport.size.x,
      viewport.position.y - viewport.anchor.y * viewport.size.y,
    );
    // Render the world through the viewport
    if ((world?.isMounted ?? false) &&
        currentCameras.length < maxCamerasDepth) {
      canvas.save();
      viewport.clip(canvas);
      try {
        currentCameras.add(this);
        canvas.transform(viewfinder.transform.transformMatrix.storage);
        world!.renderFromCamera(canvas);
        viewfinder.renderTree(canvas);
      } finally {
        currentCameras.removeLast();
      }
      canvas.restore();
    }
    // Now render the HUD elements
    viewport.renderTree(canvas);
    canvas.restore();
  }

  /// Converts from the global (canvas) coordinate space to
  /// local (camera = viewport + viewfinder).
  ///
  /// Opposite of [localToGlobal].
  Vector2 globalToLocal(Vector2 point, {Vector2? output}) {
    final viewportPosition = viewport.globalToLocal(point, output: output);
    return viewfinder.globalToLocal(viewportPosition, output: output);
  }

  /// Converts from the local (camera = viewport + viewfinder) coordinate space
  /// to global (canvas).
  ///
  /// Opposite of [globalToLocal].
  Vector2 localToGlobal(Vector2 position, {Vector2? output}) {
    final viewfinderPosition =
        viewfinder.localToGlobal(position, output: output);
    return viewport.localToGlobal(viewfinderPosition, output: output);
  }

  final _viewportPoint = Vector2.zero();

  @override
  Iterable<Component> componentsAtPoint(
    Vector2 point, [
    List<Vector2>? nestedPoints,
  ]) sync* {
    final viewportPoint = viewport.globalToLocal(point, output: _viewportPoint);
    yield* viewport.componentsAtPoint(viewportPoint, nestedPoints);
    if ((world?.isMounted ?? false) &&
        currentCameras.length < maxCamerasDepth) {
      if (viewport.containsLocalPoint(_viewportPoint)) {
        currentCameras.add(this);
        final worldPoint = viewfinder.transform.globalToLocal(_viewportPoint);
        yield* viewfinder.componentsAtPoint(worldPoint, nestedPoints);
        yield* world!.componentsAtPoint(worldPoint, nestedPoints);
        currentCameras.removeLast();
      }
    }
  }

  /// A camera that currently performs rendering.
  ///
  /// This variable is set to `this` when we begin rendering the world through
  /// this particular camera, and reset back to `null` at the end. This variable
  /// is not set when rendering components that are attached to the viewport.
  static CameraComponent? get currentCamera {
    return currentCameras.isEmpty ? null : currentCameras[0];
  }

  /// Stack of all current cameras in the render tree.
  static final List<CameraComponent> currentCameras = [];

  /// Maximum number of nested cameras that will be rendered.
  ///
  /// This variable helps prevent infinite recursion when a camera is set to
  /// look at the world that contains that camera.
  static int maxCamerasDepth = 4;

  /// Makes the [viewfinder] follow the given [target].
  ///
  /// The [target] here can be any read-only [PositionProvider]. For example, a
  /// [PositionComponent] is the most common choice of target. Alternatively,
  /// you can use [PositionProviderImpl] to construct the target dynamically.
  ///
  /// This method adds a [FollowBehavior] to the viewfinder. If there is another
  /// [FollowBehavior] currently applied to the viewfinder, it will be removed
  /// first.
  ///
  /// Parameters [maxSpeed], [horizontalOnly] and [verticalOnly] have the same
  /// meaning as in the [FollowBehavior.new] constructor.
  ///
  /// If [snap] is true, then the viewfinder's starting position will be set to
  /// the target's current location. If [snap] is false, then the viewfinder
  /// will move from its current position to the target's position at the given
  /// speed.
  void follow(
    ReadOnlyPositionProvider target, {
    double maxSpeed = double.infinity,
    bool horizontalOnly = false,
    bool verticalOnly = false,
    bool snap = false,
  }) {
    stop();
    viewfinder.add(
      FollowBehavior(
        target: target,
        owner: viewfinder,
        maxSpeed: maxSpeed,
        horizontalOnly: horizontalOnly,
        verticalOnly: verticalOnly,
      ),
    );
    if (snap) {
      viewfinder.position = target.position;
    }
  }

  /// Removes all movement effects or behaviors from the viewfinder.
  void stop() {
    viewfinder.children.forEach((child) {
      if (child is FollowBehavior || child is MoveEffect) {
        child.removeFromParent();
      }
    });
  }

  /// Moves the camera towards the specified world [point].
  void moveTo(Vector2 point, {double speed = double.infinity}) {
    stop();
    viewfinder.add(
      MoveToEffect(point, EffectController(speed: speed)),
    );
  }

  /// Move the camera by the given [offset].
  void moveBy(Vector2 offset, {double speed = double.infinity}) {
    stop();
    viewfinder.add(MoveByEffect(offset, EffectController(speed: speed)));
  }

  /// Sets or clears the world bounds for the camera's viewfinder.
  ///
  /// The bound is a [Shape], given in the world coordinates. The viewfinder's
  /// position will be restricted to always remain inside this region. Note that
  /// if you want the camera to never see the empty space outside of the world's
  /// rendering area, then you should set up the bounds to be smaller than the
  /// size of the world.
  void setBounds(Shape? bounds) {
    final boundedBehavior = viewfinder.firstChild<BoundedPositionBehavior>();
    if (bounds == null) {
      boundedBehavior?.removeFromParent();
    } else if (boundedBehavior == null) {
      viewfinder.add(
        BoundedPositionBehavior(bounds: bounds, priority: 1000),
      );
    } else {
      boundedBehavior.bounds = bounds;
    }
  }

  /// Returns true if this camera is able to see the [component].
  /// Will always return false if
  /// - [world] is null or
  /// - [world] is not mounted or
  /// - [component] is not mounted or
  /// - [componentWorld] is non-null and does not match with [world]
  ///
  /// If [componentWorld] is null, this method does not take into consideration
  /// the world to which the given [component] belongs (if any). This means, in
  /// such cases, any component overlapping the [visibleWorldRect] will be
  /// reported as visible, even if it is not part of the [world] this camera is
  /// currently looking at. This can be changed by passing the the component's
  /// world as [componentWorld].
  bool canSee(PositionComponent component, {World? componentWorld}) {
    if (!(world?.isMounted ?? false) ||
        !component.isMounted ||
        (componentWorld != null && componentWorld != world)) {
      return false;
    }

    return visibleWorldRect.overlaps(component.toAbsoluteRect());
  }
}
