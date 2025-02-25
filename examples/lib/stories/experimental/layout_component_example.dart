import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class LayoutComponentExample extends FlameGame {
  static const String description = '''
    Press the row of buttons after MainAxisAlignment, CrossAxisAlignment,
    and Gap. They will update the layout of the example row and column
    layouts to reflect the chosen values.
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
      size: Vector2(900, 28),
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
      size: Vector2(900, 28),
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
      size: Vector2(900, 28),
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
}
