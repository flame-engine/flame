import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_sim/flutter3d_sim.dart' show Portable;
import 'package:vector_math/vector_math.dart' show Quaternion, Vector3;

/// Where a Flame point is in the scene and which way a Flame angle faces
/// there: what an `Object3dComponent` writes its node through.
///
/// A `BridgePlane` is the flat one. [CurvilinearSpace] bends Flame's world
/// along a road, so a racing game can keep its cars in Flame's straight
/// coordinates (across the road, and along it) while the road winds.
abstract interface class BridgeSpace {
  /// The scene point for Flame's ([x], [y]), [lift] metres up, into [out].
  void place(double x, double y, double lift, Vector3 out);

  /// The rotation a Flame [angle] draws with at ([x], [y]), into [out].
  void turn(double x, double y, double angle, Quaternion out);
}

/// Flame's world laid along [path]: Flame's `x` is metres right of the
/// road's middle, Flame's `-y` is metres along it (so up the screen is
/// forward, as on a ground plane), and a Flame angle turns from the road's
/// own heading.
///
/// **What Enduro's road needs.** Its cars live on a straight strip in
/// Flame, where overtaking is a change of `x` and speed a change of `y`,
/// and are drawn on a track that bends. Keeping them in Flame's straight
/// coordinates keeps Flame's hitboxes meaning "side by side on the road",
/// however the road turns under them.
final class CurvilinearSpace implements BridgeSpace {
  CurvilinearSpace(this.path);

  final OpenPath path;

  final Vector3 _right = Vector3.zero();
  final Vector3 _ahead = Vector3.zero();

  @override
  void place(double x, double y, double lift, Vector3 out) {
    final s = -y;
    path
      ..pointAt(s, out)
      ..rightAt(s, _right);
    out
      ..addScaled(_right, x)
      ..addScaled(path.up, lift);
  }

  @override
  void turn(double x, double y, double angle, Quaternion out) {
    path.tangentAt(-y, _ahead);
    // The road's heading as a turn about up from -Z, then Flame's own angle
    // on top of it, clockwise on screen as on a ground plane.
    final heading = Portable.atan2(-_ahead.x, -_ahead.z);
    final phi = heading - angle;
    out.setAxisAngle(path.up, phi);
  }
}
