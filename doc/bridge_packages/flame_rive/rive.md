# flame_rive

`flame_rive` is a bridge library for using [rive](https://rive.app/) animations in your Flame game.
Rive is a real-time interactive design and animation tool and you use it to create animations.

To use a file created by Rive in your game you need to add `flame_rive` to your pubspec.yaml, as can
be seen in the
[Flame Rive example](https://github.com/flame-engine/flame/tree/main/packages/flame_rive/example)
and in the pub.dev [installation instructions](https://pub.dev/packages/flame_rive).


## How to use it

First, start with adding the `animation.riv` file to the assets folder. Then load the artboard of
the animation to the game using the `loadArtboard` method. After that, create the
`StateMachineController` from the artboard and add a controller to it. Then you can create a
`RiveComponent` using that artboard.

```{flutter-app}
:sources: ../flame/examples
:page: rive_example
:show: widget code infobox
:width: 200
:height: 200
```

```dart
class RiveExampleGame extends FlameGame {
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

You can use the controller to manage the state of animation.
Check out the example for more information.


## Full Example

You can check an example
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_rive/example).

