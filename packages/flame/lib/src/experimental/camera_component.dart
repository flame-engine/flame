import 'dart:ui';

import 'package:meta/meta.dart';

import '../components/component.dart';
import 'max_viewport.dart';
import 'viewfinder.dart';
import 'viewport.dart';
import 'world.dart';

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
/// that looks at itself.
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
    required this.world,
    Viewport? viewport,
    Viewfinder? viewfinder,
  })  : viewport = viewport ?? MaxViewport(),
        viewfinder = viewfinder ?? Viewfinder();

  /// The [viewport] is the "window" through which the game world is observed.
  ///
  /// Imagine that the world is covered with an infinite sheet of paper, but
  /// there is a hole in it. That hole is the viewport: through that aperture
  /// the world can be observed. The viewport's size is equal to or smaller
  /// than the size of the game canvas. If it is smaller, then the viewport's
  /// position specifies where exactly it is placed on the canvas.
  final Viewport viewport;

  /// The [viewfinder] controls which part of the world is seen through the
  /// viewport.
  ///
  /// Thus, viewfinder's `position` is the world point which is seen at the
  /// center of the viewport. In addition, viewfinder controls the zoom level
  /// (i.e. how much of the world is seen through the viewport), and,
  /// optionally, rotation.
  final Viewfinder viewfinder;

  /// Special component that is designed to be the root of a game world.
  ///
  /// Multiple cameras can observe the same [world] simultaneously, and the
  /// world may itself contain cameras that look into other worlds, or even into
  /// itself.
  ///
  /// The [world] component is generally mounted externally to the camera, and
  /// this variable is a mere reference to it.
  World world;

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    await addAll([viewport, viewfinder]);
  }

  /// Renders the [world] as seen through this camera.
  ///
  /// If the world is not mounted yet, only the viewport HUD elements will be
  /// rendered.
  @override
  void renderTree(Canvas canvas) {
    canvas.save();
    canvas.translate(viewport.position.x, viewport.position.y);
    // Render the world through the viewport
    if (world.isMounted && currentCameras.length < maxCamerasDepth) {
      canvas.save();
      viewport.clip(canvas);
      try {
        currentCameras.add(this);
        canvas.transform(viewfinder.transformMatrix.storage);
        world.renderFromCamera(canvas);
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
}
