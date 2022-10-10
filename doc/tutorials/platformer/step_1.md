# 1. Preparation

Before you begin any kind of game project, you need an idea of what you want to
make and I like to then give it a **name**. For this tutorial and game, I got
inspiration from @spydon's
[tweet](https://twitter.com/spydon/status/1579191596389924864?cxt=HHwWgIDU8fqYteorAAAA)
about the Flame game engine GitHub repository reaching 7000 stars and I thought,
excellent! Ember will be on a quest to gather as many stars as possible and I
will call the game, `Ember Quest`.

Now it is time to get started but first, you need to go to the tutorial and
complete the necessary setup steps. When you come back, you should already have
the `main.dart` file with the following content:

```dart
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  final game = FlameGame();
  runApp(GameWidget(game: game));
}
```


## Planning

Like in the [klondike](../klondike/klondike.md) tutorial, starting a new game
can feel overwhelming. I like to first decide what platform am I trying to
target. Will this be a mobile game, a desktop game, or maybe a web game, with
Flutter and Flame, these are all possible.  For this game though, I am going to
focus on a web game.  Starting with a simple sketch (it doesn't have to be
perfect as mine is very rough) is the best way to get an understanding of what
will need to be accomplished. Take for instance the below sketch, we know we
will need the following:

- Player Class
- Player Data Class (this will handle health and star count)
- Enemy Class
- Star Class
- Platform Class
- Background Class
- HUD Controls Class

![Sketch of Ember Quest](../../images/tutorials/emberescapades-sketch.png)

All of these will be brought together in `EmberQuestGame` derived from `FlameGame`.


## Assets

Every game needs assets.  Assets are images, sprites, animations, sounds, etc.
Now, I am not an artist, but because I am basing this game on Ember, the flame
mascot, and Ember is already designed, it sets the tone that this will be a
pixel art game.  There are numerous sites available that provide free pixel art
that can be used in games, but please check the licensing and always provide
valid creator attribution.  For this game though, I am going to take a chance
and make my artwork using an online pixel art tool.  If you decide to use this
tool, multiple online tutorials will assist you with the basic operations as
well as exporting the assets and creating spritesheets.  So with that, below are
the assets that I have created and turned into spritesheets.  

Right-click the image, choose "Save as...", and store it in the `assets/images`
folder of the project. At this point our project's structure looks like this
(there are other files too, of course, but these are the important ones):

```text
emberquest/
 ├─assets/
 │  └─images/
 │     └─ember.png
 │     └─enemy.png
 │     └─star.png
 │     └─terrain.png
 ├─lib/
 │  └─main.dart
 └─pubspec.yaml
```

By the way, this kind of file is called a **spritesheet**. It's just a
collection of multiple independent images in a single file. We are using a
spritesheet here for the simple reason that loading a single large image is
faster than many small images. In addition, rendering sprites that were
extracted from a single source image can be faster too, since Flutter will
optimize multiple such drawing commands into a single `drawAtlas` command.

Also, you need to tell Flutter about this image (just having it inside the
`assets` folder is not enough). To do this, let's add the following
lines into the `pubspec.yaml` file:

```yaml
flutter:
  assets:
    - assets/images/
```

Alright, enough with preparing -- onward to coding!
