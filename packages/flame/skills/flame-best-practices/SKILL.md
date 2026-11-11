---
name: flame-best-practices
description: >-
  Rules and idiomatic patterns for building games with Flame 2, the Flutter game
  engine in package:flame. Covers structuring a game with FlameGame, World and
  CameraComponent, the component lifecycle, input, collision detection, assets,
  effects, overlays, performance and testing with flame_test. Use it whenever
  writing, reviewing or refactoring code that uses package:flame or one of the
  flame_* bridge packages.
---

# Flame Best Practices

Flame games are trees of components. The game owns a `World` with the gameplay components and a
`CameraComponent` that looks at it. Every component goes through the same lifecycle, gets
`update(dt)` and `render(canvas)` calls every frame, and can have children of its own.

Use the `flame-cli` skill to create projects and to check changes in the running game.


## Project setup

- Start new games with `flame create`, which sets up `flame`, `flame_test` and `flame_lint`. Keep
  `flame_lint` as the analysis options and keep `flutter analyze` free of issues.
- `flame_lint` enables `use_primary_constructors`, so declare constructors as primary
  constructors, `class Player() extends PositionComponent { this : super(...); }`, like the
  examples below.
- Add bridge packages such as `flame_audio`, `flame_tiled` or `flame_forge2d` with
  `flutter pub add`, never by guessing a version constraint.
- Put each component class that is more than a few lines long in its own file under `lib/`, grouped
  by feature, and keep `main.dart` down to `runApp`.
- Put assets under `assets/images/`, `assets/audio/` and `assets/tiles/`, and declare the
  directories in the `flutter.assets` section of `pubspec.yaml`.


## Game structure

- Extend `FlameGame`. Add gameplay components to `world`, never directly to the game.
- Add the HUD, such as scores and buttons, to `camera.viewport`, so that it stays in place on the
  screen while the camera moves.
- The world origin is in the center of the viewport by default, so a component at `Vector2.zero()`
  is drawn in the middle of the screen.
- Pass a custom world to the constructor and type the game with it to reach it without casts.
- Use `CameraComponent.withFixedResolution` when the game should show the same area on every screen
  size, and `camera.follow` to keep a component in view.
- Never create the game inside a widget's `build` method, since every rebuild would create a new
  game. Use `GameWidget.managed(gameFactory: MyGame.new)` or create the game once in a `State`.

```dart
class MyGame() extends FlameGame<MyWorld> with HasCollisionDetection {
  this
    : super(
        world: MyWorld(),
        camera: CameraComponent.withFixedResolution(width: 800, height: 600),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewport.add(ScoreText());
    camera.follow(world.player);
  }
}

class MyWorld() extends World {
  final Player player = Player();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(player);
  }
}

void main() {
  runApp(const GameWidget.managed(gameFactory: MyGame.new));
}
```


## Components and their lifecycle

- Build behavior out of small components and children instead of large classes with many
  responsibilities. A health bar, a hitbox or an effect is its own child component.
