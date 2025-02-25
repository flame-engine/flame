import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/rendering.dart';

enum Direction { horizontal, vertical }

/// Superclass for linear layouts.
/// A re-layout is performed when
///  - a change in this component's children takes place
///  - the [gap] parameter is changed
///  - the [size] parameter is changed
///  - the [mainAxisAlignment] parameter is changed
///  - the [crossAxisAlignment] parameter is changed
///
/// [gap] is ignored when the [mainAxisAlignment] is set to one of:
///  - [MainAxisAlignment.spaceAround]
///  - [MainAxisAlignment.spaceBetween]
///  - [MainAxisAlignment.spaceEvenly]
///
/// Notes:
///  - currently, [CrossAxisAlignment.baseline] is unsupported, and behaves
/// exactly like [CrossAxisAlignment.start].
abstract class LayoutComponent extends PositionComponent {
  LayoutComponent({
    required this.direction,
    required CrossAxisAlignment crossAxisAlignment,
    required MainAxisAlignment mainAxisAlignment,
    required super.position,
    required super.size,
    required double gap,
    required super.children,
  })  : _crossAxisAlignment = crossAxisAlignment,
        _mainAxisAlignment = mainAxisAlignment,
        _gap = gap;
  final Direction direction;
  CrossAxisAlignment _crossAxisAlignment;

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;

  set crossAxisAlignment(CrossAxisAlignment value) {
    _crossAxisAlignment = value;
    layoutChildren();
  }

  MainAxisAlignment _mainAxisAlignment;

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;

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
  set size(Vector2 size) {
    super.size = size;
    layoutChildren();
  }

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    layoutChildren();
  }

  void layoutChildren() {
    _layoutMainAxis();
    _layoutCrossAxis();
  }

  void _layoutMainAxis() {
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

    final int numberOfGaps;
    switch (mainAxisAlignment) {
      case MainAxisAlignment.spaceEvenly:
        numberOfGaps = children.length + 1;
        break;
      case MainAxisAlignment.spaceAround:
        numberOfGaps = children.length;
        break;
      case MainAxisAlignment.spaceBetween:
        numberOfGaps = children.length - 1;
        break;
      default:
        // this should never happen because of
        // the guard at the start of this method.
        throw Exception('Unexpected call to _gapOverride');
    }
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
    final componentList = reverse ? components.reversed : components;
    for (final (index, component) in componentList.indexed) {
      final prevChild = index > 0 ? componentList.elementAt(index - 1) : null;
      final reference = prevChild == null
          // Essentially the same as start, but gap is set.
          ? initialOffset.toVector2()
          // The "end" at any loop other than the first is the previous
          // child's top left position minus the gap.
          : prevChild.topLeftPosition +
              (reverse ? -Vector2.all(gap) : prevChild.size + Vector2.all(gap));
      final positionOffset = reverse ? component.size : Vector2.zero();
      final newPosition = Vector2.zero();
      newPosition[mainAxisVectorIndex] =
          (reference - positionOffset)[mainAxisVectorIndex];
      component.topLeftPosition.setFrom(newPosition);
    }
  }

  void _layoutCrossAxis() {
    final components = children.whereType<PositionComponent>().toList();

    // There is no need to track index because cross axis positioning is
    // not influenced by sibling components.
    for (final component in components) {
      final newPosition = Vector2.copy(component.topLeftPosition);
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
      // the children. Thankfully, only cross-axis.
      if (crossAxisAlignment == CrossAxisAlignment.stretch) {
        final newSize = Vector2.copy(component.size);
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
    return positionChildren.map((c) => c.size[mainAxisVectorIndex]).sum;
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

  /// A helper function for returning the index in the various [Vector2]s like
  /// [position] and [size] to get the corresponding axis.
  int get mainAxisVectorIndex => direction == Direction.horizontal ? 0 : 1;

  /// See documentation for [mainAxisVectorIndex].
  int get crossAxisVectorIndex => direction == Direction.horizontal ? 1 : 0;
}
