# Event Behaviors ⌨

The `flame_behaviors` package also provides event behaviors. These behaviors are a layer over the
existing Flame event mixins for components. These behaviors will trigger when the user interacts with their parent entity. So these events are always relative to the parent entity.

## TappableBehavior

The `TappableBehavior` allows developers to use the [tap events][flame_tap_docs] from Flame on their entities.

```dart
class MyTappableBehavior extends TappableBehavior<MyEntity> {
  @override
  void onTapDown(TapDownEvent event) {
    // Do something on tap down update event.
  }
}
```


## DraggableBehavior

The `DraggableBehavior` allows developers to use the [drag events][flame_drag_docs] from Flame on their entities.

```dart
class MyDraggableBehavior extends DraggableBehavior<MyEntity> {
  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Do something on drag update event.
  }
}
```

[flame_drag_docs]: https://docs.flame-engine.org/1.10.0/flame/inputs/drag_events.html
[flame_tap_docs]: https://docs.flame-engine.org/1.10.0/flame/inputs/tap_events.html
