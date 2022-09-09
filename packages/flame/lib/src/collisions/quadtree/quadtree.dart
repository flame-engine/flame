import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';

/// Public interface to QuadTree internal data structures
/// Allow to read node's data without risc to affect on how collisions
/// works.
/// Use [QuadTreeNodeDebugInfo.init] to init class for current collision
/// detection. You need only this instance no get all another nodes and
/// hitboxes using [nodes] and [allElements] / [ownElements] methods.
/// Use [rect] to get node's computed box;
/// The class might be useful to render debugging info. See examples for details
class QuadTreeNodeDebugInfo {
  QuadTreeNodeDebugInfo(this.rect, this._node, this.cd);

  factory QuadTreeNodeDebugInfo.init(QuadTreeCollisionDetection cd) {
    final node = cd.quadBroadphase.tree._rootNode;
    final rect = cd.quadBroadphase.tree.mainBoxSize;
    return QuadTreeNodeDebugInfo(rect, node, cd);
  }

  final Rect rect;
  final _Node _node;
  final QuadTreeCollisionDetection cd;

  List<ShapeHitbox> get ownElements => _node.hitboxes as List<ShapeHitbox>;

  List<ShapeHitbox> get allElements =>
      _node.valuesRecursive as List<ShapeHitbox>;

  bool get noChildren => _node.children[0] == null;

  int get id => _node.id;

  List<QuadTreeNodeDebugInfo> get nodes {
    final list = <QuadTreeNodeDebugInfo>[this];
    for (var i = 0; i < _node.children.length; i++) {
      final node = _node.children[i];
      if (node == null) {
        continue;
      }

      final nodeRect = QuadTree._computeBox(rect, i);
      final dbg = QuadTreeNodeDebugInfo(nodeRect, node, cd);
      list.add(dbg);
      list.addAll(dbg.nodes);
    }
    return list;
  }
}

class _Node<T extends Hitbox<T>> {
  final List<_Node?> children =
      List.generate(4, (index) => null, growable: false);

  List<T> hitboxes = <T>[];

  _Node? parent;
  int id = 0;

  List<T> get valuesRecursive {
    final data = <T>[];

    data.addAll(hitboxes);
    for (final ch in children) {
      if (ch == null) {
        continue;
      }
      data.addAll(ch.valuesRecursive as List<T>);
    }
    return data;
  }

  @override
  String toString() {
    return 'node $id';
  }
}

/// QuadTree calculation class not bound to Flame. Could be used anywhere
/// outside of Flame, for example in isolate to calculate background logic.
///
/// Usage:
/// 1. Create new instance
/// 2. Use [add] to add hitboxes to simulation.
/// 3. Use [query] to get list of hitboxes potentially collide with specified
/// 4. Use [remove] to remove hitbox from tree
/// 5. Use sequence of [remove] and [add] to simulate hitbox movement
/// 6. Use [isMoved] to determine, does hitbox ever changed it's position
/// 7. Call [clear] to remove all data.
///
/// Use [optimize] to scan all tree and remove unused quadrants.
///
class QuadTree<T extends Hitbox<T>> {
  QuadTree({
    this.maxObjects = 25,
    this.maxLevels = 10,
    this.mainBoxSize = Rect.zero,
  });

  final int maxObjects;
  final int maxLevels;

  Rect mainBoxSize;

  var _rootNode = _Node<T>();
  int _nodeLastId = 0;
  final _oldPositionByItem = <ShapeHitbox, Aabb2>{};
  final _itemAtNode = <ShapeHitbox, _Node>{};

  List<T> get hitboxes => _rootNode.valuesRecursive;

  Rect _getBoxOfValue(T value) {
    final minOffset = Offset(
      value.aabb.min.x < 0 ? 0 : value.aabb.min.x,
      value.aabb.min.y < 0 ? 0 : value.aabb.min.y,
    );
    return Rect.fromPoints(minOffset, value.aabb.max.toOffset());
  }

  bool _noChildren(_Node node) => node.children[0] == null;

  void clear() {
    _rootNode = _Node<T>();
    _nodeLastId = 0;
    _itemAtNode.clear();
    _oldPositionByItem.clear();
  }

  static Rect _computeBox(Rect box, int i) {
    final origin = box.topLeft;
    final childSize = (box.size / 2).toOffset();
    switch (i) {
      case 0:
        // North West
        return Rect.fromLTWH(origin.dx, origin.dy, childSize.dx, childSize.dy);
      // North East
      case 1:
        return Rect.fromLTWH(
          origin.dx + childSize.dx,
          origin.dy,
          childSize.dx,
          childSize.dy,
        );
      // South West
      case 2:
        return Rect.fromLTWH(
          origin.dx,
          origin.dy + childSize.dy,
          childSize.dx,
          childSize.dy,
        );
      // South East
      case 3:
        final position = origin + childSize;
        return Rect.fromLTWH(
          position.dx,
          position.dy,
          childSize.dx,
          childSize.dy,
        );
      default:
        assert(false, 'Invalid child index');
        return Rect.zero;
    }
  }

