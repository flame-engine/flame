import 'package:flame_studio/repositories/component_repository/code_generation/dart_names.dart';
import 'package:flame_studio/repositories/repositories.dart';

/// Why a name can't be used for a child component, see
/// [ComponentTree.validateChildName].
enum ChildNameError() {
  /// The name is not a valid Dart identifier, or its getter would be a
  /// Dart keyword.
  invalid,

  /// The getter of the child would clash with a member of its parent's
  /// Flame class, such as `size` or `position`.
  reserved,

  /// Another component of the tree already uses the name.
  duplicate,

  /// The class generated for the child would have the same name as a class
  /// generated for another component of the project, see
  /// [ComponentTree.generatedClassNames].
  conflict,
}

/// Navigates and edits the tree formed by a [Component] and its children.
///
/// A node of the tree is addressed by its path: the index of each child to
/// follow from the root. The root itself is the empty path.
extension ComponentTree on Component {
  /// Returns the node at [path].
  ///
  /// Throws a [RangeError] if there is no node at [path].
  Component nodeAt(List<int> path) {
    var node = this;
    for (final index in path) {
      node = node.children[index];
    }
    return node;
  }

  /// Whether there is a node at [path].
  bool hasNodeAt(List<int> path) {
    var node = this;
    for (final index in path) {
      if (index < 0 || index >= node.children.length) {
        return false;
      }
      node = node.children[index];
    }
    return true;
  }

  /// Returns a copy of this tree where the node at [path] is replaced by the
  /// result of [update].
  ///
  /// Throws a [RangeError] if there is no node at [path].
  Component updateNodeAt(
    List<int> path,
    Component Function(Component node) update,
  ) {
    if (path.isEmpty) {
      return update(this);
    }
    final [index, ...rest] = path;
    final children = [...this.children];
    children[index] = children[index].updateNodeAt(rest, update);
    return copyWithChildren(children);
  }

  /// Returns a copy of this tree with [child] added as the last child of the
  /// node at [path].
  ///
  /// Hitboxes ([HitboxComponent]) can't have children, and can't be added
  /// to another hitbox.
  Component addChildAt(List<int> path, Component child) {
    if (nodeAt(path) is HitboxComponent) {
      throw ArgumentError.value(path, 'path', 'Hitboxes cannot have children');
    }
    return updateNodeAt(
      path,
      (node) => node.copyWithChildren([...node.children, child]),
    );
  }

  /// Returns a copy of this tree without the node at [path].
  ///
  /// The root (the empty [path]) cannot be removed.
  Component removeNodeAt(List<int> path) {
    if (path.isEmpty) {
      throw ArgumentError.value(path, 'path', 'The root cannot be removed');
    }
    final parent = path.sublist(0, path.length - 1);
    return updateNodeAt(
      parent,
      (node) => node.copyWithChildren([...node.children]..removeAt(path.last)),
    );
  }

  /// This component followed by all of its descendants, depth first.
  Iterable<Component> get nodes sync* {
    yield this;
    for (final child in children) {
      yield* child.nodes;
    }
  }

  /// The names of the [Palette] colors the nodes of this tree paint with.
  Set<String> get usedPaletteColors {
    return {
      for (final node in nodes)
        if (node case PaintedComponent(
          paint: ComponentPaint(:final String paletteColor),
        ))
          paletteColor,
    };
  }

  /// The asset paths of the images the nodes of this tree draw.
  Set<String> get usedImages {
    return {
      for (final node in nodes)
        if (node case SpritedComponent(
          sprite: ComponentSprite(:final String image),
        ))
          image,
    };
  }

  /// Returns a copy of this tree whose paints have the current value of
  /// their palette color in [palette] as their color (see
  /// [ComponentPaint.resolvedColor]), which is what they draw with.
  Component withPaletteColorsResolved(Palette palette) {
    final node = switch (this) {
      final PaintedComponent painted when painted.paint.paletteColor != null =>
        painted.copyWithPaint(
          painted.paint.copyWith(color: painted.paint.resolvedColor(palette)),
        ),
      final node => node,
    };
    if (children.isEmpty) {
      return node;
    }
    return node.copyWithChildren([
      for (final child in node.children)
        child.withPaletteColorsResolved(palette),
    ]);
  }

  /// The name of the class generated for this component as the root of its
  /// tree, such as `$PlayerShip`.
  String get generatedClassName => dartRootClassName(name);

  /// The names of the classes this component reserves in the generated
  /// code: the class of the root, and the class of every child.
  ///
  /// Only children that have children of their own, or that load a sprite,
  /// get a class, but every child reserves one, so editing a node never
  /// makes its class clash with the classes of another component. Generated
  /// classes are public, so the classes of two components of a project must
  /// not share names, or a library importing both wouldn't compile.
  Set<String> get generatedClassNames {
    return {
      generatedClassName,
      for (final node in nodes.skip(1)) dartChildClassName(name, node.name),
    };
  }

  /// Returns a name for a new [type] node that no node of the tree uses
  /// yet, such as `rectangle1`, and whose class is not one of
  /// [takenClassNames] (see [generatedClassNames]).
  String uniqueChildName(
    ComponentType type, {
    Set<String> takenClassNames = const {},
  }) {
    final names = {for (final node in nodes) dartMemberName(node.name)};
    var index = 1;
    while (names.contains('${type.key}$index') ||
        takenClassNames.contains(
          dartChildClassName(name, '${type.key}$index'),
        )) {
      index++;
    }
    return '${type.key}$index';
  }

  /// Returns why the node at [path] can't be renamed to [name], or `null`
  /// if it can.
  ///
  /// The name of a child becomes the name of its getter in the generated
  /// code, so it must be a valid getter of its parent and unique in the
  /// tree, ignoring the differences the generated code ignores (`left_arm`
  /// and `leftArm` are the same name). Its class must not be one of
  /// [takenClassNames], the [generatedClassNames] of the other components
  /// of the project. The root (the empty [path]) is not a child and can't
  /// be validated.
  ChildNameError? validateChildName(
    List<int> path,
    String name, {
    Set<String> takenClassNames = const {},
  }) {
    if (path.isEmpty) {
      throw ArgumentError.value(path, 'path', 'The root is not a child');
    }
    final getter = dartMemberName(name);
    if (!isDartIdentifier(name) ||
        !isDartIdentifier(getter) ||
        isDartKeyword(getter)) {
      return ChildNameError.invalid;
    }
    final parent = nodeAt(path.sublist(0, path.length - 1));
    if (flameMemberNames(parent.type).contains(getter)) {
      return ChildNameError.reserved;
    }
    final taken = _getterNames(const [], except: path);
    if (taken.contains(getter)) {
      return ChildNameError.duplicate;
    }
    final className = dartChildClassName(this.name, name);
    return takenClassNames.contains(className) ? ChildNameError.conflict : null;
  }

  /// The getter names of this node, at [path], and its descendants, except
  /// the node at [except].
  Iterable<String> _getterNames(
    List<int> path, {
    required List<int> except,
  }) sync* {
    if (!_samePath(path, except)) {
      yield dartMemberName(name);
    }
    for (final (index, child) in children.indexed) {
      yield* child._getterNames([...path, index], except: except);
    }
  }

  static bool _samePath(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
