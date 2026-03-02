# 1. Sprite Component


## Architecture and Responsibilities

Let's create the component where we render our sprite and apply the shader. We will split this
into two classes:

- a `SpriteComponent` subclass that loads the image and handles input events
- a `PostProcessComponent` subclass that wraps the sprite and applies the shader

This separation means that shader changes only require editing the wrapper class, while sprite
changes like adding input event mixins or additional children only require editing the sprite
class.


## Image resource

For this tutorial we need an image with a transparent background to apply the outline shader to.
Create an `assets/images/` directory in your project and add your `.png` image there.

Don't forget to register the assets folder in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```


## Sprite

Create a new file named `sword_component.dart` (replace "sword" with your own image name):

```dart
import 'package:flame/components.dart';

class SwordSprite extends SpriteComponent {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('sword.png');
    size = sprite!.srcSize;
  }
}
```


## Wrapper

Next, add the wrapper class that applies the post process. In the same file, create:

```dart
import 'package:flame/components.dart';
import 'package:flame/post_process.dart';

import 'package:basic_shader_tutorial/outline_postprocess.dart';

class OutlinedSwordSprite extends PostProcessComponent {
  OutlinedSwordSprite({super.position, super.anchor})
    : super(
        children: [SwordSprite()],
        postProcess: OutlinePostProcess(anchor: anchor ?? Anchor.topLeft),
      );
}
```


## Result

The final `sword_component.dart` file looks like this:

```dart
import 'package:flame/components.dart';
import 'package:flame/post_process.dart';

import 'package:basic_shader_tutorial/outline_postprocess.dart';

class OutlinedSwordSprite extends PostProcessComponent {
  OutlinedSwordSprite({super.position, super.anchor})
    : super(
        children: [SwordSprite()],
        postProcess: OutlinePostProcess(anchor: anchor ?? Anchor.topLeft),
      );
}

class SwordSprite extends SpriteComponent {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('sword.png');
    size = sprite!.srcSize;
  }
}
```

This won't compile yet because `OutlinePostProcess` doesn't exist. Let's create it in the next
step!