- Use the lifecycle methods for what they are meant for, and always call `super`:
  - The constructor sets up fields. The game, the parent and the assets are not available yet.
  - `onLoad` runs once, before the component is mounted for the first time. Load assets and add
    children here. It can be `async`, and the game waits for the whole tree to load before it
    starts.
  - `onMount` runs every time the component is added to a parent that is in the game.
  - `update(double dt)` runs every frame. Multiply every change over time by `dt`, the seconds
    since the last frame, so that the game runs at the same speed at any frame rate. Never create
    new objects here, see [performance](#performance).
  - `render(Canvas canvas)` runs every frame after `update`. Only draw here, never change state,
    and never create new objects.
  - `onRemove` runs when the component is removed. Release what `onMount` acquired.
- `add`, `addAll` and `addToParent` are synchronous in Flame 2. Never `await` them. When you need
  to know that a child has loaded, await `child.loaded`, or `loaded` on an iterable of
  components after `addAll`.
- Use `HasGameRef<MyGame>` and its `gameRef` getter to reach the game, and `HasWorldRef<MyWorld>`
  and `worldRef` to reach the world. They are available from `onLoad` on, never in the
  constructor.
- Use `removeFromParent()` to remove a component. Changes to the tree are applied between frames,
  so a component is not gone right after the call.
- Control the drawing order with `priority`, higher priorities are drawn on top.
- Give components that other code or the `flame` CLI needs to find a `ComponentKey.named` key, and
  look them up with `findByKeyName` on the game instead of keeping global references.
- When a component often looks up children of one type, call `children.register<Enemy>()` in
  `onLoad` and use `children.query<Enemy>()`, which is cached, instead of `whereType`.
- Use the `HasVisibility` mixin and `isVisible` to hide a component without removing it.

```dart
class Player() extends SpriteComponent with HasGameRef<MyGame> {
  this : super(size: Vector2.all(64), anchor: Anchor.center);

  final Vector2 velocity = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('assets/images/player.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.addScaled(velocity, dt);
  }
}
```


## Input

- Add input mixins to the components that react, not to the game: `TapCallbacks`,
  `DragCallbacks`, `ScaleCallbacks`, `LongPressCallbacks`, `ScrollCallbacks` and
  `MouseMoveCallbacks`.
- A component only receives pointer events inside its area, so give a `PositionComponent` the
  right `size`, or override `containsLocalPoint` for other shapes. A `World` with `TapCallbacks`
  receives the taps that no other component handles.
- An event stops at the first component that handles it. Set `event.continuePropagation = true`
  only in components that should let it reach the ones below.
- For the keyboard, add `HasKeyboardHandlerComponents` to the game and `KeyboardHandler` to the
  components. Return `false` from `onKeyEvent` when the component consumed the key, and `true` to
  let other components see it too.
- Read the pressed keys in `onKeyEvent` and apply the movement in `update`, instead of moving the
  component in the event handler.


## Collision detection

- Add `HasCollisionDetection` to the game, or to the world when only it needs collisions.
- Add hitboxes such as `RectangleHitbox`, `CircleHitbox` or `PolygonHitbox` as children of the
  components, and add `CollisionCallbacks` to the components that react.
- Hitboxes are hollow by default, so a hitbox that is completely inside another one does not
  collide with it. Pass `isSolid: true` to the outer hitbox when that should count, for example
  for a player that can overlap a small coin completely.
- Use `onCollisionStart` for things that happen once per contact, like collecting a coin, and
  `onCollision` only for things that need to happen every frame of the contact.
- Give hitboxes that never need to collide with each other, like those of bullets or walls,
  `collisionType: CollisionType.passive`, so that the pairs are never checked.
- Turn on `debugMode` on a component, or run `flame debug on`, to see its hitboxes.


## Assets

- Every loader takes the full asset path, exactly as declared in `pubspec.yaml`, for example
  `assets/images/player.png`. Flame 2 prepends nothing, and the path is also the cache key.
- Load images in `onLoad` through the game, with `gameRef.loadSprite`,
  `gameRef.loadSpriteAnimation` or `gameRef.images`, so that they are cached once and shared.
- Preload what a level needs before it starts, with `images.loadAll([...])` or
  `images.loadAllImages(directory: 'assets/images/')`, and read it with `images.fromCache` later.
- Use a sprite sheet with `SpriteSheet` or `SpriteAnimation.fromFrameData` instead of one image
  per frame, and `SpriteBatch` to draw many sprites from one image.


## Movement, effects and timers

- Use effects for animated changes instead of writing the interpolation in `update`:
  `MoveEffect.to`, `MoveEffect.by`, `ScaleEffect`, `RotateEffect`, `OpacityEffect`,
  `ColorEffect`, `SequenceEffect` and `RemoveEffect`, all driven by an `EffectController`.
- Use `TimerComponent` for things that happen after a delay or repeatedly, such as spawning
  enemies, instead of adding up `dt` in fields.
- Use `HasTimeScale` to slow down or speed up a component and its children. It needs
  `CustomTraversal` before it, as in `with CustomTraversal, HasTimeScale`, and `FlameGame` already
  has `CustomTraversal`.

```dart
player.add(
  SequenceEffect([
    MoveEffect.by(Vector2(0, -80), EffectController(duration: 0.3)),
    MoveEffect.by(Vector2(0, 80), EffectController(duration: 0.3)),
  ]),
);

world.add(
  TimerComponent(period: 2, repeat: true, onTick: world.spawnEnemy),
);
```


## Flutter UI and game states

- Build menus, dialogs and text input as Flutter widgets in overlays: register them in the
  `overlayBuilderMap` of the `GameWidget` and show them with `game.overlays.add('PauseMenu')`.
- Keep the HUD that is drawn every frame, like a score or health bar, as components in
  `camera.viewport`.
- Use `RouterComponent` with `Route`, `OverlayRoute` and `WorldRoute` for screens such as the main
  menu, the levels and the game over screen.
- Pause with `pauseEngine()` and `resumeEngine()`, and read the state with `isPaused`.
- Keep game state in the game or in dedicated components, and use `flame_bloc` or
  `flame_riverpod` when the state is shared with Flutter widgets.


## Performance


### Never create objects in `update` and `render`

`update` and `render` run for every component in every frame, so an object that is created in
them is created 60 or more times per second per component. With a hundred components that is
thousands of objects per second that the garbage collector has to clean up, which shows up as
stutter. Create the objects once, store them in fields outside of those methods, and mutate them
instead:

- Keep `Paint` objects in fields, and change their `color` or other properties when the look has
  to change, instead of creating a new `Paint` in `render`.
- Change vectors in place with `setValues`, `setFrom`, `add`, `sub`, `scale`, `addScaled` and
  `normalize`. The operators `+`, `-`, `*` and `/`, and methods like `clone`, `normalized` and
  `Vector2.copy`, all create new vectors.
- Use a scratch vector stored in a field for temporary results of a calculation.
- Keep `Rect`, `RRect`, `Path` and `TextPaint` objects in fields too, and only rebuild them when
  what they are built from changes, for example in a listener on `size`.
- Only set `TextComponent.text` when the value has changed, since it lays out the text again.
- Avoid `toList()`, `where` and closures in `update` for collections that are iterated every
  frame. Loop over the children directly or use `children.query`.

This creates a `Paint`, a `Rect` and two vectors in every frame:

```dart
class Bullet() extends PositionComponent {
  final Vector2 velocity = Vector2(0, -300);

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFFFFFFFF));
  }
}
```

This creates them once and reuses them:

```dart
class Bullet() extends PositionComponent {
  final Vector2 velocity = Vector2(0, -300);
  final Paint _paint = Paint()..color = const Color(0xFFFFFFFF);
  late final Rect _rect = size.toRect();

  @override
  void update(double dt) {
    super.update(dt);
    position.addScaled(velocity, dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_rect, _paint);
  }
}
```

For a calculation that needs a temporary vector, mutate a field instead of chaining operators:

```dart
final Vector2 _toTarget = Vector2.zero();

void moveTowards(Vector2 target, double dt) {
  _toTarget
    ..setFrom(target)
    ..sub(position);
  if (_toTarget.length2 <= speed * speed * dt * dt) {
    position.setFrom(target);
  } else {
    position.addScaled(_toTarget..normalize(), speed * dt);
  }
}
```

Creating objects in constructors, `onLoad`, `onMount` and event handlers is fine, since those run
rarely.


### Other performance rules

- Reuse components that are spawned and removed often, such as bullets, with a `ComponentPool`.
- Make hitboxes passive where possible, and remove components as soon as they leave the play area.
- Use `SpriteBatch` for large numbers of sprites that share one image.
- Measure in profile mode on a real device before optimizing anything else.


## Hot reload

- `flame reload --merge` builds copies of the game with its constructor that takes no arguments and
  runs their `onLoad` methods. Give the game such a constructor, and skip side effects like playing
  music, network calls and analytics when `isHotReloadShadow` is true.
- Keep randomness out of what the code declares where you can, or seed it, so that the merge can
  tell what the code changed.


## Testing

- Write tests with `flame_test`. Use `testWithGame` for game logic, `FlameTester.testGameWidget`
  for input through the widget, and `testGolden` for rendering.
- Call `await game.ready()` after adding components, so that they are loaded and mounted, and
  advance time with `game.update(dt)`.
- Inject `Random` and other dependencies through the constructor, so that tests are deterministic.
- Test the behavior of components, such as positions, scores and which components exist, rather
  than private fields.

```dart
void main() {
  testWithGame('collecting a coin raises the score', MyGame.new, (game) async {
    await game.ready();
    final coin = Coin(position: game.world.player.position + Vector2(30, 0));
    game.world.add(coin);
    await game.ready();

    game.update(0);
    await game.ready();

    expect(game.score, 1);
    expect(coin.isMounted, isFalse);
  });
}
```


## Things to avoid

- The removed Flame 1 APIs: `HasGameReference` and `game`, `HasWorldReference` and `world` from
  the mixin, `GameWidget.controlled`, `Game.paused`, `Event.handled`, the game level detectors such
  as `TapDetector`, `PanDetector` and `ScaleDetector`, and asset paths without the `assets/`
  directory.
- `await add(...)`, since `add` returns `void`.
- Global singletons for the game or the player, use `gameRef`, `worldRef` and component keys.
- Logic in `render`, and drawing in `update`.
- Creating `Paint`, `Vector2`, `Rect` or other objects in `update` and `render`, mutate objects
  stored in fields instead.
- Moving by a fixed amount per frame instead of multiplying by `dt`.
