# Components

In game development, a component is a self-contained unit that encapsulates a specific piece of game
behavior or visual. Flame uses the [Flame Component System](../game.md) (FCS) where every object in
your game (players, enemies, backgrounds, UI elements) is a component. This makes games easier to
build and maintain because each piece of logic lives in its own class and components can be freely
composed into a tree, much like
[Flutter's widget tree](https://docs.flutter.dev/get-started/fundamentals/widgets).

- [Position Component](position_component.md)
- [Sprite Components](sprite_components.md)
- [Parallax Component](parallax_component.md)
- [Shape Components](shape_components.md)
- [Utility Components](utility_components.md)

```{include} ../diagrams/component.md
```

This diagram might look intimidating, but don't worry, it is not as complex as it looks.


## Component

All components inherit from the `Component` class and can have other `Component`s as children.
This is the base of what we call the Flame Component System, or FCS for short.

Children can be added either with the `add(Component c)` method or directly in the constructor.

Example:

```dart
void main() {
  final component1 = Component(children: [Component(), Component()]);
  final component2 = Component();
  component2.add(Component());
  component2.addAll([Component(), Component()]);
}
```

The `Component()` here could of course be any subclass of `Component`.

Every `Component` has a few methods that you can optionally implement, which are used by the
`FlameGame` class.


### Component lifecycle

```{include} ../diagrams/component_life_cycle.md
```

The `onGameResize` method is called whenever the screen is resized, and also when this component
gets added into the component tree, before the `onMount`.

The `onParentResize` method is similar: it is also called when the component is mounted into the
component tree, and also whenever the parent of the current component changes its size.

The `onRemove` method can be overridden to run code before the component is removed from the game.
It is only run once even if the component is removed both by using the parents remove method and
the `Component` remove method.

The `onLoad` method can be overridden to run asynchronous initialization code for the component,
like loading an image for example. This method is executed before `onGameResize` and
`onMount`. This method is guaranteed to execute only once during the lifetime of the component, so
you can think of it as an "asynchronous constructor".

The `onMount` method runs every time when the component is mounted into a game tree. This means that
you should not initialize `late final` variables here, since this method might run several times
throughout the component's lifetime. This method will only run if the parent is already mounted.
If the parent is not mounted yet, then this method will wait in a queue (this will have no effect
on the rest of the game engine).

The `onChildrenChanged` method can be overridden if it's needed to detect changes in a parent's
children. This method is called whenever a child is added to or removed from a parent (this includes
if a child is changing its parent). Its parameters contain the targeting child and the type of
change it went through (`added` or `removed`).

A component lifecycle state can be checked by a series of getters:

- `isLoaded`: Returns a bool with the current loaded state.
- `loaded`: Returns a future that will complete once the component has finished loading.
- `isMounted`: Returns a bool with the current mounted state.
- `mounted`: Returns a future that will complete once the component has finished mounting.
- `isRemoved`: Returns a bool with the current removed state.
- `removed`: Returns a future that will complete once the component has been removed.


### Priority

In Flame every `Component` has the `int priority` property, which determines
that component's sorting order within its parent's children. This is sometimes referred to
as `z-index` in other languages and frameworks. The higher the `priority` is set to, the
closer the component will appear on the screen, since it will be rendered on top of any components
with lower priority that were rendered before it.

If you add two components and set one of their priorities to 1 for example, then that component will
be rendered on top of the other component (if they overlap), because the default priority is 0.

All components take in `priority` as a named argument, so if you know the priority that you want
your component at compile time, then you can pass it in to the constructor.

Example:

```dart
class MyGame extends FlameGame {
  @override
  void onLoad() {
    final myComponent = PositionComponent(priority: 5);
    add(myComponent);
  }
}
```

To update the priority of a component you have to set it to a new value, like
`component.priority = 2`, and it will be updated in the current tick before the rendering stage.

In the following example we first initialize the component with priority 1, and then when the
user taps the component we change its priority to 2:

```dart
class MyComponent extends PositionComponent with TapCallbacks {

  MyComponent() : super(priority: 1);

  @override
  void onTapDown(TapDownEvent event) {
    priority = 2;
  }
}
```


### Composability of components

Sometimes it is useful to wrap other components inside of your component. For example by grouping
visual components through a hierarchy. You can do this by adding child components to any component,
for example `PositionComponent`.

When you have child components on a component every time the parent is updated and rendered, all the
children are rendered and updated with the same conditions.

Here's an example where visibility of two components are handled by a wrapper:

```dart
class GameOverPanel extends PositionComponent {
  bool visible = false;
  final Image spriteImage;

  GameOverPanel(this.spriteImage);

  @override
  void onLoad() {
    // GameOverText is a Component
    final gameOverText = GameOverText(spriteImage);
    // GameOverRestart is a SpriteComponent
    final gameOverButton = GameOverButton(spriteImage);

    add(gameOverText);
    add(gameOverButton);
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
    } // If not visible none of the children will be rendered
  }
}
```

There are two methods for adding children components to your component. First,
you have methods `add()`, `addAll()`, and `addToParent()`, which can be used
at any time during the game. Traditionally, children will be created and added
from the component's `onLoad()` method, but it is also common to add new
children during the course of the game.

The second method is to use the `children:` parameter in the component's
constructor. This approach more closely resembles the standard Flutter API:

```dart
class MyGame extends FlameGame {
  @override
  void onLoad() {
    add(
      PositionComponent(
        position: Vector2(30, 0),
        children: [
          HighScoreDisplay(),
          HitPointsDisplay(),
          FpsComponent(),
        ],
      ),
    );
  }
}
```

The two approaches can be combined freely: the children specified within the
constructor will be added first, and then any additional child components
after.

Note that the children added via either methods are only guaranteed to be
available eventually: after they are loaded and mounted. We can only assure
that they will appear in the children list in the same order as they were
scheduled for addition.


### Access to the World from a Component

If a component that has a `World` as an ancestor and requires access to that `World` object, one can
use the `HasWorldReference` mixin.

Example:

```dart
class MyComponent extends Component with HasWorldReference<MyWorld>,
    TapCallbacks {
  @override
  void onTapDown(TapDownEvent info) {
    // world is of type MyWorld
    world.add(AnotherComponent());
  }
}
```

If you try to access `world` from a component that doesn't have a `World`
ancestor of the correct type an assertion error will be thrown.


### Ensuring a component has a given parent

When a component requires to be added to a specific parent type the
`ParentIsA` mixin can be used to enforce a strongly typed parent.

Example:

```dart
class MyComponent extends Component with ParentIsA<MyParentComponent> {
  @override
  void onLoad() {
    // parent is of type MyParentComponent
    print(parent.myValue);
  }
}
```

If you try to add `MyComponent` to a parent that is not `MyParentComponent`,
an assertion error will be thrown.


### Ensuring a component has a given ancestor

When a component requires to have a specific ancestor type somewhere in the
component tree, `HasAncestor` mixin can be used to enforce that relationship.

The mixin exposes the `ancestor` field that will be of the given type.

Example:

```dart
class MyComponent extends Component with HasAncestor<MyAncestorComponent> {
  @override
  void onLoad() {
    // ancestor is of type MyAncestorComponent.
    print(ancestor.myValue);
  }
}
```

If you try to add `MyComponent` to a tree that does not contain `MyAncestorComponent`,
an assertion error will be thrown.


### Component Keys

Components can have an identification key that allows them to be retrieved from the component tree,
from any point of the tree.

To register a component with a key, simply pass a key to the `key` argument on the component's
constructor:

```dart
final myComponent = Component(
  key: ComponentKey.named('player'),
);
```

Then, to retrieve it in a different point of the component tree:

```dart
flameGame.findByKey(ComponentKey.named('player'));
```

There are two types of keys, `unique` and `named`. Unique keys are based on equality of the key
instance, meaning that:

```dart
final key = ComponentKey.unique();
final key2 = key;
print(key == key2); // true
print(key == ComponentKey.unique()); // false
```

Named ones are based on the name that it receives, so:

```dart
final key1 = ComponentKey.named('player');
final key2 = ComponentKey.named('player');
print(key1 == key2); // true
```

When named keys are used, the `findByKeyName` helper can also be used to retrieve the component.


```dart
flameGame.findByKeyName('player');
```


### Querying child components

The children that have been added to a component live in a `QueryableOrderedSet` called
`children`. To query for a specific type of components in the set, the `query<T>()` function can be
used. By default `strictMode` is `false` in the children set, but if you set it to true, then the
queries will have to be registered with `children.register` before a query can be used.

If you know in compile time that you later will run a query of a specific type it is recommended to
register the query, no matter if the `strictMode` is set to `true` or `false`, since there are some
performance benefits to gain from it. The `register` call is usually done in `onLoad`.

Example:

```dart
@override
void onLoad() {
  children.register<PositionComponent>();
}
```

In the example above a query is registered for `PositionComponent`s, and an example of how to query
the registered component type can be seen below.

```dart
@override
void update(double dt) {
  final allPositionComponents = children.query<PositionComponent>();
}
```


### Querying components at a specific point on the screen

The method `componentsAtPoint()` allows you to check which components were rendered at some point
on the screen. The returned value is an iterable of components, but you can also obtain the
coordinates of the initial point in each component's local coordinate space by providing a writable
`List<Vector2>` as a second parameter.

The iterable retrieves the components in the front-to-back order, i.e. first the components in the
front, followed by the components in the back.

This method can only return components that implement the method `containsLocalPoint()`. The
`PositionComponent` (which is the base class for many components in Flame) provides such an
implementation. However, if you're defining a custom class that derives from `Component`, you'd have
to implement the `containsLocalPoint()` method yourself.

Here is an example of how `componentsAtPoint()` can be used:

```dart
void onDragUpdate(DragUpdateInfo info) {
  game.componentsAtPoint(info.widget).forEach((component) {
    if (component is DropTarget) {
      component.highlight();
    }
  });
}
```


### Visibility of components

The recommended way to hide or show a component is usually to add or remove it from the tree
using the `add` and `remove` methods.

However, adding and removing components from the tree will trigger lifecycle steps for that
component (such as calling `onRemove` and `onMount`). It is also an asynchronous process and care
needs to be taken to ensure the component has finished removing before it is added again if you
are removing and adding a component in quick succession.

```dart
/// Example of handling the removal and adding of a child component
/// in quick succession
void show() async {
  // Need to await the [removed] future first, just in case the
  // component is still in the process of being removed.
  await myChildComponent.removed;
  add(myChildComponent);
}

void hide() {
  remove(myChildComponent);
}
```

These behaviors are not always desirable.

An alternative method to show and hide a component is to use the `HasVisibility` mixin, which may
be used on any class that inherits from `Component`. This mixin introduces the `isVisible` property.
Simply set `isVisible` to `false` to hide the component, and `true` to show it again, without
removing it from the tree. This affects the visibility of the component and all it's descendants
(children).

```dart
/// Example that implements HasVisibility
class MyComponent extends PositionComponent with HasVisibility {}

/// Usage of the isVisible property
final myComponent = MyComponent();
add(myComponent);

myComponent.isVisible = false;
```

The mixin only affects whether the component is rendered, and will not affect other behaviors.

```{note}
Important! Even when the component is not visible, it is still in the tree and
will continue to receive calls to 'update' and all other lifecycle events. It
will still respond to input events, and will still interact with other
components, such as collision detection for example.
```

The mixin works by preventing the `renderTree` method, therefore if `renderTree` is being
overridden, a manual check for `isVisible` should be included to retain this functionality.

```dart
class MyComponent extends PositionComponent with HasVisibility {

  @override
  void renderTree(Canvas canvas) {
    // Check for visibility
    if (isVisible) {
      // Custom code here

      // Continue rendering the tree
      super.renderTree(canvas);
    }
  }
}
```


### Render Contexts

If you want a parent component to pass render-specific properties down its children tree, you
can override the `renderContext` property on the parent component. You can return a custom
class that inherits from `RenderContext`, and then use `findRenderContext` on the children
while rendering. Render Contexts are stored as a stack and propagated whenever the render
tree is navigated for rendering.

For example:

```dart
class IntContext extends ComponentRenderContext {
  int value;

  IntContext(this.value);
}

class ParentWithContext extends Component {
  @override
  IntContext renderContext = IntContext(42);
}

class ChildReadsContext extends Component {
  @override
  void render(Canvas canvas) {
    final context = findRenderContext<IntContext>();
    // context.value available
  }
}
```

Each component will have access to the context of any parent that is above it in the
component tree. If multiple components add the contexts matching the selected type
`T`, the "closest" one will be returned (though typically you would create a unique
context type for each component).


## Effects

Flame provides a set of effects that can be applied to a certain type of components, these effects
can be used to animate some properties of your components, like position or dimensions.
You can check the list of those effects [here](../effects/effects.md).

Examples of the running effects can be found [here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/effects);

```{toctree}
:hidden:

Position Component       <position_component.md>
Sprite Components        <sprite_components.md>
Parallax Component       <parallax_component.md>
Shape Components         <shape_components.md>
Utility Components       <utility_components.md>
```
