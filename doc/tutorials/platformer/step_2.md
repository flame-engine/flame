# 2. Start Coding


## The Plan

Now that we have the assets loaded and a very rough idea of what classes we will need, we need to
start thinking about how we will implement this game and our goals.  To do this, let's break down
what the game should do:

- Ember should be able to be controlled to move left, right, and jump.
- The level will be infinite, so we need a way to randomly load sections of the level.
- The objective is to collect stars while avoiding enemies.
- Enemies cannot be killed as you need to use the platforms to avoid them.
- If Ember is hit by an enemy, it should reduce Ember's health by 1.
- Ember should have 3 lives to lose.
- There should be pits that if Ember falls into, it is automatically game over.
- There should be a main menu and a game-over screen that lets the player start over.

Now that this is planned out, I know you are probably as excited as I am to begin and I just want to
see Ember on the screen.  So let's do that first.

```{note}
Why did I choose to make this game an infinite side scrolling platformer?

Well, I wanted to be able to showcase random level loading. No two game plays
will be the same. This exact setup can easily be adapted to be a traditional 
level game. As you make your way through this tutorial, you will see how we 
could modify the level code to have an end.  I will add a note in that section
to explain the appropriate mechanics.
```


## Loading Assets

For Ember to be displayed, we will need to load the assets.  This can be done in `main.dart`, but by
so doing, we will quickly clutter the file.  To keep our game organized, we should create files that
have a single focus.  So let's create a file in the `lib` folder called `ember_quest.dart`.  In that
file, we will add:

```dart
import 'package:flame/game.dart';

class EmberQuestGame extends FlameGame {
  EmberQuestGame();

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
    ]);

  }
}
```

As I mentioned in the [assets](step_1.md#assets) section, we are using multiple individual image
files and for performance reasons, we should leverage Flame's built-in caching system which will
only load the files once, but allow us to access them as many times as needed without an impact to
the game.  `await images.loadAll()` takes a list of the file names that are found in `assets\images`
and loads them to cache.


## Scaffolding

So now that we have our game file, let's prepare the `main.dart` file to receive our newly created
`FlameGame`.  Change your entire `main.dart` file to the following:

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'ember_quest.dart';

void main() {
  runApp(
    const GameWidget<EmberQuestGame>.controlled(
      gameFactory: EmberQuestGame.new,
    ),
  );
}
```

You can run this file and you should just have a blank screen now.  Let's get Ember loaded!


## Ember Time

Keeping your game files organized can always be a challenge.  I like to keep things logically
organized by how they will be involved in my game.  So for Ember, let's create the following folder,
`lib/actors` and in that folder, create `ember.dart`.  In that file, add the following code:

```dart
import 'package:flame/components.dart';

import '../ember_quest.dart';

class EmberPlayer extends SpriteAnimationComponent
    with HasGameRef<EmberQuestGame> {
  EmberPlayer({
    required super.position,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );
  }
}
```

This file uses the `HasGameRef` mixin which allows us to reach back to `ember_quest.dart` and
leverage any of the variables or methods that are defined in the game class.  You can see this in
use with the line `game.images.fromCache('ember.png')`.  Earlier, we loaded all the files into
cache, so to use that file now, we call `fromCache` so it can be leveraged by the `SpriteAnimation`.
The `EmberPlayer` class is extending a `SpriteAnimationComponent` which allows us to define
animation as well as position it accordingly in our game world.  When we construct this class, the
default size of `Vector2.all(64)` is defined as the size of Ember in our game world should be 64x64.
You may notice that in the animation `SpriteAnimationData`, the `textureSize` is defined as
`Vector2.all(16)` or 16x16.  This is because the individual frame in our `ember.png` is 16x16 and
there are 4 frames in total.  To define the speed of the animation, `stepTime` is used and set at
`0.12` seconds per frame.  You can change the `stepTime` to any length that makes the animation seem
correct for your game vision.

Now before you rush to run the game again, we have to add Ember to the game world.  To do this, go
back to `ember_quest.dart` and add the following:

```dart
import 'package:flame/game.dart';

import 'actors/ember.dart';

class EmberQuestGame extends FlameGame {
  EmberQuestGame();

  late EmberPlayer _ember;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
    ]);
    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 70),
    );
    add(_ember);
  }
}
```

Run your game now and you should now see Ember flickering in the lower left-hand corner.


## Building Blocks

Now that we have Ember showing on screen and we know our basic environment is all working correctly,
it's time to create a world for Embers Quest!  Proceed on to [](step_3.md)!
