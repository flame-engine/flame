# Oxygen

We (the Flame organization) build an ECS(Entity Component System) named Oxygen.

If you want to use Oxygen specifically for Flame as a replacement for the 
FCS(Flame Component System) you should use our bridge library
[flame_oxygen](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen) and if you
just want to use it in a Dart project you can use the
[oxygen](https://github.com/flame-engine/oxygen) library directly.

To use it in your game you just need to add `flame_oxygen` to your pubspec.yaml, as can be seen
in the
[Oxygen example](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen/example)
and in the pub.dev [installation instructions](https://pub.dev/packages/flame_oxygen).

## OxygenGame (Game extension)

If you are going to use Oxygen in your project it can be a good idea to use the Oxygen specific
extension of the `Game` class.

It is called `OxygenGame` and it will give you full access to the Oxygen framework while also
having full access to the Flame game loop.

A simple `OxygenGame` implementation example can be seen in the
[example folder](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen/example).

## Components

Components in Oxygen are different than the ones from FCS mainly because instead of containing 
logic they only contain data. This data is then used in systems which in turn define the logic.

To accomdate people who are switching from FCS to Oxygen we implemented a few components to help
you get started. Some of these components are based on the multiple functionalities that the 
`PositionComponent` from FCS has. Others are just easy wrappers around certain Flame API 
functionality, they are often accompanied by predefined systems that you can use.

### PositionComponent

TODO: Describe

### SizeComponent

TODO: Describe

### AnchorComponent

TODO: Describe

### AngleComponent

TODO: Describe

### SpriteComponent

TODO: Describe

### ParticleComponent

TODO: Describe

### TextComponent

TODO: Describe

## Systems

Systems define the logic of your game. In FCS you normally would add your logic inside a component 
with Oxygen we use systems for that. Oxygen itself is completly platform agnostic, meaning it has
no render loop. It only knows `execute`, which is a method equal to the `update` method in Flame.

On each `execute` Oxygen automatically calls all the systems that were registered in order. But in
Flame we can have different logic for different loops (render/update). So in `flame_oxygen` we 
introduced the `RenderSystem` and `UpdateSystem` mixin. These mixins allow you to add the `render`
method and the `update` method respectivally to your custom system. For more information see the [RenderSystem](#RenderSystem) and [UpdateSystem](#UpdateSystem) section.

If you are coming from FCS you might expect certain default functionality that you normally got 
from the `PositionComponent`. As mentioned before components do not contain any kind of logic, but
to give you the same default functionality we also created a class called `BaseSystem`. This system
acts almost identical to the prerender logic from the `PositionComponent` in FCS. You only have to
extend your own system from it to access it. For more information see the [BaseSystem](#BaseSystem) section.

### RenderSystem

TODO: Describe

### UpdateSystem

TODO: Describe

### BaseSystem

TODO: Describe


