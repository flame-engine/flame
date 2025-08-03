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
    final rowDemo = LayoutDemo(
      key: ComponentKey.named('row_demo'),
      direction: Direction.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      gap: 0,
      position: Vector2.zero(),
      size: NullableVector2.fromVector2(defaultSize),
    );
    final columnDemo = LayoutDemo(
      key: ComponentKey.named('column_demo'),
      direction: Direction.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      gap: 0,
      position: Vector2.zero(),
      size: NullableVector2.fromVector2(defaultSize),
    );

    final demos = [rowDemo, columnDemo];

    final mainAxisControls = RowComponent(
      gap: 16,
      children: [
        TextComponent(text: 'MainAxisAlignment:'),
        ...MainAxisAlignment.values.map((mainAxisAlignment) {
          return ButtonComponent(
            button: TextComponent(text: mainAxisAlignment.name),
            onPressed: () {
              demos.forEach(
                (demo) => demo.mainAxisAlignment = mainAxisAlignment,
              );
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
              demos.forEach(
                (demo) => demo.crossAxisAlignment = crossAxisAlignment,
              );
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
              demos.forEach(
                (demo) => demo.gap = gap,
              );
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
              demos.forEach(
                (demo) {
                  demo.layoutSize = NullableVector2.fromVector2(layoutSize);
                },
              );
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
              demos.forEach(
                (demo) => demo.padding = padding,
              );
            },
          );
        }),
      ],
    );
    final wrapperControls = RowComponent(
      gap: 16,
      children: [
        TextComponent(text: 'Wrapper:'),
        ButtonComponent(
          button: TextComponent(text: 'No ExpandedComponent'),
          onPressed: () {
            demos.forEach(
              (demo) => demo.expandedMode = false,
            );
          },
        ),
        ButtonComponent(
          button: TextComponent(text: 'Wrapped with ExpandedComponent'),
          onPressed: () {
            demos.forEach(
              (demo) => demo.expandedMode = true,
            );
          },
        ),
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
        wrapperControls,
        ...demos,
        ColumnComponent(
          key: ComponentKey.named("alice"),
          size: NullableVector2(600, 400),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpandedComponent(
              key: ComponentKey.named("bob"),
              child: RectangleComponent(
                paint: Paint()..color = Colors.purple,
              ),
            ),
            RowComponent(
              key: ComponentKey.named("charlie"),
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextComponent(text: 'test'),
              ],
            ),
          ],
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

class LayoutDemo extends LinearLayoutComponent {
  LayoutDemo({
    required super.direction,
    required super.crossAxisAlignment,
    required super.mainAxisAlignment,
    required super.gap,
    required super.position,
    super.size,
    super.key,
  }) : super(anchor: Anchor.topLeft, priority: 0, children: []);

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
