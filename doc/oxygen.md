# Oxygen

We (the Flame organization) built an ECS(Entity Component System) named Oxygen.

If you want to use Oxygen specifically for Flame as a replacement for the 
FCS(Flame Component System) you should use our bridge library
[flame_oxygen](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen) and if you
just want to use it in a Dart project you can use the
[oxygen](https://github.com/flame-engine/oxygen) library directly.

If you are not familiar with Oxygen yet we recommend you read up on its 
[documentation](https://github.com/flame-engine/oxygen/tree/main/doc).

To use it in your game you just need to add `flame_oxygen` to your pubspec.yaml, as can be seen
in the
[Oxygen example](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen/example)
and in the pub.dev [installation instructions](https://pub.dev/packages/flame_oxygen).

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

The `OxygenGame` also comes with it's own `createEntity` method that automically adds certain
default components on the entity. This is especially helpfull when you are using the 
[BaseSystem](#BaseSystem) as your base.

## Systems

Systems define the logic of your game. In FCS you normally would add your logic inside a component 
with Oxygen we use systems for that. Oxygen itself is completly platform agnostic, meaning it has
no render loop. It only knows `execute`, which is a method equal to the `update` method in Flame.

On each `execute` Oxygen automatically calls all the systems that were registered in order. But in
Flame we can have different logic for different loops (render/update). So in `flame_oxygen` we 
introduced the `RenderSystem` and `UpdateSystem` mixin. These mixins allow you to add the `render`
method and the `update` method respectivally to your custom system. For more information see the 
[RenderSystem](#RenderSystem) and [UpdateSystem](#UpdateSystem) section.

If you are coming from FCS you might expect certain default functionality that you normally got 
from the `PositionComponent`. As mentioned before components do not contain any kind of logic, but
to give you the same default functionality we also created a class called `BaseSystem`. This system 
acts almost identical to the prerender logic from the `PositionComponent` in FCS. You only have 
to subclass it to your own system. For more information see the 
[BaseSystem](#BaseSystem) section.

Systems can be registered to the world using the `world.registerSystem` method on 
[OxygenGame](#OxygenGame).

### mixin GameRef

The `GameRef` mixin allows a system to become aware of the `OxygenGame` instance its attached to. This 
allows easy access to the methods on the game class.

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

The `BaseSystem` is an abstract class whoms logic can be compared to the `PositionComponent` 
from FCS. The `BaseSystem` automatically filters all entities that have the `PositionComponent` 
and `SizeComponent` from `flame_oxygen`. On top of that you can add your own filters by defining 
a getter called `filters`. These filters are then used to filter down the entities you are 
interested in.

The `BaseSystem` is also fully aware of the game instance. You can access the game instance by using 
the `game` property. This also gives you access to the `createEntity` helper method on `OxygenGame`.

On each render loop the `BaseSystem` will prepare your canvas the same way the `PositionComponent` 
from FCS would (translating, rotating and setting the anchor. After that it will call the 
`renderEntity` method so you can add your own render logic for that entity on a prepared canvas.

The following components will be checked by `BaseSystem` for the prepartion of the
canvas:
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
allows you to use the [ParticleComponent](#ParticleComponent) without having to worry about how
it will render or when to update it. As most of that logic is already contained in the Particle 
itself.

Simply register the `ParticleSystem` and the `ParticleComponent` to your world like so:

```dart
world.registerSystem(ParticleSystem());

world.registerComponent<ParticleComponent, Particle>(() => ParticleComponent);
```

You can now create a new entity with a `ParticleComponent`. For more info about that see the 
[ParticleComponent](#ParticleComponent) section.

## Components

Components in Oxygen are different than the ones from FCS mainly because instead of containing 
logic they only contain data. This data is then used in systems which in turn define the logic.

To accomdate people who are switching from FCS to Oxygen we implemented a few components to help
you get started. Some of these components are based on the multiple functionalities that the 
`PositionComponent` from FCS has. Others are just easy wrappers around certain Flame API 
functionality, they are often accompanied by predefined systems that you can use.

Components can be registered to the world using the `world.registerComponent` method on 
[OxygenGame](#OxygenGame).

### PositionComponent

The `PositionComponent` is as its name implies is a component that describe the position of an 
entity. And it is registered to the world by default.

Creating a positioned entity using OxygenGame:

```dart
game.createEntity(
  position: Vector2(100, 100),
  size: // ...
);
```

Creating a positioned entity using the World:

```dart
world.createEntity()
  ..add<PositionComponent, Vector2>(Vector2(100, 100));
```

### SizeComponent

The `SizeComponent` is as its name implies is a component that describe the size of an entity. 
And it is registered to the world by default.

Creating a sized entity using OxygenGame:

```dart
game.createEntity(
  position: // ...
  size: Vector2(50, 50),
);
```

Creating a sized entity using the World:

```dart
world.createEntity()
  ..add<SizeComponent, Vector2>(Vector2(50, 50));
```

### AnchorComponent

The `AnchorComponent` is as its name implies is a component that describe the anchor position of an 
entity. And it is registered to the world by default.

This component is especially useful when you are using the [BaseSystem](#BaseSystem). But can also 
be used for your own anchoring logic.

Creating an anchored entity using OxygenGame:

```dart
game.createEntity(
  position: // ...
  size: // ...
  anchor: Anchor.center,
);
```

Creating an anchored entity using the World:

```dart
world.createEntity()
  ..add<AnchorComponent, Anchor>(Anchor.center);
```

### AngleComponent

The `AngleComponent` is as its name implies is a component that describe the angle of an entity. 
And it is registered to the world by default. The angle is in radians.

This component is especially useful when you are using the [BaseSystem](#BaseSystem). But can also 
be used for your own angle logic.

Creating an angled entity using OxygenGame:

```dart
game.createEntity(
  position: // ...
  size: // ...
  angle: 1.570796,
);
```

Creating an angled entity using the World:

```dart
world.createEntity()
  ..add<AngleComponent, double>(1.570796);
```

### FlipComponent

The `FlipComponent` can be used to flip your rendering on either the X or Y axis. It is registered 
to the world by default.

This component is especially useful when you are using the [BaseSystem](#BaseSystem). But can also 
be used for your own flipping logic.

Creating an entity that is flipped on it's X axis using OxygenGame:

```dart
game.createEntity(
  position: // ...
  size: // ...
  flipX: true
);
```

Creating an entity that is flipped on it's X axis using the World:

```dart
world.createEntity()
  ..add<FlipComponent, FlipInit>(FlipInit(flipX: true));
```

### SpriteComponent

The `SpriteComponent` is as its name implies is a component that describe the sprite of an entity. 
And it is registered to the world by default.

This allows you to assigning a Sprite to an Entity.

Creating an entity with a sprite using OxygenGame:

```dart
game.createEntity(
  position: // ...
  size: // ...
)..add<SpriteComponent, SpriteInit>(
  SpriteInit(await game.loadSprite('pizza.png')),
);
```

Creating an entity with a sprite using World:

```dart
world.createEntity()
  ..add<SpriteComponent, SpriteInit>(
    SpriteInit(await game.loadSprite('pizza.png')),
  );
```

### TextComponent

The `TextComponent` is as its name implies is a component that adds a text component to an entity. 
And it is registered to the world by default.

This allows you to add text to your entity, combined with the `PositionComponent` you can use it
as a text entity.

Creating an entity with text using OxygenGame:

```dart
game.createEntity(
  position: // ...
  size: // ...
)..add<TextComponent, TextInit>(
  TextInit(
    'Your text',
    config: const TextPaintConfig(),
  ),
);
```

Creating an entity with text using World:

```dart
world.createEntity()
  ..add<TextComponent, TextInit>(
    TextInit(
      'Your text',
      config: const TextPaintConfig(),
    ),
  );
```

### ParticleComponent

The `ParticleComponent` wraps a `Particle` from Flame. Combined with the 
[ParticleSystem](#ParticleSystem) you can easily add particles to your game without having to 
worry about how to render a particle or when/how to update one.

Creating an entity with a particle using OxygenGame:

```dart
game.createEntity(
  position: // ...
  size: // ...
)..add<ParticleComponent, Particle>(
  // Your Particle.
);
```

Creating an entity with a particle using World:

```dart
world.createEntity()
  ..add<ParticleComponent, Particle>(
    // Your Particle.
  );
```
