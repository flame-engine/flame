# FlameIsolate

The power of [integral_isolates](https://pub.dev/packages/integral_isolates) neatly packaged in
[flame_isolates](https://pub.dev/packages/flame_isolates) for your Flame game.

If you've ever used the [compute](https://api.flutter.dev/flutter/foundation/compute-constant.html)
function before, you will feel right at home. This mixin allows you to run CPU-intensive code in an
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


### Performance note

Keep in mind that every component with `FlameIsolate` mixin that you create and add to your game
will create a new isolate. This means you will probably want to create a manager component to
manage a lot of "dumber" components. Think of it like ants, where the queen controls the worker
ants. If every individual worker ant got its own isolate, it would be a total waste of power,
hence you would put it on the queen, which in turn tells all the worker ants what to do.

A simple example of this can be found in the example application for the FlameIsolate package.


### Backpressure Strategies

Backpressure strategies are a way to cope with the job queue when job items are produced more
rapidly than the isolate can handle them. This presents the problem of what to do with such a
growing backlog of unhandled jobs. To mitigate this problem this library funnels all jobs through a
job queue handler. Also known as `BackpressureStrategy`.

The ones currently supported are:

- `NoBackPressureStrategy` that basically does not handle back pressure. It uses a FIFO stack for
storing a backlog of unhandled jobs.
-`ReplaceBackpressureStrategy` that has a job queue with size one, and discards the queue upon
adding a new job.
- `DiscardNewBackPressureStrategy` that has a job queue with size one, and as long as the queue is
populated a new job will not be added.

You can specify a backpressure strategy by overriding the `backpressureStrategy` field. This will
create the isolate with the specified strategy when the component is mounted.

```dart
class MyGame extends FlameGame with FlameIsolate {
  @override
  BackpressureStrategy get backpressureStrategy => ReplaceBackpressureStrategy();
  ...
}
```
