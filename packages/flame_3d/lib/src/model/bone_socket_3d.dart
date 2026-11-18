import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';

/// {@template bone_socket_3d}
/// A [Component3D] container that locks its transform to a node (bone) of an
/// ancestor [ModelComponent] every frame.
///
/// Add meshes, lights, particles, or trails as children of a [BoneSocket3D] to
/// attach equipment or effects to animated characters:
///
/// ```dart
/// character.add(
///   BoneSocket3D.byName(
///     'Hand.R',
///     children: [swordMesh,RibbonTrail3D()],
///   ),
/// );
/// ```
/// {@endtemplate}
class BoneSocket3D extends Component3D {
  /// Attaches to the node with index [nodeIndex] on the nearest ancestor
  /// [ModelComponent].
  BoneSocket3D.byIndex(
    int this.nodeIndex, {
    super.children,
  }) : nodeName = null;

  /// Attaches to the first node named [nodeName] on the nearest ancestor
  /// [ModelComponent].
  BoneSocket3D.byName(
    String this.nodeName, {
    super.children,
  }) : nodeIndex = null;

  /// Target node index when created with [BoneSocket3D.byIndex].
  final int? nodeIndex;

  /// Target node name when created with [BoneSocket3D.byName].
  final String? nodeName;

  ModelComponent? _owner;
  int? _resolvedIndex;

  final Vector3 _translation = Vector3.zero();
  final Quaternion _rotation = Quaternion.identity();
  final Vector3 _scale = Vector3.all(1.0);

  @override
  void onMount() {
    super.onMount();
    _resolveOwner();
    syncToBone();
  }

  @override
  void onRemove() {
    _owner = null;
    _resolvedIndex = null;
    super.onRemove();
  }

  @override
  void update(double dt) {
    syncToBone();
    super.update(dt);
  }

  /// Immediately updates this socket's local [transform] from its target bone's
  /// current evaluated model-space matrix.
  void syncToBone() {
    final owner = _owner ?? _resolveOwner();
    final idx = _resolvedIndex;
    if (owner == null || idx == null) {
      return;
    }
    final boneMatrix = owner.nodeTransform(idx);
    if (boneMatrix == null) {
      return;
    }
    boneMatrix.decompose(_translation, _rotation, _scale);
    position.setFrom(_translation);
    rotation.setFrom(_rotation);
    scale.setFrom(_scale);
  }

  ModelComponent? _resolveOwner() {
    for (final ancestor in ancestors()) {
      if (ancestor is ModelComponent) {
        _owner = ancestor;
        _resolvedIndex =
            nodeIndex ??
            (nodeName == null
                ? null
                : ancestor.model.nodeIndexByName(nodeName!));
        return ancestor;
      }
    }
    return null;
  }
}
