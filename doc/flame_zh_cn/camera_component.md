# Camera component

作为组件的摄像机是构建游戏的新方式，这种方法在放置摄像机时更加灵活，甚至可以同时拥有多个摄像机。

为了理解这种方法的工作原理，请想象你的游戏世界是一个独立于你的应用程序之外存在的实体。想象你的游戏只是一个窗口，通过它你可以观察那个世界。你可以在任何时候关闭那个窗口，游戏世界仍然存在。或者，相反，你可以打开多个窗口，它们同时观察同一个世界（或不同的世界）。

有了这种心态，我们现在可以理解作为组件的摄像机是如何工作的。

首先，有 [World](#world) 类，它包含了你的游戏世界内的所有组件。`World` 组件可以安装在任何地方，例如，像内置的 `World` 一样，安装在游戏类的根目录。

然后，有一个 [CameraComponent](#cameracomponent) 类，它“观察” [World](#world)。`CameraComponent` 有一个 [Viewport](#viewport) 和一个 [Viewfinder](#viewfinder)，允许在屏幕上的任何位置渲染世界，并且还控制观察位置和角度。`CameraComponent` 还包含一个 [backdrop](#backdrop) 组件，它在世界下方静态渲染。


## World

这个组件应该用来托管构成你的游戏世界的所有其他组件。`World` 类的主要属性是它不通过传统方式进行渲染——相反，它是由一个或多个 [CameraComponent](#cameracomponent) 来“观察”这个世界。在 `FlameGame` 类中有一个名为 `world` 的 `World`，它默认被添加并与默认的 `CameraComponent` 称为 `camera` 配对。

一个游戏可以有多个 `World` 实例，它们可以同时渲染，或者在不同的时间渲染。例如，如果你有两个世界 A 和 B 以及一个单一的摄像机，那么将该摄像机的目标从 A 切换到 B 将瞬间切换到世界 B 的视图，而无需卸载 A 然后安装 B。

就像大多数 `Component` 一样，可以通过在其构造函数中使用 `children` 参数，或者使用 `add` 或 `addAll` 方法来向 `World` 添加子组件。

对于许多游戏，你想要扩展世界并在其中创建你的逻辑，这样的游戏结构可能看起来像这样：

```dart
void main() {
  runApp(GameWidget(FlameGame(world: MyWorld())));
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    // Load all the assets that are needed in this world
    // and add components etc.
  }
}
```


## CameraComponent

这是一个通过它来渲染 `World` 的组件。在构造期间，它需要对 `World` 实例的引用；但后来目标世界可以被另一个替换。多个摄像机可以同时观察同一个世界。

在 `FlameGame` 类中有一个默认的 `CameraComponent` 叫做 `camera`，它与默认的 `world` 配对，所以如果你的游戏不需要，你就不需要创建或添加你自己的 `CameraComponent`。

`CameraComponent` 内部还有两个组件：一个 [Viewport](#viewport) 和一个 [Viewfinder](#viewfinder)。与 `World` 对象不同，摄像机拥有视口和取景器，这意味着这些组件是摄像机的子组件。

还有一个静态属性 `CameraComponent.currentCamera`，它只在渲染阶段不为 null，并且它返回当前执行渲染的摄像机对象。这只在某些高级用例中需要，其中组件的渲染取决于摄像机设置。例如，一些组件可能决定如果它们在摄像机的视口之外，则跳过自身及其子组件的渲染。

`FlameGame` 类在其构造函数中有一个 `camera` 字段，所以你可以在像这样设置你想要的默认摄像机类型：

```dart
void main() {
  runApp(
    GameWidget(
      FlameGame(
        camera: CameraComponent.withFixedResolution(width: 800, height: 600),
      ),
    ),
  );
}
```


### CameraComponent.withFixedResolution()

这个工厂构造函数将让你假装用户的设备有一个你选择的固定分辨率。例如：

```dart
final camera = CameraComponent.withFixedResolution(
  world: myWorldComponent,
  width: 800,
  height: 600,
);
```

这将创建一个摄像机，其视口位于屏幕中央，尽可能多地占用空间，同时仍然保持 800:600 的长宽比，并显示一个大小为 800 x 600 的游戏世界区域。

“固定分辨率”非常简单易用，但如果用户的设备像素比例与你所选的尺寸相同，否则它会浪费用户可用的屏幕空间。


## Viewport

`Viewport` 是一个通过它可以看到 `World` 的窗口。这个窗口在屏幕上有一定的大小、形状和位置。有多种类型的视图可用，你总是可以实现你自己的。

`Viewport` 是一个组件，这意味着你可以向它添加其他组件。这些子组件将受到视图位置的影响，但不受其剪辑蒙版的影响。因此，如果视图是一个进入游戏世界的“窗口”，那么它的子组件就是你可以在窗口上方放置的东西。

向视图添加元素是实现 “HUD” 组件的便捷方式。

以下是可用的视图：

- `MaxViewport`（默认）——这个视图扩展到游戏所允许的最大大小，即它将等于游戏画布的大小。
- `FixedResolutionViewport` ——保持分辨率和长宽比固定，如果与长宽比不匹配，则在两侧有黑条。
- `FixedSizeViewport` ——一个简单的矩形视图，具有预定义的大小。
- `FixedAspectRatioViewport` ——一个矩形视图，它扩展以适应游戏画布，但保留其长宽比。
- `CircularViewport` ——一个固定大小的圆形视图。

如果你向 `Viewport` 添加子元素，它们将作为静态 HUD 出现在世界的前方。


## Viewfinder

摄像机的这一部分负责知道我们当前正在观察底层游戏世界的哪个位置。`Viewfinder` 还控制着视图的缩放级别和旋转角度。

`Viewfinder` 的 `anchor` 属性允许你指定视窗内的哪个点作为摄像机的“逻辑中心”。例如，在横向滚动的动作游戏中，通常将摄像机聚焦在主角身上，主角不是显示在屏幕的中心，而是更靠近左下角。这个偏中心的位置将是摄像机的“逻辑中心”，由 `viewfinder` 的 `anchor` 控制。

如果你向 `Viewfinder` 添加子元素，它们将出现在世界前方，但在视窗后方，并且应用了与世界相同的变换，因此这些组件不是静态的。

你还可以向 `Viewfinder` 添加行为组件作为子元素，例如 [特效](effects.md) 或其他控制器。例如，如果你添加了一个 `ScaleEffect`，你将能够在你的游戏中实现平滑的缩放。


## Backdrop

要在世界后方添加静态组件，你可以将它们添加到 `backdrop` 组件中，或者替换 `backdrop` 组件。例如，如果你想在可以围绕其移动的世界下方拥有一个静态的 `ParallaxComponent`，这将非常有用。

示例：

```dart
camera.backdrop.add(MyStaticBackground());
```

or

```dart
camera.backdrop = MyStaticBackground();
```


## Camera controls

在运行时修改相机设置有几种方法：

1. 手动操作。你可以随时覆盖 `CameraComponent.update()` 方法（或视窗或取景器上的相同方法），并在其中根据需要改变取景器的位置或缩放。这种方法在某些情况下可能是可行的，但通常不推荐。

2. 对相机的 `Viewfinder` 或 `Viewport` 应用特效和/或行为。特效和行为是特殊类型的组件，其目的是随着时间的推移修改它们附加的组件的某些属性。

3. 使用特殊的相机功能，如 `follow()`、`moveBy()` 和 `moveTo()`。在底层，这种方法使用与 (2) 中相同的特效/行为。

相机有几种方法可以控制其行为：

- `Camera.follow()` 将强制相机跟随提供的目標。
  你可以选择限制相机移动的最大速度，或者只允许它水平/垂直移动。

- `Camera.stop()` 将撤销上一个调用的效果并停止相机在其当前位置。

- `Camera.moveBy()` 可以用来按指定的偏移量移动相机。
  如果相机已经在跟随另一个组件或向某个方向移动，那么这些行为将自动取消。

- `Camera.moveTo()` 可以用来将相机移动到世界地图上的指定点。
  如果相机已经在跟随另一个组件或向另一个点移动，那么这些行为将自动取消。

- `Camera.setBounds()` 允许你添加限制相机可以移动的范围。这些限制以 `Shape` 的形式存在，通常是一个矩形，但也可以是任何其他形状。


### visibleWorldRect

相机暴露了一个属性 `visibleWorldRect`，这是一个描述当前通过相机可见的世界区域的矩形。这个区域可以用来避免渲染视野之外的组件，或者减少远离玩家的对象的更新频率。

`visibleWorldRect` 是一个缓存的属性，当相机移动或视口改变大小时，它会自动更新。


### Check if a component is visible from the camera point of view

`CameraComponent` 有一个叫做 `canSee` 的方法，可以用来检查从相机的视角看一个组件是否可见。
这对于剔除不在视野中的组件非常有用。

```dart
if (!camera.canSee(component)) {
   component.removeFromParent(); // Cull the component
}
```
