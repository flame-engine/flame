import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;

/// A world whose edges meet: what leaves by the right comes in on the left,
/// what leaves by the top comes in at the bottom. Asteroids' screen.
///
/// **Wrapping a position is the easy third.** A ship half over the right
/// edge is half on the left too, and has to be drawn there; a rock drifting
/// out on the left has to be hit by a shot coming in on the right. Games
/// that wrapped the position alone had craft that blinked from one side to
/// the other and a seam nothing could be hit across.
///
/// So, for every child within [margin] of an edge, this draws a ghost: a
/// copy of what the child's node draws, one world across, on the other side;
/// in a corner, three. And it gives the child ghost hitboxes, the same
/// shapes one world across, so Flame's own collision detection finds a
/// contact across the seam and reports it to the child itself, in its own
/// `onCollision`. Children are the bridged components added to this one.
///
/// **One contact is one callback.** Two craft by the same edge touch twice,
/// really and through their ghosts, and two by opposite edges touch through
/// each one's ghost; each pair reported its hit twice, and a rock took
/// double damage. A ghost never meets another ghost, and of two ghosts
/// that stand for the same meeting only one takes part. A ghost has its
/// owner's hitbox's collision type, solidity and shape, polygons included.
///
/// **Drawn as it is now.** A ghost's meshes take their owner's tint and
/// opacity every frame, so a hit flash or a fade shows on both sides.
///
/// **Bodies wrap too.** A child placed from the scene side, a body the
/// physics steps, had its Flame position wrapped and read straight back from
/// the body on the far side of the edge; it is carried across in the scene
/// as well, still moving. A ghost is tapped as its owner is: a tap on a
/// craft seen across the seam reaches the craft.
///
/// [min] and [max] are the world's corners in Flame's coordinates.
class WrapSpace extends Component with CustomTraversal {
  WrapSpace({
    required this.min,
    required this.max,
    required this.scene,
    this.margin = 1.0,
  }) : assert(max.x > min.x && max.y > min.y, 'a world with no room');

  final Vector2 min;
  final Vector2 max;

  /// Where the ghosts are drawn.
  final Scene scene;

  /// How near an edge a child has to be to have a ghost across it: about
  /// the size of the biggest thing in the world.
  double margin;

  double get _width => max.x - min.x;
  double get _height => max.y - min.y;

  final Map<Object3dComponent, _Ghosts> _ghosts =
      <Object3dComponent, _Ghosts>{};

  /// Where [point] is, brought back inside the world.
  Vector2 wrap(Vector2 point) => Vector2(
    min.x + ((point.x - min.x) % _width),
    min.y + ((point.y - min.y) % _height),
  );

  /// The shortest way from [from] to [to], going across an edge when that
  /// is shorter: where a homing rock should turn.
  Vector2 shortestWay(Vector2 from, Vector2 to) {
    var dx = to.x - from.x;
    var dy = to.y - from.y;
    if (dx > _width / 2) {
      dx -= _width;
    }
    if (dx < -_width / 2) {
      dx += _width;
    }
    if (dy > _height / 2) {
      dy -= _height;
    }
    if (dy < -_height / 2) {
      dy += _height;
    }
    return Vector2(dx, dy);
  }

  /// Brings every child that has left the world back in. One placed from
  /// the scene side, a body the physics moves, is carried across in the
  /// scene too ([Object3dComponent.shiftScene]), before it reads its place
  /// back this frame.
  @override
  void update(double dt) {
    super.update(dt);
    for (final child in children.whereType<PositionComponent>()) {
      final p = child.position;
      if (p.x < min.x || p.x >= max.x || p.y < min.y || p.y >= max.y) {
        final wrapped = wrap(p);
        if (child is Object3dComponent &&
            child.direction == SyncDirection.sceneToFlame) {
          child.shiftScene(child.plane.to3d(wrapped - p, at: 0.0));
        }
        child.position.setFrom(wrapped);
      }
    }
  }

  /// The boxes round [owner]'s ghosts, where they are drawn this frame: what
  /// a tap on a craft seen across the seam is tested against.
  Iterable<Aabb3> ghostBoundsOf(Object3dComponent owner) sync* {
    final ghosts = _ghosts[owner];
    if (ghosts == null) {
      return;
    }
    for (final ghost in ghosts._byOffset.values) {
      final box = ghost._drawing?.subtreeBounds;
      if (box != null) {
        yield box;
      }
    }
  }

