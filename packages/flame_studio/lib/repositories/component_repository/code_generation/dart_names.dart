import 'package:flame_studio/repositories/repositories.dart';

final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

/// Whether [name] is a valid Dart identifier.
bool isDartIdentifier(String name) => _identifier.hasMatch(name);

/// The name of the class generated for a component called [name]:
/// `player_ship` and `playerShip` become `PlayerShip`.
String dartClassName(String name) {
  return [
    for (final word in name.split('_'))
      if (word.isNotEmpty) word[0].toUpperCase() + word.substring(1),
  ].join();
}

/// The name of the class generated for a root component called [name],
/// with the `$` prefix of generated code: `player_ship` becomes
/// `$PlayerShip`.
///
/// The prefix keeps generated classes from clashing with the classes of
/// the game (or Flame's), which can subclass them.
String dartRootClassName(String name) => '\$${dartClassName(name)}';

/// The name of the class generated for a child component called
/// [childName] of the root component called [rootName]: the `head` of
/// `player_ship` becomes `$PlayerShipHead`.
///
/// Only children that have children of their own, or that load a sprite,
/// get a class.
String dartChildClassName(String rootName, String childName) {
  return '${dartRootClassName(rootName)}${dartClassName(childName)}';
}

/// The name of the getter generated for a child component called [name]:
/// `left_arm` and `LeftArm` become `leftArm`.
String dartMemberName(String name) {
  final className = dartClassName(name);
  if (className.isEmpty) {
    return className;
  }
  return className[0].toLowerCase() + className.substring(1);
}

/// The name, without extension, of the file generated for a component
/// called [name]: `PlayerShip` and `playerShip` become `player_ship`.
String dartFileName(String name) {
  return name
      .replaceAllMapped(
        RegExp('([a-z0-9])([A-Z])'),
        (match) => '${match[1]}_${match[2]}',
      )
      .toLowerCase()
      .split('_')
      .where((word) => word.isNotEmpty)
      .join('_');
}

/// Whether [name] is a Dart keyword, which can't be used as a member name.
bool isDartKeyword(String name) => _keywords.contains(name);

/// The names of the members a generated class inherits from the Flame class
/// of [type]. Getters of children must not use them.
Set<String> flameMemberNames(ComponentType type) {
  return switch (type) {
    ComponentType.rectangle => _rectangleComponentMembers,
    ComponentType.position => _positionComponentMembers,
    ComponentType.circle => _circleComponentMembers,
    ComponentType.polygon => _polygonComponentMembers,
    ComponentType.sprite => _spriteComponentMembers,
    // Hitboxes have no children, so no getters: the members of their shape
    // are enough.
    ComponentType.rectangleHitbox => _rectangleComponentMembers,
    ComponentType.circleHitbox => _circleComponentMembers,
    ComponentType.polygonHitbox => _polygonComponentMembers,
  };
}

const _keywords = {
  // Reserved words.
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue',
  'default', 'do', 'else', 'enum', 'extends', 'false', 'final', 'finally',
  'for', 'if', 'in', 'is', 'new', 'null', 'rethrow', 'return', 'super',
  'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while', 'with',
  // Built-in identifiers and contextual keywords.
  'abstract', 'as', 'async', 'await', 'base', 'covariant', 'deferred',
  'dynamic', 'export', 'extension', 'external', 'factory', 'get', 'hide',
  'implements', 'import', 'interface', 'late', 'library', 'mixin', 'of',
  'on', 'operator', 'part', 'required', 'sealed', 'set', 'show', 'static',
  'sync', 'typedef', 'when', 'yield',
};

