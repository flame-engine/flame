# Behaviors

`SteeringBehavior`s are a collection of composable classes that can be used to imbue components
in your game with desired behaviors. These behaviors can be applied to `SteerableComponent`s, or
your custom components that implement `Steerable` interface.

The following behaviors are provided:
  
  - [`Pursue`](#pursue)
  

## Pursue

This behavior forces the agent to follow its target. The agent will try to anticipate where the
target will be in the future, and intercept it at that point. 

```dart
final missile = MissileSteerableComponent()
    ..maxLinearSpeed = 1000
    ..maxLinearAcceleration = 200
    ..behavior = Pursue(target: player);
```
