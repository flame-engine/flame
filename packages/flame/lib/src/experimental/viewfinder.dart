import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';
import '../game/transform2d.dart';
import 'camera_component.dart';
import 'viewport.dart';

/// [Viewfinder] is a part of a [CameraComponent] system that controls which
/// part of the game world is currently visible through a viewport.
///
/// The viewfinder contains the game point that is currently at the
/// "cross-hairs" of the viewport ([position]), the [zoom] level, and the
/// [angle] of rotation of the camera.
class Viewfinder extends Component {
  /// Internal transform matrix used by the viewfinder.
  final Transform2D _transform = Transform2D();

  /// The game coordinates of a point that is to be positioned at the center
  /// of the viewport.
  Vector2 get position => -_transform.offset;
  set position(Vector2 value) => _transform.offset = -value;

  /// Zoom level of the game.
  ///
  /// The default zoom value of 1 means that the world coordinates are in 1:1
  /// correspondence with the pixels on the screen. Zoom levels higher than 1
  /// make the world appear closer: each unit of game coordinate systems maps
  /// to [zoom] pixels on the screen. Conversely, when [zoom] is less than 1,
  /// the game world will appear further away and smaller in size.
  ///
  /// See also: [visibleGameSize] for setting the zoom level dynamically.
  double get zoom => _transform.scale.x;
  set zoom(double value) {
    assert(value > 0, 'zoom level must be positive: $value');
    _transform.scale = Vector2.all(value);
  }

  /// Rotation angle of the game world, in radians.
  ///
  /// The rotation is around the axis that is perpendicular to the screen.
  double get angle => -_transform.angle;
  set angle(double value) => _transform.angle = -value;

  /// Reference to the parent camera.
  CameraComponent get camera => parent! as CameraComponent;

  /// How much of a game world ought to be visible through the viewport.
  ///
  /// When this property is non-null, the viewfinder will automatically select
  /// the maximum zoom level such that a rectangle of size [visibleGameSize]
  /// (in game coordinates) is visible through the viewport. If you want a
  /// certain dimension to be unconstrained, set it to zero.
  ///
  /// For example, if `visibleGameSize` is set to `[100.0, 0.0]`, the zoom level
  /// will be chosen such that 100 game units will be visible across the width
  /// of the viewport. Likewise, setting `visibleGameSize` to `[5.0, 10.0]`
  /// will ensure that 5 or more game units are visible across the width of the
  /// viewport, and 10 or more game units across the height.
  ///
  /// This property is an alternative way to set the [zoom] level for the
  /// viewfinder. It is persistent too: if the game size changes, the zoom
  /// will be recalculated to fit the constraint.
  Vector2? get visibleGameSize => _visibleGameSize;
  Vector2? _visibleGameSize;
  set visibleGameSize(Vector2? value) {
    if (value == null || (value.x == 0 && value.y == 0)) {
      _visibleGameSize = null;
    } else {
      assert(
        value.x >= 0 && value.y >= 0,
        'visibleGameSize cannot be negative: $value',
      );
      _visibleGameSize = value;
      _initZoom();
    }
  }

  /// Set [zoom] level based on the [_visibleGameSize].
  void _initZoom() {
    if (isMounted && _visibleGameSize != null) {
      final viewportSize = camera.viewport.size;
      final zoomX = viewportSize.x / _visibleGameSize!.x;
      final zoomY = viewportSize.y / _visibleGameSize!.y;
      zoom = min(zoomX, zoomY);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _initZoom();
  }

  @mustCallSuper
  @override
  void onMount() {
    assert(
      parent! is CameraComponent,
      'Viewfinder can only be mounted to a Camera2',
    );
    _initZoom();
  }

  @override
  void renderTree(Canvas canvas) {}

  /// Internal rendering method called by the [Viewport] (regular rendering is
  /// disabled). This ensures that the viewfinder performs its rendering only
  /// after the viewport applied the necessary transforms / clip mask.
  @internal
  void renderFromViewport(Canvas canvas) {
    final world = camera.world;
    if (world.isMounted &&
        CameraComponent.currentCameras.length <
            CameraComponent.maxCamerasDepth) {
      try {
        CameraComponent.currentCameras.add(camera);
        canvas.transform(_transform.transformMatrix.storage);
        world.renderFromCamera(canvas);
        super.renderTree(canvas);
      } finally {
        CameraComponent.currentCameras.removeLast();
      }
    }
  }
}
