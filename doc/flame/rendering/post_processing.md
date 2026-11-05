# Post Processing and Shaders

Post processing is a technique used in game development to apply visual effects to a component tree
after it has been rendered. Once a frame is rendered, either directly or rasterized into an
image, post processing can modify or enhance the visuals.

Post processing leverages fragment shaders to create dynamic visual effects such as blur, bloom,
color grading, distortion, and lighting adjustments.

In Flame, the post processing system is modular and flexible, allowing developers to:

- Define custom post processes by sub-classing the abstract class `PostProcess`.
- Apply a single post process effect or chain multiple effects using groups.
- Manage effects globally with the `CameraComponent` or locally with `PostProcessComponent`.


## Key Components of the Post Processing System

- **`PostProcess`**: Abstract base class for defining custom post-processing effects. Implement
  your effect logic in its `postProcess` method.

- **`ShaderPostProcess`**: A post process that draws a fragment shader, and takes care of loading
  it, rasterizing the subtree and setting the common uniforms.

- **`PostProcessComponent`**: Applies a post process specifically to its children, enabling
  localized effects.

- **`CameraComponent`**: Applies post processes globally to the entire scene or world.

- **`PostProcessGroup`**: Applies multiple post processes in parallel, useful when effects can be
  applied independently.

- **`PostProcessSequentialGroup`**: Applies post processes sequentially, where each process uses
  the output of the previous one.


## PostProcessComponent

```{dartdoc}
:package: flame
:symbol: PostProcessComponent
:file: src/post_process/post_process_component.dart
```


## ShaderPostProcess

Most post processes draw a fragment shader over the subtree. `ShaderPostProcess` does that for
you: it loads the shader, keeps track of the time, rasterizes the subtree when the shader samples
it, and draws the shader over the size of the post process.

Every frame, it sets these uniforms if the shader declares them:

| Uniform               | Value                                                 |
| --------------------- | ----------------------------------------------------- |
| `uniform vec2 uSize`  | The size of the post process, in logical pixels.      |
| `uniform float uTime` | The seconds passed since the post process was loaded. |

To sample the subtree, declare `uniform sampler2D uTexture` as the first sampler of the shader.
The subtree is then rasterized with `rasterizeSubtree` every frame and given to `uTexture`. A
shader that only needs these uniforms doesn't need a subclass:

```dart
PostProcessComponent(
  postProcess: ShaderPostProcess('assets/shaders/grayscale.frag'),
  children: [player],
);
```


### Shaders on the web

`ShaderPostProcess` detects whether the shader samples the subtree by looking up `uTexture` by name.
Flutter can't look up the samplers of a shader by name on the web yet, so if your game runs on the
web, pass `sampleSubtree` to say whether the shader samples the subtree:

```dart
ShaderPostProcess('assets/shaders/grayscale.frag', sampleSubtree: true);
ShaderPostProcess('assets/shaders/vignette.frag', sampleSubtree: false);
```

Without it, loading the post process throws an error on the web. On the other platforms, an error
is thrown when the shader is loaded if `sampleSubtree` doesn't match whether the shader declares
`uTexture`, so running the game on one of them catches a wrong value.

The `placement` decides where the shader is drawn relative to the subtree:

| `ShaderPlacement` | What is drawn                              | For example                 |
| ----------------- | ------------------------------------------ | --------------------------- |
| `replace`         | Only the shader. This is the default.      | Pixelation, grayscale       |
| `over`            | The subtree, then the shader on top of it. | Fog, vignette, a glow       |
| `under`           | The shader, then the subtree on top of it. | A background, a drop shadow |

Whether the shader samples the subtree is independent of its placement. For example, a glow placed
`over` the subtree can sample `uTexture` to find its edges:

```dart
PostProcessComponent(
  postProcess: ShaderPostProcess(
    'assets/shaders/glow.frag',
    sampleSubtree: true,
    placement: ShaderPlacement.over,
  ),
  children: [player],
);
```

The subtree is rendered at most once per frame. With `sampleSubtree: true`, it costs a
`rasterizeSubtree` every frame, which is the expensive part. When such a shader is placed `over` or
`under` the subtree, the rasterized image is also drawn as the subtree, instead of rendering the
subtree again. Without `sampleSubtree`, a shader placed `over` or `under` the subtree only renders
it as usual, without rasterizing it.

To use a `FragmentProgram` that is already loaded, for example one shared by several post
processes, use `ShaderPostProcess.fromProgram`.


### Setting uniforms by name

Set any other uniforms in `updateUniforms`, using the name of each uniform in the shader instead
of its position. Look each uniform up once, in `onLoad`, and set it every frame. The slot types,
like `UniformFloatSlot`, come from `dart:ui`:

