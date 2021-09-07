import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:ordered_set/queryable_ordered_set.dart';

import '../../components.dart';
import '../../extensions.dart';
import '../components/component.dart';
import '../components/mixins/collidable.dart';
import '../components/mixins/draggable.dart';
import '../components/mixins/has_collidables.dart';
import '../components/mixins/hoverable.dart';
import '../components/mixins/tappable.dart';
import 'camera/camera.dart';
import 'camera/camera_wrapper.dart';
import 'game.dart';

/// This is a more complete and opinionated implementation of Game.
///
/// BaseGame should be extended to add your game logic.
/// [update], [render] and [onGameResize] methods have default implementations.
/// This is the recommended structure to use for most games.
/// It is based on the Component system.
class BaseGame extends Game {
  BaseGame() {
    _cameraWrapper = CameraWrapper(Camera(), components);
  }

  /// The camera translates the coordinate space after the viewport is applied.
  Camera get camera => _cameraWrapper.camera;

  // When the Game becomes a Component (#906), this could be added directly
  // into the component tree.
  late final CameraWrapper _cameraWrapper;

  /// This is overwritten to consider the viewport transformation.
  ///
  /// Which means that this is the logical size of the game screen area as
  /// exposed to the canvas after viewport transformations and camera zooming.
  ///
  /// This does not match the Flutter widget size; for that see [canvasSize].
  @override
  Vector2 get size => camera.gameSize;

  /// This is the original Flutter widget size, without any transformation.
  Vector2 get canvasSize => camera.canvasSize;

  /// This method sets up the OrderedSet instance used by this game, before
  /// any lifecycle methods happen.
  ///
  /// You can return a specific sub-class of OrderedSet, like
  /// [QueryableOrderedSet] for example, that we use for Collidables.
  @override
  ComponentSet createComponentSet() {
    final components = super.createComponentSet();
    if (this is HasCollidables) {
      components.register<Collidable>();
    }
    return components;
  }

  /// This method is called for every component before it is added to the
  /// component tree.
  /// It does preparation on a component before any update or render method is
  /// called on it.
  ///
  /// You can use this to set up your mixins or pre-calculate things for
  /// example.
  /// By default, this calls the first [onGameResize] for every component, so
  /// don't forget to call `super.prepareComponent` when overriding.
  @mustCallSuper
  void prepareComponent(Component c) {
    assert(
      hasLayout,
      '"prepare/add" called before the game is ready. '
      'Did you try to access it on the Game constructor? '
      'Use the "onLoad" ot "onParentMethod" method instead.',
    );

    if (c is Collidable) {
      assert(
        this is HasCollidables,
        'You can only use the Hitbox/Collidable feature with games that has '
        'the HasCollidables mixin',
      );
    }
    if (c is Tappable) {
      assert(
        this is HasTappableComponents,
        'Tappable Components can only be added to a BaseGame with '
        'HasTappableComponents',
      );
    }
    if (c is Draggable) {
      assert(
        this is HasDraggableComponents,
        'Draggable Components can only be added to a BaseGame with '
        'HasDraggableComponents',
      );
    }
    if (c is Hoverable) {
      assert(
        this is HasHoverableComponents,
        'Hoverable Components can only be added to a BaseGame with '
        'HasHoverableComponents',
      );
    }

    // First time resize
    c.onGameResize(size);
  }

  /// This implementation of render renders each component, making sure the
  /// canvas is reset for each one.
  ///
  /// You can override it further to add more custom behavior.
  /// Beware of that if you are rendering components without using this method;
  /// you must be careful to save and restore the canvas to avoid components
  /// interfering with each others rendering.
  @override
  @mustCallSuper
  void render(Canvas canvas) {
    _cameraWrapper.render(canvas);
  }

  /// This updates every component in the tree.
  ///
  /// It also adds the components added via [add] since the previous tick, and
  /// removes those that are marked for removal via the [remove] and
  /// [Component.removeFromParent] methods.
  /// You can override it to add more custom behavior.
  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);

    if (this is HasCollidables) {
      (this as HasCollidables).handleCollidables();
    }

    _cameraWrapper.update(dt);
  }

  /// This passes the new size along to every component in the tree via their
  /// [Component.onGameResize] method, enabling each one to make their decision
  /// of how to handle the resize event.
  ///
  /// It also updates the [size] field of the class to be used by later added
  /// components and other methods.
  /// You can override it further to add more custom behavior, but you should
  /// seriously consider calling the super implementation as well.
  /// This implementation also uses the current [camera] in order to transform
  /// the coordinate system appropriately.
  @override
  @mustCallSuper
  void onGameResize(Vector2 canvasSize) {
    camera.handleResize(canvasSize);
    super.onGameResize(canvasSize);
  }

  /// Changes the priority of [component] and reorders the games component list.
  ///
  /// Returns true if changing the component's priority modified one of the
  /// components that existed directly on the game and false if it
  /// either was a child of another component, if it didn't exist at all or if
  /// it was a component added directly on the game but its priority didn't
  /// change.
  bool changePriority(
    Component component,
    int priority, {
    bool reorderRoot = true,
  }) {
    if (component.priority == priority) {
      return false;
    }
    component.changePriorityWithoutResorting(priority);
    if (reorderRoot) {
      if (component.parent != null) {
        component.parent!.reorderChildren();
      } else if (contains(component)) {
        children.rebalanceAll();
      }
    }
    return true;
  }

  /// Since changing priorities is quite an expensive operation you should use
  /// this method if you want to change multiple priorities at once so that the
  /// tree doesn't have to be reordered multiple times.
  void changePriorities(Map<Component, int> priorities) {
    var hasRootComponents = false;
    final parents = <Component>{};
    priorities.forEach((component, priority) {
      final wasUpdated = changePriority(
        component,
        priority,
        reorderRoot: false,
      );
      if (wasUpdated) {
        if (component.parent != null) {
          parents.add(component.parent!);
        } else {
          hasRootComponents |= contains(component);
        }
      }
    });
    if (hasRootComponents) {
      children.rebalanceAll();
    }
    parents.forEach((parent) => parent.reorderChildren());
  }

  /// Whether a point is within the boundaries of the visible part of the game.
  @override
  bool containsPoint(Vector2 p) {
    return p.x > 0 && p.y > 0 && p.x < size.x && p.y < size.y;
  }

  /// Returns the current time in seconds with microseconds precision.
  ///
  /// This is compatible with the `dt` value used in the [update] method.
  double currentTime() {
    return DateTime.now().microsecondsSinceEpoch.toDouble() /
        Duration.microsecondsPerSecond;
  }

  @override
  Vector2 projectVector(Vector2 vector) {
    return camera.combinedProjector.projectVector(vector);
  }

  @override
  Vector2 unprojectVector(Vector2 vector) {
    return camera.combinedProjector.unprojectVector(vector);
  }

  @override
  Vector2 scaleVector(Vector2 vector) {
    return camera.combinedProjector.scaleVector(vector);
  }

  @override
  Vector2 unscaleVector(Vector2 vector) {
    return camera.combinedProjector.unscaleVector(vector);
  }
}