  int _getQuadrant(Rect nodeBox, Rect valueBox) {
    final center = nodeBox.center;
    // West
    if (valueBox.right <= center.dx) {
      // North West
      if (valueBox.bottom <= center.dy) {
        return 0;
      } else if (valueBox.top > center.dy) {
        return 2;
      } else {
        return -1;
      }
    }
    // East
    else if (valueBox.left > center.dx) {
      // North East
      if (valueBox.bottom <= center.dy) {
        return 1;
      } else if (valueBox.top > center.dy) {
        return 3;
      } else {
        return -1;
      }
    }
    // Not contained in any quadrant
    else {
      return -1;
    }
  }

  void add(T hitbox) {
    final node = _add(_rootNode, 0, mainBoxSize, hitbox, null);
    _oldPositionByItem[hitbox as ShapeHitbox] = Aabb2.copy(hitbox.aabb);
    _itemAtNode[hitbox as ShapeHitbox] = node;
  }

  _Node<T> _add(_Node<T> node, int depth, Rect box, T value, _Node? parent) {
    // assert(box.containsRect(getBoxOfValue(value)));
    _Node<T> finalNode;
    if (_noChildren(node)) {
      // Insert the value in this node if possible
      if (depth >= maxLevels || node.hitboxes.length < maxObjects) {
        node.hitboxes.add(value);
        finalNode = node;
      }
      // Otherwise, we split and we try again
      else {
        _split(node, box);
        finalNode = _add(node, depth, box, value, parent);
      }
    } else {
      final quadrant = _getQuadrant(box, _getBoxOfValue(value));
      // Add the value in a child if the value is entirely contained in it
      if (quadrant != -1) {
        final children = node.children[quadrant];
        if (children == null) {
          throw 'Invalid index $quadrant';
        }
        finalNode = _add(
          children as _Node<T>,
          depth + 1,
          _computeBox(box, quadrant),
          value,
          node,
        );
      }
      // Otherwise, we add the value in the current node
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

  void _split(_Node node, Rect box) {
    assert(_noChildren(node), 'Only leaves can be split');
    // Create children
    for (var i = 0; i < node.children.length; i++) {
      final newId = ++_nodeLastId;
      node.children[i] = _Node<T>()
        ..parent = node
        ..id = newId;
    }

    // Assign values to children
    final moveValues = <T>[]; // New values for this node
    for (final value in node.hitboxes) {
      final quadrant = _getQuadrant(box, _getBoxOfValue(value as T));
      if (quadrant != -1) {
        final children = node.children[quadrant];
        if (children == null) {
          throw 'Invalid index $quadrant';
        }
        children.hitboxes.add(value);
      } else {
        moveValues.add(value);
      }
    }
    node.hitboxes = moveValues;
  }

  void remove(T hitbox, {bool oldPosition = false}) =>
      _removeFast(hitbox, oldPosition: oldPosition);

  bool _removeFast(T hitbox, {bool oldPosition = false}) {
    final node = _itemAtNode[hitbox];
    if (node == null) {
      throw '${node.toString()} not found';
    } else {
      return node.hitboxes.remove(hitbox);
    }
  }

  void optimize() {
    _tryMergeRecursive(_rootNode);
  }

  void _tryMergeRecursive(_Node node) {
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
      final clear = <ShapeHitbox>[];
      for (final hitbox in node.hitboxes) {
        if (hitbox is ShapeHitbox && hitbox.parent == null) {
          clear.add(hitbox);
        }
      }
      clear.forEach(node.hitboxes.remove);
    }
  }

  Map<int, List<T>> query(T value) => _queryFast(value);

  Map<int, List<T>> _queryFast(T value) {
    final node = _itemAtNode[value as ShapeHitbox];
    var id = -1;
    final values = <T>[];
    if (node == null) {
      throw '${node.toString()} not found';
    } else {
      id = node.id;
      values.addAll(node.hitboxes as List<T>);
      values.addAll(_getChildrenItems(node));
      values.addAll(_getParentItems(node));
    }
    return {id: values};
  }

  List<T> _getChildrenItems(_Node parent) {
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

  List<T> _getParentItems(_Node node) {
    final list = <T>[];
    final parent = node.parent;
    if (parent != null) {
      list.addAll(parent.hitboxes as List<T>);
      list.addAll(_getParentItems(parent));
    }
    return list;
  }

  bool isMoved(T hitbox) {
    final lastPos = _oldPositionByItem[hitbox];
    if (lastPos == null) {
      return true;
    }
    if (lastPos.min == hitbox.aabb.min && lastPos.max == hitbox.aabb.max) {
      return false;
    } else {
      return true;
    }
  }
}
