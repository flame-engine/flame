# Takeaways


## Conclusion

According to my logic, there are three layers of using shaders
in the Flame engine, where:

- the component layer: `SpriteComponent` and `PostProcessComponent`
  - connecting shaders to Flame components and holding game logic, and
  handling user inputs
- post process layer: `PostProcess`
  - the link between components and holding runtime settings, behavior
  logic, updating uniforms for shaders
- the GLSL shader: `.frag` file
  - the core shader code


## Closure

I hope this tutorial helped you to understand the basics!
Don't forget, if you know better solutions: go for it! You can tweak this
solution to your needs, happy coding!

If you found some errors or mistakes please let us know through GitHub or Discord
and we will update the tutorial accordingly.
