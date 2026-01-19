# Takeaways


## Conclusion

According to my logic, there are three layers of using shaders
in Flame Engine, where:
- the component layer: ```SpriteComponent``` and ```PostProcessComponent```
  - connecting shaders to Flame components and holding game logic, and user
  handling user inputs
- post process layer: ```PostProcess```
  - the link between components and holding runtime settings, behaviour
  logic, updating uniforms for shaders
- the GLSL shader: ```.frag``` file 
  - the core shader code

There is an optional step to take this tutorial a little bit further:
altering shader behaviour from the component when user input arrives.  
Check Appendix A.


## Closure

I hope this tutorial helped you to understand the basics!  
Don't forget, if you know better solutions: go for it! You can tweak this
solution to your needs, happy coding!  

If you found some errors or mistakes please let me know through Github or Discord
and I will look after them and update the tutorial accordingly.

The repository of this tutorial is available
[here](https://github.com/kornellapu/basic_shader_tutorial),
and it is set to the end of the basic tutorial.  
The Appendix files are present, but commented out.  

```{note}
After downloading the repo, it is possible that you have to run
```flutter create .``` from the root folder, to reinitialize it.
```

And if you are using any part of the shader codes, please credit me as:  
**Kornél (Hoodead) Lapu**  
Thanks in advance!

Also don't forget to support the superb Flame Engine community.  
Cheers!
