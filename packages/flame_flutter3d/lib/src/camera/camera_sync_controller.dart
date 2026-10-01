/// A flutter3d [CameraNode] and a Flame [Viewfinder] kept describing the
/// same view, one side authoritative each frame.
///
/// **Why a camera needs its own bridge instead of reusing
/// `Object3dComponent`.** A camera is not a prop: nothing draws it, so it
/// never needs a `Scene` entry or a mount/unmount lifecycle, and it carries
/// a second number a
/// `PositionComponent` does not — how much of the world is visible — which
/// `Object3dComponent` has no field for. What the two do share is the
/// position half of the problem and the question of which side writes, which
/// is why this reads position through the same [BridgePlane] and reuses
/// [SyncDirection] rather than defining its own.
library;

import 'package:flame/camera.dart' show Viewfinder;
import 'package:flame_flutter3d/src/camera/camera_sync_component.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart'
    show SyncDirection, Object3dComponent;
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:vector_math/vector_math.dart' show Quaternion, Vector3;

/// Reconciles a flutter3d [CameraNode] with a Flame [Viewfinder], on one
/// [BridgePlane], one [direction] deciding who writes each frame.
///
/// **Not a Flame `Component`.** Nothing here needs Flame's lifecycle
/// (`onLoad`, `onMount`) or its render tree — it is a plain reconciliation
/// step, called from wherever a bridged game already ticks its other
/// controllers, the same way `OrbitController` is a plain Dart class with
/// its own `advance`. A caller that wants this driven by Flame's own update
/// loop adds a [CameraSyncComponent]; this class does not presume one.
///
/// **Takes a [Viewfinder], not a `CameraComponent`.** A [Viewfinder]'s
/// `position`/`zoom`/`angle` setters only ever touch its own `Transform2D`
/// — nothing in them reaches for `camera.viewport`, so a `Viewfinder()` is
/// fully usable, and testable, unmounted. Requiring a mounted
/// `CameraComponent` here would mean this controller's own tests need a
/// `GameWidget`, and — per this package's own test notes — mounting one
/// under `flutter_test` currently hangs. A caller that already has a
/// `CameraComponent` passes its `viewfinder` field straight through.
///
/// **Reuses [SyncDirection] rather than a second enum.** The choice this
/// makes — which side is the source of truth this frame — is exactly the
/// choice [Object3dComponent] already names, and a bridged game routing a
/// camera and its props through two differently-spelled but identically
/// shaped enums would be a distinction with no difference, just a second
/// `switch` a reader has to convince themselves matches the first.
///
/// **The zoom/height reconciliation assumes an orthographic lens, and says
/// so rather than pretending otherwise.** Flame's [Viewfinder.zoom] is a
/// single scalar: pixels on screen per world unit. An
/// [OrthographicProjection]'s `height` is the same kind of number — how much
/// of the world is visible, independent of how far the camera stands from
/// it — so the two have one honest correspondence. A [PerspectiveProjection]
/// has no such number: how much of the world a perspective camera shows
/// depends on both its field of view *and* its distance from whatever it is
/// looking at, and no single scalar copied onto [Viewfinder.zoom] would mean
/// the same thing twice in a row as that distance changed. So this class
/// checks [CameraNode.projection] with `is OrthographicProjection` every
/// frame rather than requiring the type up front: a camera is free to swap
/// lenses (the same freedom [CameraNode.projection] itself is mutable for),
/// and when it is not orthographic this controller still keeps position in
/// sync and simply leaves whichever side's zoom/height it would have written
/// alone, rather than writing a number that does not mean what the other
/// side thinks it means.
///
/// **The zoom ↔ height mapping is `zoom = 1 / height`, a chosen convention,
/// not a pixel-exact one.** The two numbers move the right way relative to
/// each other with no further data: zooming in (raising [Viewfinder.zoom])
/// shrinks the visible world, and so should [OrthographicProjection.height]
/// falling — which the reciprocal does, and does invertibly, so a value
/// written by one side and read back by the other round-trips exactly. What
/// this deliberately does *not* attempt is pixel-accurate agreement — "N
/// world units always exactly fill the viewport's height in both engines at
/// once" — because that would need the Flame viewport's own pixel size,
/// which an unmounted [Viewfinder] does not carry and which this class was
/// built to work without. A caller that needs that tighter guarantee scales
/// [Viewfinder.zoom] by its viewport's pixel height on its own before or
/// after calling [advance]; this class only guarantees the two lenses agree
/// with each other under its own convention, consistently, every frame.
final class CameraSyncController {
  CameraSyncController({
    required this.camera,
    required this.viewfinder,
    required this.plane,
    this.direction = SyncDirection.sceneToFlame,
    this.viewportHeight,
    this.syncAngle = false,
    Vector3? eyeOffset,
  }) : _base = camera.readRotation(),
       eyeOffset = eyeOffset?.clone();

  /// Where a perspective camera stands from the point it looks at, in the
  /// scene, at a zoom of one: `(0, 12, 10)` is above and behind a ground
  /// plane's point. Flowing Flame to the scene with this given, the camera
  /// looks at [Viewfinder.position] on [plane] from there, the offset divided
  /// by [Viewfinder.zoom] and, with [syncAngle], turned by
  /// [Viewfinder.angle] about the plane's normal.
  ///
  /// **Flame's camera, driving a perspective one.** Without it the camera was
  /// put at the viewfinder's point, on the plane, and nothing Flame's camera
  /// does reached a perspective lens: `follow` with its `maxSpeed`,
  /// `setBounds`, a `MoveEffect` or a `ScaleEffect` on the viewfinder. With
  /// it they all do, as they would a flat Flame game.
  ///
  /// **Under an orthographic lens it is the angle of view**: the camera
  /// looks along it from as far as it says, and the zoom stays the lens's
  /// height. An isometric board, a pyramid of cubes seen from a corner, is
  /// an offset of equal parts on all three axes.
  final Vector3? eyeOffset;

