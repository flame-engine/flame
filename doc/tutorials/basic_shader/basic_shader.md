# Basic shader tutorial

This tutorial will give you a brief understanding how to create and use basic shaders on
```SpriteComponents``` with ```PostProcess``` and ```PostProcessComponent```
using Dart/Flutter and Flame Engine frameworks.  

My intention was to keep this tutorial as beginner friendly as possible.  
So the tutorial starts at the installation and preparation of a Flame game
(feel free to skip any steps, what you don't need).  
Then goes through creating three classes (other than the game and world) and then
wire them together.  
At the end it will give you a working shader example which you can
tweak it further as you wish.  

The basic tutorial consists of 5 steps.  
In there, we will create a simple outline shader for sprites which
has a transparent layer as background.  

The appendix consits of one section, which is about adding user input response.

```{note}
This tutorial intended to work on images with transparent background,
like ```.png``` files.
```

*Created by Kornél (Hoodead) Lapu, at 2025.12.22.*  
You can reach the standalone repository
[here at Github](https://github.com/kornellapu/basic_shader_tutorial).

---
*I was using the following versions, when initially created the tutorial:  
**Dart**: 3.10.4  
**Flutter**: 3.10.4  
**Flame Engine**: 1.34.0*

---


## Author's notes

*I have met a curious mind through
[Flame Engine's Discord server](https://discord.gg/pxrBmy4), who wanted to use
shaders with Flame Engine.  
Well, that was two of us who could use some basic shader knowledge in Flame, so
I decided to capture what was my solution, to share with others.*  

*Please keep in mind, there can be better solutions to **your** specific needs.  
This code present only one structure and one way to use shaders in Flame.  
Experiment, tweak the code to suit you best - but first, **have fun!***

*If you have questions or constructive suggestions please share with the community!  
Thanks and happy coding!* ^.^


```{toctree}
:hidden:

1. Setup                    <step1.md>
2. Widget, Game and World   <step2.md>
3. Sprite Component         <step3.md>
4. Outline Post Process     <step4.md>
5. Shader                   <step5.md>
6. Takeaways                <takeaways.md>
7. Appendix A - User Input  <appendix_a.md>
```
