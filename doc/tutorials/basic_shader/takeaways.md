# Takeaways


## Conclusion

There are three layers involved when using shaders in Flame:

- **Component layer** (`SpriteComponent` and `PostProcessComponent`): connects shaders to Flame
  components, holds game logic and handles user input.
- **Post process layer** (`PostProcess`): bridges components and shaders, manages runtime settings
  and updates uniforms each frame.
- **GLSL shader** (`.frag` file): the GPU program that determines the final pixel colors.

This tutorial builds the post process on `PostProcess`, to show every step. For most shaders,
[`ShaderPostProcess`](../../flame/rendering/post_processing.md#shaderpostprocess) does those steps
for you: it loads the shader, rasterizes the subtree, sets the size and time uniforms, and lets you
set the other uniforms by name.


## Closure

We hope this tutorial helped you understand the basics of using shaders in Flame. Feel free to
tweak the code to suit your needs, happy coding!

If you find any errors or have suggestions, please let us know through GitHub or Discord.
