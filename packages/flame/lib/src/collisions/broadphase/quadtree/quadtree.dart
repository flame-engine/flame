import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';

/// QuadTree calculation class not bound to Flame. Could be used anywhere
/// outside of Flame, for example in isolates to calculate background logic.
///
/// Usage:
/// 1. Create new instance.
/// 2. Use [add] to add hitboxes to simulation.
/// 3. Use [query] to get list of hitboxes that potentially collide.
/// 4. Use [remove] to remove a hitbox from the tree.
/// 5. Use sequence of [remove] and [add] to simulate hitbox movement.
/// 6. Use [hasMoved] to determine if a hitbox ever changed its position.
/// 7. Call [clear] to remove all data.
///
/// Use [optimize] to scan the tree and remove unused quadrants.
class QuadTree<T extends Hitbox<T>> {
  QuadTree({
    this.maxObjects = 25,
    this.maxDepth = 10,
    this.mainBoxSize = Rect.zero,
  });

  final int maxObjects;
  final int maxDepth;

  Rect mainBoxSize;

  var _rootNode = QuadTreeNode<T>();
  int _nodeLastId = 0;
  final _oldPositionByItem = <ShapeHitbox, Aabb2>{};
  final _hitboxAtNode = <ShapeHitbox, QuadTreeNode>{};

  List<T> get hitboxes => _rootNode.valuesRecursive;

  Rect _getBoxOfValue(T value) {
    final minOffset = Offset(
      value.aabb.min.x < 0 ? 0 : value.aabb.min.x,
      value.aabb.min.y < 0 ? 0 : value.aabb.min.y,
    );
    return Rect.fromPoints(minOffset, value.aabb.max.toOffset());
  }

  bool _noChildren(QuadTreeNode node) => node.children[0] == null;

  void clear() {
    _rootNode = QuadTreeNode<T>();
    _nodeLastId = 0;
    _hitboxAtNode.clear();
    _oldPositionByItem.clear();
  }

  static Rect _computeBox(Rect box, _QuadTreeZone zone) {
    final origin = box.topLeft;
    final childSize = (box.size / 2).toOffset();
    switch (zone) {
      case _QuadTreeZone.topLeft:
        return Rect.fromLTWH(origin.dx, origin.dy, childSize.dx, childSize.dy);
      case _QuadTreeZone.topRight:
        return Rect.fromLTWH(
          origin.dx + childSize.dx,
          origin.dy,
          childSize.dx,
          childSize.dy,
        );
      case _QuadTreeZone.bottomLeft:
        return Rect.fromLTWH(
          origin.dx,
          origin.dy + childSize.dy,
          childSize.dx,
          childSize.dy,
        );
      case _QuadTreeZone.bottomRight:
        final position = origin + childSize;
        return Rect.fromLTWH(
          position.dx,
          position.dy,
          childSize.dx,
          childSize.dy,
        );
      default:
        assert(false, 'Invalid child index $box $zone');
        return Rect.zero;
    }
  }

  _QuadTreeZone _getQuadrant(Rect nodeBox, Rect valueBox) {
    final center = nodeBox.center;
    if (valueBox.right <= center.dx) {
      if (valueBox.bottom <= center.dy) {
        return _QuadTreeZone.topLeft;
      } else if (valueBox.top > center.dy) {
        return _QuadTreeZone.bottomLeft;
      } else {
        return _QuadTreeZone.root;
      }
    } else if (valueBox.left > center.dx) {
      if (valueBox.bottom <= center.dy) {
        return _QuadTreeZone.topRight;
      } else if (valueBox.top > center.dy) {
        return _QuadTreeZone.bottomRight;
      } else {
        return _QuadTreeZone.root;
      }
    } else {
      return _QuadTreeZone.root;
    }
  }

  void add(T hitbox) {
    final node = _add(_rootNode, 0, mainBoxSize, hitbox, null);
    _oldPositionByItem[hitbox as ShapeHitbox] = Aabb2.copy(hitbox.aabb);
    _hitboxAtNode[hitbox as ShapeHitbox] = node;
  }

