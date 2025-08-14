import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class LayoutComponentExample extends FlameGame with DragCallbacks {
  static const String description = '''
Press the row of buttons after MainAxisAlignment, CrossAxisAlignment,
and Gap. They will update the layout of the example row and column
layouts to reflect the chosen values.
  ''';

  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;

    final defaultSize = Vector2(900, 300);
    final rowDemo = RowComponent(
      size: defaultSize,
      children: createComponentList(),
    );
    final columnDemo = ColumnComponent(
      size: defaultSize,
      children: createComponentList(),
    );

    final mainAxisControls = RowComponent(
      gap: 16,
      children: [
        TextComponent(text: 'MainAxisAlignment:'),
        ...MainAxisAlignment.values.map((mainAxisAlignment) {
          return ButtonComponent(
            button: TextComponent(text: mainAxisAlignment.name),
            onPressed: () {
              rowDemo.mainAxisAlignment = mainAxisAlignment;
              columnDemo.mainAxisAlignment = mainAxisAlignment;
            },
          );
        }),
      ],
    );
    final crossAxisControls = RowComponent(
      gap: 16,
      children: [
        TextComponent(text: 'CrossAxisAlignment:'),
        ...CrossAxisAlignment.values.map((crossAxisAlignment) {
          return ButtonComponent(
            button: TextComponent(text: crossAxisAlignment.name),
            onPressed: () {
              rowDemo.crossAxisAlignment = crossAxisAlignment;
              columnDemo.crossAxisAlignment = crossAxisAlignment;
            },
          );
        }),
      ],
    );
    final gapControls = RowComponent(
      gap: 16,
      children: [
        TextComponent(text: 'Gap:'),
        ...<double>[0, 24, 48].map((gap) {
          return ButtonComponent(
            button: TextComponent(text: 'Gap = $gap'),
            onPressed: () {
              rowDemo.gap = gap;
              columnDemo.gap = gap;
            },
          );
        }),
      ],
    );
    final sizeControls = RowComponent(
      gap: 16,
      children: [
        TextComponent(text: 'Size:'),
        ...[defaultSize, Vector2(1080, 600), null].map((layoutSize) {
          return ButtonComponent(
            button: TextComponent(text: layoutSize.toString()),
            onPressed: () {
              rowDemo.size = layoutSize;
              columnDemo.size = layoutSize;
            },
          );
        }),
      ],
    );
    final paddingControls = RowComponent(
      gap: 16,
      children: [
        TextComponent(text: 'Padding:'),
        ...[
          EdgeInsets.zero,
          const EdgeInsets.all(16),
          const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        ].map((padding) {
          return ButtonComponent(
            button: TextComponent(text: padding.toString()),
            onPressed: () {
              rowDemo.children.query<PaddingComponent>().first.padding =
                  padding;
              columnDemo.children.query<PaddingComponent>().first.padding =
                  padding;
            },
          );
        }),
      ],
    );
    final rootColumnComponent = ColumnComponent(
      position: Vector2(48, 48),
      gap: 24,
      children: [
        TextComponent(
          text:
              // ignore: lines_longer_than_80_chars
              'Because this example deals with sizes a lot, we have made it draggable.',
        ),
        TextBoxComponent(
          boxConfig: TextBoxConfig(maxWidth: defaultSize.x),
          text:
              // ignore: lines_longer_than_80_chars
              'The root of this example is a shrinkWrapped ColumnComponent. Notice how, when you update the size of the examples, the root component also resizes. This is a demonstration of the fact that shrinkWrapped LayoutComponents listen to changes in the sizes of their children.',
        ),
        mainAxisControls,
        crossAxisControls,
        gapControls,
        sizeControls,
        paddingControls,
        rowDemo,
        columnDemo,
      ],
    );
    world.add(
      rootColumnComponent,
    );
  }

  /// This needs to be a method rather than a static list
  /// because each of these components needs to be recreated.
  /// Otherwise, they'll be operated on by reference and re-parented.
  List<Component> createComponentList() {
    return [
      TextComponent(text: 'Some short text'),
      TextComponent(
        text: 'Perhaps a bit longer text',
      ),
      PaddingComponent(
        padding: EdgeInsets.zero,
        child: CircleComponent(
          radius: 48,
          paint: Paint()..color = Colors.blue,
        ),
      ),
    ];
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
