import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/post_process.dart';
import 'package:flame/src/camera/behaviors/bounded_position_behavior.dart';
import 'package:flame/src/camera/behaviors/follow_behavior.dart';
import 'package:flame/src/camera/behaviors/viewport_aware_bounds_behavior.dart';
import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/camera/viewport.dart';
import 'package:flame/src/camera/viewports/fixed_resolution_viewport.dart';
import 'package:flame/src/camera/viewports/max_viewport.dart';
import 'package:flame/src/components/core/component_render_context.dart';
import 'package:flame/src/components/core/component_tree_root.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/move_by_effect.dart';
import 'package:flame/src/effects/move_effect.dart';
import 'package:flame/src/effects/move_to_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/experimental/geometry/shapes/circle.dart';
import 'package:flame/src/experimental/geometry/shapes/rectangle.dart';
import 'package:flame/src/experimental/geometry/shapes/rounded_rectangle.dart';
import 'package:flame/src/experimental/geometry/shapes/shape.dart';
import 'package:flame/src/game/flame_game.dart';

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
///
/// A [PostProcess] can be applied to the camera, which will affect the
/// rendering of the world. This is useful for applying effects such as bloom,
/// blur, or other fragment shader effects to the world. See [postProcess] for
/// more information.
class CameraComponent extends Component {
  CameraComponent({
    this.world,
    Viewport? viewport,
    Viewfinder? viewfinder,
    Component? backdrop,
    List<Component>? hudComponents,
    super.children,
    super.key,
  })  : _viewport = (viewport ?? MaxViewport())..addAll(hudComponents ?? []),
        _viewfinder = viewfinder ?? Viewfinder(),
        _backdrop = backdrop ?? Component(),
        // The priority is set to the max here to avoid some bugs for the users,
        // if they for example would add any components that modify positions
        // before the CameraComponent, since it then will render the positions
        // of the last tick each tick.
        super(priority: 0x7fffffff) {
    children.register<PostProcessComponent>();
    addAll([_backdrop, _viewport, _viewfinder]);
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
  CameraComponent.withFixedResolution({
    required double width,
    required double height,
    World? world,
    Viewfinder? viewfinder,
    Component? backdrop,
    List<Component>? hudComponents,
    Iterable<Component>? children,
    ComponentKey? key,
  }) : this(
          world: world,
          viewport: FixedResolutionViewport(resolution: Vector2(width, height)),
          viewfinder: viewfinder ?? Viewfinder(),
          backdrop: backdrop,
          hudComponents: hudComponents,
          children: children,
          key: key,
        );

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

  /// The [backdrop] component is rendered statically behind the world.
  ///
  /// Here you can add things like the parallax component which should be static
  /// when the camera moves around.
  Component get backdrop => _backdrop;
  Component _backdrop;
  set backdrop(Component newBackdrop) {
    _backdrop.removeFromParent();
    add(newBackdrop);
    _backdrop = newBackdrop;
  }

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
  /// If the world is not mounted yet, only the viewport and viewfinder elements
  /// will be rendered.
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
      viewport.transformCanvas(canvas);
      backdrop.renderTree(canvas);
      canvas.save();
      try {
        currentCameras.add(this);
        void renderWorld(Canvas canvas) {
          canvas.transform2D(viewfinder.transform);
          world!.renderFromCamera(canvas);

          // Render the viewfinder elements, which will be in front of
          // the world,
          // but with the same transforms applied to them.
          viewfinder.renderTree(canvas);
        }

        final postProcessors = children.query<PostProcessComponent>();
        if (postProcessors.isNotEmpty) {
          assert(
            postProcessors.length == 1,
            'Only one post process component is allowed per camera.',
          );
          final postProcessor = postProcessors.first.postProcess;
          postProcessor.render(
            canvas,
            viewport.virtualSize,
            renderWorld,
            (context) {
              renderContext.currentPostProcess = context;
            },
          );
        } else {
          renderWorld(canvas);
        }
      } finally {
        currentCameras.removeLast();
      }
      canvas.restore();
      // Render the viewport elements, which will be in front of the world.
      viewport.renderTree(canvas);
      canvas.restore();
    }
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