/// Public members of Flame's `PositionComponent` (Flame 2.0.0-dev.1),
/// including the inherited ones.
const _positionComponentMembers = {
  'absoluteAngle',
  'absoluteAngleWithoutReflection',
  'absoluteCenter',
  'absolutePosition',
  'absolutePositionOf',
  'absolutePositionOfAnchor',
  'absoluteScale',
  'absoluteScaledSize',
  'absoluteToLocal',
  'absoluteTopLeftPosition',
  'add',
  'addAll',
  'addToParent',
  'afterChildrenRendered',
  'ancestors',
  'anchor',
  'angle',
  'angleTo',
  'center',
  'children',
  'componentsAtLocation',
  'componentsAtPoint',
  'contains',
  'containsLocalPoint',
  'containsPoint',
  'createComponentList',
  'debugColor',
  'debugCoordinatesPrecision',
  'debugMode',
  'debugPaint',
  'debugTextPaint',
  'decorator',
  'descendants',
  'distance',
  'findGame',
  'findParent',
  'findRenderContext',
  'findRootGame',
  'firstChild',
  'flipHorizontally',
  'flipHorizontallyAroundCenter',
  'flipVertically',
  'flipVerticallyAroundCenter',
  'handleHotReload',
  'handleResize',
  'hasChildren',
  'hashCode',
  'height',
  'isFlippedHorizontally',
  'isFlippedVertically',
  'isLoaded',
  'isLoading',
  'isMounted',
  'isMounting',
  'isRemoved',
  'isRemoving',
  'key',
  'lastChild',
  'loadSettled',
  'loaded',
  'localToParent',
  'lookAt',
  'mounted',
  'nativeAngle',
  'noSuchMethod',
  'onChildrenChanged',
  'onGameResize',
  'onHotReload',
  'onLoad',
  'onMount',
  'onParentResize',
  'onRemove',
  'parent',
  'parentToLocal',
  'position',
  'positionOf',
  'positionOfAnchor',
  'priority',
  'propagateToChildren',
  'rebalanceChildren',
  'remove',
  'removeAll',
  'removeFromParent',
  'removeWhere',
  'removed',
  'render',
  'renderChild',
  'renderContext',
  'renderDebugMode',
  'renderTree',
  'renderTreeWithoutDecorator',
  'runtimeType',
  'scale',
  'scaledSize',
  'setByRect',
  'setLoaded',
  'setMounted',
  'setRemoved',
  'size',
  'toAbsoluteRect',
  'toLocal',
  'toRect',
  'toString',
  'topLeftPosition',
  'transform',
  'transformMatrix',
  'update',
  'updateTree',
  'width',
  'x',
  'y',
};

/// Public members of Flame's `RectangleComponent` (Flame 2.0.0-dev.1),
/// including the inherited ones. It adds no public instance members to
/// `PolygonComponent`.
const Set<String> _rectangleComponentMembers = _polygonComponentMembers;

/// Public members of Flame's `PolygonComponent` (Flame 2.0.0-dev.1),
/// including the inherited ones: the `PositionComponent` ones, plus those
/// of `HasPaint` and `ShapeComponent`.
const Set<String> _polygonComponentMembers = {
  ..._positionComponentMembers,
  'deletePaint',
  'getAlpha',
  'getEdge',
  'getOpacity',
  'getPaint',
  'getVertex',
  'globalVertices',
  'hasPaintLayers',
  'hue',
  'isSolid',
  'makeOpaque',
  'makeTransparent',
  'manuallyPositioned',
  'onChanged',
  'opacity',
  'opacityProviderOf',
  'opacityProviderOfList',
  'paint',
  'paintLayers',
  'paintLayersInternal',
  'possibleIntersectionVertices',
  'refreshVertices',
  'renderShape',
  'setAlpha',
  'setColor',
  'setOpacity',
  'setPaint',
  'shrinkToBounds',
  'tint',
  'vertices',
};

/// Public members of Flame's `SpriteComponent` (Flame 2.0.0-dev.1),
/// including the inherited ones: the `PositionComponent` ones, plus those
/// of `HasPaint`, `ImageRetainer` and `RendersSprite`.
const Set<String> _spriteComponentMembers = {
  ..._positionComponentMembers,
  'autoResize',
  'bleed',
  'deletePaint',
  'getAlpha',
  'getOpacity',
  'getPaint',
  'hasPaintLayers',
  'makeOpaque',
  'makeTransparent',
  'opacity',
  'opacityProviderOf',
  'opacityProviderOfList',
  'paint',
  'paintLayers',
  'paintLayersInternal',
  'renderSprite',
  'retainedImages',
  'setAlpha',
  'setColor',
  'setOpacity',
  'setPaint',
  'sprite',
  'tint',
  'updateRetainedImages',
};

/// Public members of Flame's `CircleComponent` (Flame 2.0.0-dev.1),
/// including the inherited ones: the `PositionComponent` ones, plus those
/// of `HasPaint` and `ShapeComponent`.
const Set<String> _circleComponentMembers = {
  ..._positionComponentMembers,
  'deletePaint',
  'getAlpha',
  'getOpacity',
  'getPaint',
  'hasPaintLayers',
  'hue',
  'isSolid',
  'lineSegmentIntersections',
  'makeOpaque',
  'makeTransparent',
  'onChanged',
  'opacity',
  'opacityProviderOf',
  'opacityProviderOfList',
  'paint',
  'paintLayers',
  'paintLayersInternal',
  'radius',
  'renderShape',
  'scaledRadius',
  'setAlpha',
  'setColor',
  'setOpacity',
  'setPaint',
  'tint',
};
