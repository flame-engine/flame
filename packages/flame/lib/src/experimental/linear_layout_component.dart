import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/rendering.dart';

enum Direction {
  horizontal,
  vertical;

  /// A getter for returning the [LayoutAxis] whose [LayoutAxis.axisIndex] can
  /// be used with [Vector2]s to get the corresponding axis values.
  LayoutAxis get mainAxis =>
      this == Direction.horizontal ? LayoutAxis.x : LayoutAxis.y;

  /// See [mainAxis]
  LayoutAxis get crossAxis =>
      this == Direction.horizontal ? LayoutAxis.y : LayoutAxis.x;

  /// A helper for returning the main axis for [vector], given this direction.
  double mainAxisValue(Vector2 vector) {
    return vector[mainAxis.axisIndex];
  }

  /// A helper for returning the cross axis for [vector], given this direction.
  double crossAxisValue(Vector2 vector) {
    return vector[crossAxis.axisIndex];
  }
}

/// Superclass for linear layouts.
/// A re-layout is performed when
///  - [children] are added or removed
///  - some types of [children] are resized
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
///    from its children via [intrinsicSize]. In this mode, certain layout
///    options become meaningless. The following are the behaviors you should
///    note:
///    - [mainAxisAlignment] acts like [MainAxisAlignment.start], regardless
///      of its original value.
///    - [crossAxisAlignment] will cause all children to have the same length
///      along the cross-axis, equal to the largest child in that axis.
///    - [ExpandedComponent]s no longer expand, and their size is set to their
///      [intrinsicSize], which is simply the size of their respective children.
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
    required super.key,
    required this.direction,
    required CrossAxisAlignment crossAxisAlignment,
    required MainAxisAlignment mainAxisAlignment,
    required double gap,
    required super.size,
    required super.position,
    required super.priority,
    required super.anchor,
    required super.children,
  }) : _crossAxisAlignment = crossAxisAlignment,
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
    ComponentKey? key,
  }) {
    switch (direction) {
      case Direction.horizontal:
        return RowComponent(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          gap: gap,
          size: size,
          position: position,
          children: children,
          key: key,
        );
      case Direction.vertical:
        return ColumnComponent(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          gap: gap,
          size: size,
          position: position,
          children: children,
          key: key,
        );
    }
  }

  final Direction direction;

  CrossAxisAlignment _crossAxisAlignment;

  CrossAxisAlignment get crossAxisAlignment {
    return _crossAxisAlignment;
  }

  set crossAxisAlignment(CrossAxisAlignment value) {
    _crossAxisAlignment = value;
    _layoutCrossAxis();
  }

  MainAxisAlignment _mainAxisAlignment;

  MainAxisAlignment get mainAxisAlignment {
    if (isShrinkWrappedIn(direction.mainAxis)) {
      return MainAxisAlignment.start;
    }
    return _mainAxisAlignment;
  }

  set mainAxisAlignment(MainAxisAlignment value) {
    _mainAxisAlignment = value;
    _layoutMainAxis();
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
    // mainAxisAlignment is not an alignment that can override gaps
    // OR
    // There are [ExpandedComponent]s among the children
    if (!gapOverridingAlignments.contains(mainAxisAlignment) ||
        children.query<ExpandedComponent>().isNotEmpty) {
      return _gap;
    }

    final mainAxisVectorIndex = direction.mainAxis.axisIndex;
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
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    if (child is! PositionComponent) {
      return;
    }

    void childResizeListener() {
      onChildResize(child);
    }

    // A child can be added, and indeed, can be later resized.
    if (type == ChildrenChangeType.added && child is! ExpandedComponent) {
      child.size.addListener(childResizeListener);
    } else {
      child.size.removeListener(childResizeListener);
    }
    childResizeListener();
  }

  void onChildResize(PositionComponent child) {
    resetSize();
    if (child is! LayoutComponent) {
      layoutChildren();
      return;
    }
    if (child.isShrinkWrappedIn(direction.mainAxis)) {
      _layoutMainAxis();
    }
    if (child.isShrinkWrappedIn(direction.crossAxis)) {
      _layoutCrossAxis();
    }
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

  /// Lays out the children along both main and cross axes.
  @override
  void layoutChildren() {
    _layoutMainAxis();
    _layoutCrossAxis();
  }

  void _layoutMainAxis() {
    final mainAxisVectorIndex = direction.mainAxis.axisIndex;
    final availableSpace = size[mainAxisVectorIndex];
    final nonExpandingOccupiedSpace = positionChildren.fold<double>(
      0.0,
      (sum, child) => child is ExpandedComponent
          ? sum
          : sum + child.size[mainAxisVectorIndex],
    );
    final gapSpace = numberOfGaps * gap;

    _mainAxisSizing(
      components: positionChildren,
      direction: direction,
      freeSpace: availableSpace - nonExpandingOccupiedSpace - gapSpace,
    );

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
  void _mainAxisSizing({
    required List<PositionComponent> components,
    required Direction direction,
    required double freeSpace,
  }) {
    final expandedComponents = components.whereType<ExpandedComponent>();
    // Abort if:
    // Shrink-wrapped (because meaningless to do any main axis calculation)
    // OR, There isn't any free space to expand
    // OR, There are no expanded components to grow
    if (isShrinkWrappedIn(direction.mainAxis) ||
        freeSpace <= 0 ||
        expandedComponents.isEmpty) {
      return;
    }

    final spacePerExpandedComponent = freeSpace / expandedComponents.length;
    for (final expandedComponent in expandedComponents) {
      final layoutAxisLength = switch (direction.mainAxis) {
        LayoutAxis.x => expandedComponent.layoutSizeX,
        LayoutAxis.y => expandedComponent.layoutSizeY,
      };
      if (layoutAxisLength != spacePerExpandedComponent) {
        expandedComponent.setLayoutAxisLength(
          direction.mainAxis,
          spacePerExpandedComponent,
        );
      }
    }
  }

  /// Positions [components] linearly starting from [initialOffset], spaced
  /// [gap] apart, along a [direction].
  void _mainAxisPositioning({
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

    /// true if laying out from the end (bottom/right)
    bool reverse = false,
  }) {
    final mainAxisVectorIndex = direction.mainAxis.axisIndex;
    final componentList = reverse ? components.reversed : components;
    for (final (index, component) in componentList.indexed) {
      final previousChild = index > 0
          ? componentList.elementAt(index - 1)
          : null;
      final reference = previousChild == null
          // Essentially the same as start, but gap is set.
          ? initialOffset.toVector2()
          // The "end" at any loop other than the first is the previous
          // child's top left position minus the gap.
          : previousChild.topLeftPosition +
                (reverse
                    ? -Vector2.all(gap)
                    : previousChild.size + Vector2.all(gap));
      final positionOffset = reverse ? component.size : Vector2.zero();
      final newPosition = Vector2.zero();
      newPosition[mainAxisVectorIndex] =
          (reference - positionOffset)[mainAxisVectorIndex];
      component.topLeftPosition.setFrom(newPosition);
    }
  }

  void _layoutCrossAxis() {
    final crossAxisVectorIndex = direction.crossAxis.axisIndex;
    final positionChildren = this.positionChildren;
    final newPosition = Vector2.zero();
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
    }
    _crossAxisSizing(
      components: positionChildren,
      crossAxisAlignment: crossAxisAlignment,
      direction: direction,
      crossAxisLength: size[crossAxisVectorIndex],
    );
  }

  void _crossAxisSizing({
    required List<PositionComponent> components,
    required CrossAxisAlignment crossAxisAlignment,
    required Direction direction,
    required double crossAxisLength,
  }) {
    final crossAxisVectorIndex = direction.crossAxis.axisIndex;
    for (final component in components) {
      if (crossAxisAlignment != CrossAxisAlignment.stretch) {
        continue;
      }
      if (component is LayoutComponent) {
        final layoutAxisLength = switch (direction.crossAxis) {
          LayoutAxis.x => component.layoutSizeX,
          LayoutAxis.y => component.layoutSizeY,
        };
        // Don't set value if the value is already correct.
        if (layoutAxisLength != crossAxisLength) {
          component.setLayoutAxisLength(
            direction.crossAxis,
            crossAxisLength,
          );
        }
      } else {
        // Don't set value if the value is already correct.
        if (component.size[crossAxisVectorIndex] != crossAxisLength) {
          component.size[crossAxisVectorIndex] = crossAxisLength;
        }

        if (direction == Direction.vertical &&
            component is TextBoxComponent &&
            component.boxConfig.maxWidth != crossAxisLength) {
          final originalBoxConfig = component.boxConfig;
          component.boxConfig = originalBoxConfig.copyWith(
            maxWidth: crossAxisLength,
          );
        }
      }
    }
  }

  /// The total space along the main axis occupied by the [positionChildren]
  /// without the [gap]s. This is so named because we expect to
  /// implement crossAxisOccupiedSpace for shrink wrapping.
  double get _mainAxisOccupiedSpace {
    return positionChildren.fold(0.0, (sum, child) {
      // Because ExpandedComponent size can be their expanded state
      // and thus the occupied space will be inflated.
      final mainAxisLength = child is ExpandedComponent
          ? child.intrinsicSize[direction.mainAxis.axisIndex]
          : child.size[direction.mainAxis.axisIndex];
      return sum + mainAxisLength;
    });
  }

  /// Any positioning done in [layoutChildren] should not affect the
  /// [intrinsicSize]. This is because all [crossAxisAlignment] transformations
  /// fall within the largestCrossAxisLength, while [mainAxisAlignment] is
  /// entirely ignored in all cases where [intrinsicSize] is needed.
  /// This means that [intrinsicSize] should be used either *before* or at the
  /// start of [layoutChildren].
  @override
  Vector2 get intrinsicSize {
    final positionChildren = this.positionChildren;
    final crossAxisVectorIndex = direction.crossAxis.axisIndex;
    final mainAxisVectorIndex = direction.mainAxis.axisIndex;
    if (positionChildren.isEmpty) {
      return Vector2.zero();
    }
    final largestCrossAxisLength = positionChildren.fold(0.0, (largest, child) {
      final crossAxisLength = child is ExpandedComponent
          ? child.intrinsicSize[crossAxisVectorIndex]
          : child.size[crossAxisVectorIndex];
      return max(largest, crossAxisLength);
    });
    // This is tricky because it depends on the mainAxisAlignment.
    // This should only apply when mainAxisAlignment is start, center, or end.
    // spaceAround, spaceBetween, and spaceEvenly requires the size as a
    // constraint.
    final cumulativeMainAxisLength =
        ((positionChildren.length - 1) * gap) +
        positionChildren.fold(0.0, (sum, child) {
          final mainAxisLength = child is ExpandedComponent
              ? child.intrinsicSize[mainAxisVectorIndex]
              : child.size[mainAxisVectorIndex];
          return sum + mainAxisLength;
        });
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
