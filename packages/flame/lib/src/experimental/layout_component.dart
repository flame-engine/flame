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
///
/// Notes:
///  - Currently, [CrossAxisAlignment.baseline] is unsupported, and behaves
///    exactly like [CrossAxisAlignment.start].
///  - Because [CrossAxisAlignment.stretch] alters the size of the children,
///    and there is no uniform interface for getting the inherent sizes of
///    [PositionComponent]s, using [CrossAxisAlignment.stretch] "permanently"
///    changes the sizes of the children. Subsequent changes to
///    [crossAxisAlignment] will work with the new sizes of the children.
abstract class LayoutComponent extends PositionComponent {
  LayoutComponent({
    required this.direction,
    required CrossAxisAlignment crossAxisAlignment,
    required MainAxisAlignment mainAxisAlignment,
    required double gap,
    required super.position,
    required Vector2? size,
    required super.children,
    super.priority,
  })  : _crossAxisAlignment = crossAxisAlignment,
        _mainAxisAlignment = mainAxisAlignment,
        _gap = gap {
    // use the size setter rather than invoke [layoutChildren] because the
    // latter needs the intent to shrinkwrap pre-set by [_shrinkWrapMode].
    // At the time of construction, [_shrinkWrapMode] only has its default
    // value.
    this.size = size;
  }

