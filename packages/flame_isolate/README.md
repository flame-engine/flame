# FlameIsolate

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

Backpressure strategies is a way to cope with the job queue when job items are produced more rapidly
than the isolate can handle them. This presents the problem of what to do with such a growing
backlog of unhandled jobs. To mitigate this problem this library funnels all jobs through a job
queue handler. Also known as `BackpressureStrategy`.

The ones currently supported are:

* `NoBackPressureStrategy` that basically does not handle back pressure. It uses a FIFO stack for
  storing a backlog of unhandled jobs.
* `ReplaceBackpressureStrategy` that has a job queue with size one, and discards the queue upon
  adding a new job.
* `DiscardNewBackPressureStrategy` that has a job queue with size one, and as long as the queue is
  populated a new job will not be added.

You can specify a backpressure strategy by overriding the `backpressureStrategy` field. This will
create the isolate with the specified strategy when component is mounted.

```dart
class MyGame extends FlameGame with FlameIsolate {
  @override
  BackpressureStrategy get backpressureStrategy => ReplaceBackpressureStrategy();
  ...
}
```


### Additional information

You could expect this API to be *mostly* stable, but implementation of the underlying package
(integral_isolates) is not fully finalized yet, and there is more features coming before both
packages can count as stable.
