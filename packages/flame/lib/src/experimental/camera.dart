import 'package:meta/meta.dart';

import '../components/component.dart';
import 'max_viewport.dart';
import 'viewfinder.dart';
import 'viewport.dart';
import 'world.dart';

/// [Camera2] is a component through which a [World] is observed.
///
/// A camera consists of two main parts: a [Viewport] and a [Viewfinder]. It
/// also a references a [World] component, and by "references" we mean that the
/// world is not mounted to the camera, but the camera merely knows about the
/// world, which exists somewhere else in the game tree.
///
/// The [viewport] is the "window" through which the game world is observed.
/// Imagine that the world is covered with an infinite sheet of paper, but there
/// is a hole in it. That hole is the viewport: through that aperture the world
/// can be observed. The viewport's size is equal to or smaller than the size
/// of the game canvas. If it is smaller, then the viewport's position specifies
/// where exactly it is placed on the canvas.
///
/// The [viewfinder] controls which part of the world is seen through the
/// viewport. Thus, viewfinder's `position` is the world point which is seen
/// at the center of the viewport. In addition, viewfinder controls the zoom
/// level (i.e. how much of the world is seen through the viewport), and,
/// optionally, rotation.
///
/// The [world] is a special component that is designed to be the root of a
/// game world. Multiple cameras can observe the world simultaneously, and the
/// world may itself contain cameras that look into other worlds, or even the
/// same world.
class Camera2 extends Component {
  Camera2({
    required this.world,
    Viewport? viewport,
    Viewfinder? viewfinder,
  }) : viewport = viewport ?? MaxViewport(),
      viewfinder = viewfinder ?? Viewfinder();

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    await add(viewport);
    await add(viewfinder);
  }

  final Viewport viewport;
  final Viewfinder viewfinder;
  World world;

  /// A camera that currently performs rendering.
  ///
  /// This variable is set to `this` when we begin rendering the world through
  /// this particular camera, and reset back to `null` at the end. This variable
  /// is not set when rendering components that are attached to the viewport.
  static Camera2? get currentCamera {
    return currentCameras.isEmpty? null : currentCameras[0];
  }
  static final List<Camera2> currentCameras = [];

  /// Maximum number of nested cameras that will be rendered.
  ///
  /// This variable helps prevent infinite recursion when a camera is set to
  /// look at the world that contains that camera.
  static int maxCamerasDepth = 4;
}
