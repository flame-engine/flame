import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class LayoutComponentExample extends FlameGame {
  static const String description = '''
    On this example, click on the "Skip" button to display all the text at once.
  ''';

  @override
  FutureOr<void> onLoad() {
    final rowDemo = RowComponent(
      size: Vector2(900, 300),
      children: createComponentList(),
    );
    final columnDemo = ColumnComponent(
      size: Vector2(900, 300),
      children: createComponentList(),
    );

    final mainAxisControls = RowComponent(
      size: Vector2(900, 48),
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
            // size: Vector2(48, 100),
          );
        }),
      ],
    );
    final crossAxisControls = RowComponent(
      size: Vector2(900, 48),
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
            // size: Vector2(48, 100),
          );
        }),
      ],
    );
    final gapControls = RowComponent(
      size: Vector2(900, 48),
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
            // size: Vector2(48, 100),
          );
        }),
      ],
    );
    mainAxisControls.size = mainAxisControls.inherentSize();
    crossAxisControls.size = crossAxisControls.inherentSize();
    gapControls.size = gapControls.inherentSize();
    final rootColumnComponent = ColumnComponent(
      position: Vector2(48, 48),
      gap: 48,
      children: [
        mainAxisControls,
        crossAxisControls,
        gapControls,
        rowDemo,
        columnDemo,
      ],
    );
    add(
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
      CircleComponent(
        radius: 48,
        paint: Paint()..color = Colors.blue,
      ),
    ];
  }

  @override
  // TODO: implement debugMode
  bool get debugMode => true;
}
