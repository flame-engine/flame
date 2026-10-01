import 'dart:async' show scheduleMicrotask;

import 'package:flame/components.dart';
import 'package:flame/effects.dart'
    show OpacityProvider, ReadOnlyAngleProvider, ReadOnlyPositionProvider;
import 'package:flame_flutter3d/flame_flutter3d.dart'
    show RigidBodyComponent, ActorComponent;
import 'package:flame_flutter3d/src/host/has_flutter3d.dart';
import 'package:flame_flutter3d/src/transform/bridge_space.dart';
import 'package:flame_flutter3d/src/transform/bridged3d.dart';
import 'package:flame_flutter3d/src/transform/flame_pose.dart';
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;

/// Which side of an [Object3dComponent] writes a frame's transform into the
/// other.
///
/// Nothing infers a direction from which value "changed more recently" —
/// two systems can each believe the other is the one reading, and a
/// transform that no caller ever explicitly wrote into would still look
/// changed to whichever side polled it first. A direction chosen once, at
/// construction, is one field instead of a heuristic.
enum SyncDirection {
  /// This component's flutter3d [SceneNode] is authoritative; its position
  /// and rotation are copied onto the Flame side every frame. What every
  /// existing flutter3d system already owns — a rigid body, an actor — is
  /// scene-authoritative, so [RigidBodyComponent] and [ActorComponent] both
  /// default to this.
  sceneToFlame,

  /// This component's Flame [PositionComponent] is authoritative; its
  /// position and angle are copied onto the flutter3d [SceneNode] every
  /// frame — a Flame-driven prop that should also draw as a 3D billboard,
  /// say.
  flameToScene,
}

