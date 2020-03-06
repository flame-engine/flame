# Component System

If using the `BaseGame` class instead of the `Game` class, as your core game loop, you can use Flame's component system to manage your game objects.

| Table of Contents |
| :-- |
| [Comonent (abstract class)](#component-abstract-class) <br/> [PositionComponent (abstract class)](#positioncomponent-abstract-class) <br/> [ComposedComponent (mixin)](#composedcomponent-mixin) <br/> [SpriteComponent](#SpriteComponent) <br/> [AnimationComponent](#AnimationComponent) <br/> [SvgComponent](#SvgComponent) <br/> [FlareComponent](#FlareComponent) <br/> [ParallaxComponent](#ParallaxComponent) <br/> [TiledComponent](#TiledComponent) <br/> [NineTileBoxComponent](#NineTileBoxComponent) <br/> [Box2DComponent](#Box2DComponent) |

## Component (abstract class)

The base abstract `Component` class represents a single object on the screen, being a floating rectangle or a rotating sprite.

The `Component` class implements and automatically calls the usual methods of `update()` and `render()`.

Every `Component` has a few other methods that you can optionally implement, that are used by the `BaseGame` class. If you are not using the base game, you can alternatively use these methods on your own game loop.

The `resize()` method is called whenever the screen is resized, and in the beginning once when the component is added via the `add` method. You need to apply here any changes to the x, y, width and height of your component, or any other changes, due to the screen resizing. You can start these variables here, as the sprite won't be rendered until everything is set.

The `destroy()` method can be implemented to return true and warn the `BaseGame` that your object is marked for destruction, and it will be remove after the current update loop. It will then no longer be rendered or updated.

The `isHUD()` method can be implemented to return true (default false) to make the `BaseGame` ignore the `camera` for this element.

## PositionComponent (abstract class)

The intermediate inheritance `PositionComponent` class controls the position and final size of your game objects by adding `x`, `y`, `width`, `height` and `angle` (in radians), as well as some useful methods like `distance()` and `angleBetween()`.

In the event that you want to easily change the direction of your components rendering, you can also use
`renderFlipX` and `renderFlipY` to flip anything drawn to canvas during `render(Canvas canvas)`. 
This is available on all `PositionComponent` objects, and is especially useful on `SpriteComponent` and
`AnimationComponent`. Simply set `component.renderFlipX = true`, for example, to reverse the horizontal rendering.

## ComposedComponent (mixin)

The `ComposedComponent` mixin helps you make a `Component` that wraps other components. It is useful to group visual components through a hierarchy. When implemented, every item in its `components` collection field is updated and rendered with the same conditions.

Example of usage, where visibility of two components are handled by a wrapper:

```dart
class GameOverPanel extends PositionComponent with HasGameRef, Tapable, ComposedComponent {
  bool visible = false;

  GameOverText gameOverText;
  GameOverButton gameOverButton;

  GameOverPanel(Image spriteImage) : super() {
    gameOverText = GameOverText(spriteImage); // GameOverText is a Component
    gameOverButton = GameOverButton(spriteImage); // GameOverRestart is a SpriteComponent

    components..add(gameOverText)..add(gameOverButton);
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    } // If not, neither of its `components` will be rendered
  }
}
```

## SpriteComponent

The high-level `SpriteComponent` is intended for easy component creation from a [`Sprite` object](/doc/images.md#sprite).

For example, to create a `SpriteComponent` from a `Sprite`:

```dart
import 'package:flame/components/component.dart';

// on your constructor or init logic
Image image = Flame.images.fromCache('player.png');
Sprite sprite = Sprite.fromImage(image);

const size = 128.0; // render size, not sprite source size
final player = SpriteComponent(
  sprite,
  width:  size,
  height: size,
  x:      ..., // starting X position
  y:      ..., // starting Y position
  angle:  ..., // starting rotation (in radians)
);
```

## AnimationComponent

The high-level `AnimationComponent` is intended for easy component creation from an [`Animation` object](/doc/images.md#animation).

For example, this will create a simple, three-frame animation:

```dart
Image image = Flame.images.fromCache('playersheet.png');
this.player = AnimationComponent(
  Animation.fromImage(
    image,
    frameWidth:  64,
    frameHeight: 64,
    frameCount:  3,
    stepTime:    0.01
  ),
  x:      10, // starting X position
  y:      10, // starting Y position
);
```

`AnimationComponent` adds an additional optional named parameter:

* `destroyOnFinish:` automatically execute `detroy()` on this object when animation finishes (defaults to false)

If you are not using `BaseGame`, don't forget this component needs `update()` to be called to tick the internal clock to move the frames.

See the [**animations** example app](/doc/examples/animations).

See the [**spritesheet** example app](/doc/examples/spritesheet).

## SvgComponent

The high-level `SvgComponent` is intended for easy component creation from an [`Svg` object](/doc/images.md#svg).

For example:

```dart
Svg svg = Svg('android.svg');
SvgComponent android = SvgComponent(
  svg,
  width:  100,
  height: 100,
  x:      10,
  y:      10,
);
```

See the [**svg** example app](/doc/examples/svg).

## FlareComponent

This component wraps an instance of the [FlareAnimation](/doc/images.md#FlareAnimation), it receives the filename of the Flare animation file, which animation from that file you want to use, and the `width` and `height` of the rendered animation.

```dart
final fileName = "assets/Bob_Minion.flr";
final animation = "Wave";
final width = 306;
final height = 228;

FlareComponent flareAnimation = FlareComponent(fileName, animation, width, height);
flareAnimation.x = 50;
flareAnimation.y = 240;
add(flareAnimation);
```

You can also change the current playing animation using the `updateAnimation` method.

See the [**flare** example app](/doc/examples/flare).

## ParallaxComponent

This Component can be used to render pretty backgrounds by drawing several transparent images on top of each other, each dislocated by a tiny amount.

The rationale is that when you look at the horizon and moving, closer objects seem to move faster than distant ones.

This component simulates this effect, making a more realistic background with a feeling of depth.

Create it like this:

```dart
final images = [
ParallaxImage("mountains.jpg"),
ParallaxImage("forest.jpg"),
ParallaxImage("city.jpg"),
];
this.bg = ParallaxComponent(images);
```

This creates a static background, if you want it to move you have to set the named optional parameters `baseSpeed` and `layerDelta`. For example if you want to move your background images along the X-axis and have the images further away you would do the following:

```dart
this.bg = ParallaxComponent(images, baseSpeed: Offset(50, 0), layerDelta: Offset(20, 0));
```
You can set the baseSpeed and layerDelta at any time, for example if your character jumps or your game speeds up.

```dart
this.bg.baseSpeed = Offset(100, 0);
this.bg.layerDelta = Offset(40, 0);
```

By default the images are aligned to the bottom left, repeated along the X-axis and scaled proportionally so that the image covers the height of the screen. If you want to change this behaviour, for example if you are not making a side scrolling game, you can set the `repeat`, `alignment` and `fill` parameters for each ParallaxImage.

Advanced example:
```dart
final images = [
ParallaxImage("stars.jpg", repeat: ImageRepeat.repeat, alignment: Alignment.center, fill: LayerFill.width),
ParallaxImage("planets.jpg", repeat: ImageRepeat.repeatY, alignment: Alignment.bottomLeft, fill: LayerFill.none),
ParallaxImage("dust.jpg", repeat: ImageRepeat.repeatX, alignment: Alignment.topRight, fill: LayerFill.height),
];
this.bg = ParallaxComponent(images, baseSpeed: Offset(50, 0), layerDelta: Offset(20, 0));
```

* The stars image in this example will be repeatedly drawn in both axis, align in the center and be scaled to fill the screen width.
* The planets image will be repeated in Y-axis, aligned to the bottom left of the screen and not be scaled.
* The dust image will be repeated in X-axis, aligned to the top right and scaled to fill the screen height.

Once you are done with setting the parameters to your needs, render the ParallaxComponent as any other component.

Like the AnimationComponent, even if your parallax is static, you must call update on this component, so it runs its animation.
Also, don't forget to add you images to the `pubspec.yaml` file as assets or they wont be found.

See the [**parallax** example app](/doc/examples/parallax).

## TiledComponent

Currently we have a very basic implementation of a Tiled component. This API uses the lib [Tiled](https://github.com/feroult/tiled.dart) to parse map files and render visible layers.

See the [**tiled** example app](/doc/examples/tiled).

## NineTileBoxComponent

A Nine Tile Box is a rectangle drawn using a grid sprite.

The grid sprite is a 3x3 grid and with 9 blocks, representing the 4 corners, the 4 sides and the middle.

The corners are drawn at the same size, the sides are stretched on the side direction and the middle is expanded both ways.

Using this, you can get a box/rectangle that expands well to any sizes. This is useful for making panels, dialogs, borders.

See the [**nine_tile_box** example app](/doc/examples/nine_tile_box).

## Box2DComponent

Flame comes with a basic integration with the Flutter implementation of [Box2D](https://github.com/google/box2d.dart).

The whole concept of a box2d's World is mapped to the `Box2DComponent` component; every Body should be a `BodyComponent`, and added directly to the `Box2DComponent`, and not to the game list.

So you can have HUD and other non-physics-related components in your game list, and also as many `Box2DComponents` as you'd like (normally one, I guess), and then add your physical entities to your Components instance. When the Component is updated, it will use box2d physics engine to properly update every child.

You can see a more complete example of box2d usage on [this WIP game](https://github.com/feroult/haunt) made by @feroult (beware, though, it uses 0.6.x version of flame, but the Box2D related apis are unchanged).
