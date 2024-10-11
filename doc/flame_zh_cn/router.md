
```{flutter-app}
:sources: ../flame/examples
:page: router
:show: widget code infobox

This example app shows the use of the `RouterComponent` to move across multiple
screens within the game. In addition, the "pause" button stops time and applies
visual effects to the content of the page below it.
```


# RouterComponent

**RouterComponent** 的作用是管理游戏中多个屏幕之间的导航。它在精神上类似于 Flutter 的 [Navigator][Flutter Navigator] 类，只不过它使用的是 Flame 组件而不是 Flutter 小部件。

一个典型的游戏通常会包含多个页面：启动屏幕、开始菜单页面、设置页面、制作人员名单、主游戏页面、几个弹出窗口等。路由器将组织所有这些目的地，并允许你在它们之间进行转换。

在内部，`RouterComponent` 包含一个路由堆栈。当你请求它显示一个路由时，它将被放置在堆栈中所有其他页面的顶部。之后你可以使用 `pop()` 来从堆栈中移除最顶部的页面。路由器的页面通过它们的唯一名称来标识。

路由器中的每个页面可以是透明的或不透明的。如果一个页面是不透明的，那么它在堆栈中下面的页面将不会被渲染，也不会接收指针事件（例如点击或拖动）。相反，如果一个页面是透明的，那么它下面的页面将被正常渲染和接收事件。这种透明页面适用于实现模态对话框、库存或对话 UI 等。如果你想让你的路由在视觉上是透明的，但是它下面的路由不接收事件，请确保在你的路由中添加一个背景组件，该组件通过使用 [事件捕获混入](inputs/inputs.md) 中的一个来捕获事件。

使用示例：

```dart
class MyGame extends FlameGame {
  late final RouterComponent router;

  @override
  void onLoad() {
    add(
      router = RouterComponent(
        routes: {
          'home': Route(HomePage.new),
          'level-selector': Route(LevelSelectorPage.new),
          'settings': Route(SettingsPage.new, transparent: true),
          'pause': PauseRoute(),
          'confirm-dialog': OverlayRoute.existing(),
        },
        initialRoute: 'home',
      ),
    );
  }
}

class PauseRoute extends Route { ... }
```

```{note}
如果你导入的任何包中导出了另一个名为 `Route` 的类，使用 `hide Route`。

例如：`import 'package:flutter/material.dart' hide Route;`
```


[Flutter Navigator]: https://api.flutter.dev/flutter/widgets/Navigator-class.html


## Route

**Route** 组件保存了关于特定页面内容的信息。`Route` 作为子组件被挂载到 `RouterComponent`。

`Route` 的主要属性是它的 `builder` —— 这个函数负责创建包含其页面内容的组件。

此外，路由可以是透明的或不透明的（默认）。不透明的路由会阻止它下面的路由渲染或接收指针事件，而透明的路由则不会。通常，如果一个路由是全屏的，就声明为不透明；如果它只覆盖屏幕的一部分，则声明为透明。

默认情况下，路由在从堆栈中弹出后会保持页面组件的状态，`builder` 函数只在路由首次激活时被调用。将 `maintainState` 设置为 `false` 会在路由从路由堆栈中弹出后丢弃页面组件，并且每次路由被激活时都会调用 `builder` 函数。

当前路由可以使用 `pushReplacementNamed` 或 `pushReplacement` 进行替换。每种方法简单地在当前路由上执行 `pop`，然后执行 `pushNamed` 或 `pushRoute`。


## OverlayRoute

**OverlayRoute** 是一种特殊的路由，允许通过路由器添加游戏覆盖层。这些路由默认是透明的。

`OverlayRoute` 有两种构造函数。第一种构造函数需要一个构建函数，描述了覆盖层的组件如何构建。第二种构造函数可以在 `GameWidget` 中已经指定了构建函数时使用：

```dart
final router = RouterComponent(
  routes: {
    'ok-dialog': OverlayRoute(
      (context, game) {
        return Center(
          child: DecoratedContainer(...),
        );
      },
    ),  // OverlayRoute
    'confirm-dialog': OverlayRoute.existing(),
  },
);
```

在 `GameWidget` 中定义的覆盖层甚至不需要事先在路由映射中声明：`RouterComponent.pushOverlay()` 方法可以为你完成这项工作。
一旦覆盖层路由被注册，它可以通过常规的 `.pushNamed()` 方法激活，
也可以通过 `.pushOverlay()` 方法激活——这两种方法将完全相同，尽管你可以使用第二种方法来使你的代码更清晰地表明正在添加一个覆盖层而不是一个常规路由。

当前覆盖层可以使用 `pushReplacementOverlay` 替换。这个方法根据被推送的覆盖层的状态执行 `pushReplacementNamed` 或 `pushReplacement`。


## ValueRoute

```{flutter-app}
:sources: ../flame/examples
:page: value_route
:show: widget code infobox
:width: 280
```

**ValueRoute** 是一种路由，当它最终从堆栈中弹出时，会返回一个值。这样的路由可以用于例如请求用户反馈的对话框。

为了使用 `ValueRoute`s，需要两个步骤：

1. 创建一个从 `ValueRoute<T>` 类派生的路由，其中 `T` 是你的路由将返回的值的类型。在这个类中覆盖 `build()` 方法来构建将显示的组件。该组件应该使用 `completeWith(value)` 方法来弹出路由并返回指定的值。

   ```dart
   class YesNoDialog extends ValueRoute<bool> {
     YesNoDialog(this.text) : super(value: false);
     final String text;

     @override
     Component build() {
       return PositionComponent(
         children: [
           RectangleComponent(),
           TextComponent(text: text),
           Button(
             text: 'Yes',
             action: () => completeWith(true),
           ),
           Button(
             text: 'No',
             action: () => completeWith(false),
           ),
         ],
       );
     }
   }
   ```

2. 使用 `Router.pushAndWait()` 显示路由，该方法返回一个未来（future），它将用路由返回的值解决。

   ```dart
   Future<void> foo() async {
     final result = await game.router.pushAndWait(YesNoDialog('Are you sure?'));
     if (result) {
       // ... the user is sure
     } else {
       // ... the user was not so sure
     }
   }
   ```