  @override
  void updateSubtree(double dt) {
    super.updateSubtree(dt);
    final seen = <Object3dComponent>{};
    for (final child in children.whereType<Object3dComponent>()) {
      if (child.isRemoving) {
        continue;
      }
      seen.add(child);
      final ghosts = _ghosts.putIfAbsent(
        child,
        () => _Ghosts(child, scene, this),
      );
      ghosts.follow(_offsetsFor(child.position));
    }
    for (final gone in _ghosts.keys.where((c) => !seen.contains(c)).toList()) {
      _ghosts.remove(gone)!.clear();
    }
  }

  @override
  void onRemove() {
    for (final ghosts in _ghosts.values) {
      ghosts.clear();
    }
    _ghosts.clear();
    super.onRemove();
  }

  /// Whether [owner] has a ghost [dx], [dy] across: then a meeting of that
  /// ghost with a real hitbox stands for the same one as the reverse.
  bool _hasGhost(Object3dComponent owner, double dx, double dy) =>
      _ghosts[owner]?._byOffset.containsKey((dx, dy)) ?? false;

  /// The world-sized steps across which [p] needs a ghost: none in the
  /// middle, one by an edge, three in a corner.
  List<Vector2> _offsetsFor(Vector2 p) {
    final xs = <double>[
      if (p.x > max.x - margin) -_width,
      if (p.x < min.x + margin) _width,
    ];
    final ys = <double>[
      if (p.y > max.y - margin) -_height,
      if (p.y < min.y + margin) _height,
    ];
    return <Vector2>[
      for (final dx in xs) Vector2(dx, 0.0),
      for (final dy in ys) Vector2(0.0, dy),
      for (final dx in xs)
        for (final dy in ys) Vector2(dx, dy),
    ];
  }
}

/// One child's ghosts: a copy of its drawing and of its hitboxes per offset.
final class _Ghosts {
  _Ghosts(this.owner, this.scene, this.space);

  final Object3dComponent owner;
  final Scene scene;
  final WrapSpace space;
  final Map<(double, double), _Ghost> _byOffset = <(double, double), _Ghost>{};

  void follow(List<Vector2> offsets) {
    final wanted = <(double, double)>{for (final o in offsets) (o.x, o.y)};
    for (final key
        in _byOffset.keys.where((k) => !wanted.contains(k)).toList()) {
      _byOffset.remove(key)!.clear();
    }
    for (final offset in offsets) {
      _byOffset.putIfAbsent((
        offset.x,
        offset.y,
      ), () => _Ghost(owner, scene, space, offset)).follow();
    }
  }

  void clear() {
    for (final ghost in _byOffset.values) {
      ghost.clear();
    }
    _byOffset.clear();
  }
}

/// A copy of [owner]'s drawing and hitboxes, [offset] across the world.
final class _Ghost {
  _Ghost(this.owner, this.scene, this.space, Vector2 offset)
    : offset = offset.clone(),
      _step = owner.plane.to3d(offset, at: 0.0);

  final Object3dComponent owner;
  final Scene scene;
  final WrapSpace space;
  final Vector2 offset;
  final Vector3 _step;

  SceneNode? _drawing;
  int _drawn = -1;
  final Map<ShapeHitbox, ShapeHitbox> _hitboxes = <ShapeHitbox, ShapeHitbox>{};

  void follow() {
    _followDrawing();
    _followHitboxes();
  }

  void _followDrawing() {
    // Made again when what the node draws changes: a model dressed onto a
    // primitive, a part added.
    final size = _count(owner.node);
    var drawing = _drawing;
    if (drawing == null || size != _drawn) {
      drawing?.removeFromParent();
      drawing = _drawing = _copy(owner.node);
      _drawn = size;
      scene.add(drawing);
    }
    final at = owner.node.readPosition()..add(_step);
    drawing
      ..setPositionFrom(at)
      ..setRotation(owner.node.readRotation())
      ..visible = owner.node.visible;
    final s = owner.node.readScale();
    drawing.setScale(s.x, s.y, s.z);
    _tint(owner.node, drawing);
  }

  /// Copies each mesh's tint onto its copy, the two trees being the same
  /// shape: a hit flash or a fade out shows on the ghost too.
  static void _tint(SceneNode from, SceneNode to) {
    if (from is MeshNode && to is MeshNode && to.tint != from.tint) {
      to.tint.setFrom(from.tint);
    }
    final a = from.childrenView;
    final b = to.childrenView;
    for (var i = 0; i < a.length && i < b.length; i++) {
      _tint(a.elementAt(i), b.elementAt(i));
    }
  }

  /// Whether a meeting of this ghost with [other] is told to [owner]. Never
  /// one with another ghost: the real hitboxes, or a real one and a ghost,
  /// meet as well and tell it. Nor one with a real hitbox of a child that
  /// has the ghost opposite this one: that ghost meets [owner]'s real
  /// hitbox, and [owner] hears it from there.
  bool tells(ShapeHitbox other) {
    if (other is _GhostHitbox) {
      return false;
    }
    final them = other.hitboxParent;
    if (them is! Object3dComponent) {
      return true;
    }
    return !space._hasGhost(them, -offset.x, -offset.y);
  }

