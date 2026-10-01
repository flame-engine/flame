import 'package:flame/components.dart' show Component;
import 'package:flame_flutter3d/flame_flutter3d.dart' show CameraSyncController;
import 'package:flame_flutter3d/src/camera/camera_sync_controller.dart'
    show CameraSyncController;
import 'package:flame_flutter3d/src/host/bridge_priority.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_physics/flutter3d_physics.dart' show CollisionWorld;
import 'package:flutter3d_sim/flutter3d_sim.dart' show CameraRig;
import 'package:vector_math/vector_math.dart' show Vector3;

/// A camera that follows a bridged component from where [offset] puts it,
/// looking at where [lookOffset] points: behind and above a jet, looking up
/// the river ahead of it.
///
/// **For a perspective camera, where [CameraSyncController] cannot help.**
/// That reconciles a Flame viewfinder's zoom with an orthographic height;
/// a perspective chase has nothing of Flame's to reconcile, only a target
/// to keep in frame, and every game that had one wrote it by hand.
///
/// **Part way across.** Along the plane's own x axis the camera follows
/// the target by [followAcross] and aims by [lookAcross], fractions of the
/// target's x: a camera locked to a craft's every dodge turns the whole
/// world with it, and one that does not follow at all loses a craft off a
/// narrow screen. Everything else follows the target in full.
///
/// **Stiff or springy.** With [stiffness] at zero the camera is exactly
/// where the offsets say every frame. Above zero it closes on that place
/// exponentially, [stiffness] being how many times its distance it closes
/// per second, and the first [advance] still puts it there outright.
///
/// **Through `flutter3d_sim`'s `CameraRig`.** The easing, a knock, a shake
/// and the pull out of walls are the rig's, written once for every chasing
/// camera: [rig] is there to shake when the craft is hit, and a `world`
/// with walls in it keeps the camera out of them. Without one the camera
/// has nothing to be kept out of.
final class ChaseCamera {
  ChaseCamera({
    required this.camera,
    required this.target,
    required this.offset,
    required this.lookOffset,
    this.followAcross = 1.0,
    this.lookAcross = 1.0,
    this.stiffness = 0.0,
    CollisionWorld? world,
  }) : rig = CameraRig(world: world ?? CollisionWorld());

  final CameraNode camera;
  final Object3dComponent target;

  /// From the target's scene position to the camera.
  final Vector3 offset;

  /// From the target's scene position to the point the camera looks at.
  final Vector3 lookOffset;

  final double followAcross;
  final double lookAcross;
  final double stiffness;

  /// What eases the camera, and what shakes it: `rig.shake(0.4)` when the
  /// craft goes down.
  final CameraRig rig;

  /// A closing rate high enough that a stiff camera is where it should be
  /// after any frame, through the same easing a springy one goes through.
  static const double _rigid = 1e4;

  /// Moves the camera for this frame. Call it once the target has moved,
  /// from `Flutter3dFlameWidget.onTick` or through [ChaseCameraComponent].
  void advance(double dt) {
    final at = target.scenePosition;
    final eye = at + offset
      ..x = at.x * followAcross + offset.x;
    final look = at + lookOffset
      ..x = at.x * lookAcross + lookOffset.x;
    rig.place(
      desiredEye: eye,
      desiredTarget: look,
      lag: stiffness > 0.0 ? stiffness : _rigid,
      dt: dt,
    );
    camera
      ..setPositionFrom(rig.eye)
      ..lookAt(rig.target);
  }
}

/// A [ChaseCamera] run as a Flame component, for a game that would rather
/// order it by priority than call it from a tick. Give it a priority above
/// whatever moves the target, so it follows this frame's move.
final class ChaseCameraComponent extends Component {
  ChaseCameraComponent(this.chase, {super.priority = BridgePriority.camera});

  final ChaseCamera chase;

  @override
  void update(double dt) => chase.advance(dt);
}
