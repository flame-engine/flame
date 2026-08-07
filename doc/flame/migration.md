# Migration Guides

This section describes the breaking changes that you need to be aware of when upgrading between
major versions of Flame, together with the steps required to migrate your code.


## Migrating from v1.38.0 to v2.0.0


### `HasGameRef` removed in favour of `HasGameReference`

The deprecated `HasGameRef` mixin has been removed. Use `HasGameReference` instead, which is
otherwise identical apart from not offering the `gameRef` alias — use `game`:

```dart
// Before
class MyComponent extends Component with HasGameRef<MyGame> {
  void doSomething() => gameRef.score++;
}

// After
class MyComponent extends Component with HasGameReference<MyGame> {
  void doSomething() => game.score++;
}
```

The `game` getter, its setter (useful for mocking in tests), and the `findGame()` override all
behave exactly as before.


### Asset prefix removed

`Images` and `AssetsCache` no longer prepend anything to the paths you give them. `Images` used to
prepend `assets/images/` and `AssetsCache` used to prepend `assets/`, both configurable through a
`prefix` property. That property is gone, along with the `prefix` constructor argument.

Every asset is now addressed by its full path, exactly as declared in the `pubspec.yaml`:

```dart
// Before
await Flame.images.load('player.png');
final level = await Flame.assets.readJson('levels/level1.json');

// After
await Flame.images.load('assets/images/player.png');
final level = await Flame.assets.readJson('assets/levels/level1.json');
```

This applies to everything that loads through those caches, including `Sprite.load`,
`SpriteAnimation.load`, `SpriteBatch.load`, `Game.loadSprite`, `Game.loadSpriteAnimation`, the
`Parallax` loaders and `ParallaxImageData`/`ParallaxAnimationData`, and the `.asset` constructors of
`SpriteWidget`, `SpriteAnimationWidget`, `NineTileBoxWidget` and `SpriteButton`.

If you relied on a custom prefix, there is nothing to replace it with, and nothing to configure:
just write the paths you actually want.

```dart
// Before
Flame.images.prefix = 'gfx/';
await Flame.images.load('player.png');

// After
await Flame.images.load('gfx/player.png');
```


#### Cache keys are now the full path

The path is also the key the asset is cached under, so anything that reads the cache by key needs
the same full path:

```dart
// Before
await Flame.images.load('player.png');
final image = Flame.images.fromCache('player.png');

// After
await Flame.images.load('assets/images/player.png');
final image = Flame.images.fromCache('assets/images/player.png');
```

This affects `Images.fromCache`, `Images.containsKey`, `Images.clear`, `Images.keys`,
`AssetsCache.fromCache` and `AssetsCache.clear`. It also affects `SpriteBatch`, whose internal
`imageKey` is derived from the path you loaded with.

One consequence is a bug fix: `Images.load` now includes the package in the cache key, matching what
`AssetsCache` already did. Previously, loading the same filename from two different packages
collided on one key and the second load silently returned the first package's image.


#### `loadAllImages` and `loadAllFromPattern` require a directory

These two methods used the prefix both to filter the asset manifest and to strip it back off the
resulting keys. They now take a required `directory` argument instead, and cache entries under their
full manifest path. Pass an empty string to scan the whole bundle.

```dart
// Before
await Flame.images.loadAllImages();

// After
await Flame.images.loadAllImages(directory: 'assets/images/');
```


#### `flame_audio`

The global `AudioCache` is now created with an empty prefix, so audio paths are full paths too.
`FlameAudio.updatePrefix()` has been removed, as there is no longer a prefix to update.

```dart
// Before
FlameAudio.play('explosion.mp3');
FlameAudio.bgm.play('music/theme.mp3');

// After
FlameAudio.play('assets/audio/explosion.mp3');
FlameAudio.bgm.play('assets/audio/music/theme.mp3');
```


#### `flame_tiled`

The `prefix` argument is gone from `TiledComponent.load`, `RenderableTiledMap.fromFile`,
`RenderableTiledMap.fromString` and `FlameTsxProvider.parse`. The map's file name is now a full
path, and the assertion that it must not contain path separators has been removed.

External `.tsx` tilesets are resolved relative to the map's own directory, derived from that path.
`RenderableTiledMap.fromString` has no path to derive from, so its `prefix` argument became
`tsxDirectory`.

Watch out for these two, since they change behavior without failing to compile:
`RenderableTiledMap.fromString`'s `tsxDirectory` and `FlameTsxProvider.parse`'s third argument both
default to `''` now, where the old `prefix` defaulted to `assets/tiles/`. If you call either
directly and rely on that default, pass the directory explicitly.

