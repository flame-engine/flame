
# Sprite Component


## 3.0 Architecture and Responsibilities

Let's create the component where we render our sprite and apply the shader.  

For clarity and some modularity I separated the sprite into two classes:  

- one for having a standard sprite class (purpose: general sprite and event handling)
- one for applying a post process as a wrapper class (purpose: specific shader application)

Now if I want to modify the shader of the sword only, I don't have to modify the
underlying sprite class or  
I can "freely" modify the sprite and add input event mixins to it or add other
children, if it is a composite sprite. In these cases only one class has to be
modified, when these features are added.  

These are intended to be the application of
[Single Responsibility](https://en.wikipedia.org/wiki/Single-responsibility_principle) and
[Low Coupling](https://en.wikipedia.org/wiki/Coupling_(computer_programming))
programming principles.  

```{note}
Feel free to modify the code and experiment with different approaches
after the tutorial concluded.
```


## 3.1 Sprite

Create a new file named ```sword_component.dart```
(*or instead of "sword" use what you have of course*):  

```dart
import 'dart:async';
import 'package:flame/components.dart';

class SwordSprite extends SpriteComponent{
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('sword.png');
    size = sprite!.srcSize;

    return super.onLoad();
  }
}
```


## 3.2 Wrapper

Here comes the wrapper class for applying shaders and post process, in the
same file (*or in a separate one if you prefer, but don't forget to link them
together afterwards via import*) create another class:

```dart
//... 
import 'package:flame/post_process.dart';

// We will create this file later
import 'package:basic_shader_tutorial/outline_postprocess.dart';
//... 

class SwordSpritePostProcessed extends PostProcessComponent{
  SwordSpritePostProcessed({super.position, super.anchor})
  : super(
    children: [SwordSprite()],
    postProcess: OutlinePostProcess(anchor: anchor ?? Anchor.topLeft),
  );
}
```


## 3.3 Result

So the final ```sword_component.dart``` file looks like this:  

```dart
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/post_process.dart';

import 'package:basic_shader_tutorial/outline_postprocess.dart';

class SwordSpritePostProcessed extends PostProcessComponent{
  SwordSpritePostProcessed({super.position, super.anchor})
  : super(
    children: [SwordSprite()],
    postProcess: OutlinePostProcess(anchor: anchor ?? Anchor.topLeft),
  );
}

class SwordSprite extends SpriteComponent{
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('sword.png');
    size = sprite!.srcSize;

    return super.onLoad();
  }
}
```

Here you will get a syntax error because ```OutlinePostProcess()``` does not
exists nor the imported package.. yet!  

Let's create those in the next step!
