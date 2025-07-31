import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/rendering.dart';

enum Direction {
  horizontal,
  vertical;

  /// A helper function for returning the index in the various [Vector2]s like
  /// position and size to get the corresponding axis.
  int get mainAxisVectorIndex => this == Direction.horizontal ? 0 : 1;

  /// See documentation for [mainAxisVectorIndex].
  int get crossAxisVectorIndex => this == Direction.horizontal ? 1 : 0;

  /// A helper for returning the main axis for [vector], given this direction.
  double mainAxis(Vector2 vector) {
    return vector[mainAxisVectorIndex];
  }

  /// A helper for returning the cross axis for [vector], given this direction.
  double crossAxis(Vector2 vector) {
    return vector[crossAxisVectorIndex];
  }
}

/// Superclass for linear layouts.
/// A re-layout is performed when
///  - a change in this component's children takes place
///  - the [gap] parameter is changed
///  - the [size] parameter is changed
///  - the [mainAxisAlignment] parameter is changed
///  - the [crossAxisAlignment] parameter is changed
///
/// Property interactions and gotchas
///  - [gap] is ignored when the [mainAxisAlignment] is set to one of:
///    - [MainAxisAlignment.spaceAround]
///    - [MainAxisAlignment.spaceBetween]
///    - [MainAxisAlignment.spaceEvenly]
///  - [size] can be set to null to activate shrink-wrap mode.
///    Instead of top-down sizing and layout, LayoutComponent derives its size
///    from its children via [inherentSize]. In this mode, certain layout
///    options become meaningless. The following are the behaviors you should
///    note:
///    - [mainAxisAlignment] acts like [MainAxisAlignment.start], regardless
///      of its original value.
///    - [crossAxisAlignment] acts like [CrossAxisAlignment.start], only if
///      its value is [CrossAxisAlignment.stretch].
///    - [ExpandedComponent]s no longer expand, and their size is set to their
///      [inherentSize], which is simply the size of their respective children.
///  - The existence of an [ExpandedComponent] among the [children]
///    automatically disables [MainAxisAlignment.spaceAround],
///    [MainAxisAlignment.spaceBetween], and [MainAxisAlignment.spaceEvenly],
///    and inter-child spacing will be fully dictated by [gap]. This is because
///    [ExpandedComponent]s expand to fill the available space.
///
/// Notes:
///  - Currently, [CrossAxisAlignment.baseline] is unsupported, and behaves
///    exactly like [CrossAxisAlignment.start].
///  - Because [CrossAxisAlignment.stretch] alters the size of the children,
///    and there is no uniform interface for getting the inherent sizes of
///    [PositionComponent]s, using [CrossAxisAlignment.stretch] "permanently"
///    changes the sizes of the children. Subsequent changes to
///    [crossAxisAlignment] will work with the new sizes of the children.
abstract class LinearLayoutComponent extends LayoutComponent {
  LinearLayoutComponent({
    required this.direction,
    required CrossAxisAlignment crossAxisAlignment,
    required MainAxisAlignment mainAxisAlignment,
    required double gap,
    required super.position,
    required super.size,
    required super.priority,
    required super.anchor,
    required super.children,
  })  : _crossAxisAlignment = crossAxisAlignment,
        _mainAxisAlignment = mainAxisAlignment,
        _gap = gap;

