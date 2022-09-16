The power of [integral_isolates](https://pub.dev/packages/integral_isolates) in your
[Flame](https://pub.dev/packages/flame) game.

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

## Additional information

You could expect this API to be _mostly_ stable, but implementation of the underlying package
(integral_isolates) is not fully finalized yet, and there is more features coming before both
packages can count as stable.
