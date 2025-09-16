import 'dart:async';

import 'package:examples/stories/experimental/layout_component_example_size.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum LayoutComponentExampleLayout { layout1, layout2 }

class LayoutComponentExample2 extends FlameGame with DragCallbacks {
  LayoutComponentExample2({
    required this.direction,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.gap,
    required this.demoSize,
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
              'draggable.',
        ),
        LayoutDemo2(
          direction: direction,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          gap: gap,
          position: Vector2.zero(),
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

class LayoutDemo2 extends LinearLayoutComponent {
  LayoutDemo2({
    required super.direction,
    required super.crossAxisAlignment,
    required super.mainAxisAlignment,
    required super.gap,
    required super.position,
    super.size,
    super.key,
  }) : super(anchor: Anchor.topLeft, priority: 0, children: []);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    addAll(
      createComponentList(
        direction: direction,
      ),
    );
  }

  PaddingComponent? get paddingComponent {
    return descendants().whereType<PaddingComponent>().firstOrNull;
  }

  /// This needs to be a method rather than a static list
  /// because each of these components needs to be recreated.
  /// Otherwise, they'll be operated on by reference and re-parented.
  static List<Component> createComponentList({
    required Direction direction,
  }) {
    return [
      ExpandedComponent(
        child: RectangleComponent(
          paint: Paint()..color = Colors.purple,
        ),
      ),
      LinearLayoutComponent.fromDirection(
        // Basically adopt the opposite direction
        direction == Direction.horizontal
            ? Direction.vertical
            : Direction.horizontal,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextComponent(text: 'test'),
        ],
      ),
    ];
  }
}
