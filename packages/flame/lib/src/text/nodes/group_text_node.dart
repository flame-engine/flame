import 'package:flame/text.dart';

/// An [InlineTextNode] to group other [InlineTextNode]s.
class GroupTextNode extends InlineTextNode {
  GroupTextNode(this.children);

  final List<InlineTextNode> children;

  @override
  void fillStyles(DocumentStyle stylesheet, InlineTextStyle parentTextStyle) {
    style = parentTextStyle;
    for (final node in children) {
      node.fillStyles(stylesheet, style);
    }
  }

  @override
  TextNodeLayoutBuilder get layoutBuilder => _GroupTextLayoutBuilder(this);
}

class _GroupTextLayoutBuilder extends TextNodeLayoutBuilder {
  _GroupTextLayoutBuilder(this.node);

  final GroupTextNode node;
  int _currentIndex = 0;
  _ChildLayout? _currentChild;

  @override
  bool get isDone => _currentIndex == node.children.length;

  @override
  double get leadingRunWidth {
    var width = 0.0;
    for (final builder in _remainingBuilders()) {
      width += builder.leadingRunWidth;
      if (builder.hasBreakOpportunity) {
        break;
      }
    }
    return width;
  }

  @override
  bool get hasBreakOpportunity {
    return _remainingBuilders().any((builder) => builder.hasBreakOpportunity);
  }

  Iterable<TextNodeLayoutBuilder> _remainingBuilders() sync* {
    for (var i = _currentIndex; i < node.children.length; i++) {
      final inProgress = i == _currentIndex ? _currentChild?.builder : null;
      yield inProgress ?? node.children[i].layoutBuilder;
    }
  }

  @override
  InlineTextElement? layOutNextLine(
    double availableWidth, {
    required bool isStartOfLine,
    double trailingWidth = 0,
  }) {
    assert(!isDone);
    final out = <InlineTextElement>[];
    var usedWidth = 0.0;
    while (true) {
      if (_currentChild?.builder.isDone ?? false) {
        _currentChild = null;
        _currentIndex += 1;
        if (_currentIndex == node.children.length) {
          break;
        }
      }
      final child = _currentChild ??= _ChildLayout(node, _currentIndex);

      final maybeLine = child.builder.layOutNextLine(
        availableWidth - usedWidth,
        isStartOfLine: isStartOfLine && out.isEmpty,
        trailingWidth:
            child.followingRunWidth +
            (child.followingRunReachesEnd ? trailingWidth : 0),
      );
      if (maybeLine == null) {
        break;
      } else {
        assert(maybeLine.metrics.left == 0 && maybeLine.metrics.baseline == 0);
        maybeLine.translate(usedWidth, 0);
        out.add(maybeLine);
        usedWidth += maybeLine.metrics.width;
      }
    }
    if (out.isEmpty) {
      return null;
    } else {
      return GroupTextElement(out);
    }
  }
}

/// The layout state of the child of a group currently being laid out.
class _ChildLayout {
  final TextNodeLayoutBuilder builder;

  /// The width of the run glued (i.e. non-breaking) to the end of this child,
  /// or zero if it is immediately followed by a break.
  final double followingRunWidth;

  /// Whether that run continues past the end of the group, so it also
  /// includes whatever is glued to the end of the group itself.
  final bool followingRunReachesEnd;

  /// Creates the builder for the child at [index] of [group], and measures
  /// the run glued to its end over the children that follow it, up to the
  /// first whitespace. This does not depend on the line, so it is measured
  /// once per child.
  factory _ChildLayout(GroupTextNode group, int index) {
    final builder = group.children[index].layoutBuilder;
    var width = 0.0;
    for (final sibling in group.children.skip(index + 1)) {
      final siblingBuilder = sibling.layoutBuilder;
      width += siblingBuilder.leadingRunWidth;
      if (siblingBuilder.hasBreakOpportunity) {
        return _ChildLayout._(builder, width, followingRunReachesEnd: false);
      }
    }
    return _ChildLayout._(builder, width, followingRunReachesEnd: true);
  }

  const _ChildLayout._(
    this.builder,
    this.followingRunWidth, {
    required this.followingRunReachesEnd,
  });
}
