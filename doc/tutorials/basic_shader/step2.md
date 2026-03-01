# 2. Outline Post Process


## Responsibility

The `PostProcess` class manages the fragment (pixel) shader. It is responsible for loading the
shader program, creating GPU resources, and keeping uniform variables up to date each frame. You
can also expose runtime settings through uniforms, for example to enable or disable effects.


## Post process

Create a new file named `outline_postprocess.dart`. This class loads the shader program in
`onLoad()` and passes uniform values to the GPU each frame in `postProcess()`:

```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/post_process.dart';

extension on Color {
  Vector4 toVector4() {
    return Vector4(r, g, b, a);
  }
}

class OutlinePostProcess extends PostProcess {
  final double outlineSize;
  Color outlineColor;
  final Anchor anchor;

  OutlinePostProcess({
    this.outlineSize = 7.0,
    this.outlineColor = Colors.purpleAccent,
    this.anchor = Anchor.topLeft,
  });

  late final FragmentProgram _fragmentProgram;
  late final FragmentShader _fragmentShader =
      _fragmentProgram.fragmentShader();
  late final Paint _myPaint = Paint()..shader = _fragmentShader;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _fragmentProgram =
        await FragmentProgram.fromAsset('assets/shaders/outline.frag');
  }

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    final preRenderedSubtree = rasterizeSubtree();

    _fragmentShader.setFloatUniforms((value) {
      value
        ..setVector(size)
        ..setFloat(outlineSize)
        ..setVector(outlineColor.toVector4());
    });

    _fragmentShader.setImageSampler(0, preRenderedSubtree);

    canvas
      ..save()
      ..translate(-size.x * anchor.x, -size.y * anchor.y)
      ..drawRect(Offset.zero & size.toSize(), _myPaint)
      ..restore();
  }
}
```

With this file in place, the syntax error from the previous step will go away.

Since the `PostProcessComponent` is the parent of the `SpriteComponent`, the post process renders
first and the sprite is drawn on top. The `rasterizeSubtree()` call captures all children into an
image that the shader can sample from.


## Usage

Now we need to wire everything together. Open `main.dart` and add both a plain sprite and an
outlined sprite to the world so we can compare them side by side:

```dart
import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:basic_shader_tutorial/sword_component.dart';

void main() {
  runApp(
    GameWidget(game: MyGame()),
  );
}

class MyGame extends FlameGame {
  MyGame() : super(world: MyWorld());

  @override
  Color backgroundColor() => Colors.green;
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    add(
      SwordSprite()
        ..position = Vector2(-200, 0)
        ..anchor = Anchor.center,
    );

    add(
      OutlinedSwordSprite(
        position: Vector2(200, 0),
        anchor: Anchor.center,
      ),
    );
  }
}
```

Here we use a custom `FlameGame` subclass to override the background color. Adjust the positions
and color to suit your own images.

Run the application. You should see only one sprite, the outlined one is missing. The console
will show why:
`[...] Unhandled Exception: Exception: Asset 'assets/shaders/outline.frag' not found [...]`

We haven't created the shader file yet. Let's do that in the next step.
