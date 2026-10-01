import 'package:flame/components.dart' show Component;
import 'package:flame_flutter3d/src/camera/chase_camera.dart' show ChaseCamera;
import 'package:flame_flutter3d/src/host/bridge_priority.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_physics/flutter3d_physics.dart' show CollisionWorld;
import 'package:flutter3d_sim/flutter3d_sim.dart' show CameraRig;
import 'package:vector_math/vector_math.dart' show Vector3;

/// A camera eased towards wherever a function says it should be.
///
/// **For what one component cannot say.** [ChaseCamera] follows a bridged
/// component; a camera over a co-op party follows all of it, and where it
/// should be is worked out from every hero at once — by the game's own
/// framing, which may also be a rule of the simulation. [view] is that
/// answer, asked once a frame: it writes the eye and the point looked at
/// into the two vectors it is handed, or answers false while there is
/// nothing to look at yet.
///
/// Through the same [CameraRig] as [ChaseCamera]: the easing, the shake and
/// the pull out of walls are the rig's.
final class ViewCamera {
  ViewCamera({
    required this.camera,
    required this.view,
    this.stiffness = 4.0,
    CollisionWorld? world,
  }) : rig = CameraRig(world: world ?? CollisionWorld());

  final CameraNode camera;

  /// Where the camera wants to be this frame, written into `eye` and
  /// `target`; false leaves the camera where it is.
  final bool Function(Vector3 eye, Vector3 target) view;

  /// How many times its distance the camera closes per second; zero puts it
  /// there outright.
  final double stiffness;

  /// What eases the camera, and what shakes it.
  final CameraRig rig;

  final Vector3 _eye = Vector3.zero();
  final Vector3 _target = Vector3.zero();

  /// Moves the camera for this frame.
  void advance(double dt) {
    if (!view(_eye, _target)) {
      return;
    }
    rig.place(
      desiredEye: _eye,
      desiredTarget: _target,
      lag: stiffness > 0.0 ? stiffness : 1e4,
      dt: dt,
    );
    camera
      ..setPositionFrom(rig.eye)
      ..lookAt(rig.target);
  }
}

/// A [ViewCamera] run as a Flame component, after whatever moves what it
/// frames.
final class ViewCameraComponent extends Component {
  ViewCameraComponent(
    this.viewCamera, {
    super.priority = BridgePriority.camera,
  });

  final ViewCamera viewCamera;

  @override
  void update(double dt) => viewCamera.advance(dt);
}
