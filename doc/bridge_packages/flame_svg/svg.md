# Flame SVG

flame_svg provides a simple API for rendering SVG images in your game.


## Installation

Svg support is provided by the `flame_svg` bridge package, be sure to put it in your pubspec file
to use it.

If you want to know more about the installation visit
[flame_svg on pub.dev](https://pub.dev/packages/flame_svg/install).


## How to use flame_svg

To use it just import the `Svg` class from `'package:flame_svg/flame_svg.dart'`, and use the
following snippet to render it on the canvas:

```dart
final svgInstance = await Svg.load('assets/android.svg');

final position = Vector2(100, 100);
final size = Vector2(300, 300);

svgInstance.renderPosition(canvas, position, size);
```

or use the `SvgComponent` and add it to the component tree:

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final svgInstance = await Svg.load('assets/android.svg');
    final size = Vector2.all(100);
    final position = Vector2.all(100);
    final svgComponent = SvgComponent(
      size: size,
      position: position,
      svg: svgInstance,
    );

    add(svgComponent);
  }
}
```


## SvgPaths and SvgPathsComponent

`SvgPaths` imports the paths of an SVG file as Flutter `Path` objects with their paints, so that
they can be both rendered and used for collisions. Only the paths are imported: clipping, masks,
group opacity, text, images and patterns are ignored, so use `Svg` for files that rely on them.

By default, consecutive paths with the same paint are merged, as long as their bounds do not
overlap, which keeps the painting order of the file; pass `merge: false` to keep every path.

```dart
final svg = await SvgPaths.fromFile('assets/svgs/spaceship.svg');
svg.render(canvas, Vector2.all(100));
```

The `SvgPathsComponent` renders an `SvgPaths` object fitted within its size, keeping its aspect
ratio, and gives it hitboxes. Its size is by default the size of the bounds of the paths.
`SvgPathsComponent.load` reads the file from `assets/svgs/` by default:

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  @override
  Future<void> onLoad() async {
    final spaceship = await SvgPathsComponent.load(
      'spaceship',
      position: Vector2.all(100),
      size: Vector2.all(60),
    );
    add(spaceship);
  }
}
```

The `hitboxes` parameter, an `SvgHitboxes` value, chooses how the hitboxes are created:

- `SvgHitboxes.single` (the default): one `SvgPathsHitbox` for the whole file. Its paths count as a
  single solid, so a ray hits the outline of their union, and not the edges of paths that are
  inside of others.
- `SvgHitboxes.perPath`: a `PathComponent` for each path, each with its own `PathHitbox`, which
  render the paths themselves.

The polygons of the hitboxes are sampled from the paths every `sampling` units, and simplified
within a `tolerance`, both in the units of the component and not of the SVG file. With `filter`,
the default, the polygons inside of the largest one are left out. Pass `renderHitboxes: true` to
see the hitboxes.

To add a hitbox to a component of your own, `SvgPathsComponent.createSvgPathsHitbox` and
`SvgPathsComponent.createPathComponents` create the same hitboxes for a given size.


## SvgPathsAnimationComponent

The `SvgPathsAnimationComponent` plays an `SvgPathsAnimation`, much like the
`SpriteAnimationComponent` plays a `SpriteAnimation`, but each frame is an `SvgPaths` object loaded
from its own SVG file.

Each frame is described by the time it appears, its `start`, and the time it lasts, its
`duration`, both in seconds:

- Overlapping frames are all rendered, in the order of the frames.
- During a gap between frames, the frames shown last remain on screen.
- Before the earliest frame appears, that frame is already shown in the first loop, while in the
  next loops the frames shown last remain.

By default, each loop of the animation lasts until the latest end of its frames. A longer
`duration` adds a pause at the end of each loop.

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final animation = await SvgPathsAnimation.load(
      [
        SvgPathsAnimationFrameData(
          fileName: 'assets/svgs/invader1.svg',
          start: 0,
          duration: 0.3,
        ),
        SvgPathsAnimationFrameData(
          fileName: 'assets/svgs/invader1_feet_in.svg',
          start: 0.4,
          duration: 0.3,
        ),
      ],
      duration: 1.2,
    );

    add(
      SvgPathsAnimationComponent(
        animation,
        position: Vector2.all(100),
        size: Vector2.all(60),
      ),
    );
  }
}
```

The frames are expected to share the same size and position. They are all rendered from the
union of their bounds, the `area` of the animation, which is fitted within the size of the
component while keeping its aspect ratio. The size of the component is by default the size of
that area.

Each SVG file used by the frames gets an `SvgPathsHitbox`, which is only a child of the component
while one of its frames is shown, so that hidden frames neither collide nor get hit by rays. Like
any child, a hitbox is added or removed at the next tick after its frames change. Pass
`hitboxes: false` to skip them, or `renderHitboxes: true` to see them.

Like the `SpriteAnimationComponent`, the component can be paused with `playing`, removed when a
non-looping animation finishes with `removeOnFinish`, and reset when removed with
`resetOnRemove`. Its `animationTicker` exposes the frames currently shown, and the `onStart`,
`onFrame` and `onComplete` callbacks. An `SvgPathsAnimation` can be shared by several
components, since each one gets its own ticker.
