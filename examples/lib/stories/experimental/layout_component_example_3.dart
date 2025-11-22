import 'dart:async';

import 'package:examples/stories/experimental/layout_component_example_size.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class LayoutComponentExample3 extends FlameGame with DragCallbacks {
  LayoutComponentExample3({
    required this.demoSize,
  });

  static const String description = '''
When ColumnComponent has a TextBoxComponent as a child, and its 
crossAxisAlignment is stretch, it will also set the maxWidth of the
TextBoxComponent.
  ''';

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
        LayoutDemo3(
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

class LayoutDemo3 extends ColumnComponent {
  LayoutDemo3({
    required super.position,
    super.size,
    super.key,
  }) : super(
         anchor: Anchor.topLeft,
         priority: 0,
         children: [],
         gap: 16,
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.stretch,
       );

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    addAll([
      TextBoxComponent(
        text: sampleText,
      ),
      TextBoxComponent(
        text: sampleText,
      ),
    ]);
  }

  PaddingComponent? get paddingComponent {
    return descendants().whereType<PaddingComponent>().firstOrNull;
  }

  static const sampleText =
      'In a bustling city, a small team of developers set out to create '
      'a mobile game using the Flame engine for Flutter. Their goal was '
      'simple: to create an engaging, easy-to-play game that could reach '
      'a wide audience on both iOS and Android platforms. '
      'After weeks of brainstorming, they decided on a concept: '
      'a fast-paced, endless runner game set in a whimsical, '
      'ever-changing world. They named it "Swift Dash." '
      "Using Flutter's versatility and the Flame engine's "
      'capabilities, the team crafted a game with vibrant graphics, '
      'smooth animations, and responsive controls. '
      'The game featured a character dashing through various landscapes, '
      'dodging obstacles, and collecting points. '
      'As they launched "Swift Dash," the team was anxious but hopeful. '
      'To their delight, the game was well-received. Players loved its '
      'simplicity and charm, and the game quickly gained popularity.';
}
