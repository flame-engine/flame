# Naming Conventions

> **Note**: The following naming conventions are simply recommendations and are completely
optional. Feel free to use whatever naming conventions you prefer.

## Entities


### Anatomy of entities

`Type (name)`

### Examples of entities

✅ **Good**

```dart
class Player extends Entity {}

class Enemy extends Entity {}

class Bullet extends Entity {}
```

❌ **Bad**

```dart
class PlayerEntity extends Entity {}

class EnemyEntity extends Entity {}

class BulletEntity extends Entity {}
```

## Behaviors


### Anatomy of behaviors

`Verb (action)` + `Behavior`


### Examples of behaviors

✅ **Good**

```dart
class JumpingBehavior extends Behavior<Entity> {}

class AttackingBehavior extends Behavior<Entity> {}
```

❌ **Bad**

```dart
class JumpBehavior extends Behavior<Entity> {}

class AttackBehavior extends Behavior<Entity> {}
```