  void _followHitboxes() {
    final own = owner.children
        .whereType<ShapeHitbox>()
        .where((h) => h is! _GhostHitbox)
        .toList();
    for (final gone in _hitboxes.keys.where((h) => !own.contains(h)).toList()) {
      _hitboxes.remove(gone)!.removeFromParent();
    }
    // The offset in the owner's own frame, which may be turned and scaled.
    final here = owner.absolutePosition;
    final local =
        owner.absoluteToLocal(here + offset) - owner.absoluteToLocal(here);
    for (final hitbox in own) {
      final ghost = _hitboxes.putIfAbsent(hitbox, () {
        final ShapeHitbox made = switch (hitbox) {
          final CircleHitbox circle => _GhostCircle(this, circle.radius),
          final PolygonHitbox polygon => _GhostPolygon(this, <Vector2>[
            for (final v in polygon.vertices) v.clone(),
          ]),
          _ => _GhostRectangle(this, hitbox.size),
        };
        owner.add(made);
        return made;
      });
      ghost
        ..position.setFrom(hitbox.position + local)
        ..anchor = hitbox.anchor
        ..angle = hitbox.angle
        ..collisionType = hitbox.collisionType
        ..isSolid = hitbox.isSolid;
      if (ghost is _GhostRectangle) {
        ghost.size.setFrom(hitbox.size);
      }
    }
  }

  void clear() {
    _drawing?.removeFromParent();
    _drawing = null;
    for (final ghost in _hitboxes.values) {
      ghost.removeFromParent();
    }
    _hitboxes.clear();
  }

  static int _count(SceneNode node) {
    var n = 1;
    for (final child in node.childrenView) {
      n += _count(child);
    }
    return n;
  }

  /// What [node] draws, as nodes of its own: the meshes and materials are
  /// shared, the transforms copied.
  static SceneNode _copy(SceneNode node) {
    final made = node is MeshNode
        ? (MeshNode(node.mesh, node.material)..tint.setFrom(node.tint))
        : SceneNode();
    made
      ..setPositionFrom(node.readPosition())
      ..setRotation(node.readRotation());
    final s = node.readScale();
    made.setScale(s.x, s.y, s.z);
    for (final child in node.childrenView) {
      made.add(_copy(child));
    }
    return made;
  }
}

/// A hitbox standing in for one of its owner's, a world across. It tells
/// its owner of a meeting only when nothing else will: see [_Ghost.tells].
mixin _GhostHitbox on ShapeHitbox {
  _Ghost get ghost;

  final Set<ShapeHitbox> _told = <ShapeHitbox>{};

  CollisionCallbacks? get _owner => switch (hitboxParent) {
    final CollisionCallbacks owner => owner,
    _ => null,
  };

  /// Runs Flame's own handling without its telling the owner: a hitbox
  /// tells its parent only while it and the other both let it, and the
  /// other side has to keep hearing of this ghost.
  void _quietly(void Function() handle) {
    triggersParentCollision = false;
    try {
      handle();
    } finally {
      triggersParentCollision = true;
    }
  }

  @override
  void onCollisionStart(List<Vector2> points, ShapeHitbox other) {
    _quietly(() => super.onCollisionStart(points, other));
    if (!ghost.tells(other)) {
      return;
    }
    _told.add(other);
    _owner?.onCollisionStart(points, other.hitboxParent);
  }

  @override
  void onCollision(List<Vector2> points, ShapeHitbox other) {
    _quietly(() => super.onCollision(points, other));
    if (_told.contains(other)) {
      _owner?.onCollision(points, other.hitboxParent);
    }
  }

  @override
  void onCollisionEnd(ShapeHitbox other) {
    _quietly(() => super.onCollisionEnd(other));
    if (_told.remove(other)) {
      _owner?.onCollisionEnd(other.hitboxParent);
    }
  }
}

final class _GhostRectangle extends RectangleHitbox with _GhostHitbox {
  _GhostRectangle(this.ghost, Vector2 size) : super(size: size.clone());

  @override
  final _Ghost ghost;
}

final class _GhostCircle extends CircleHitbox with _GhostHitbox {
  _GhostCircle(this.ghost, double radius) : super(radius: radius);

  @override
  final _Ghost ghost;
}

final class _GhostPolygon extends PolygonHitbox with _GhostHitbox {
  _GhostPolygon(this.ghost, super.vertices);

  @override
  final _Ghost ghost;
}
