# Components

![Component Diagram](https://i.imgur.com/1mTqcqI.png)
This diagram might look intimidating, but don't worry, it is not as complex as it looks.

## Component
All components inherit from the abstract class `Component`.

If you want to skip reading about abstract classes you can jump directly to [PositionComponent](./components.md#PositionComponent).

Every `Component` has a few methods that you can optionally implement, that are used by the `BaseGame` class. If you are not using the base game, you can alternatively use these methods on your own game loop.

The `resize` method is called whenever the screen is resized, and in the beginning once when the component is added via the `add` method.

The `shouldRemove` variable can be overridden or set to true and `BaseGame` will remove the component before the next update loop. It will then no longer be rendered or updated. Note that `game.remove(Component c)` can also be used to remove components.

The `isHUD` variable can be overridden or set to true (default false) to make the `BaseGame` ignore the `camera` for this element, make it static in relation to the screen that is.

The `onMount` method can be overridden to run initialization code for the component. When this method is called, BaseGame ensures that all the mixins which would change this component's behaviour are already resolved.

The `onRemove` method can be overridden to run code before the component is removed from the game, it is only run once even if the component is removed both by using the `BaseGame` remove method and the ´Component´ remove method.

## BaseComponent
Usually if you are going to make your own component you want to extend `PositionComponent`, but if you want to be able to handle effects and child components but handle the positioning differently you can extend the BaseComponent.

It is used by `SpriteBodyComponent` and `BodyComponent` in Forge2D since those components doesn't have their position in relation to the screen, but in relation to the Forge2D world.

## PositionComponent

This class represent a single object on the screen, being a floating rectangle or a rotating sprite.

A `PositionComponent` has a `position`, `size` and `angle`, as well as some useful methods like `distance` and `angleBetween`.

In the event that you want to change the direction of your components rendering, you can also use
`renderFlipX` and `renderFlipY` to flip anything drawn to canvas during `render(Canvas canvas)`.
This is available on all `PositionComponent` objects, and is especially useful on `SpriteComponent` and
`SpriteAnimationComponent`. For example set `component.renderFlipX = true` to reverse the horizontal rendering.

## SpriteComponent
The most commonly used implementation of `PositionComponent` is `SpriteComponent`, and it can be created with a `Sprite`:

```dart
    import 'package:flame/components/component.dart';

    Sprite sprite = Sprite('player.png');

    final size = Vector2.all(128.0);
    var player = SpriteComponent.fromSprite(size, sprite);

    // screen coordinates
    player.position = ... // Vector2(0.0, 0.0) by default
    player.angle = ... // 0 by default

    player.render(canvas); // it will render only if the image is loaded and the position and size parameters are not null
```

## SpriteAnimationComponent

This class is used to represent a Component that has a sprite that runs a single cyclic animation.

This will create a simple three frame animation

```dart
    List<Sprite> sprites = [0, 1, 2].map((i) => Sprite('player_${i}.png')).toList();
    final size = Vector2.all(64.0);
    this.player = SpriteAnimationComponent(size, new Animation.spriteList(sprites, stepTime: 0.01));
```

If you have a sprite sheet, you can use the `sequenced` constructor, identical to the one provided by the `Animation` class (check more details in [the appropriate section](/doc/images.md#Animation)):

```dart
    final size = Vector2.all(64.0);
    this.player = SpriteAnimationComponent.sequenced(size, 'player.png', 2);
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

## FlareActorComponent

*Note*: The previous implementation of a Flare integration API using `FlareAnimation` and `FlareComponent` has been deprecated.

To use Flare within Flame, use the [`flame_flare`](https://github.com/flame-engine/flame_flare) package.

This is the interface to use a [flare animation](https://pub.dev/packages/flare_flutter) within flame.
`FlareActorComponent` has almost the same API as of flare's FlareActor widget. It receives the animation filename (that are loaded by default with `Flame.bundle`),
it also can receive a FlareController that can play multiple animations and control nodes.

```dart
    import 'package:flame_flare/flame_flare.dart';

    // your implementation of FlareController
    class WashingtonController extends FlareControls {
        
        ActorNode rightHandNode;
        
        void initialize(FlutterActorArtboard artboard) {
            super.initialize(artboard);
            
            // get flare node
            rightHand = artboard.getNode('right_hand');
        }
    }

    final fileName = 'assets/george_washington.flr';
    final size = Vector2(1776, 1804);
    final controller = WashingtonController(); //instantiate controller
    
    FlareActorComponent flareAnimation = FlareActorComponent(
      fileName,
      controller: controller,
      width: 306,
      height: 228,
    );
 
    flareAnimation.x = 50;
    flareAnimation.y = 240;
    add(flareAnimation);

    // to play an animation
    controller.play('rise_up');

    // you can add another animation to play at the same time
    controller.play('close_door_way_out');
    
    // also, get a flare node and modify it
    controller.rightHandNode.rotation = math.pi;
```

You can also change the current playing animation using the `updateAnimation` method.

For a working example, check this [source file](/doc/examples/flare/lib/main_component.dart).

## Composability of components

Sometimes it is useful to make your component wrap other components. For example by grouping visual components through a hierarchy.
You can do this by having child components on any component that extends `BaseComponent`, for example `PositionComponent` or `BodyComponent`.
When you have child components on a component every time the parent is updated and rendered, all the children are rendered and updated with the same conditions.

Example of usage, where visibility of two components are handled by a wrapper:

```dart
class GameOverPanel extends PositionComponent with HasGameRef<MyGame> {
  bool visible = false;

  GameOverText gameOverText;
  GameOverButton gameOverButton;

  GameOverPanel(Image spriteImage) : super() {
    gameOverText = GameOverText(spriteImage); // GameOverText is a Component
    gameOverButton = GameOverButton(spriteImage); // GameOverRestart is a SpriteComponent

    addChild(gameRef, gameOverText);
    addChild(gameRef, gameOverButton);
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    } // If not visible none of the children will be rendered
  }
}
```

## ParallaxComponent

This Component can be used to render pretty backgrounds by drawing several transparent images on top of each other, each dislocated by a tiny amount.

The rationale is that when you look at the horizon and moving, closer objects seem to move faster than distant ones.

This component simulates this effect, making a more realistic background with a feeling of depth.

Create it like this:

```dart
  final images = [
    ParallaxImage('mountains.jpg'),
    ParallaxImage('forest.jpg'),
    ParallaxImage('city.jpg'),
  ];
  this.bg = ParallaxComponent(images);
```

This creates a static background, if you want it to move you have to set the named optional parameters `baseSpeed` and `layerDelta`. For example if you want to move your background images along the X-axis and have the images further away you would do the following:

```dart
  this.bg = ParallaxComponent(images, baseSpeed: Offset(50, 0), layerDelta: Offset(20, 0));
```
You can set the baseSpeed and layerDelta at any time, for example if your character jumps or your game speeds up.

```dart
  this.bg.baseSpeed = Vector2(100, 0);
  this.bg.layerDelta = Vector2(40, 0);
```

By default the images are aligned to the bottom left, repeated along the X-axis and scaled proportionally so that the image covers the height of the screen. If you want to change this behaviour, for example if you are not making a side scrolling game, you can set the `repeat`, `alignment` and `fill` parameters for each ParallaxImage.

Advanced example:
```dart
  final images = [
    ParallaxImage('stars.jpg', repeat: ImageRepeat.repeat, alignment: Alignment.center, fill: LayerFill.width),
    ParallaxImage('planets.jpg', repeat: ImageRepeat.repeatY, alignment: Alignment.bottomLeft, fill: LayerFill.none),
    ParallaxImage('dust.jpg', repeat: ImageRepeat.repeatX, alignment: Alignment.topRight, fill: LayerFill.height),
  ];
  this.bg = ParallaxComponent(images, baseSpeed: Vector2(50, 0), layerDelta: Vector2(20, 0));
```

* The stars image in this example will be repeatedly drawn in both axis, align in the center and be scaled to fill the screen width.
* The planets image will be repeated in Y-axis, aligned to the bottom left of the screen and not be scaled.
* The dust image will be repeated in X-axis, aligned to the top right and scaled to fill the screen height.

Once you are done with setting the parameters to your needs, render the ParallaxComponent as any other component.

Like the SpriteAnimationComponent, even if your parallax is static, you must call update on this component, so it runs its animation.
Also, don't forget to add you images to the `pubspec.yaml` file as assets or they wont be found.

An example implementation can be found in the [examples directory](/doc/examples/parallax).

## SpriteBodyComponent

See [SpriteBodyComponent](/doc/forge2d.md#spritebodycomponent) in the box2d documentation.

## TiledComponent

Currently we have a very basic implementation of a Tiled component. This API uses the lib [Tiled](https://github.com/feroult/tiled.dart) to parse map files and render visible layers.

An example of how to use the API can be found [here](/doc/examples/tiled).

## IsometricTileMapComponent

This component allows you to render an isometric map based on a cartesian matrix of blocks and an isometric tileset.

A simple example on how to use it:

```dart
  // creates a tileset, the block ids are automatically assigned sequentially starting at 0, from left to right and then top to bottom.
  final tilesetImage = await images.load('tileset.png');
  final tileset = IsometricTileset(tilesetImage, 32);
  // each element is a block id, -1 means nothing
  final matrix = [[0, 1, 0], [1, 0, 0], [1, 1, 1]];
  add(IsometricTileMapComponent(tileset, matrix));
```

It also provides methods for converting coordinates so you can handle clicks, hovers, render entities on top of tiles, add a selector, etc.

A more in-depth example can be found [here](/doc/examples/isometric).

![An example of a isometric map with selector](images/isometric.png)

## NineTileBoxComponent

A Nine Tile Box is a rectangle drawn using a grid sprite.

The grid sprite is a 3x3 grid and with 9 blocks, representing the 4 corners, the 4 sides and the middle.

The corners are drawn at the same size, the sides are stretched on the side direction and the middle is expanded both ways.

Using this, you can get a box/rectangle that expands well to any sizes. This is useful for making panels, dialogs, borders.

Check the example app `nine_tile_box` details on how to use it.

## Effects

Flame provides a set of effects that can be applied to a certain type of components, these effects can be used to animate some properties of your components, like position or dimensions. You can check the list of those effects [here](/doc/effects.md).

Examples of the running effects can be found [here](/doc/examples/effects);
