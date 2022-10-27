# 7. Adding Menus

To add menus to the game, we will leverage Flame's built-in
[overlay](../../flame/game.md#flutter-widgets-and-game-instances) system.  


## Main Menu

In the `lib/overlays` folder, create `main_menu.dart` and add the following code:

```dart
import 'package:flutter/material.dart';

import '../ember_quest.dart';

class MainMenu extends StatelessWidget {
  // Reference to parent game.
  final EmberQuestGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 250,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ember Quest',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('MainMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(
                      fontSize: 40.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Use WASD or Arrow Keys for movement.  Space bar to jump.
                 Collect as many stars as you can and avoid enemies!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

This is a pretty self-explanatory file that just uses standard Flutter widgets to display
information and provide a `Play` button.  The only Flame-related line is
`game.overlays.remove('MainMenu');` which simply removes the overlay so the user can play the
game.  It should be noted that the user can technically move Ember while this is displayed, but
trapping the input is outside the scope of this tutorial as there are multiple ways this can be
accomplished.


## Game Over Menu

Next, create a file called `lib/overlays/game_over.dart` and add the following code:

```dart
import 'package:flutter/material.dart';

import '../ember_quest.dart';

class GameOver extends StatelessWidget {
  // Reference to parent game.
  final EmberQuestGame game;
  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 200,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.reset();
                    game.overlays.remove('GameOver');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

As with the Main Menu, this is all standard Flutter widgets except for the call to remove the
overlay and also the call to `game.reset()` which we will create now.  

Open `lib/ember_quest.dart` and add / update the following code:

```dart
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
    initializeGame(true);
}

void initializeGame(bool loadHud) {
    // Assume that size.x < 3200
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (640 * i).toDouble());
    }

    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 128),
    );
    add(_ember);
    if (loadHud) {
      add(Hud());
    }
  }

void reset() {
    starsCollected = 0;
    health = 3;
    initializeGame(false);
}
```

You may notice that we have added a parameter to the `initializeGame` method which allows us to
bypass adding the HUD to the game.  This is because in the coming section, when Ember's health drops
to 0, we will wipe the game, but we do not need to remove the HUD, as we just simply need to reset
the values using `reset()`.


## Displaying the Menus

To display the menus, add the following code to `lib/main.dart`:

```dart
void main() {
  runApp(
    GameWidget<EmberQuestGame>.controlled(
      gameFactory: EmberQuestGame.new,
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
        'GameOver': (_, game) => GameOver(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
```

If the menus did not auto-import, add the following:

```dart
import 'overlays/game_over.dart';
import 'overlays/main_menu.dart';
```

If you run the game now, you should be greeted with the Main Menu overlay.  Pressing play will
remove it and allow you to start playing the game.


### Health Check for Game Over

Our last step to finish Ember Quest is to add a game-over mechanism.  This is fairly simple but
requires us to place similar code in all of our components.  So let's get started!

In `lib/actors/ember.dart`, in the `update` method, add the following:

```dart
// If ember fell in pit, then game over.
if (position.y > game.size.y + size.y) {
    game.health = 0;
}

if (game.health <= 0) {
    removeFromParent();
}
```

In `lib/actors/water_enemy.dart`, in the `update` method update the following code:

```dart
if (position.x < -size.x || game.health <= 0) {
    removeFromParent();
}
```

In `lib/objects/ground_block.dart`, in the `update` method update the following code:

```dart
if (game.health <= 0) {
    removeFromParent();
}
```

In `lib/objects/platform_block.dart`, in the `update` method update the following code:

```dart
if (position.x < -size.x || game.health <= 0) {
    removeFromParent();
}
```

In `lib/objects/star.dart`, in the `update` method update the following code:

```dart
if (position.x < -size.x || game.health <= 0) {
    removeFromParent();
}
```

Finally, in `lib/ember_quest.dart`, add the following `update` method:

```dart
@override
void update(double dt) {
    if (health <= 0) {
        overlays.add('GameOver');
    }
    super.update(dt);
}
```


## Congratulations

You made it!  You have a working Ember Quest.  Press the button below to see what the resulting code
looks like or to play it live.

```{flutter-app}
:sources: ../tutorials/platformer/app
:show: popup code
```
