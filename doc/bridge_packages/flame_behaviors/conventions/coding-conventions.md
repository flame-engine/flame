# Coding Conventions

> **Note**: The following coding conventions are simply recommendations and are completely
optional. Feel free to use whatever coding conventions you prefer.


## Entities

Entities should not contain any behavioral logic, instead they should be composed of behaviors. This
allows for more flexible and reusable code. Entities should not do any direct rendering, instead they
should add child components to handle the visualization of the entity.


### Example of entities

✅ **Good**

```dart
class Player extends Entity {
  Player() {
    // Behaviors
    add(JumpingBehavior());
    add(AttackingBehavior());

    // Components
    add(SpriteComponent(...));
  }
}
```

❌ **Bad**

```dart
class Player extends Entity {
  void update(double dt) {
    if (isJumping) {
      // Jump logic
    }
    
    if (isAttacking) {
      // Attack logic
    }
  }

  void render(Canvas canvas) {
    // Render player
    canvas.drawImage(...);
  }
}
```


## Behaviors

Behaviors should only contain code related to the behavioral logic it describes. Behaviors should
never do any direct rendering.

A behavior is allowed to have its own components for adding extra functionality related to the
behavior. For example, a behavior that makes an entity jump could have a `TimerComponent` to ensure
that the entity can only jump once every 0.5 seconds. And that behavior can also use a
`KeyboardHandler` mixin to listen for the jump key to trigger the jump. Any logic that is not
related to the behavior should not be in the behavior.


### Example of behaviors

✅ **Good**

```dart
class JumpingBehavior extends Behavior<Entity> with KeyboardHandler {
  bool isJumping = false;

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    isJumping = keysPressed.contains(LogicalKeyboardKey.space);
    return true;
  }

  @override
  void update(double dt) {
    if (isJumping) {
      // Jump logic
    }
  }
}
```

❌ **Bad**

```dart
class JumpBehavior extends Behavior<Entity> with KeyboardHandler {
  bool isJumping = false;
  bool isAttacking = false;

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    isJumping = keysPressed.contains(LogicalKeyboardKey.space);
    isAttacking = keysPressed.contains(LogicalKeyboardKey.keyA);
    return true;
  }

    
  void update(double dt) {
    if (isJumping) {
      // Jump logic
    }
    if (isAttacking) {
      // Attack logic
    }
  }
    
  void render(Canvas canvas) {
    // Render something
    canvas.drawImage(...);
  }
}
```