  QuadTreeNode<T> _add(
    QuadTreeNode<T> node,
    int depth,
    Rect box,
    T value,
    QuadTreeNode? parent,
  ) {
    QuadTreeNode<T> finalNode;
    if (_noChildren(node)) {
      // Insert the value in this node if possible.
      if (depth >= maxDepth || node.hitboxes.length < maxObjects) {
        node.hitboxes.add(value);
        finalNode = node;
      }
      // Otherwise, we split and we try again.
      else {
        _split(node, box);
        finalNode = _add(node, depth, box, value, parent);
      }
    } else {
      final quadrant = _getQuadrant(box, _getBoxOfValue(value));
      // Add the value in a child if the value is entirely contained in it.
      if (quadrant != _QuadTreeZone.root) {
        final children = node.children[quadrant.value];
        if (children == null) {
          throw 'Invalid index $quadrant';
        }
        finalNode = _add(
          children as QuadTreeNode<T>,
          depth + 1,
          _computeBox(box, quadrant),
          value,
          node,
        );
      }
      // Otherwise, we add the value in the current node.
      else {
        node.hitboxes.add(value);
        finalNode = node;
      }
    }
    if (parent != null && finalNode.parent == null) {
      finalNode.parent = parent;
    }
    return finalNode;
  }

  void _split(QuadTreeNode node, Rect box) {
    assert(_noChildren(node), 'Only leaves can be split');
    // Create children
    for (var i = 0; i < node.children.length; i++) {
      final newId = ++_nodeLastId;
      node.children[i] = QuadTreeNode<T>()
        ..parent = node
        ..id = newId;
    }

    // Assign values to children
    final moveValues = <T>[]; // New values for this node
    for (final value in node.hitboxes) {
      final quadrant = _getQuadrant(box, _getBoxOfValue(value as T));
      if (quadrant != _QuadTreeZone.root) {
        final children = node.children[quadrant.value];
        if (children == null) {
          throw 'Invalid index $quadrant';
        }
        children.hitboxes.add(value);
        _hitboxAtNode[value as ShapeHitbox] = children;
      } else {
        moveValues.add(value);
        _hitboxAtNode[value as ShapeHitbox] = node;
      }
    }
    node.hitboxes = moveValues;
  }

  void remove(T hitbox, {bool keepOldPosition = false}) {
    final node = _hitboxAtNode.remove(hitbox as ShapeHitbox);
    if (node != null) {
      node.hitboxes.remove(hitbox);
      if (!keepOldPosition) {
        _oldPositionByItem.remove(hitbox as ShapeHitbox);
      }
    }
  }

  void optimize() {
    _tryMergeRecursive(_rootNode);
  }

  void _tryMergeRecursive(QuadTreeNode node) {
    if (_noChildren(node)) {
      return;
    }

    var tryMerge = true;
    var hitboxesInside = node.hitboxes.length;
    for (final child in node.children) {
      if (child == null) {
        throw 'Child must be not null';
      }
      _tryMergeRecursive(child);
      if (_noChildren(child)) {
        hitboxesInside += child.hitboxes.length;
      } else {
        tryMerge = false;
      }
    }

    if (hitboxesInside <= maxObjects && tryMerge) {
      for (var i = 0; i < node.children.length; i++) {
        final child = node.children[i];
        if (child == null) {
          throw 'Child must be not null';
        }
        node.hitboxes.addAll(child.hitboxes);
        child.hitboxes.clear();
        node.children[i] = null;
      }
    }
  }

  Map<int, List<T>> query(T value) {
    final node = _hitboxAtNode[value as ShapeHitbox];
    var id = -1;
    final values = <T>[];
    if (node == null) {
      throw '$node not found';
    }
    id = node.id;
    values.addAll(node.hitboxes as List<T>);
    values.addAll(_getChildrenItems(node));
    values.addAll(_getParentItems(node));
    return {id: values};
  }

