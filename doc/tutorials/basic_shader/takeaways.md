# Takeaways


## Conclusion

There are three layers involved when using shaders in Flame:

- **Component layer** (`SpriteComponent` and `PostProcessComponent`): connects shaders to Flame
  components, holds game logic and handles user input.
- **Post process layer** (`PostProcess`): bridges components and shaders, manages runtime settings
  and updates uniforms each frame.
- **GLSL shader** (`.frag` file): the GPU program that determines the final pixel colors.


## Closure

We hope this tutorial helped you understand the basics of using shaders in Flame. Feel free to
tweak the code to suit your needs, happy coding!

If you find any errors or have suggestions, please let us know through GitHub or Discord.
