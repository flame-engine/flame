import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/rendering.dart';

enum Direction { horizontal, vertical }

/// Superclass for linear layouts.
/// Depending on the direction,
/// A relayout is performed when
///  - a change in this component's children takes place
///  - the [gap] parameter is changed
///  - the [size] parameter is changed
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
    final components = children.whereType<PositionComponent>().toList();

    final availableSpace = size[_vectorMainAxisIndex];
    final totalSizeOfComponents =
        components.map((c) => c.size[_vectorMainAxisIndex]).sum;
    final occupiedSpace = availableSpace - totalSizeOfComponents;
    final gapSpace = gap * (components.length - 1);

    // Execute gap override. Internally, only does so if applicable.
    _gapOverride(occupiedSpace);

    // If the accessor `[]` operator is implemented for Offset,
    // can directly workk with Offset rather than Vector2.
    final initialOffsetVector = Vector2.zero();
    initialOffsetVector[_vectorMainAxisIndex] = switch (mainAxisAlignment) {
      MainAxisAlignment.spaceEvenly => gap,
      MainAxisAlignment.spaceAround => gap / 2,
      MainAxisAlignment.spaceBetween => 0,
      MainAxisAlignment.start => 0,
      MainAxisAlignment.end => size[_vectorMainAxisIndex],
      MainAxisAlignment.center => (occupiedSpace - gapSpace) / 2,
    };
    _layoutMainAxisImpl(
      components: components,
      initialOffset: initialOffsetVector.toOffset(),
      reverse: mainAxisAlignment == MainAxisAlignment.end,
    );
  }

  /// In cases where the [mainAxisAlignment] is a value where gap overrides
  /// make sense i.e. spaceEvenly, spaceAround, spaceBetween, override the
  /// value of gap based on the expected behavior of those alignments.
  /// Otherwise, no-op.
  void _gapOverride(double occupiedSpace) {
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
    _gap = occupiedSpace / numberOfGaps;
  }

  void _layoutMainAxisImpl({
    required List<PositionComponent> components,

    /// - Zero when [MainAxisAlignment.start].
    /// - [LayoutComponent.size] when [MainAxisAlignment.end] and
    /// [MainAxisAlignment.spaceBetween]
    /// - Half of free space when [MainAxisAlignment.center]
    /// - [LayoutComponent.gap] when [MainAxisAlignment.spaceEvenly]
    /// - Half of [LayoutComponent.gap] when [MainAxisAlignment.spaceAround]
    ///
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
      newPosition[_vectorMainAxisIndex] =
          (reference - positionOffset)[_vectorMainAxisIndex];
      component.topLeftPosition.setFrom(newPosition);
    }
  }

  void _layoutCrossAxis() {
    final components = children.whereType<PositionComponent>().toList();

    // There is no need to track index because cross axis positioning is
    // not influenced by sibling components.
    for (final component in components) {
      final newPosition = Vector2.copy(component.topLeftPosition);
      final crossAxisLength = size[_vectorCrossAxisIndex];
      final componentCrossAxisLength = component.size[_vectorCrossAxisIndex];
      newPosition[_vectorCrossAxisIndex] = switch (crossAxisAlignment) {
        CrossAxisAlignment.start => 0,
        CrossAxisAlignment.end => crossAxisLength - componentCrossAxisLength,
        CrossAxisAlignment.center =>
          (crossAxisLength - componentCrossAxisLength) / 2,
        CrossAxisAlignment.stretch => 0,
        CrossAxisAlignment.baseline => 0,
      };
      component.topLeftPosition.setFrom(newPosition);
    }
  }

  /// Does not automatically update [size]. This is a convenience method for
  /// setting the size of a component after the fact.
  Vector2 inherentSize() {
    final components = children.whereType<PositionComponent>().toList();
    final largestCrossAxisLength = components
        .map((component) => component.size[_vectorCrossAxisIndex])
        .max;
    // This is tricky because it depends on the mainAxisAlignment.
    // This should only apply when mainAxisAlignment is start, center, or end.
    // spaceAround, spaceBetween, and spaceEvenly requires the size as a
    // constraint.
    final cumulativeMainAxisLength = ((components.length - 1) * gap) +
        components.map((component) => component.size[_vectorMainAxisIndex]).sum;
    final out = Vector2.zero();
    out[_vectorMainAxisIndex] = cumulativeMainAxisLength;
    out[_vectorCrossAxisIndex] = largestCrossAxisLength;
    return out;
  }

  int get _vectorMainAxisIndex => direction == Direction.horizontal ? 0 : 1;
  int get _vectorCrossAxisIndex => direction == Direction.horizontal ? 1 : 0;
}
