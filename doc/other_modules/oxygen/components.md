# Components

Components in Oxygen are different than the ones from FCS mainly because instead of containing logic
they only contain data. This data is then used in systems which in turn define the logic. To
accommodate people who are switching from FCS to Oxygen we implemented a few components to help you
get started. Some of these components are based on the multiple functionalities that the
`PositionComponent` from FCS has. Others are just easy wrappers around certain Flame API
functionality, they are often accompanied by predefined systems that you can use.

Components can be registered to the world using the `world.registerComponent` method on
`OxygenGame`.


## PositionComponent

The `PositionComponent` as its name implies is a component that describes the position of an
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


## SizeComponent

The `SizeComponent` as its name implies is a component that describes the size of an entity.
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


## AnchorComponent

The `AnchorComponent` as its name implies is a component that describes the anchor position of an
entity. And it is registered to the world by default.

This component is especially useful when you are using the `BaseSystem`. But can also
be used for your anchoring logic.

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

The `AngleComponent` as its name implies is a component that describes the angle of an entity and
it is registered to the world by default. The angle is in radians.

This component is especially useful when you are using the `BaseSystem`. But can also
be used for your angle logic.

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


## FlipComponent

The `FlipComponent` can be used to flip your rendering on either the X or Y axis. It is registered
to the world by default.

This component is especially useful when you are using the `BaseSystem`. But can also
be used for your flipping logic.

Creating an entity that is flipped on its X-axis using OxygenGame:

```dart
game.createEntity(
  position: // ...
  size: // ...
  flipX: true
);
```

Creating an entity that is flipped on its X-axis using the World:

```dart
world.createEntity()
  ..add<FlipComponent, FlipInit>(FlipInit(flipX: true));
```


## SpriteComponent

The `SpriteComponent` as its name implies is a component that describes the sprite of an entity and
it is registered to the world by default.

This allows you to assign a Sprite to an Entity.

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


## TextComponent

The `TextComponent` as its name implies is a component that adds a text component to an entity.
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


## ParticleComponent

The `ParticleComponent` wraps a `Particle` from Flame. Combined with the `ParticleSystem` you can
easily add particles to your game without having to worry about how to render a particle or when/how
to update one.

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