  @override
  Iterable<Component> componentsAtLocation<T>(
    T locationContext,
    List<T>? nestedContexts,
    T? Function(CoordinateTransform, T) transformContext,
    bool Function(Component, T) checkContains,
  ) sync* {
    final viewportPoint = transformContext(viewport, locationContext);
    if (viewportPoint == null) {
      return;
    }

    yield* viewport.componentsAtLocation(
      viewportPoint,
      nestedContexts,
      transformContext,
      checkContains,
    );
    if ((world?.isMounted ?? false) &&
        currentCameras.length < maxCamerasDepth) {
      if (checkContains(viewport, viewportPoint)) {
        currentCameras.add(this);
        final worldPoint = transformContext(viewfinder, viewportPoint);
        if (worldPoint == null) {
          return;
        }
        yield* viewfinder.componentsAtLocation(
          worldPoint,
          nestedContexts,
          transformContext,
          checkContains,
        );
        yield* world!.componentsAtLocation(
          worldPoint,
          nestedContexts,
          transformContext,
          checkContains,
        );
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
    viewfinder.children.toList().forEach((child) {
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
  /// position will be restricted to always remain inside this region.
  ///
  /// When [considerViewport] is true none of the viewport can go outside
  /// of the bounds, when it is false only the viewfinder anchor is considered.
  /// Note that this option only works with [Rectangle], [RoundedRectangle] and
  /// [Circle] shapes.
  void setBounds(Shape? bounds, {bool considerViewport = false}) {
    final boundedBehavior = viewfinder.firstChild<BoundedPositionBehavior>();
    final viewPortAwareBoundsBehavior =
        viewfinder.firstChild<ViewportAwareBoundsBehavior>();

    if (bounds == null) {
      // When bounds is null, all bounds-related components need to be dropped.
      boundedBehavior?.removeFromParent();
      viewPortAwareBoundsBehavior?.removeFromParent();
      return;
    }

    Future<void>? boundedBehaviorFuture;
    if (boundedBehavior == null) {
      final BoundedPositionBehavior ref;
      viewfinder.add(
        ref = BoundedPositionBehavior(
          bounds: bounds,
          priority: 1000,
        ),
      );

      boundedBehaviorFuture = ref.mounted;
    } else {
      boundedBehavior.bounds = bounds;
    }

    if (!considerViewport) {
      // Edge case: remove pre-existing viewport aware components.
      viewPortAwareBoundsBehavior?.removeFromParent();
      return;
    }

    // Param `considerViewPort` was true and we have a bounds.
    // Add a ViewportAwareBoundsBehavior component with
    // our desired bounds shape or update the boundsShape if the
    // component already exists.
    if (viewPortAwareBoundsBehavior == null) {
      switch (boundedBehaviorFuture) {
        case null:
          // This represents the case when BoundedPositionBehavior was mounted
          // earlier in another cycle. This allows us to immediately add the
          // ViewportAwareBoundsBehavior component which will subsequently adapt
          // the camera to the virtual resolution this frame.
          _addViewPortAwareBoundsBehavior(bounds);
        case _:
          // This represents the case when BoundedPositionBehavior was added
          // in this exact cycle but did not mount into the tree.
          // We must wait for that component to mount first in order for
          // ViewportAwareBoundsBehavior to correctly affect the camera.
          boundedBehaviorFuture
              .whenComplete(() => _addViewPortAwareBoundsBehavior(bounds));
      }
    } else {
      viewPortAwareBoundsBehavior.boundsShape = bounds;
    }
  }

  void _addViewPortAwareBoundsBehavior(Shape bounds) {
    viewfinder.add(
      ViewportAwareBoundsBehavior(
        boundsShape: bounds,
      ),
    );
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
  /// currently looking at. This can be changed by passing the component's
  /// world as [componentWorld].
  bool canSee(PositionComponent component, {World? componentWorld}) {
    if (!(world?.isMounted ?? false) ||
        !component.isMounted ||
        (componentWorld != null && componentWorld != world)) {
      return false;
    }

    return visibleWorldRect.overlaps(component.toAbsoluteRect());
  }

  @override
  final CameraRenderContext renderContext = CameraRenderContext();

  /// A [PostProcess] that is applied to the world of a camera.
  ///
  /// Do note that only one [postProcess] can be active on the camera at once.
  /// If the [postProcess] is set to null, the previous post process will
  /// be removed.
  /// If the [postProcess] is set to not null, it will be added to the camera,
  /// and any previously active post process will be removed.
  ///
  /// See also:
  /// - [PostProcess] for the base class for post processes and more information
  /// about how to create them.
  /// - [PostProcessComponent] for a component that can be used to apply a
  /// post process to a specific component.
  PostProcess? get postProcess =>
      children.query<PostProcessComponent>().firstOrNull?.postProcess;
  set postProcess(PostProcess? postProcess) {
    final postProcessComponents =
        children.query<PostProcessComponent>().toList();
    final queuedPostProcessAdds = findGame()
        ?.queue
        .where(
          (event) =>
              event.kind == LifecycleEventKind.add &&
              event.child is PostProcessComponent,
        )
        .map((event) => event.child!);
    removeAll([...postProcessComponents, ...?queuedPostProcessAdds]);
    if (postProcess != null) {
      add(PostProcessComponent(postProcess: postProcess));
    }
  }
}

class CameraRenderContext extends ComponentRenderContext {
  PostProcess? currentPostProcess;
}
