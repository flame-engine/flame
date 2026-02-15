
# Setup


## 1.0 Tools

First of all you need to install the frameworks.  
You can find the instructions of installing Flutter
[here](https://docs.flutter.dev/install/with-vs-code)
and after that for Flame Engine
[here](https://docs.flame-engine.org/latest/#installation).  

```{note}
I am using Microsoft Windows OS and Visual Studio Code for development, the
links are for this setup.  
To setup development on other platforms, you can consult the documentation
or the community online.  
```

At the end of installation you should have a working project.  
If you don't have it or you already installed then, create a folder for your
project, I will use this for example:  
`C:\Projects\basic_shader_tutorial`  
Open your folder in VS Code.  
Press `Ctr + J` to open terminal window in VS Code.  
Execute the following commands, to create new flutter project in current
directory:  
`flutter create .`  
Now you have a new flutter project.  

*Nice!*


## 1.1 Extensions

While installing through VS Code you are asked to install extensions for Dart
and Flutter, I recommend it to add one.  

Also we need something to work with fragment (aka pixel) shaders in `.frag`
files, so we need some GLSL highlight or linting. I suggest you to go ahead and
download one from the Extensions tab in VS Code.  
I used a syntax highlighter:
[GLSL Syntax for VS Code](https://marketplace.visualstudio.com/items?itemName=GeForceLegend.vscode-glsl)
from GeForceLegend, but it is really up to your preferences.  


## 1.2 Image resource

I will use an image (sword.png) created by
[lapu_land__](https://www.instagram.com/lapu_land__/).  

![Image of a drawn sword](../../images/tutorials/basic_shader/sword.png)  

If you fancy about to add your own resource, don't hesitate and I also
encourage you, to do so.  
The important part is to have **transparent background** in the `.png`
file.  

Create the folder where it suits you best.  
Copy the chosen file under your assets folder in the project, something like
this: `C:\Projects\basic_shader_tutorial\assets\images\sword.png`  

Do not forget to add the containing folder to assets in `pubspec.yaml` and
save:  

```yaml
#... omitted for brevity

flutter:  
  assets:  
    - "assets/images/"  
```

</br>

Pretty much that's it for the **Setup**.  
We are working with vanilla Flame Engine settings, with nearly vanilla VS Code.  

In the next step we will create the wireframe of the Flame game.
