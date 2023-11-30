# flame_spine

This package allows you to load and add Spine skeletal animations to your Flame game.


## Usage

To use it in your game you just need to add `flame_spine` to your pubspec.yaml and your spine
assets to your `assets/` directory, and you can add a `SpineComponent` to your `FlameGame`.

```{note}
Remember to call `await initSpineFlutter();` in your `main` method, or in `onLoad`.
```

Example:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSpineFlutter();
  runApp(const GameWidget.controlled(gameFactory: SpineExample.new));
}

class FlameSpineExample extends FlameGame with TapDetector {
 late final SpineComponent spineboy;

 @override
 Future<void> onLoad() async {
  await initSpineFlutter();
  // Load the Spineboy atlas and skeleton data from asset files
  // and create a SpineComponent from them, scaled down and
  // centered on the screen
  spineboy = await SpineComponent.fromAssets(
   atlasFile: 'assets/spine/spineboy.atlas',
   skeletonFile: 'assets/spine/spineboy-pro.skel',
   scale: Vector2(0.4, 0.4),
   anchor: Anchor.center,
   position: size / 2,
  );

  // Set the "walk" animation on track 0 in looping mode
  spineboy.animationState.setAnimationByName(0, 'walk', true);
  await add(spineboy);
 }

 @override
 void onDetach() {
  // Dispose the native resources that have been loaded for spineboy.
  spineboy.dispose();
 }
}
```