  factory LayoutComponent.fromDirection(
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

  /// This size setter is nullable unlike its superclass, to allow this
  /// [LayoutComponent] to shrink-wrap its children. In other words, it sets
  /// the size to [inherentSize]. This setter also records the intent to
  /// shrink-wrap via the [_shrinkWrapMode] property, so that [layoutChildren]
  /// knows whether or not to invoke this setter.
  ///
  /// Internally, this [size] setter should only ever be invoked upon
  /// construction, and inside [layoutChildren] to make it easier to track and
  /// reason about.
  ///
  /// Externally, this [size] setter is designed as an API, so a library user
  /// should feel free to use this.
  @override
  set size(Vector2? newSize) {
    final shrinkWrapMode = newSize == null;
    if (_shrinkWrapMode != shrinkWrapMode) {
      // We only invoke this when [_shrinkWrapMode]'s value is changing.
      // This is so we can avoid accumulation of listeners on the children.
      _setupSizeListeners(_shrinkWrapMode);
    }
    _shrinkWrapMode = shrinkWrapMode;
    // we use [super.size] to benefit from the superclass's notifier mechanisms.
    if (newSize == null) {
      super.size = inherentSize;
    } else {
      super.size = newSize;
    }
    // We might be tempted to use [layoutChildren], but recall that we already
    // have listeners attached to size via [setupSizeListeners].
    _layoutMainAxis();
    _layoutCrossAxis();
  }

  final Direction direction;

  bool _shrinkWrapMode = false;

  /// Attaches or removes size listeners from [positionChildren], depending on
  /// the mode of operation. [_shrinkWrapMode] is a property accessible to this
  /// function, so technically we can access the property directly from within
  /// the function, but because this function is very sensitive to the value of
  /// this property, as a safety measure we are making it explicitly a function
  /// of [shrinkWrapMode].
  ///
  /// Previously, this method also attached or removed a listener on the
  /// component [size] itself, but now that [size] is being overloaded to
  /// signal intent to shrink wrap, the layout methods are invoked directly
  /// from the [size] setter itself.
  void _setupSizeListeners(bool shrinkWrapMode) {
    if (shrinkWrapMode) {
      // In shrink wrap mode, since sizing is bottom-up, the children have the
      // listener and trigger layout.
      for (final child in positionChildren) {
        child.size.addListener(layoutChildren);
      }
    } else {
      // In explicit sizing mode, since sizing is top-down, remove the listeners
      // from the children.
      for (final child in positionChildren) {
        child.size.removeListener(layoutChildren);
      }
    }
  }

  CrossAxisAlignment _crossAxisAlignment;

  CrossAxisAlignment get crossAxisAlignment {
    if (_shrinkWrapMode && _crossAxisAlignment == CrossAxisAlignment.stretch) {
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
    if (_shrinkWrapMode) {
      return MainAxisAlignment.start;
    }
    return _mainAxisAlignment;
  }

  set mainAxisAlignment(MainAxisAlignment value) {
    _mainAxisAlignment = value;
    layoutChildren();
  }

  double _gap;

  /// gap between components
  double get gap => _gap;
  set gap(double gap) {
    _gap = gap;
    layoutChildren();
  }

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    if (child is! PositionComponent) {
      return;
    }
    // setupSizeListeners(), but for a single child
    if (type == ChildrenChangeType.added && _shrinkWrapMode) {
      child.size.addListener(layoutChildren);
    } else {
      child.size.removeListener(layoutChildren);
    }
    layoutChildren();
  }

  /// Sets the size of this [LayoutComponent], then lays out the children
  /// along both main and cross axes.
  void layoutChildren() {
    if (_shrinkWrapMode) {
      size = null;
    }
    _layoutMainAxis();
    _layoutCrossAxis();
  }

  void _layoutMainAxis() {
    final mainAxisVectorIndex = direction.mainAxisVectorIndex;
    final availableSpace = size[mainAxisVectorIndex];
    final unoccupiedSpace = availableSpace - _mainAxisOccupiedSpace;
    final freeSpace = unoccupiedSpace - _gapSpace;
    // Execute gap override. Internally, only does so if applicable.
    _gapOverride(unoccupiedSpace);

    // If the accessor `[]` operator is implemented for Offset,
    // can directly work with Offset rather than Vector2.
    final initialOffsetVector = Vector2.zero();
    initialOffsetVector[mainAxisVectorIndex] = switch (mainAxisAlignment) {
      MainAxisAlignment.spaceEvenly => gap,
      MainAxisAlignment.spaceAround => gap / 2,
      MainAxisAlignment.spaceBetween => 0,
      MainAxisAlignment.start => 0,
      MainAxisAlignment.end => availableSpace,
      MainAxisAlignment.center => freeSpace / 2,
    };
    _layoutMainAxisImpl(
      components: positionChildren,
      initialOffset: initialOffsetVector.toOffset(),
      reverse: mainAxisAlignment == MainAxisAlignment.end,
    );
  }

  /// In cases where the [mainAxisAlignment] is a value where gap overrides
  /// make sense i.e. spaceEvenly, spaceAround, spaceBetween, override the
  /// value of gap based on the expected behavior of those alignments.
  /// Otherwise, no-op.
  void _gapOverride(double freeSpace) {
    final gapOverridingAlignments = {
      MainAxisAlignment.spaceEvenly,
      MainAxisAlignment.spaceAround,
      MainAxisAlignment.spaceBetween,
    };
    if (!gapOverridingAlignments.contains(mainAxisAlignment)) {
      // mainAxisAlignment is not an alignment that can override gaps, so no-op.
      return;
    }

    final numberOfGaps = switch (mainAxisAlignment) {
      MainAxisAlignment.spaceEvenly => children.length + 1,
      MainAxisAlignment.spaceAround => children.length,
      MainAxisAlignment.spaceBetween => children.length - 1,
      _ =>
        // this should never happen because of
        // the guard at the start of this method.
        throw Exception('Unexpected call to _gapOverride'),
    };
    _gap = freeSpace / numberOfGaps;
  }

  void _layoutMainAxisImpl({
    required List<PositionComponent> components,

    /// - Zero when [MainAxisAlignment.start].
    /// - [LayoutComponent.size] when [MainAxisAlignment.end] and
    /// [MainAxisAlignment.spaceBetween]
    /// - Half of free space when [MainAxisAlignment.center]
    /// - [LayoutComponent.gap] when [MainAxisAlignment.spaceEvenly]
    /// - Half of [LayoutComponent.gap] when [MainAxisAlignment.spaceAround]
    Offset initialOffset = Offset.zero,

    /// true if laying out from the end (bottom/right)
    bool reverse = false,
  }) {
    final mainAxisVectorIndex = direction.mainAxisVectorIndex;
    final componentList = reverse ? components.reversed : components;
    for (final (index, component) in componentList.indexed) {
      final previousChild =
          index > 0 ? componentList.elementAt(index - 1) : null;
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
    return positionChildren
        .map((c) => c.size[direction.mainAxisVectorIndex])
        .sum;
  }

  /// The total space along the main axis taken up by the gaps between
  /// the [positionChildren].
  double get _gapSpace {
    return gap * (positionChildren.length - 1);
  }

  /// A helper property to get only the [PositionComponent]s
  /// among the [children].
  List<PositionComponent> get positionChildren =>
      children.whereType<PositionComponent>().toList();

  /// Any positioning done in [layoutChildren] should not affect the
  /// [inherentSize]. This is because all [crossAxisAlignment] transformations
  /// fall within the largestCrossAxisLength, while [mainAxisAlignment] is
  /// entirely ignored in all cases where [inherentSize] is needed.
  /// This means that [inherentSize] should be used either *before* or at the
  /// start of [layoutChildren].
  Vector2 get inherentSize {
    // Used at multiple points, cache to avoid recalculating each invocation
    final positionChildren = this.positionChildren;
    final crossAxisVectorIndex = direction.crossAxisVectorIndex;
    final mainAxisVectorIndex = direction.mainAxisVectorIndex;
    if (positionChildren.isEmpty) {
      return Vector2.zero();
    }
    final largestCrossAxisLength = positionChildren
        .map((component) => component.size[crossAxisVectorIndex])
        .max;
    // This is tricky because it depends on the mainAxisAlignment.
    // This should only apply when mainAxisAlignment is start, center, or end.
    // spaceAround, spaceBetween, and spaceEvenly requires the size as a
    // constraint.
    final cumulativeMainAxisLength = ((positionChildren.length - 1) * gap) +
        positionChildren
            .map((component) => component.size[mainAxisVectorIndex])
            .sum;
    final out = Vector2.zero();
    out[mainAxisVectorIndex] = cumulativeMainAxisLength;
    out[crossAxisVectorIndex] = largestCrossAxisLength;
    return out;
  }
}