```dart
class OutlinePostProcess() extends ShaderPostProcess {
  this : super('assets/shaders/outline.frag');

  double outlineWidth = 4;
  Color outlineColor = Colors.purpleAccent;

  late final UniformFloatSlot _outlineWidth;
  late final UniformVec4Slot _outlineColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _outlineWidth = shader.getUniformFloat('uOutlineWidth');
    _outlineColor = shader.getUniformVec4('uOutlineColor');
  }

  @override
  void updateUniforms(Vector2 size) {
    _outlineWidth.set(outlineWidth);
    _outlineColor.setColor(outlineColor);
  }
}
```

Looking a uniform up by a name that the shader doesn't declare throws an `ArgumentError`, so a
typo is reported right away. Note that the shader compiler removes uniforms that the shader
doesn't use, and those can't be looked up either.

Flame adds methods to the uniform slots of `dart:ui` to set them from its own types:

- `UniformVec2Slot`: `setVector(Vector2)`, `setSize(Size)` and `setOffset(Offset)`.
- `UniformVec3Slot`: `setVector(Vector3)`.
- `UniformVec4Slot`: `setVector(Vector4)` and `setColor(Color, premultiply: false)`.
- `UniformMat2Slot`, `UniformMat3Slot` and `UniformMat4Slot`: `setMatrix` with a `Matrix2`,
  `Matrix3` or `Matrix4`.

These work on any `FragmentShader`, not only in a `ShaderPostProcess`.


## Creating a Custom Post Process

For effects that need more control, for example rendering the subtree several times, implement a
post process yourself:

1. Subclass `PostProcess`.
2. Override the `postProcess` method, implementing your rendering logic with `renderSubtree` or
   `rasterizeSubtree`.
3. Optionally, implement `onLoad` and `update` methods for managing resources and updating effects
   each frame.

This system makes it easy to add creative and useful visual effects to your Flame game.


## Example: pixelation

Here’s an example of creating a pixelation effect using a fragment shader:

```dart
class PostProcessGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world.add(
      PostProcessComponent(
        postProcess: PixelationPostProcess(),
        position: Vector2(0, 0),
        anchor: Anchor.center,
        children: [
          EmberPlayer(size: Vector2(100, 100)),
        ],
      ),
    );
  }
}

class PixelationPostProcess() extends ShaderPostProcess {
  this
    : super(
        'packages/flutter_shaders/shaders/pixelation.frag',
        sampleSubtree: true,
      );

  late final UniformVec2Slot _pixels;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _pixels = shader.getUniformVec2('uPixels');
  }

  @override
  void updateUniforms(Vector2 size) {
    _pixels.setVector(size / (20 * sin(time)));
  }
}
```

In this example:

- A fragment shader (`pixelation.frag`) is loaded and used to apply a pixelation effect.

- The shader declares `uTexture` and `sampleSubtree` is true, so `ShaderPostProcess` captures the
  component tree with `rasterizeSubtree` and passes it to the shader. The texture is rendered at the
  post process's `pixelRatio` and covers the whole subtree, so the shader can sample it with
  coordinates from 0 to 1 across `uSize`, which is also set by `ShaderPostProcess`.

- The only other uniform, `uPixels`, is looked up by name in `onLoad` and set from `time` in
  `updateUniforms`, creating an animated pixelation effect.

This example demonstrates how straightforward it is to add visual effects to your Flame game using
the post-processing system.

```{flutter-app}
:sources: ../flame/examples
:page: post_process
:show: widget code infobox
:width: 180
:height: 180
```

The pixelation shader file:

```glsl
#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uPixels;
uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 puv = round(uv * uPixels) / uPixels;
  fragColor = texture(uTexture, puv);
}
```


## Advanced Example: Crystal Ball

For a more advanced use case of post processing, check out the
[Crystal Ball example](https://examples.flame-engine.org/), which demonstrates camera-level post
processing and chaining multiple effects using `PostProcessSequentialGroup`.

![Crystal Ball Example](../images/crystal_ball.png)

Here's how multiple post-processing effects are combined on a camera:

```dart
class CrystalBallGame extends FlameGame<CrystalBallGameWorld> {

  CrystalBallGame() : super(
          camera: CameraComponent.withFixedResolution(
            width: kCameraSize.x,
            height: kCameraSize.y,
          ),
          world: CrystalBallGameWorld(),
        ) {
    camera.postProcess = PostProcessGroup(
      postProcesses: [
        PostProcessSequentialGroup(
          postProcesses: [
            FireflyPostProcess(),
            WaterPostProcess(),
          ],
        ),
        ForegroundFogPostProcess(),
      ],
    );
  }
}
```

In this code:

- The camera applies a `PostProcessGroup` containing multiple effects.
- `PostProcessSequentialGroup` chains two effects (`FireflyPostProcess` and `WaterPostProcess`)
  sequentially.
- An additional parallel effect (`ForegroundFogPostProcess`) is applied alongside the sequential
  group.

You can explore the source code [on GitHub](https://github.com/flame-engine/flame/tree/main/examples/games/crystal_ball).
