# FlameIsolate

The power of [integral_isolates](https://pub.dev/packages/integral_isolates) neatly packaged in 
[flame_isolates](https://pub.dev/packages/flame_isolates) for your Flame game.

If you've ever used the [compute](https://api.flutter.dev/flutter/foundation/compute-constant.html)
function before, you will feel right at home. This mixin allows you to run CPU intensive code in an
isolate.

To use it in your game you just need to add `flame_isolate` to your pubspec.yaml.

## Usage

Just add the mixin `FlameIsolate` to your component and start utilizing the power of an isolate as
simple as running the [compute](https://api.flutter.dev/flutter/foundation/compute-constant.html)
function.

Example:
```dart
class MyGame extends FlameGame with FlameIsolate {
  ...
  @override
  void update(double dt) {
    if (shouldRecalculate) {
      isolate(recalculateWorld, worldData).then(updateWorld);
    }
    ...
  }
  ...
}
```

### Backpressure Strategies
You can specify a backpressure strategy by overriding the `backpressureStrategy` field. This will
create the isolate with the specified strategy when component is mounted.
```dart
class MyGame extends FlameGame with FlameIsolate {
  @override
  BackpressureStrategy get backpressureStrategy => ReplaceBackpressureStrategy();
  ...
}
```
