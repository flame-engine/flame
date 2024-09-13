import 'package:flame_3d/core.dart';

class JointsInfo {
  /// Joints per surface idx
  Map<int, List<Matrix4>> jointTransformsPerSurface = {};

  /// Joints for the current surface
  List<Matrix4> jointTransforms = [];

  void setSurface(int surfaceIdx) {
    jointTransforms = jointTransformsPerSurface[surfaceIdx] ?? [];
  }
}
