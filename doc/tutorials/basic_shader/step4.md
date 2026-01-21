# Outline Post Process


## 4.0 Responsibility

Here we are preparing for shaders.  
This `PostProcess` is the handler of the fragment (pixel) shader, and this
class is responsible for creating shader resources and for keeping the uniform
variables updated.  
We also can store shader "settings" here (through uniforms) if you want it to
be modifiable in runtime, for example enabling and disabling effects.  

```{note}
Also I created an extension for Color to Vector4 conversion, this should be
in a "utility" class to be accessible to other classes too without referencing
this specific file.  
For clarity I omitted creating a new file.
```


## 4.1 Post process

We create the missing class in a new file, name it to `outline_postprocess.dart`:  

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
  double outlineSize;
  Color outlineColor;
  Anchor anchor;

  OutlinePostProcess({
    this.outlineSize = 7.0,
    this.outlineColor = Colors.purpleAccent,
    this.anchor = Anchor.topLeft
  });

  late final FragmentProgram _fragmentProgram;
  late final FragmentShader _fragmentShader = _fragmentProgram.fragmentShader();
  late final myPaint = Paint()..shader = _fragmentShader;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _fragmentProgram = await FragmentProgram.fromAsset('assets/shaders/outline.frag');
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
      ..translate( -size.x*anchor.x, -size.y*anchor.y )
      ..drawRect(Offset.zero & size.toSize(), myPaint)
      ..restore();
  }
}
```

Okay so if the linking / importing is right the syntax error will go away.  

The outline should be "under" the image, so I added the
`PostProcessComponent` as the parent of the `SpriteComponent`, which
would mean the post process (shader) is rendered first, and then the
`SpriteComponent` with the image overwriting the layer of the shader.  
You can test it by stacking only `SpriteComponents` within each other.
The last (deepest) child will be rendered on top.

Using any kind of `PostProcessComponent` will "overwrite" the rendering
order and the post process will decide what will be the final color of the
rendered pixels (you can check out the added hints for the class
and it's source code for details).  

This structure allows us to simply use `rasterizeSubtree()`, which
will implicitly rasterize all added children.  

Let's run the application.  
`Ctrl + J`.  
`flutter run` then choose your platform.  
Nothing, but darkness...  


## 4.2 Usage

Well we did create the components and postprocess classes but we did not
add any of those to the game itself.  

Go to the `main.dart` and add two components to the world with a little
positional offsets:  

```dart
import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:basic_shader_tutorial/sword_component.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame()
    ),
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
      ..anchor = Anchor.center
    );

    add(
      SwordSpritePostProcessed(
        position: Vector2(200, 0),
        anchor: Anchor.center
      )
    );
  }
}
```

In the new `main.dart` I replaced the `FlameGame` with a custom class
where I override the background color, because I have a black-and-white image.
You can change it to suit your images too.  

Also change the position of components based on the size of my images and
window size.  

Run the application again.  

What? There is only one sprite? Why? You may ask, my fellow tutorial buddy.  
The reason is printed early in the console, if you whish to trace it.  

There is no such file what we would like to load as a shader file in
`OutlinePostProcess`:  
`[...] Unhandled Exception: Exception: Asset 'assets/shaders/outline.frag' not found [...]`  

There won't be more missing files after the next section.  
In the next step we will create the shader itself.
