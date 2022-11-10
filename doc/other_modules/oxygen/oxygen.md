# Oxygen

We (the Flame organization) built an ECS (Entity Component System) named Oxygen.

If you want to use Oxygen specifically for Flame as a replacement for the
FCS(Flame Component System) you should use our bridge library
[flame_oxygen](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen) and if you
just want to use it in a Dart project you can use the
[oxygen](https://github.com/flame-engine/oxygen) library directly.

If you are not familiar with Oxygen yet we recommend you read up on its
[documentation](https://github.com/flame-engine/oxygen/tree/main/doc).

To use it in your game you just need to add `flame_oxygen` to your `pubspec.yaml`, as can be seen
in the
[Oxygen example](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen/example)
and in the `pub.dev` [installation instructions](https://pub.dev/packages/flame_oxygen).


## OxygenGame (Game extension)

If you are going to use Oxygen in your project it can be a good idea to use the Oxygen specific
extension of the `Game` class.

It is called `OxygenGame` and it will give you full access to the Oxygen framework while also
having full access to the Flame game loop.

Instead of using `onLoad`, as you are used to with Flame, `OxygenGame` comes with the `init`
method. This method is called in the `onLoad` but before the world initialization, allowing you
to register components and systems and do anything else that you normally would do in `onLoad`.

A simple `OxygenGame` implementation example can be seen in the
[example folder](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen/example).

The `OxygenGame` also comes with it's own `createEntity` method that automatically adds certain
default components on the entity. This is especially helpful when you are using the
[BaseSystem](#basesystem) as your base.


## Systems

Systems define the logic of your game. In FCS you normally would add your logic inside a component
with Oxygen we use systems for that. Oxygen itself is completely platform agnostic, meaning it has
no render loop. It only knows `execute`, which is a method equal to the `update` method in Flame.

On each `execute` Oxygen automatically calls all the systems that were registered in order. But in
Flame we can have different logic for different loops (render/update). So in `flame_oxygen` we
introduced the `RenderSystem` and `UpdateSystem` mixin. These mixins allow you to add the `render`
method and the `update` method respectively to your custom system. For more information see the
[RenderSystem](#mixin-rendersystem) and [UpdateSystem](#mixin-updatesystem) section.

If you are coming from FCS you might expect certain default functionality that you normally got
from the `PositionComponent`. As mentioned before components do not contain any kind of logic, but
to give you the same default functionality we also created a class called `BaseSystem`. This system
acts almost identical to the prerender logic from the `PositionComponent` in FCS. You only have
to subclass it to your own system. For more information see the
[BaseSystem](#basesystem) section.

Systems can be registered to the world using the `world.registerSystem` method on
[OxygenGame](#oxygengame-game-extension).


### mixin GameRef

The `GameRef` mixin allows a system to become aware of the `OxygenGame` instance its attached to.
This allows easy access to the methods on the game class.

```dart
class YourSystem extends System with GameRef<YourGame> {
  @override
  void init() {
    // Access to game using the .game propery
  }

  // ...
}
```


### mixin RenderSystem

The `RenderSystem` mixin allows a system to be registered for the render loop.
By adding a `render` method to the system you get full access to the canvas as
you normally would in Flame.

```dart
class SimpleRenderSystem extends System with RenderSystem {
  Query? _query;

  @override
  void init() {
    _query = createQuery([/* Your filters */]);
  }

  void render(Canvas canvas) {
    for (final entity in _query?.entities ?? <Entity>[]) {
      // Render entity based on components
    }
  }
}
```


### mixin UpdateSystem

The `MixinSystem` mixin allows a system to be registered for the update loop.
By adding a `update` method to the system you get full access to the delta time as you
normally would in Flame.

```dart
class SimpleUpdateSystem extends System with UpdateSystem {
  Query? _query;

  @override
  void init() {
    _query = createQuery([/* Your filters */]);
  }

  void update(double dt) {
    for (final entity in _query?.entities ?? <Entity>[]) {
      // Update components values
    }
  }
}
```


### BaseSystem

The `BaseSystem` is an abstract class whose logic can be compared to the `PositionComponent`
from FCS. The `BaseSystem` automatically filters all entities that have the `PositionComponent`
and `SizeComponent` from `flame_oxygen`. On top of that you can add your own filters by defining
a getter called `filters`. These filters are then used to filter down the entities you are
interested in.

The `BaseSystem` is also fully aware of the game instance. You can access the game instance by using
the `game` property. This also gives you access to the `createEntity` helper method on `OxygenGame`.

On each render loop the `BaseSystem` will prepare your canvas the same way the `PositionComponent`
from FCS would (translating, rotating and setting the anchor. After that it will call the
`renderEntity` method so you can add your own render logic for that entity on a prepared canvas.

The following components will be checked by `BaseSystem` for the preparation of the canvas:

- `PositionComponent` (required)
- `SizeComponent` (required)
- `AnchorComponent` (optional, defaults to `Anchor.topLeft`)
- `AngleComponent` (optional, defaults to `0`)

```dart
class SimpleBaseSystem extends BaseSystem {
  @override
  List<Filter<Component>> get filters => [];

  @override
  void renderEntity(Canvas canvas, Entity entity) {
    // The canvas is translated, rotated and fully prepared for rendering.
  }
}
```


### ParticleSystem

The `ParticleSystem` is a simple system that brings the Particle API from Flame to Oxygen. This
allows you to use the [ParticleComponent](components.md#particlecomponent) without having to worry
about how it will render or when to update it. As most of that logic is already contained in the
Particle itself.

Simply register the `ParticleSystem` and the `ParticleComponent` to your world like so:

```dart
world.registerSystem(ParticleSystem());

world.registerComponent<ParticleComponent, Particle>(() => ParticleComponent);
```

You can now create a new entity with a `ParticleComponent`. For more info about that see the
`ParticleComponent` section.

```{toctree}
:hidden:

Components     <components.md>
```
