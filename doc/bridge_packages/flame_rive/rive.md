# flame_rive

`flame_rive` is a bridge library for using [rive](https://rive.app/) animations in your Flame game.
Rive is a real-time interactive design and animation tool and you use it to create animations.

To use a file created by Rive in your game you need to add `flame_rive` to your pubspec.yaml, as can
be seen in the
[Flame Rive example](https://github.com/flame-engine/flame/tree/main/packages/flame_rive/example)
and in the pub.dev [installation instructions](https://pub.dev/packages/flame_rive).


## How to use it

First, add `animation.riv` file in the assets folder. Then load the artboard of the animation to the
game using the `loadArtboard` method. After, create `StateMachineController` from the loaded
artboard and add controller to artboard. Then create a `RiveComponent` using artboard.

```dart
class RiveExampleGame extends FlameGame with HasTappables {
  @override
  Future<void> onLoad() async {
    final skillsArtboard =
    await loadArtboard(RiveFile.asset('assets/skills.riv'));

    final controller = StateMachineController.fromArtboard(
      skillsArtboard,
      "Designer's Test",
    );

    skillsArtboard.addController(controller!);

    add(RiveComponent(artboard: skillsArtboard, size: Vector2.all(550)));
  }
}
```

You can use the controller to manage the state of animation. Check out an example for more.


## Full Example

You can check an example
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_rive/example).

