# Getting Started 🚀


## Prerequisites 📝

In order to use Flame Behaviors you must have the [Flame package][flame_package_link] added to
your project.

> **Note**: Flame Behaviors requires Flame `">=1.10.0 <2.0.0"`


## Installing 🧑‍💻

Let's start by adding the [`flame_behaviors`][flame_behaviors_package_link] package:

```shell
# 📦 Add the flame_behaviors package from pub.dev to your project
flutter pub add flame_behaviors
```


## Entity

The entity is the building block of a game. It represents a visual game object that can hold
multiple `Behavior`s, which in turn define how the entity behaves.

```dart
// Define a custom entity by extending `Entity`.
class MyEntity extends Entity {
  MyEntity() : super(behaviors: [MyBehavior()]);
}
```


### Types of Entities

There are two types of entities in Flame Behaviors:

- `Entity`: A generic entity that can be used to represent any game object.
- `PositionedEntity`: An entity that has a position and size, it is based on the `PositionComponent`.

These entities use the `EntityMixin` which is a mixin that provides the basic functionality
for an entity.

If you want to turn any component into an entity, you can use this mixin. For instance, if you want
to turn a `SpriteComponent` into an entity, you can do the following:

```dart
class MySpriteEntity extends SpriteComponent with EntityMixin {
  Future<void> onLoad() async {
    // Add behaviors to the entity.
    add(MyBehavior());
  }
}
```

You can even turn a `FlameGame` into an entity:

```dart
class MyGame extends FlameGame with EntityMixin {
  Future<void> onLoad() async {
    // Add behaviors to the entity.
    add(MyGameBehavior());
  }
}
```


## Behavior

A behavior is a component that defines how an entity behaves. It can be attached to any component
that uses the `EntityMixin` and handle a specific behavior for that entity. Behaviors can either
be generic for any entity or you can specify the specific type of entity that a behavior requires:

```dart
// Can be added to any type of Entity.
class MyGenericBehavior extends Behavior {
  ...
}

// Can only be added to MyEntity and subclasses of it.
class MySpecificBehavior extends Behavior<MyEntity> {
  ...
}
```


### Behavior Composition

Each behavior can have its own `Component`s for adding extra functionality related to the behavior.
For instance a `TimerComponent` can implement a time-based behavioral activity:

```dart
class MyBehavior extends Behavior {
  @override
  Future<void> onLoad() async {
    await add(TimerComponent(period: 5, repeat: true, onTick: _onTick));
  }

  void _onTick() {
    // Do something every 5 seconds.
  }
}
```

> [!NOTE]
> A `Behavior` is a non-visual component that describes how a visual component (Entity)
> behaves therefore, a behavior can't have its own `Behavior`s.


## What's Next

The following sections will show you how to use Flame Behaviors for common game development tasks:

- [Handling Game Input][input_behaviors_link]
- [Handling Collisions][collision_behaviors_link]

Flame Behaviors also provides some conventions on how to name and organize your code:

- [Naming Conventions][naming_conventions_link]
- [Code Conventions][code_conventions_link]

To learn more about how to use Flame Behaviors, check out our [article][article_link].

[flame_package_link]: https://pub.dev/packages/flame
[flame_behaviors_package_link]: https://pub.dev/packages/flame_behaviors
[article_link]: https://verygood.ventures/blog/build-games-with-flame-behaviors
[input_behaviors_link]: https://github.com/flame-engine/flame/blob/main/doc/bridge_packages/flame_behaviors/event-behaviors.md
[naming_conventions_link]: https://github.com/flame-engine/flame/blob/main/doc/bridge_packages/flame_behaviors/conventions/naming-conventions.md
[code_conventions_link]: https://github.com/flame-engine/flame/blob/main/doc/bridge_packages/flame_behaviors/conventions/coding-conventions.md
[collision_behaviors_link]: https://github.com/flame-engine/flame/blob/main/doc/bridge_packages/flame_behaviors/collision-detection.md