Tileset and image-layer sources are resolved against a new `imagesDirectory` argument, which
defaults to `assets/images/` and so preserves the previous behavior.

```dart
// Before
await TiledComponent.load('map.tmx', Vector2.all(16));
await TiledComponent.load(
  'map.tmx',
  Vector2.all(16),
  prefix: 'assets/maps/',
);

// After
await TiledComponent.load('assets/tiles/map.tmx', Vector2.all(16));
await TiledComponent.load('assets/maps/map.tmx', Vector2.all(16));
```

Note that `TiledAtlas` cache keys are now scoped by `imagesDirectory`, so a key that was
`tiles.png` is now `assets/images/tiles.png`.


#### `flame_texturepacker`

The `assetsPrefix` argument is gone from `atlasFromAssets`, `TexturePackerAtlas.load` and
`TexturePackerAtlas.loadAtlas`. The atlas path is a full path, and page textures listed inside the
atlas are resolved relative to the atlas's own directory.

```dart
// Before
final atlas = await atlasFromAssets('atlas_map.atlas');

// After
final atlas = await atlasFromAssets('assets/images/atlas_map.atlas');
```


#### `flame_sprite_fusion`

The `tilemapPrefix` argument is gone from `SpriteFusionTilemapComponent.load`. Both `mapJsonFile`
and `spriteSheetFile` are now full paths.

```dart
// Before
await SpriteFusionTilemapComponent.load(
  mapJsonFile: 'map.json',
  spriteSheetFile: 'spritesheet.png',
);

// After
await SpriteFusionTilemapComponent.load(
  mapJsonFile: 'assets/tiles/map.json',
  spriteSheetFile: 'assets/images/spritesheet.png',
);
```


### `VerticalDragDetector` and `HorizontalDragDetector` removed

Both game-level mixins have been removed, with no direct replacement in Flame.

They existed only to expose Flutter's `VerticalDragGestureRecognizer` and
`HorizontalDragGestureRecognizer`, whose distinguishing feature is not the filtering itself but how
they behave in Flutter's gesture arena: an axis-constrained recognizer yields to a competitor on the
other axis. That matters when a `GameWidget` is nested inside a scrollable, which is a concern of
the widget tree rather than of the game, and it is not something the component-level `DragCallbacks`
can reproduce.

If your game accepts drags on any axis, use `DragCallbacks`, which can be mixed directly into your
game class:

```dart
// Before
class MyGame extends FlameGame with VerticalDragDetector {
  @override
  void onVerticalDragUpdate(DragUpdateInfo info) { /* ... */ }
}

// After
class MyGame extends FlameGame with DragCallbacks {
  @override
  void onDragUpdate(DragUpdateEvent event) { /* ... */ }
}
```

If you specifically need the arena behavior, wrap your `GameWidget` in Flutter's own
[`GestureDetector`](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html) and use its
`onVerticalDragUpdate` / `onHorizontalDragUpdate` callbacks.


### `ForcePressDetector` removed

The `ForcePressDetector` mixin and its `ForcePressInfo` event class have been removed, with no
replacement.