  factory LinearLayoutComponent.fromDirection(
    Direction direction, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    double gap = 0.0,
    Vector2? position,
    Vector2? size,
    Iterable<Component> children = const [],
  }) {
    switch (direction) {
      case Direction.horizontal:
        return RowComponent(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          gap: gap,
          position: position,
          size: size,
          children: children,
        );
      case Direction.vertical:
        return ColumnComponent(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          gap: gap,
          position: position,
          size: size,
          children: children,
        );
    }
  }

  final Direction direction;

  CrossAxisAlignment _crossAxisAlignment;

  CrossAxisAlignment get crossAxisAlignment {
    if (shrinkWrapMode && _crossAxisAlignment == CrossAxisAlignment.stretch) {
      return CrossAxisAlignment.start;
    }
    return _crossAxisAlignment;
  }

  set crossAxisAlignment(CrossAxisAlignment value) {
    _crossAxisAlignment = value;
    layoutChildren();
  }

  MainAxisAlignment _mainAxisAlignment;

  MainAxisAlignment get mainAxisAlignment {
    if (shrinkWrapMode) {
      return MainAxisAlignment.start;
    }
    return _mainAxisAlignment;
  }

  set mainAxisAlignment(MainAxisAlignment value) {
    _mainAxisAlignment = value;
    layoutChildren();
  }

  /// This reflects the value set explicitly and naively, without considering
  /// the various values of [mainAxisAlignment].
  double _gap;

  /// The gap between components, that will actually be used for positioning.
  /// If one or more [ExpandedComponent]s exist among the [children], or if
  /// [mainAxisAlignment] is not a member of [gapOverridingAlignments], then
  /// this getter simplifies to [_gap].
  ///
  /// Otherwise, returns the value of gap based on the expected behavior of
  /// [mainAxisAlignment].
  double get gap {
    if ( // mainAxisAlignment is not an alignment that can override gaps
        !gapOverridingAlignments.contains(mainAxisAlignment) ||
            // There are [ExpandedComponent]s among the children
            children.query<ExpandedComponent>().isNotEmpty) {
      return _gap;
    }

    final mainAxisVectorIndex = direction.mainAxisVectorIndex;
    final availableSpace = size[mainAxisVectorIndex];
    final unoccupiedSpace = availableSpace - _mainAxisOccupiedSpace;
    final numberOfGaps = switch (mainAxisAlignment) {
      MainAxisAlignment.spaceEvenly => children.length + 1,
      MainAxisAlignment.spaceAround => children.length,
      MainAxisAlignment.spaceBetween => children.length - 1,
      _ =>
        // this should never happen because of
        // the guard at the start of this method.
        throw Exception('Unexpected call to _gapOverride'),
    };
    return unoccupiedSpace / numberOfGaps;
  }

  set gap(double newGap) {
    _gap = newGap;
    layoutChildren();
  }

  int get numberOfGaps {
    return switch (mainAxisAlignment) {
      MainAxisAlignment.spaceEvenly => children.length + 1,
      MainAxisAlignment.spaceAround => children.length,
      MainAxisAlignment.spaceBetween => children.length - 1,
      _ => children.length - 1,
    };
  }

  @override
  void onMount() {
    super.onMount();
    size.addListener(layoutChildren);
  }

  @override
  void onRemove() {
    size.removeListener(layoutChildren);
  }

  /// Sets the size of this [LinearLayoutComponent], then lays out the children
  /// along both main and cross axes.
  @override
  void layoutChildren() {
    super.layoutChildren();
    _layoutMainAxis();
    _layoutCrossAxis();
  }

  void _layoutMainAxis() {
    final mainAxisVectorIndex = direction.mainAxisVectorIndex;
    final availableSpace = size[mainAxisVectorIndex];
    final nonExpandingOccupiedSpace = positionChildren
        .where((child) => child is! ExpandedComponent)
        .map((child) => child.size[mainAxisVectorIndex])
        .sum;
    final gapSpace = numberOfGaps * gap;

    if (!shrinkWrapMode) {
      _mainAxisSizing(
        components: positionChildren,
        direction: direction,
        freeSpace: availableSpace - nonExpandingOccupiedSpace - gapSpace,
      );
    }
    final unoccupiedSpace = availableSpace - _mainAxisOccupiedSpace;
    final freeSpace = unoccupiedSpace - gapSpace;

    // If the accessor `[]` operator is implemented for Offset,
    // can directly work with Offset rather than Vector2.
    final initialOffsetVector = Vector2.zero();
    initialOffsetVector[mainAxisVectorIndex] = switch (mainAxisAlignment) {
      MainAxisAlignment.spaceEvenly => gap,
      MainAxisAlignment.spaceAround => gap / 2,
      MainAxisAlignment.spaceBetween => 0,
      MainAxisAlignment.start => 0,
      MainAxisAlignment.end => freeSpace,
      MainAxisAlignment.center => freeSpace / 2,
    };
    _mainAxisPositioning(
      components: positionChildren,
      gap: gap,
      direction: direction,
      initialOffset: initialOffsetVector.toOffset(),
    );
  }

  /// Expands any [ExpandedComponent] found among [components] to maximize,
  /// between themselves, the [freeSpace] available along a [direction].
  static void _mainAxisSizing({
    required List<PositionComponent> components,
    required Direction direction,
    required double freeSpace,
  }) {
    if (freeSpace <= 0) {
      // There isn't actual any free space to expand or whatnot, sizing is
      // standard.
      return;
    }
    final expandedComponents = components.whereType<ExpandedComponent>();
    if (expandedComponents.isEmpty) {
      // There's actually no reason to perform any main axis sizing.
      return;
    }

    final spacePerExpandedComponent = freeSpace / expandedComponents.length;
    for (final expandedComponent in expandedComponents) {
      final newSize = Vector2.copy(expandedComponent.inherentSize);
      newSize[direction.mainAxisVectorIndex] = spacePerExpandedComponent;
      expandedComponent.size.setFrom(newSize);
    }
  }

  /// Positions [components] linearly starting from [initialOffset], spaced
  /// [gap] apart, along a [direction].
  static void _mainAxisPositioning({
    required List<PositionComponent> components,

    /// The gap between [components]
    required double gap,
    required Direction direction,

    /// - Zero when [MainAxisAlignment.start] and
    ///   [MainAxisAlignment.spaceBetween]
    /// - [LinearLayoutComponent.size] when [MainAxisAlignment.end]
    /// - Half of free space when [MainAxisAlignment.center]
    /// - [LinearLayoutComponent.gap] when [MainAxisAlignment.spaceEvenly]
    /// - Half of [LinearLayoutComponent.gap] when
    ///   [MainAxisAlignment.spaceAround]
    required Offset initialOffset,
  }) {
    final mainAxisVectorIndex = direction.mainAxisVectorIndex;
    PositionComponent? previousChild;
    for (final component in components) {
      late final Vector2 reference;
      if (previousChild == null) {
        reference = initialOffset.toVector2();
      } else {
        final previousChildSize = (previousChild is ExpandedComponent)
            ? previousChild.inherentSize
            : previousChild.size;
        reference = previousChild.topLeftPosition +
            previousChildSize +
            Vector2.all(gap);
      }
      final newPosition = Vector2.zero();
      // We never work with a crossAxisVectorIndex because we're laying out only
      // the main axis.
      newPosition[mainAxisVectorIndex] = reference[mainAxisVectorIndex];
      component.topLeftPosition.setFrom(newPosition);
      previousChild = component;
    }
  }

  void _layoutCrossAxis() {
    final crossAxisVectorIndex = direction.crossAxisVectorIndex;
    final positionChildren = this.positionChildren;
    final newPosition = Vector2.zero();
    final newSize = Vector2.zero();
    // There is no need to track index because cross axis positioning is
    // not influenced by sibling components.
    for (final component in positionChildren) {
      newPosition.setFrom(component.topLeftPosition);
      final crossAxisLength = size[crossAxisVectorIndex];
      final componentCrossAxisLength = component.size[crossAxisVectorIndex];
      newPosition[crossAxisVectorIndex] = switch (crossAxisAlignment) {
        CrossAxisAlignment.start => 0,
        CrossAxisAlignment.end => crossAxisLength - componentCrossAxisLength,
        CrossAxisAlignment.center =>
          (crossAxisLength - componentCrossAxisLength) / 2,
        CrossAxisAlignment.stretch => 0,
        CrossAxisAlignment.baseline => 0,
      };
      component.topLeftPosition.setFrom(newPosition);

      // Stretch is the only CrossAxisAlignment that involves resizing
      if (crossAxisAlignment == CrossAxisAlignment.stretch) {
        newSize.setFrom(component.size);
        newSize[crossAxisVectorIndex] = size[crossAxisVectorIndex];
        // Don't use setFrom because children might have their own resizing
        // logic, such as a nested LayoutComponent.
        component.size = newSize;
      }
    }
  }

  /// The total space along the main axis occupied by the [positionChildren]
  /// without the [gap]s. This is so named because we expect to
  /// implement crossAxisOccupiedSpace for shrink wrapping.
  double get _mainAxisOccupiedSpace {
    return positionChildren.map((child) {
      if (child is ExpandedComponent) {
        // Because ExpandedComponent size can be their expanded state
        // and thus the occupied space will be inflated.
        return child.inherentSize[direction.mainAxisVectorIndex];
      }
      return child.size[direction.mainAxisVectorIndex];
    }).sum;
  }

  /// Any positioning done in [layoutChildren] should not affect the
  /// [inherentSize]. This is because all [crossAxisAlignment] transformations
  /// fall within the largestCrossAxisLength, while [mainAxisAlignment] is
  /// entirely ignored in all cases where [inherentSize] is needed.
  /// This means that [inherentSize] should be used either *before* or at the
  /// start of [layoutChildren].
  @override
  Vector2 get inherentSize {
    final positionChildren = this.positionChildren;
    final crossAxisVectorIndex = direction.crossAxisVectorIndex;
    final mainAxisVectorIndex = direction.mainAxisVectorIndex;
    if (positionChildren.isEmpty) {
      return Vector2.zero();
    }
    final largestCrossAxisLength = positionChildren.map((component) {
      if (component is ExpandedComponent) {
        return component.inherentSize[crossAxisVectorIndex];
      } else {
        return component.size[crossAxisVectorIndex];
      }
    }).max;
    // This is tricky because it depends on the mainAxisAlignment.
    // This should only apply when mainAxisAlignment is start, center, or end.
    // spaceAround, spaceBetween, and spaceEvenly requires the size as a
    // constraint.
    final cumulativeMainAxisLength = ((positionChildren.length - 1) * gap) +
        positionChildren.map((component) {
          if (component is ExpandedComponent) {
            return component.inherentSize[mainAxisVectorIndex];
          } else {
            return component.size[mainAxisVectorIndex];
          }
        }).sum;
    final out = Vector2.zero();
    out[mainAxisVectorIndex] = cumulativeMainAxisLength;
    out[crossAxisVectorIndex] = largestCrossAxisLength;
    return out;
  }

  static const gapOverridingAlignments = {
    MainAxisAlignment.spaceEvenly,
    MainAxisAlignment.spaceAround,
    MainAxisAlignment.spaceBetween,
  };
}
