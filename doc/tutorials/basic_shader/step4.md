# 4. User Input

In this step we add mouse hover support so the outline color changes when the cursor enters the
sprite.


## Event handling

Open `sword_component.dart` and add the `HoverCallbacks` mixin to `OutlinedSwordSprite`:

```dart
import 'package:flame/events.dart';

class OutlinedSwordSprite extends PostProcessComponent
    with HoverCallbacks {
  // ...
}
```

Then add a field to store the original color, and override the hover callbacks to swap it:

```dart
Color? _originalPostProcessColor;

@override
void onHoverEnter() {
  super.onHoverEnter();

  final outlinePostProcess = postProcess as OutlinePostProcess;
  _originalPostProcessColor = outlinePostProcess.outlineColor;
  outlinePostProcess.outlineColor = Colors.blue;
}

@override
void onHoverExit() {
  final outlinePostProcess = postProcess as OutlinePostProcess;
  outlinePostProcess.outlineColor =
      _originalPostProcessColor ?? Colors.purpleAccent;

  super.onHoverExit();
}
```


## Full solution

The final `sword_component.dart` with hover support:

```dart
import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/post_process.dart';

import 'package:basic_shader_tutorial/outline_postprocess.dart';

class OutlinedSwordSprite extends PostProcessComponent
    with HoverCallbacks {
  OutlinedSwordSprite({super.position, super.anchor})
    : super(
        children: [SwordSprite()],
        postProcess: OutlinePostProcess(anchor: anchor ?? Anchor.topLeft),
      );

  @override
  void onChildrenChanged(
    Component component,
    ChildrenChangeType changeType,
  ) {
    _recalculateBoundingSize();
    super.onChildrenChanged(component, changeType);
  }

  void _recalculateBoundingSize() {
    final boundingBox = Vector2.zero();

    final rectChildren = children.query<PositionComponent>();
    if (rectChildren.isNotEmpty) {
      final boundingRect = rectChildren
          .map((child) => child.toRect())
          .reduce((a, b) => a.expandToInclude(b));

      boundingBox.setValues(boundingRect.width, boundingRect.height);
    }

    size = boundingBox;
  }

  Color? _originalPostProcessColor;

  @override
  void onHoverEnter() {
    super.onHoverEnter();

    final outlinePostProcess = postProcess as OutlinePostProcess;
    _originalPostProcessColor = outlinePostProcess.outlineColor;
    outlinePostProcess.outlineColor = Colors.blue;
  }

  @override
  void onHoverExit() {
    final outlinePostProcess = postProcess as OutlinePostProcess;
    outlinePostProcess.outlineColor =
        _originalPostProcessColor ?? Colors.purpleAccent;

    super.onHoverExit();
  }
}

class SwordSprite extends SpriteComponent {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('sword.png');
    size = sprite!.srcSize;
  }
}
```

When you hover over the sprite, the outline turns blue. When the cursor leaves, it reverts to the
original color.

![GIF of mouse hover](../../images/tutorials/basic_shader/hover_demo.webp)