/// A Flame [PositionComponent] and a flutter3d [SceneNode] kept at the same
/// place, on one [BridgePlane], one [direction] deciding who writes.
///
/// **Size and anchor are Flame's, and usually wanted.** Nothing on the 3D side
/// reads them, but a `RectangleHitbox()` fills its parent's [size], and the
/// [anchor] decides whether [position] (the point written into the scene) is
/// the component's centre or its corner. A bridged component that collides
/// passes `anchor: Anchor.center` and the size of what it draws.
///
/// **Lifecycle follows Flame's.** [onMount] adds [node] to [scene]; [onRemove]
/// calls `node.removeFromParent()`. A [SceneNode] never outlives the
/// component that owns it, and never needs a caller to remember to detach
/// it by hand — the same guarantee `CameraNode.onAttachedToScene` already
/// gives a [Scene]'s own registries. [removeFromParent] hides [node] at
/// once: Flame takes the component out of its tree on the next lifecycle
/// pass, and a node that stayed visible until then was drawn one frame
/// after the game had let it go.
///
/// **Where it is, not where it is relative to its parent.** The transform
/// written into the scene is Flame's absolute one, so a component nested
/// under another (a frog riding a log) lands where Flame draws it. [node]
/// itself stays wherever it was added, normally the scene's root.
///
/// **Flowing Flame to the scene, it syncs after its children.** A Flame
/// effect is a child of the component it moves, and effects update after
/// their parent's own [update]; syncing in [update] put the 3D side a frame
/// behind every `MoveEffect` and `RotateEffect`. [updateSubtree] runs the sync
/// once the whole subtree has moved.
///
/// **The rest of Flame's transform crosses too.** [elevation] lifts the
/// point off the plane along its normal. Flame's absolute scale, its own
/// times its ancestors', scales [node], the plane's two axes from its `x`
/// and `y` and the normal from their mean. Flame's visibility is written
/// into `node.visible` whenever it changes, and only then, so code that
/// blinks a node by hand keeps working: shown when this component and every
/// ancestor with [HasVisibility] is, as Flame draws it, since a hidden
/// parent hides its children.
///
/// **[visual] is the bridge's to create and the game's to turn.** The
/// bridge writes [node]'s rotation every frame, so a model turned to face
/// its way, banked into a turn or tilted as it sinks has to hang from a
/// node below it. [visual] is that node, made the first time it is asked
/// for; nothing here writes its transform.
///
/// **Opacity and a tint cross as well.** [opacity], which Flame's
/// `OpacityEffect` drives, fades every mesh under [node], and [tint]
/// colours them, through each mesh's own `MeshNode.tint`: a hit flash or a
/// wreck fading out, over a material a hundred craft share.
class Object3dComponent extends PositionComponent
    with CustomTraversal, HasVisibility
    implements OpacityProvider, Bridged3d {
  Object3dComponent({
    required this.node,
    required this.scene,
    required this.plane,
    this.direction = SyncDirection.sceneToFlame,
    this.elevation = 0.0,
    this.owns = const <DeviceMesh>[],
    this.space,
    this.follows,
    super.position,
    super.size,
    super.anchor,
    super.angle,
    super.scale,
    super.children,
    super.priority,
    super.key,
  });

  /// Where Flame's point is placed and turned in the scene, when not flat on
  /// [plane]: a [CurvilinearSpace] bends it along a road. Null places it on
  /// [plane]. Only the write from Flame to the scene goes through it: a
  /// component read back from the scene is read flat off [plane].
  @override
  final BridgeSpace? space;

  /// Something of Flame's this stands where it stands, and turns as it
  /// turns when it has an angle: a `flame_forge2d` `BodyComponent`, whose
  /// place its body decides, is both. Flowing Flame to the scene, its
  /// position and angle are taken every frame before they are written.
  ///
  /// **Flame's own physics, drawn in 3D.** A body of `flame_forge2d` is not
  /// a `PositionComponent`, so nothing of this bridge could be hung under
  /// it, and a pinball table whose flippers and ball its solver moves could
  /// not be drawn here. Any of Flame's position providers will do.
  final ReadOnlyPositionProvider? follows;

  void _follow() {
    final target = follows;
    if (target == null) {
      return;
    }
    position.setFrom(target.position);
    if (target is ReadOnlyAngleProvider) {
      angle = (target as ReadOnlyAngleProvider).angle;
    }
  }

  /// The box round [node] and everything under it.
  @override
  Aabb3? get drawnBounds3d => node.subtreeBounds;

  /// Meshes this component made for itself and lets go of when it is
  /// removed: a bridge's span, a wreck's hull built for the moment.
  ///
  /// **Let go after the frames in flight**, through the renderer of the
  /// `HasFlutter3d` game it is in, since a frame already sent may still be
  /// drawing them; at once when that game has no renderer, as in a test. A
  /// game without `HasFlutter3d` has no device here to give them back to,
  /// and keeps them. A component that is pooled and added again must not
  /// own anything: removal is the end of what it owns.
  final List<DeviceMesh> owns;

  HasFlutter3d? _host;

  /// The flutter3d node this component is bridged to.
  final SceneNode node;

  /// The scene [node] is added to on mount and removed from on unmount.
  final Scene scene;

  /// The 2D↔3D axis mapping this component reads and writes through.
  @override
  final BridgePlane plane;

  /// Which side is authoritative each frame. See [SyncDirection].
  final SyncDirection direction;

  /// Metres off [plane] along its normal: a flying craft's height over a
  /// ground plane, a jump's arc, a tanker settling under the water. Read
  /// every frame, so an effect or the game can move it.
  @override
  double elevation;

  SceneNode? _visual;
  bool? _visibleWritten;

  /// How opaque every mesh under [node] is drawn, from 0 to 1. What Flame's
  /// `OpacityEffect` moves.
  @override
  double opacity = 1.0;

  /// A linear colour every mesh under [node] is multiplied by; its alpha
  /// multiplies [opacity]. White leaves them as their materials say.
  @override
  final Vector4 tint = Vector4.all(1.0);

  bool _tintWritten = false;

  /// A node under [node] for what is drawn, which the bridge never turns.
  /// Made, and added to [node], the first time it is read.
  SceneNode get visual {
    final made = _visual;
    if (made != null) {
      return made;
    }
    final visual = SceneNode(name: '${node.name ?? 'object'} visual');
    node.add(visual);
    return _visual = visual;
  }

  /// Where this component is in the scene: its absolute Flame position on
  /// [plane], lifted by [elevation]. For placing something at it, a blast
  /// where a target went down, say.
  Vector3 get scenePosition {
    final bent = space;
    if (bent == null) {
      return plane.to3d(absolutePosition, at: plane.constant + elevation);
    }
    final at = absolutePosition;
    final out = Vector3.zero();
    bent.place(at.x, at.y, elevation, out);
    return out;
  }

  @override
  void onMount() {
    super.onMount();
    final game = findGame();
    if (game is HasFlutter3d) {
      _host = game;
    }
    if (node.parent == null) {
      scene.add(node);
    }
    _visibleWritten = null;
  }

  /// **Moved is not gone.** Flame moves a component to a new parent by
  /// removing it and mounting it again at once, and [owns] let go of here
  /// was a moved bridge drawing meshes already given back. So they are let
  /// go of a moment later, and only if the component is by then in no tree
  /// and on its way to none.
  @override
  void onRemove() {
    node.removeFromParent();
    if (owns.isNotEmpty) {
      scheduleMicrotask(() {
        if (!isMounted && parent == null) {
          _letGo();
        }
      });
    }
    super.onRemove();
  }

  void _letGo() {
    final host = _host;
    if (host == null || !host.has3d) {
      return;
    }
    final drawing = host.renderer;
    for (final mesh in owns) {
      if (drawing != null) {
        drawing.releaseMeshAfterFrame(mesh);
      } else {
        host.device
          ..releaseGeometry(mesh.vertices)
          ..releaseGeometry(mesh.indices);
      }
    }
  }

  @override
  void removeFromParent() {
    node.visible = false;
    _visibleWritten = false;
    super.removeFromParent();
  }

  /// Reads the scene side first, so this component's children see where the
  /// body is this frame. Flowing the other way it writes the scene here too,
  /// for a caller that drives a component by calling [update] itself, and
  /// again in [updateSubtree] once the effects under it have moved it.
  @override
  void update(double dt) {
    super.update(dt);
    switch (direction) {
      case SyncDirection.sceneToFlame:
        _readScene();
      case SyncDirection.flameToScene:
        _follow();
        _writeScene();
    }
  }

  @override
  void updateSubtree(double dt) {
    super.updateSubtree(dt);
    if (direction == SyncDirection.flameToScene) {
      _follow();
      _writeScene();
    }
    _writeTint();
    if (isRemoving) {
      node.visible = false;
    } else {
      final shown = shownInFlame(this);
      if (_visibleWritten != shown) {
        node.visible = shown;
        _visibleWritten = shown;
      }
    }
  }

  /// Writes [tint] and [opacity] into every mesh under [node] while either
  /// is not plain, so a model dressed onto the node later takes it too, and
  /// once more when they come back to plain.
  void _writeTint() {
    final alpha = tint.w * opacity;
    final plain =
        tint.x == 1.0 && tint.y == 1.0 && tint.z == 1.0 && alpha == 1.0;
    if (plain && !_tintWritten) {
      return;
    }
    _tintWritten = !plain;
    _paint(node, alpha);
  }

  void _paint(SceneNode at, double alpha) {
    if (at is MeshNode) {
      at.tint.setValues(tint.x, tint.y, tint.z, alpha);
    }
    for (final child in at.children) {
      _paint(child, alpha);
    }
  }

  /// Writes Flame's transform into [node], and only when it moved.
  ///
  /// **Unchanged is not written.** A node's setters mark it changed whatever
  /// they are given, and the engine reads that mark to decide whether its
  /// shadow cascades and its tree of bounds are still good. A bridged prop
  /// that never moved rewrote its place every frame, and one still tanker on
  /// the river had every shadow redrawn every frame. So the transform is
  /// compared with the one last written, and a component nested in nothing
  /// reads its own fields rather than Flame's absolute ones, which are made
  /// afresh on every read.
  void _writeScene() {
    final pose = _pose..readFrom(this);
    final x = pose.x;
    final y = pose.y;
    final turn = pose.turn;
    final sx = pose.scaleX;
    final sy = pose.scaleY;
    if (x == _writtenX &&
        y == _writtenY &&
        turn == _writtenAngle &&
        sx == _writtenScaleX &&
        sy == _writtenScaleY &&
        elevation == _writtenElevation) {
      return;
    }
    _writtenX = x;
    _writtenY = y;
    _writtenAngle = turn;
    _writtenScaleX = sx;
    _writtenScaleY = sy;
    _writtenElevation = elevation;

    final bent = space;
    if (bent == null) {
      plane.to3dInto(x, y, _place, at: plane.constant + elevation);
      plane.rotationInto(turn, _turn);
    } else {
      bent
        ..place(x, y, elevation, _place)
        ..turn(x, y, turn, _turn);
    }
    node
      ..setPositionFrom(_place)
      ..setRotation(_turn);
    final across = (sx.abs() + sy.abs()) / 2.0;
    switch (plane.axis) {
      case PlaneAxis.y:
        node.setScale(sx, across, sy);
      case PlaneAxis.z:
        node.setScale(sx, sy, across);
    }
  }

  final FlamePose _pose = FlamePose();
  final Vector3 _place = Vector3.zero();
  final Quaternion _turn = Quaternion.identity();
  double _writtenX = double.nan;
  double _writtenY = double.nan;
  double _writtenAngle = double.nan;
  double _writtenScaleX = double.nan;
  double _writtenScaleY = double.nan;
  double _writtenElevation = double.nan;

  /// Moves [node] to [at], and only if it is not there already: for a
  /// subclass that carries a body's place onto the node every frame. A
  /// body at rest was written every frame all the same, and a written node
  /// is a changed node, whose shadow cascades are drawn again.
  void placeNode(Vector3 at) {
    final now = node.readPosition(_nodeAt);
    if (now.x == at.x && now.y == at.y && now.z == at.z) {
      return;
    }
    node.setPositionFrom(at);
  }

  /// Turns [node] to [yaw] radians about the world's up, and only if it is
  /// not turned so already; see [placeNode].
  void turnNodeTo(double yaw) {
    if (yaw == _placedYaw) {
      return;
    }
    _placedYaw = yaw;
    node.setRotation(_yawTurn..setAxisAngle(_up, yaw));
  }

  final Vector3 _nodeAt = Vector3.zero();
  double _placedYaw = double.nan;
  final Quaternion _yawTurn = Quaternion.identity();
  static Vector3 get _up => Vector3(0.0, 1.0, 0.0);

  /// Moves what this component's place is read from by [by], in the scene:
  /// [node], and in a subclass the body under it, without stopping it. How
  /// a `WrapSpace` carries a component placed from the scene side across
  /// its seam; wrapping Flame's position alone was undone by the next read.
  void shiftScene(Vector3 by) {
    node.setPositionFrom(node.readPosition(_nodeAt)..add(by));
  }

  /// Forgets what was last written, so the next write happens whether or
  /// not Flame's side moved: for a caller that moved [node] itself and
  /// wants Flame's place put back.
  void rewriteScene() => _writtenX = double.nan;

  /// The node's place, brought into the space of the nearest positioned
  /// component above this one, when there is one; under a mirrored one the
  /// turn is reversed, as it is on the way out.
  void _readScene() {
    final world = plane.to2d(node.readPosition());
    final worldAngle = plane.angleFor(node.readRotation());
    final holder = placedAncestor(this);
    if (holder != null) {
      final above = _pose..readTurnOf(holder);
      final local = worldAngle - above.turn;
      position = holder.absoluteToLocal(world);
      angle = above.mirrored ? -local : local;
    } else {
      position = world;
      angle = worldAngle;
    }
  }
}

/// Whether Flame draws [component]: it is visible, and so is every ancestor
/// that can be hidden. A hidden parent does not render its children, and
/// the scene node of a child is not under its parent's node, so the bridge
/// has to ask the whole chain.
bool shownInFlame(HasVisibility component) {
  if (!component.isVisible) {
    return false;
  }
  for (final ancestor in component.ancestors()) {
    if (ancestor is HasVisibility && !ancestor.isVisible) {
      return false;
    }
  }
  return true;
}
