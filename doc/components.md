# Components

This class represent a single object on the screen, being a floating rectangle or a rotating sprite.

The base abstract class has the common expected methods update and render to be implemented.

The intermediate inheritance `PositionComponent` adds `x`, `y`, `width`, `height` and `angle` to your Components, as well as some useful methods like distance and angleBetween.

The most commonly used implementation, `SpriteComponent`, can be created with a `Sprite`:

```dart
    import 'package:flame/components/component.dart';

    Sprite sprite = Sprite('player.png');

    const size = 128.0;
    var player = SpriteComponent.fromSprite(size, size, sprite); // width, height, sprite

    // screen coordinates
    player.x = ... // 0 by default
    player.y = ... // 0 by default
    player.angle = ... // 0 by default

    player.render(canvas); // it will render only if the image is loaded and the x, y, width and height parameters are not null
```

In the event that you want to easily change the direction of your components rendering, you can also use
`renderFlipX` and `renderFlipY` to flip anything drawn to canvas during `render(Canvas canvas)`. 
This is available on all `PositionComponent` objects, and is especially useful on `SpriteComponent` and
`AnimationComponent`. Simply set `component.renderFlipX = true` for example reverse the horizontal rendering.

Every `Component` has a few other methods that you can optionally implement, that are used by the `BaseGame` class. If you are not using the base game, you can alternatively use these methods on your own game loop.

The `resize` method is called whenever the screen is resized, and in the beginning once when the component is added via the `add` method. You need to apply here any changes to the x, y, width and height of your component, or any other changes, due to the screen resizing. You can start these variables here, as the sprite won't be rendered until everything is set.

The `destroy` method can be implemented to return true and warn the `BaseGame` that your object is marked for destruction, and it will be remove after the current update loop. It will then no longer be rendered or updated.

The `isHUD` method can be implemented to return true (default false) to make the `BaseGame` ignore the `camera` for this element.

There are also other implementations:

* The `AnimationComponent` takes an `Animation` object and renders a cyclic animated sprite (more details about Animations [here](doc/images.md#Animation))
* The `SvgComponent` takes an `Svg` object and renders the SVG on the game
* The `ParallaxComponent` can render a parallax background with several frames
* The `Box2DComponent`, that has a physics engine built-in (using the [Box2D](https://github.com/google/box2d.dart) port for Dart)

## Animation Component

This component uses an instance of the [Animation](doc/images.md#Animation) class to represent a Component that has a sprite that runs a single cyclic animation.

This will create a simple three frame animation

```dart
    List<Sprite> sprites = [0, 1, 2].map((i) => new Sprite('player_${i}.png')).toList();
    this.player = AnimationComponent(64.0, 64.0, new Animation.spriteList(sprites, stepTime: 0.01));
```

If you have a sprite sheet, you can use the `sequenced` constructor, identical to the one provided by the `Animation` class (check more details in [the appropriate section](doc/images.md#Animation)):

```dart
    this.player = AnimationComponent.sequenced(64.0, 64.0, 'player.png', 2);
```

If you are not using `BaseGame`, don't forget this component needs to be update'd even if static, because the animation object needs to be ticked to move the frames.

## SvgComponent

This component uses an instance of `Svg` class to represent a Component that has a svg that is rendered on the game:

```dart
    Svg svg = Svg('android.svg');
    SvgComponent android = SvgComponent.fromSvg(100, 100, svg);
    android.x = 100;
    android.y = 100;
```

## FlareAnimation Component

This component wraps an instance of the [FlareAnimation](doc/images.md#FlareAnimation), it receives the filename of the Flare animation file, which animation from that file you want to use, and the `width` and `height` of the rendered animation.

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

## Composed component

A mixin that helps you to make a `Component` wraps other components. It is useful to group visual components through a hierarchy. When implemented, makes every item in its `components` collection field be updated and rendered with the same conditions.

Example of usage, where visibility of two components are handled by a wrapper:

```dart
class GameOverPanel extends PositionComponent with Resizable, ComposedComponent {
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

## Parallax Component

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

An example implementation can be found in the [examples directory](https://github.com/flame-engine/flame/tree/master/doc/examples/parallax).

## Box2D Component

Flame comes with a basic integration with the Flutter implementation of [Box2D](https://github.com/google/box2d.dart).

The whole concept of a box2d's World is mapped to the `Box2DComponent` component; every Body should be a `BodyComponent`, and added directly to the `Box2DComponent`, and not to the game list.

So you can have HUD and other non-physics-related components in your game list, and also as many `Box2DComponents` as you'd like (normally one, I guess), and then add your physical entities to your Components instance. When the Component is updated, it will use box2d physics engine to properly update every child.

You can see a more complete example of box2d usage on [this WIP game](https://github.com/feroult/haunt) made by @feroult (beware, though, it uses 0.6.x version of flame, but the Box2D related apis are unchanged).

## Tiled Component

Currently we have a very basic implementation of a Tiled component. This API uses the lib [Tiled](https://github.com/feroult/tiled.dart) to parse map files and render visible layers.

A example of how to use the API can be found [here](https://github.com/luanpotter/flame/tree/master/examples/tiled). 
