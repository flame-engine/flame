import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/overlay_route.dart';
import 'package:flame/src/components/route.dart';
import 'package:flame/src/components/value_route.dart';
import 'package:meta/meta.dart';

/// [RouterComponent] handles transitions between multiple pages of a game.
///
/// The term **page** is used descriptively here: it is any full-screen (or
/// partial-screen) component. For example: a starting page, a settings page,
/// the main game world page, and so on. A page can also be any individual piece
/// of UI, such as a confirmation dialog box, or a user inventory pop-up.
///
/// The router doesn't handle the pages directly -- instead, it operates a stack
/// of [Route]s. Each route, in turn, manages a single page component. However,
/// routes are lazy: they will only build their pages when they become active.
///
/// Internally, the router maintains a stack of Routes. In the beginning,
/// the stack will contain the [initialRoute]. New routes can be added via the
/// [pushNamed] method, and removed with [pop]. However, the stack must be
/// kept non-empty: it is an error to attempt to remove the only remaining route
/// from the stack.
///
/// Routes that are on the stack are mounted as components. When a route is
/// popped, it is removed from the stack and unmounted. Routes can be either
/// transparent or opaque. An opaque route prevents all routes below it from
/// rendering, and also stops pointer events. In addition, routes are able to
/// stop or slow down time for the pages that they control, or to apply visual
/// effects (via decorators) to those pages.
class RouterComponent extends Component {
  RouterComponent({
    required this.initialRoute,
    required Map<String, Route> routes,
    Map<String, _RouteFactory>? routeFactories,
    this.onUnknownRoute,
  })  : _routes = routes,
        _routeFactories = routeFactories ?? {} {
    routes.forEach((name, route) => route.name = name);
  }

  /// Route that will be placed on the stack in the beginning.
  final String initialRoute;

  /// The stack of all currently active routes. This stack must not be empty
  /// (it will be populated with the [initialRoute] in the beginning).
  ///
  /// The routes in this list are also added to the Router as child
  /// components. However, due to the fact that children are usually added or
  /// removed with a delay, there could be temporary discrepancies between this
  /// list and the list of children.
  final List<Route> _routeStack = [];
  @visibleForTesting
  List<Route> get stack => _routeStack;

  /// The map of all routes known to the Router, each route will have a
  /// unique name. This map is initialized in the constructor; in addition, any
  /// routes produced by the [_routeFactories] will also be cached here.
  Map<String, Route> get routes => _routes;
  final Map<String, Route> _routes;

  /// Set of functions that are able to resolve routes dynamically.
  ///
  /// Route factories will be used to resolve pages with names like
  /// "prefix/arg". For such a name, we will call the factory "prefix" with the
  /// argument "arg". The produced route will be cached in the main [_routes]
  /// map, and then built and mounted normally.
  final Map<String, _RouteFactory> _routeFactories;

  /// Function that will be called to resolve any route names that couldn't be
  /// resolved via [_routes] or [_routeFactories]. Unlike with routeFactories,
  /// the route returned by this function will not be cached.
  final _RouteFactory? onUnknownRoute;

  /// Returns the route that is currently at the top of the stack.
  Route get currentRoute => _routeStack.last;

  /// Returns the route that is below the current topmost route, if it exists.
  Route? get previousRoute {
    return _routeStack.length >= 2 ? _routeStack[_routeStack.length - 2] : null;
  }

  /// Puts the route [name] on top of the navigation stack.
  ///
  /// If the route is already in the stack, it will be simply moved to the top.
  /// Otherwise the route will be mounted and added at the top. We will also
  /// initiate building the route's page if it hasn't been built before. If the
  /// route is already on top of the stack, this method will do nothing.
  ///
  /// The method calls the [Route.didPush] callback for the newly activated
  /// route.
  void pushNamed(String name) {
    final route = _resolveRoute(name);
    if (route == currentRoute) {
      return;
    }
    if (_routeStack.contains(route)) {
      _routeStack.remove(route);
    } else {
      add(route);
    }
    _routeStack.add(route);
    _adjustRoutesOrder();
    route.didPush(previousRoute);
    _adjustRoutesVisibility();
  }