It was a niche API, only available on some older Apple's 3D Touch devices; the iPhone XS and XS Max
(2018) were the last models to include it (see Apple's
[Models with 3D Touch](https://support.apple.com/guide/iphone/aside/iph945ccc462/14.0/ios/14.0),
a list that Apple even stopped carrying forward after the iOS 14 guide). Every iPhone since,
starting with the XR, uses Haptic Touch, which responds to how long a press lasts rather than how
hard it is, and so never produces these callbacks. Only a handful of Android devices ever
supported it, and some of those (such as the Pixel 2 and 3) have faux pressure sensors that never
fired the callbacks anyway.

Combined with force press being the last gesture without an equivalent on the component-level event
system, maintaining it was no longer worth the surface area.

If you do still target a 3D Touch device, the gesture remains fully available from Flutter: wrap
your `GameWidget` in a
[`GestureDetector`](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html) and use its
`onForcePressStart`, `onForcePressPeak`, `onForcePressUpdate` and `onForcePressEnd` callbacks
directly.


### Deprecated tap and long press game detectors removed

The game-level detector mixins that were deprecated in v1.38.0 have now been removed, together with
the event classes that only they used:

| Removed | Use instead |
| --- | --- |
| `TapDetector` | `TapCallbacks` |
| `SecondaryTapDetector` | `SecondaryTapCallbacks` |
| `TertiaryTapDetector` | `TertiaryTapCallbacks` |
| `DoubleTapDetector` | `DoubleTapCallbacks` |
| `LongPressDetector` | `LongPressCallbacks` |
| `LongPressStartInfo` | `LongPressStartEvent` |
| `LongPressMoveUpdateInfo` | `LongPressMoveUpdateEvent` |
| `LongPressEndInfo` | `LongPressEndEvent` |

The replacements are mixed into a component rather than into the game, and each callback takes a
single event object:

```dart
// Before
class MyGame extends FlameGame with TapDetector {
  @override
  void onTapDown(TapDownInfo info) {
    final position = info.eventPosition.widget;
  }
}

// After
class MyComponent extends PositionComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    final position = event.localPosition;
  }
}
```

Note that a component only receives events that occur on top of it, as determined by
`containsLocalPoint()`, whereas the old game-level detectors received every event on the game
surface. To keep the old whole-screen behavior, add the mixin to your `FlameGame` subclass directly
— `FlameGame` is itself a `Component`.

See [Tap Events](inputs/tap_events.md) and [Long Press Events](inputs/long_press_events.md) for the
full replacement APIs.


### `ScaleDetector` removed

The `ScaleDetector` game mixin has been removed, together with the event classes that only it used:

| Removed | Use instead |
| --- | --- |
| `ScaleDetector` | `ScaleCallbacks` |
| `ScaleStartInfo` | `ScaleStartEvent` |
| `ScaleUpdateInfo` | `ScaleUpdateEvent` |
| `ScaleEndInfo` | `ScaleEndEvent` |

`ScaleUpdateEvent` is a strict superset of `ScaleUpdateInfo`: `info.scale.global.x` and
`info.scale.global.y` become `event.horizontalScale` and `event.verticalScale`, and
`info.delta.global` becomes `event.focalPointDelta`.

There is one behavioral difference to be aware of. The old detector was backed by Flutter's
`ScaleGestureRecognizer`, which also emits scale events for a *single* pointer, with a scale factor
of 1.0 — a quirk that games commonly relied on to pan the camera from within `onScaleUpdate`. The
new `MultiDragScaleGestureRecognizer` only emits scale events once two or more pointers are down, so
panning must now be handled with `DragCallbacks`, which can be combined freely with `ScaleCallbacks`:

```dart
// Before
class MyGame extends FlameGame with ScaleDetector {
  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scale = info.scale.global;
    if (!scale.isIdentity()) {
      camera.viewfinder.zoom = startZoom * scale.y;
    } else {
      camera.moveBy((info.delta.global..negate()) / camera.viewfinder.zoom);
    }
  }
}

// After
class MyGame extends FlameGame with ScaleCallbacks, DragCallbacks {
  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    camera.viewfinder.zoom = startZoom * event.verticalScale;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Two-finger pinches emit both drag and scale; skip pan while zooming
    if (isScaling) {
      return;
    }
    camera.moveBy((event.localDelta..negate()) / camera.viewfinder.zoom);
  }
}
```

Note that trackpad pinch gestures are not currently recognized by the new system:
`MultiDragScaleGestureRecognizer` does not yet handle Flutter's `PointerPanZoom` events, which is how
a trackpad pinch reaches a scale recognizer. Touchscreen pinches are unaffected.

See [Scale Events](inputs/scale_events.md) for the full replacement API.


### `MultiTouchTapDetector` and `MultiTouchDragDetector` removed

Both game-level mixins have been removed:

| Removed | Use instead |
| --- | --- |
| `MultiTouchTapDetector` | `TapCallbacks` |
| `MultiTouchDragDetector` | `DragCallbacks` |

The `pointerId` that used to be passed as a separate first argument is now carried on the event
itself, so simultaneous touches can still be told apart:

```dart
// Before
class MyGame extends FlameGame with MultiTouchTapDetector {
  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    taps[pointerId] = info.eventPosition.widget;
  }
}

// After
class MyGame extends FlameGame with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    taps[event.pointerId] = event.canvasPosition;
  }
}
```

`TapCallbacks` has no equivalent of `MultiTouchTapDetector.onTap`, which was a direct passthrough of
Flutter's "tap completed" callback on `MultiTapGestureRecognizer`. Use `onTapUp` instead, which fires
at the same point in the gesture.

Because the new mixins are routed through `MultiDragScaleDispatcher`, they no longer conflict with
`PanDetector` in the gesture arena, and the assertion that used to guard against combining
`MultiTouchDragDetector` with `PanDetector` has been removed.

See [Tap Events](inputs/tap_events.md) and [Drag Events](inputs/drag_events.md) for the full
replacement APIs.


### `ScrollDetector` removed

The `ScrollDetector` game mixin has been removed, together with the event class that only it used:

| Removed | Use instead |
| --- | --- |
| `ScrollDetector` | `ScrollCallbacks` |
| `PointerScrollInfo` | `ScrollEvent` |

The scroll delta is now read directly off the event rather than through a nested wrapper, and the
event carries the usual `PositionEvent` fields, so the position where the scroll occurred is
available as `devicePosition` / `canvasPosition` / `localPosition`:

```dart
// Before
class MyGame extends FlameGame with ScrollDetector {
  @override
  void onScroll(PointerScrollInfo info) {
    camera.viewfinder.zoom += info.scrollDelta.global.y.sign * 0.02;
  }
}

// After
class MyGame extends FlameGame with ScrollCallbacks {
  @override
  void onScroll(ScrollEvent event) {
    camera.viewfinder.zoom += event.scrollDelta.y.sign * 0.02;
  }
}
```

Unlike the old detector, which received every scroll event anywhere on the game surface,
`ScrollCallbacks` is routed by position like the other component callbacks: a component only receives
scrolls that occur on top of it, as determined by `containsLocalPoint()`. Mixing it into your
`FlameGame` subclass directly, as above, keeps the old whole-surface behavior.

See [Pointer Events](inputs/pointer_events.md) for the full replacement API.


### `MouseMovementDetector` removed and `PointerMove*` renamed to `MouseMove*`

The `MouseMovementDetector` game mixin has been removed, together with the event class that only it
used. At the same time, the component-level API it is replaced by has been renamed from `PointerMove`
to `MouseMove`:

| Removed / renamed | Use instead |
| --- | --- |
| `MouseMovementDetector` | `MouseMoveCallbacks` |
| `PointerHoverInfo` | `MouseMoveEvent` |
| `PointerMoveCallbacks` | `MouseMoveCallbacks` |
| `PointerMoveEvent` | `MouseMoveEvent` |
| `PointerMoveDispatcher` | `MouseMoveDispatcher` |
| `onPointerMove` | `onMouseMove` |
| `onPointerMoveStop` | `onMouseMoveStop` |

The rename has two reasons. Flame's `PointerMoveEvent` collided with Flutter's class of the same
name, forcing a `hide` on any file that imported both `package:flame/events.dart` and
`package:flutter/material.dart`. And "mouse move" is simply more accurate: the event wraps Flutter's
`PointerHoverEvent` and is delivered from a `MouseRegion`, so it is mouse movement specifically, not
pointer movement in general. `MouseMoveDispatcherKey` was already named this way.

Migrating from the detector, the callback keeps its `onMouseMove` name and only the parameter
changes, with the position read directly off the event instead of through the nested `eventPosition`
wrapper:

```dart
// Before
class MyGame extends FlameGame with MouseMovementDetector {
  @override
  void onMouseMove(PointerHoverInfo info) {
    target = info.eventPosition.widget;
  }
}

// After
class MyGame extends FlameGame with MouseMoveCallbacks {
  @override
  void onMouseMove(MouseMoveEvent event) {
    target = event.canvasPosition;
  }
}
```

Unlike the old detector, which received every mouse movement anywhere on the game surface,
`MouseMoveCallbacks` is routed by position like the other component callbacks: a component only
receives movements that occur on top of it, as determined by `containsLocalPoint()`. Mixing it into
your `FlameGame` subclass directly, as above, keeps the old whole-surface behavior.
`MouseMoveCallbacks` additionally offers `onMouseMoveStop`, which has no equivalent on the old
detector.

`flame_test`'s `createMouseMoveEvent` helper now returns a `MouseMoveEvent`, and if you were using
`flame_behaviors`, note that it no longer re-exports the legacy `*Info` event classes.

See [Pointer Events](inputs/pointer_events.md) for the full replacement API.


### `onDragCancel` no longer delegates to `onDragEnd`

`DragCallbacks.onDragCancel` used to convert the cancellation into an `onDragEnd` event by default,
which made a cancelled drag look exactly like a completed one. A cancellation means that the gesture
was interrupted (another recognizer won the gesture arena, a second pointer triggered a scale
takeover, a system event, etc.) and it carries no velocity, so components such as drag-to-dismiss
would apply their action even though the drag never finished. This is not a rare event either, since
with `MultiDragScaleDispatcher` every two finger pinch cancels the individual pointer drags.

The default implementation now only resets `isDragged`, which means that `onDragEnd` is no longer
called when a drag is cancelled. If you were relying on the old behavior, override `onDragCancel`
and forward the event yourself with `DragCancelEvent.toDragEnd`:

```dart
// Before
class MyComponent extends PositionComponent with DragCallbacks {
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // This also ran when the drag was cancelled.
    dismiss();
  }
}

// After
class MyComponent extends PositionComponent with DragCallbacks {
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    dismiss();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    onDragEnd(event.toDragEnd());
  }
}
```

If a cancelled drag should instead be reverted, put that logic in `onDragCancel` without calling
`onDragEnd`.


### `MultiDragDispatcher` removed

The deprecated `MultiDragDispatcher` and `MultiDragDispatcherKey` aliases have been removed. Use
`MultiDragScaleDispatcher` and `MultiDragScaleDispatcherKey` instead, if you were using them
directly at all (normally you should just use the mixins).

```dart
// Before
game.findByKey(const MultiDragDispatcherKey())
    as MultiDragDispatcher?;

// After
game.findByKey(const MultiDragScaleDispatcherKey())
    as MultiDragScaleDispatcher?;
```


### `Event.handled` removed in favour of `continuePropagation`

Events used to carry two independent booleans: `handled`, which Flame never set nor read, and
`continuePropagation`, which actually controls whether an event keeps traversing down the component
tree. The former has been removed; `continuePropagation` is now the single propagation flag on every
event.

By default, an event stops at the first component that can handle it, so a component that "consumes"
an event does not need to do anything at all — the components below it will not see it:

```dart
// Before
class Square extends RectangleComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
    event.handled = true;
  }
}

class MyWorld extends World with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    if (!event.handled) {
      add(Square(event.localPosition));
    }
  }
}

// After
class Square extends RectangleComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
  }
}

class MyWorld extends World with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    add(Square(event.localPosition));
  }
}
```

If you were using `handled` to let an event reach several components, set
`event.continuePropagation = true` in the components that should pass it along instead.

The equivalent field on the deprecated `*Info` event classes (`TapDownInfo.handled` and friends) has
been removed as well.


### `add`, `addAll` and `addToParent` are now synchronous

`Component.add`, `Component.addAll` and `Component.addToParent` used to return a future, which made
it look like you could await the addition. That future only covered the child's loading, never its
mounting, so awaiting it was misleading, and forgetting to await it (or to wrap it in `unawaited`)
tripped the `discarded_futures` lint in a lot of games. All three methods now return `void`.

Drop the `await`:

```dart
// Before
await add(MyComponent());
await addAll([MyComponent(), MyOtherComponent()]);

// After
add(MyComponent());
addAll([MyComponent(), MyOtherComponent()]);
```

If you were relying on the returned future to know when the child had loaded, await the child's
`loaded` future instead:

```dart
// Before
await add(crate);

// After
add(crate);
await crate.loaded;
```

For a batch of children, `loaded`, `mounted` and `removed` are also available on any
`Iterable<Component>`:

```dart
// Before
await addAll(crates);

// After
addAll(crates);
await crates.loaded;
```

Or, when you need them to be present in `children` rather than just loaded, await
`game.lifecycleEventsProcessed` once after adding them.


#### Load errors are no longer reported by `GameWidget.errorBuilder`

`GameWidget.errorBuilder` shows a widget when the *game's* loading fails, and it used to catch a
failing child's `onLoad` as well, because `await add(child)` chained the child's error onto the
game's own `onLoad` future. Since `add` no longer returns a future, that chain is gone: a child that
throws in `onLoad` no longer reaches `errorBuilder`.

The component itself is not added to the tree, and the rest of the game keeps running. The error is
reported through the child's `loaded` future, and if nothing is awaiting it, it is handed to the
current `Zone` as an uncaught error.

To get the old behavior for a specific child, await its `loaded` future inside the parent's
`onLoad`, which puts the error back onto the future `errorBuilder` watches:

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final level = Level();
    world.add(level);
    // Throws here if Level.onLoad fails, so errorBuilder is shown.
    await level.loaded;
  }
}
```


### `GameWidget.controlled` renamed to `GameWidget.managed`

The `GameWidget.controlled` constructor has been renamed to `GameWidget.managed`. The behavior is
unchanged; only the name is different.

Replace every usage of `GameWidget.controlled` with `GameWidget.managed`:

```dart
// Before
GameWidget.controlled(
  gameFactory: MyGame.new,
);

// After
GameWidget.managed(
  gameFactory: MyGame.new,
);
```


### `Game.paused` renamed to `Game.isPaused`

The `paused` getter and setter on `Game` have been renamed to `isPaused`, to be consistent with the
other boolean properties in Flame. The behavior is unchanged; only the name is different.

Replace every usage of `game.paused` with `game.isPaused`:

```dart
// Before
if (game.paused) {
  game.paused = false;
}

// After
if (game.isPaused) {
  game.isPaused = false;
}
```
