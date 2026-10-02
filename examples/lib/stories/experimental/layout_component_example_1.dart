import 'dart:async';

import 'package:examples/stories/experimental/layout_component_example_size.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

class LayoutComponentExample1({
  required final Direction direction,
  required final MainAxisAlignment mainAxisAlignment,
  required final CrossAxisAlignment crossAxisAlignment,
  required final double gap,
  required final LayoutComponentExampleSize demoSize,
  required final EdgeInsets padding,
  required final bool expandedMode,
  required final bool paddingInflateChild,
}) extends FlameGame with DragCallbacks {
  static const String description = '''
This example demonstrates the various behaviors of LayoutComponents.
Press the pen button on the floating group of icons on the upper right to see
the various ways you can change this layout.
  ''';

  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;

    final rootColumnComponent = ColumnComponent(
      position: Vector2(48, 48),
      gap: 24,
      children: [
        TextComponent(
          text:
              'Because this example deals with sizes a lot, we have made it '
              'draggable. Note that the blue square has a PaddingComponent '
              'around it.',
        ),
        LayoutDemo1(
          direction: direction,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          gap: gap,
          position: Vector2.zero(),
          padding: padding,
          expandedMode: expandedMode,
          paddingInflateChild: paddingInflateChild,
          size: demoSize.toVector2(),
        ),
      ],
    );
    world.add(
      rootColumnComponent,
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    camera.viewfinder.position -= event.localDelta;
  }

  @override
  // This is intentional for this example, so the user can see the bounding
  // boxes without us having to render RectangleComponents.
  bool get debugMode => true;
}

class LayoutDemo1({
  required super.direction,
  required super.crossAxisAlignment,
  required super.mainAxisAlignment,
  required super.gap,
  required super.position,
  required var EdgeInsets _padding,
  required var bool _expandedMode,
  required final bool paddingInflateChild,
  super.size,
  super.key,
}) extends LinearLayoutComponent {
  this : super(anchor: Anchor.topLeft, priority: 0, children: []);

  bool get expandedMode => _expandedMode;

  set expandedMode(bool value) {
    _expandedMode = value;
    removeAll(children.toList());
    addAll(
      createLayoutChildren(
        expandedMode: expandedMode,
        padding: padding,
        inflateChild: paddingInflateChild,
      ),
    );
  }

  EdgeInsets get padding => _padding;

  set padding(EdgeInsets value) {
    _padding = value;
    paddingComponent?.padding = padding;
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    addAll(
      createLayoutChildren(
        expandedMode: expandedMode,
        padding: padding,
        inflateChild: paddingInflateChild,
      ),
    );
  }

  PaddingComponent? get paddingComponent {
    return descendants().whereType<PaddingComponent>().firstOrNull;
  }

  /// This needs to be a method rather than a static list
  /// because each of these components needs to be recreated.
  /// Otherwise, they'll be operated on by reference and re-parented.
  static List<Component> createLayoutChildren({
    required bool expandedMode,
    required EdgeInsets padding,
    required bool inflateChild,
  }) {
    return [
      TextComponent(text: 'Some short text'),
      if (expandedMode)
        ExpandedComponent(
          child: RectangleComponent(
            size: Vector2(100, 70),
            paint: Paint()..color = Colors.amber,
          ),
        )
      else
        RectangleComponent(
          size: Vector2(100, 70),
          paint: Paint()..color = Colors.amber,
        ),
      if (expandedMode)
        ExpandedComponent(
          child: PaddingComponent(
            padding: padding,
            inflateChild: inflateChild,
            child: RectangleComponent(
              size: Vector2(96, 96),
              paint: Paint()..color = Colors.blue,
            ),
          ),
        )
      else
        PaddingComponent(
          padding: padding,
          inflateChild: inflateChild,
          child: RectangleComponent(
            size: Vector2(96, 96),
            paint: Paint()..color = Colors.blue,
          ),
        ),
    ];
  }
}
