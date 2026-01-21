# Shader


## 5.0 Considerations

In this section we will create the fragment (pixel) shader program which runs
on the GPU, then add as a resource.  

It is important to note, we are going to program the GPU, so this code will
need a little bit of different thinking from what we did before.  

```{note}
The reason is that, **the fragment shader runs for each pixel**.  
*Pff.. and?*  
Well that means, you should not excessively branch or loop, because it will
be calculated, iterated, or be checked for each pixel in each frame.  
I am serious,
a 1K screen (like mine) has 1920 * 1080 pixels => 2 073 600 pixels in full
screen mode.  
A for loop of 16*16 will create 256 * 2 073 600 => 530 841 600 iterations
per frame in worst case.  
That means with 30 FPS, it is ___15 925 248 000___ calls per seconds, for a
relatively simple shader with minimum settings.  
*Yikes..*  
So please be mindful what are you doing and how in your shader.  
You can think of it like, it *nearly* has
[O<sup>2</sup>](https://en.wikipedia.org/wiki/Big_O_notation) scale,
because of the "per pixel" execution, where the input size is based on
the width and height of the screen.
```

```{note}
Also the shader optimization is out of the scope of this tutorial.  
But there are guards, to escape as early as possible.  

Instead of square root, it would be a better solution to compare squared
values only.
```

Everything is ready to create the GLSL based shader.  


## 5.1 Shader code

Create new directory at `\assets\shaders` and a file named `outline.frag`.  
For example, in my project it looks like this:  
`C:\Projects\basic_shader_tutorial\assets\shaders\outline.frag`  

Open the `outline.frag` file and add the following lines:  

```glsl
#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uOutlineWidth;
uniform vec4 uOutlineColor;
uniform sampler2D uTexture;

const int MAX_SAMPLE_DISTANCE = 8;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec4 texColor = texture(uTexture, uv);
    
  // If the current pixel is not transparent, render the original color
  if (texColor.a > 0.0) {
    fragColor = texColor;
    return;
  }
    
  // Check surrounding pixels for outline
  vec2 texelSize = 1.0 / uSize;
  bool foundOpaqueNearby = false;
    
  // Sample in the bounding square pattern around the current pixel
  // You must use static const loop counts in GLSL
  for (int x = -MAX_SAMPLE_DISTANCE; x <= MAX_SAMPLE_DISTANCE; x++) {
    for (int y = -MAX_SAMPLE_DISTANCE; y <= MAX_SAMPLE_DISTANCE; y++) {
      if (x == 0 && y == 0) continue;
      
      // Checking the real distance, instead of square based (manhattan) distance
      float distance = sqrt(float( x*x + y*y ));
      if (distance > uOutlineWidth) continue;
      
      // Sample the shifted pixel from the current pixel (uv)
      vec2 offset = vec2(float(x), float(y)) * texelSize;
      vec4 sampleColor = texture(uTexture, uv + offset);
      
      if (sampleColor.a > 0.0) {
        // We found solid color in the iteration --> sprite is nearby
        foundOpaqueNearby = true;
        break;
      }
    }
    // Also break out from outer loop, if found a solid color next to current pixel
    if (foundOpaqueNearby) break;
  }
    
  if (foundOpaqueNearby) {
    fragColor = uOutlineColor;
  } else {
    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
  }
}
```

*So.. what does this shader do?*  
Grabbing each transparent pixel and checking: is it next to an opaque pixel?  
If yes, then color it as the outline color (passed in as an uniform variable),
else it will be full transparent.  

That is why the transparency of the `.png` image was important in the
beginning (at Setup section).  

```{note}
The loop of a GLSL shader accepts only a compile time constant.  
So as far as I know we can not use the outline width, because that is a
uniform, which are not present in the shader at compile time.  
This is altering the shader behavior if the outline uniform is set to a
bigger value than this shader sampler distance. It should be set accordingly
and manually in the shader too.
```


## 5.2 Shader resource

To let the flutter linking process know about this shader asset we have to add
it to the `pubspec.yaml` file before compilation.

Open the `pubspec.yaml` and write the following lines under what we already added:

```yaml
#... still omitted for brevity

flutter:
  assets:
    - assets/images/
  # the new lines:
  shaders:
    - assets/shaders/outline.frag
```

Save it and let the automatic `pub get` command to run.  
Now the resource will be loaded when the project is next compiled.  

Now run the application.  
Open the console (`Ctrl + J`).  
Execute `flutter run`, then choose your platform.  

*Voila!*  
You should see two sprites in the window.  
The left is without an outline, the right one is with a colored outline from
the shader.  

![Image of the reference and the shader](../../images/tutorials/basic_shader/final_result.png)

We are done with the basic shader tutorial.  
*Cool!*  

It's time for you to experiment!
