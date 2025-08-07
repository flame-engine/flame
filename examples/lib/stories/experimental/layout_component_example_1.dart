import 'dart:async';

import 'package:examples/stories/experimental/layout_component_example_size.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class LayoutComponentExample1 extends FlameGame with DragCallbacks {
  LayoutComponentExample1({
    required this.direction,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.gap,
    required this.demoSize,
    required this.padding,
    required this.expandedMode,
  });

  static const String description = '''
This example demonstrates the various behaviors of LayoutComponents.
Press the pen button on the floating group of icons on the upper right to see
the various ways you can change this layout.
  ''';

  final Direction direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double gap;
  final LayoutComponentExampleSize demoSize;
  final EdgeInsets padding;
  final bool expandedMode;

  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;

    final rootColumnComponent = ColumnComponent(
      position: Vector2(48, 48),
      gap: 24,
      children: [
        TextComponent(
          text: 'Because this example deals with sizes a lot, we have made it '
              'draggable.',
        ),
        LayoutDemo1(
          direction: direction,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          gap: gap,
          position: Vector2.zero(),
          padding: padding,
          expandedMode: expandedMode,
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

class LayoutDemo1 extends LinearLayoutComponent {
  LayoutDemo1({
    required super.direction,
    required super.crossAxisAlignment,
    required super.mainAxisAlignment,
    required super.gap,
    required super.position,
    required EdgeInsets padding,
    required bool expandedMode,
    super.size,
    super.key,
  })  : _padding = padding,
        _expandedMode = expandedMode,
        super(anchor: Anchor.topLeft, priority: 0, children: []);

  bool _expandedMode = false;

  bool get expandedMode => _expandedMode;

  set expandedMode(bool value) {
    _expandedMode = value;
    removeAll(children.toList());
    addAll(createComponentList(expandedMode: expandedMode, padding: padding));
  }

  EdgeInsets _padding = EdgeInsets.zero;

  EdgeInsets get padding => _padding;

  set padding(EdgeInsets value) {
    _padding = value;
    paddingComponent?.padding = padding;
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    addAll(createComponentList(expandedMode: expandedMode, padding: padding));
  }

  PaddingComponent? get paddingComponent {
    return descendants().whereType<PaddingComponent>().firstOrNull;
    // return children.query<PaddingComponent>().firstOrNull;
  }

  /// This needs to be a method rather than a static list
  /// because each of these components needs to be recreated.
  /// Otherwise, they'll be operated on by reference and re-parented.
  static List<Component> createComponentList({
    required bool expandedMode,
    required EdgeInsets padding,
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
            child: RectangleComponent(
              size: Vector2(96, 96),
              paint: Paint()..color = Colors.blue,
            ),
          ),
        )
      else
        PaddingComponent(
          padding: padding,
          child: RectangleComponent(
            size: Vector2(96, 96),
            paint: Paint()..color = Colors.blue,
          ),
        ),
    ];
  }
}