  List<T> _getChildrenItems(QuadTreeNode parent) {
    final list = <T>[];
    for (final child in parent.children) {
      if (child != null) {
        list.addAll(child.hitboxes as List<T>);
        if (child.children[0] != null) {
          list.addAll(_getChildrenItems(child));
        }
      }
    }
    return list;
  }

  List<T> _getParentItems(QuadTreeNode node) {
    final list = <T>[];
    final parent = node.parent;
    if (parent != null) {
      list.addAll(parent.hitboxes as List<T>);
      list.addAll(_getParentItems(parent));
    }
    return list;
  }

  bool hasMoved(T hitbox) {
    final lastPos = _oldPositionByItem[hitbox as ShapeHitbox];
    if (lastPos == null) {
      return true;
    }
    return lastPos.min != hitbox.aabb.min || lastPos.max == hitbox.aabb.max;
  }
}

/// Public interface to QuadTree internal data structures.
///
/// Allows to read a node's data without risk of affecting the outcome of
/// collisions.
/// Use [QuadTreeNodeDebugInfo.init] to initialize the class for the
/// current collision detection. You need only this instance to get all
/// another nodes and hitboxes using [nodes] and the
/// [allElements] / [ownElements] methods.
/// Use [rect] to get node's computed box;
/// The class might be useful to render debugging info.
/// See examples for details.
class QuadTreeNodeDebugInfo {
  QuadTreeNodeDebugInfo(this.rect, this.node, this.cd);

  factory QuadTreeNodeDebugInfo.init(QuadTreeCollisionDetection cd) {
    final node = cd.broadphase.tree._rootNode;
    final rect = cd.broadphase.tree.mainBoxSize;
    return QuadTreeNodeDebugInfo(rect, node, cd);
  }

  final Rect rect;
  final QuadTreeNode node;
  final QuadTreeCollisionDetection cd;

  List<ShapeHitbox> get ownElements => node.hitboxes as List<ShapeHitbox>;

  List<ShapeHitbox> get allElements =>
      node.valuesRecursive as List<ShapeHitbox>;

  bool get noChildren => node.children[0] == null;

  int get id => node.id;

  List<QuadTreeNodeDebugInfo> get nodes {
    final list = <QuadTreeNodeDebugInfo>[this];
    for (var i = 0; i < node.children.length; i++) {
      final node = this.node.children[i];
      if (node == null) {
        continue;
      }

      final nodeRect = QuadTree._computeBox(rect, _QuadTreeZone.fromIndex(i));
      final dbg = QuadTreeNodeDebugInfo(nodeRect, node, cd);
      list.add(dbg);
      list.addAll(dbg.nodes);
    }
    return list;
  }
}

class QuadTreeNode<T extends Hitbox<T>> {
  final List<QuadTreeNode?> children = List.generate(
    4,
    (index) => null,
    growable: false,
  );

  List<T> hitboxes = <T>[];

  QuadTreeNode? parent;
  int id = 0;

  List<T> get valuesRecursive {
    final data = <T>[];

    data.addAll(hitboxes);
    for (final child in children) {
      if (child == null) {
        continue;
      }
      data.addAll(child.valuesRecursive as List<T>);
    }
    return data;
  }

  @override
  String toString() {
    return 'node $id';
  }
}

enum _QuadTreeZone {
  root(-1),
  topLeft(0),
  topRight(1),
  bottomLeft(2),
  bottomRight(3);

  const _QuadTreeZone(this.value);

  factory _QuadTreeZone.fromIndex(int i) {
    return switch (i) {
      0 => _QuadTreeZone.topLeft,
      1 => _QuadTreeZone.topRight,
      2 => _QuadTreeZone.bottomLeft,
      3 => _QuadTreeZone.bottomRight,
      _ => _QuadTreeZone.root,
    };
  }

  final int value;
}
