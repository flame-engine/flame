# Flame 3D Component

flame_3d_component lets you put a 3D object, rendered by the
[flutter_scene](https://pub.dev/packages/flutter_scene) engine, into the regular 2D component tree of
a Flame game. The `Component3D` is a `PositionComponent`, so it can be positioned, sized, scaled,
rotated, anchored, and layered together with your sprites and other 2D components.

All the 3D rendering is done by [Flutter Scene](https://fscene.dev), the realtime 3D engine for
Flutter created and maintained by [Brandon DeRosier (bdero)](https://github.com/bdero). Big thanks
to him for building it. The engine's own documentation, guides, and API reference live at
[fscene.dev](https://fscene.dev), and everything there applies to the scene inside a `Component3D`.


## Scope

This package is for when you want a 3D object in an otherwise 2D Flame game, for example a spinning
model in the menu, a 3D character on top of a 2D background, or a dice rolling across a board.

It is not a 3D game engine and it is not meant to replace one. The scene graph, cameras, materials,
lighting, animation, model loading, and physics are all handled by flutter_scene. This package only
draws a flutter_scene scene into a Flame component. If you are building a full 3D game, use
flutter_scene directly, or the experimental [flame_3d](https://pub.dev/packages/flame_3d) package,
which is a separate effort with a different purpose.


## Installation

3D scene support is provided by the `flame_3d_component` bridge package, be sure to put it in your pubspec
file to use it.

If you want to know more about the installation visit
[flame_3d_component on pub.dev](https://pub.dev/packages/flame_3d_component/install).

flutter_scene renders through Flutter GPU, which has to be enabled on every native platform. While
developing you can pass a flag:

```sh
flutter run --enable-flutter-gpu
```

See the [flutter_scene README](https://pub.dev/packages/flutter_scene#enable-flutter-gpu) for how to
enable it permanently per platform. On the web nothing needs to be enabled.


## How to use flame_3d_component

Import `package:flame_3d_component/flame_3d_component.dart`, which also re-exports the
flutter_scene API, and add a `Component3D` to your game. Everything added to its `root` node is
rendered through the component's `camera`:

```dart
class SpinningCube extends Component3D {
  SpinningCube()
    : super(
        size: Vector2(400, 300),
        camera: PerspectiveCamera(position: Vector3(2, 2, -4)),
      );

  late final Node cube;
  double _rotation = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    cube = Node(
      mesh: Mesh(CuboidGeometry(Vector3.all(1)), PhysicallyBasedMaterial()),
    );
    root.add(cube);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _rotation += dt;
    cube.rotation = Quaternion.axisAngle(Vector3(0, 1, 0), _rotation);
  }
}
```

Geometry and materials need the engine's shader libraries, so create them after `super.onLoad()`
has completed, like in the example above. The component's `onLoad` waits for
`Scene.initializeStaticResources`.

Models can be loaded with the regular flutter_scene loaders, for example `loadScene` for assets
converted by the flutter_scene asset pipeline or `Node.fromGlbAsset` for a glTF binary that is
parsed at runtime:

```dart
final model = await Node.fromGlbAsset('assets/models/dash.glb');
root.add(model);
```

The scene's clock follows Flame's clock: the `dt` passed to the component's `update` is handed to
the scene right before it renders, so pausing the game also pauses animations and node components
inside the scene.

An existing `Scene` can also be shared with the component, which is useful when a scene is built
outside of the component tree:

```dart
final sceneComponent = Component3D(
  scene: myScene,
  camera: myCamera,
  size: Vector2(400, 300),
);
```


## Name clashes

Both Flame and flutter_scene define classes named `Component` and `Sprite`, so
`flame_3d_component` does not re-export those two. Import `package:flutter_scene/scene.dart`
directly if you need the flutter_scene versions, for example to attach a flutter_scene component
to a node.


## Resolution

By default the scene is rasterized at the device pixel ratio multiplied by the current zoom of the
canvas, so it stays sharp when the Flame camera zooms in. Pass `pixelRatio` to the component to
override this, for example to render at a lower resolution for performance.