  final Vector3 _looked = Vector3.all(double.nan);
  double _lookedZoom = double.nan;
  double _lookedAngle = double.nan;

  /// The Flame viewport's height in logical pixels, read every frame; when
  /// given, the two lenses agree to the pixel.
  ///
  /// **Pixel-exact, not a convention.** Without it the zoom is the
  /// reciprocal of the height, which moves the right way and agrees with
  /// nothing on screen. With it, [Viewfinder.zoom] is pixels per world unit,
  /// the viewport's height over [OrthographicProjection.height], so a
  /// 224-by-256 field fills the same pixels in both layers at any window
  /// size: what a Space Invaders cabinet drawn in both engines needs.
  final double Function()? viewportHeight;

  /// Whether Flame's [Viewfinder.angle] and the camera's turn about the
  /// plane's normal are kept the same: a screen that rolls.
  ///
  /// The camera's rotation when this controller was made is its rest, and
  /// the angle is a turn about the plane's normal on top of it.
  final bool syncAngle;

  final Quaternion _base;

  /// Takes the camera's rotation now as its rest: for a camera turned with
  /// `lookAt` after this controller was made, whose rest was otherwise the
  /// turn it had before.
  void takeRest() => _base.setFrom(camera.readRotation());

  /// The flutter3d camera this controller reconciles.
  final CameraNode camera;

  /// The Flame viewfinder kept in step with [camera].
  final Viewfinder viewfinder;

  /// The 2D↔3D axis mapping [camera]'s position is read and written through
  /// — the same [BridgePlane] every other bridged component in this scene
  /// shares, so a 2D point means the same 3D point everywhere.
  final BridgePlane plane;

  /// Which side is authoritative each frame. See [SyncDirection].
  final SyncDirection direction;

  /// Copies one frame's worth of state from whichever side [direction] names
  /// as authoritative onto the other.
  ///
  /// Takes [dt] to match the shape every other per-frame controller in this
  /// repo has — `OrbitController.advance`, `Object3dComponent.update` — so a
  /// host loop can call every controller it owns the same way without
  /// asking which ones actually use the elapsed time. This one does not: a
  /// copy has no notion of speed, unlike `OrbitController`'s own `advance`,
  /// which is easing a turn already in flight.
  void advance(double dt) {
    switch (direction) {
      case SyncDirection.sceneToFlame:
        _sceneToFlame();
      case SyncDirection.flameToScene:
        _flameToScene();
    }
  }

  /// Pixels per world unit for a view [height] units tall.
  double _zoomFor(double height) {
    final pixels = viewportHeight?.call();
    return pixels == null ? 1.0 / height : pixels / height;
  }

  /// The view height in world units that [zoom] shows.
  double _heightFor(double zoom) {
    final pixels = viewportHeight?.call();
    return pixels == null ? 1.0 / zoom : pixels / zoom;
  }

  void _sceneToFlame() {
    viewfinder.position = plane.to2d(camera.readPosition());
    final projection = camera.projection;
    if (projection is OrthographicProjection) {
      viewfinder.zoom = _zoomFor(projection.height);
    }
    if (syncAngle) {
      final rest = Quaternion.copy(_base)..inverse();
      viewfinder.angle = plane.angleFor(camera.readRotation() * rest);
    }
  }

  /// Written only when the viewfinder moved: a camera written is a changed
  /// node, and a still one had its shadows drawn again every frame.
  ///
  /// An orthographic lens looks along the offset from as far as it is
  /// given, and its zoom is its height instead: nearer would not show less.
  void _lookFrom(Vector3 offset, {required bool byZoom}) {
    final at = viewfinder.position;
    final zoom = byZoom ? viewfinder.zoom : 1.0;
    final angle = syncAngle ? viewfinder.angle : 0.0;
    if (_looked.x == at.x &&
        _looked.y == at.y &&
        _lookedZoom == zoom &&
        _lookedAngle == angle) {
      return;
    }
    _looked.setValues(at.x, at.y, 0.0);
    _lookedZoom = zoom;
    _lookedAngle = angle;
    final target = plane.to3d(at);
    final eye = plane.rotationFor(angle).rotated(offset / zoom)..add(target);
    camera
      ..setPositionFrom(eye)
      ..lookAt(target);
  }

  void _flameToScene() {
    final offset = eyeOffset;
    final projection = camera.projection;
    if (offset != null) {
      _lookFrom(offset, byZoom: projection is! OrthographicProjection);
    } else {
      camera.setPositionFrom(plane.to3d(viewfinder.position));
    }
    if (projection is OrthographicProjection) {
      final height = _heightFor(viewfinder.zoom);
      // A lens made only when the zoom moved, not every frame.
      if (height != projection.height) {
        camera.projection = projection.copyWith(height: height);
      }
    }
    if (syncAngle && offset == null) {
      camera.setRotation(plane.rotationFor(viewfinder.angle) * _base);
    }
  }
}