  /// Puts a new [route] on top of the navigation stack.
  ///
  /// The route may also be given a [name], in which case it will be cached in
  /// the [routes] map under this name (if there was already a route with the
  /// same name, it will be overwritten).
  ///
  /// The method calls [Route.didPush] for this new route after it is added.
  void pushRoute(Route route, {String name = ''}) {
    route.name = name;
    if (name.isNotEmpty) {
      _routes[name] = route;
    }
    add(route);
    _routeStack.add(route);
    _adjustRoutesOrder();
    route.didPush(previousRoute);
    _adjustRoutesVisibility();
  }

  /// Puts the overlay route [name] on top of the navigation stack.
  ///
  /// If [name] was already registered as a name of an overlay route, then this
  /// method is equivalent to [pushNamed]. If not, then a new [OverlayRoute]
  /// will be created based on the overlay with the same name within the root
  /// game.
  void pushOverlay(String name) {
    if (_routes.containsKey(name)) {
      assert(_routes[name] is OverlayRoute, '"$name" is not an overlay route');
      pushNamed(name);
    } else {
      pushRoute(OverlayRoute.existing(), name: name);
    }
  }

  /// Puts [route] on top of the stack and waits until that route is popped.
  ///
  /// More precisely, this method returns a future that can be awaited until
  /// the route is popped; the value returned by this future is generated by
  /// the route as the "return value". This can be useful for creating dialog
  /// boxes that take user input and then return it to the user.
  Future<T> pushAndWait<T>(ValueRoute<T> route) {
    pushRoute(route);
    return route.future;
  }

  /// Removes the topmost route from the stack, and also removes it as a child
  /// of the Router.
  ///
  /// The method calls [Route.didPop] for the route that was removed.
  ///
  /// It is an error to attempt to pop the last remaining route on the stack.
  void pop() {
    assert(
      _routeStack.length > 1,
      'Cannot pop the last route from the Router',
    );
    final route = _routeStack.removeLast();
    _adjustRoutesOrder();
    _adjustRoutesVisibility();
    route.didPop(_routeStack.last);
    route.removeFromParent();
  }

  /// Removes routes from the top of the stack until reaches the route with the
  /// given [name].
  ///
  /// After this method, the route [name] will be at the top of the stack. An
  /// error will occur if this method is run when there is no route with the
  /// specified name on the stack.
  void popUntilNamed(String name) {
    while (currentRoute.name != name) {
      pop();
    }
  }

  /// Removes routes from the stack until [route] is removed. This is equivalent
  /// to [pop] if [route] is currently on top of the stack.
  void popRoute(Route route) {
    while (currentRoute != route) {
      pop();
    }
    pop();
  }

  /// Attempts to resolve the route with the given [name] by searching in the
  /// [_routes] map, or invoking one of the [_routeFactories], or, lastly,
  /// falling back to the [onUnknownRoute] function. If none of these methods
  /// is able to produce a valid [Route], an exception will be raised.
  Route _resolveRoute(String name) {
    final existingRoute = _routes[name];
    if (existingRoute != null) {
      return existingRoute;
    }
    if (name.contains('/')) {
      final i = name.indexOf('/');
      final factoryName = name.substring(0, i);
      final factory = _routeFactories[factoryName];
      if (factory != null) {
        final argument = name.substring(i + 1);
        final generatedRoute = factory(argument)..name = name;
        _routes[name] = generatedRoute;
        return generatedRoute;
      }
    }
    if (onUnknownRoute != null) {
      return onUnknownRoute!(name)..name = name;
    }
    throw ArgumentError('Route "$name" could not be resolved by the Router');
  }

  void _adjustRoutesOrder() {
    for (var i = 0; i < _routeStack.length; i++) {
      _routeStack[i].changePriorityWithoutResorting(i);
    }
    reorderChildren();
  }

  void _adjustRoutesVisibility() {
    var render = true;
    for (var i = _routeStack.length - 1; i >= 0; i--) {
      _routeStack[i].isRendered = render;
      render &= _routeStack[i].transparent;
    }
  }

  @override
  void onMount() {
    super.onMount();
    final route = _resolveRoute(initialRoute);
    _routeStack.add(route);
    add(route);
    route.didPush(null);
  }
}

typedef _RouteFactory = Route Function(String parameter);
