import 'package:flame/src/components/component.dart';
import 'package:flame/src/components/route.dart';

/// [Navigator] is a component that handles transitions between multiple pages
/// of your game.
///
/// The term **page** is used descriptively here: it is any full-screen (or
/// partial-screen) component. For example: a starting page, a settings page,
/// the main game world page, and so on. A page can also be any individual piece
/// of UI, such as a confirmation dialog box, or a user inventory pop-up.
///
/// The [Navigator] doesn't handle the pages directly -- instead, it operates
/// a stack of [Route]s. Each route, in turn, manages a single page component.
/// However, routes are "lazy": they will only build their pages when they
/// become active.
///
/// Internally, the Navigator maintains a stack of Routes. In the beginning,
/// the stack will contain the [initialRoute]. New routes can be added via the
/// [pushRoute] method, and removed with [popRoute]. However, the stack must be
/// kept non-empty: it is an error to attempt to remove the only remaining route
/// from the stack.
///
/// Routes that are on the stack are mounted as components. When a route is
/// popped, it is removed from the stack and unmounted. Routes can be either
/// transparent or opaque. An opaque route prevents all routes below it from
/// rendering, and also stops pointer events. In addition, routes are able to
/// stop or slow down time for the pages that they control, or to apply visual
/// effects to those pages.
class Navigator extends Component {
  Navigator({
    required this.initialRoute,
    required Map<String, Route> routes,
    Map<String, _RouteFactory>? routeFactories,
    this.onUnknownRoute,
  })  : _routes = routes,
        _routeFactories = routeFactories ?? {};

  final String initialRoute;
  final Map<String, Route> _routes;
  final Map<String, _RouteFactory> _routeFactories;
  final List<Route> _currentRoutes = [];
  final _RouteFactory? onUnknownRoute;

  /// Puts the page [name] on top of the navigation stack.
  ///
  /// If the page is already in the stack, it will be simply moved on top;
  /// otherwise the page will be built, mounted, and added at the top. If the
  /// page is already on the top, this method will be a noop.
  ///
  ///
  void pushRoute(String name) {
    final route = _resolveRoute(name);
    final currentActiveRoute = _currentRoutes.last;
    if (route == currentActiveRoute) {
      return;
    }
    if (_currentRoutes.contains(route)) {
      _currentRoutes.remove(route);
      _currentRoutes.add(route);
    } else {
      _currentRoutes.add(route);
      add(route);
    }
    _adjustRoutesOrder();
    route.didPush(currentActiveRoute);
    _adjustRoutesVisibility();
  }

  void popRoute() {
    assert(
      _currentRoutes.length > 1,
      'Cannot pop the last route from the Navigator',
    );
    final route = _currentRoutes.removeLast();
    _adjustRoutesOrder();
    _adjustRoutesVisibility();
    route.didPop(_currentRoutes.last);
    route.removeFromParent();
  }

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
        final generatedRoute = factory(argument);
        _routes[name] = generatedRoute;
        return generatedRoute;
      }
    }
    if (onUnknownRoute != null) {
      return onUnknownRoute!(name);
    }
    throw ArgumentError('Route "$name" could not be resolved by the Navigator');
  }

  void _adjustRoutesOrder() {
    for (var i = 0; i < _currentRoutes.length; i++) {
      _currentRoutes[i].changePriorityWithoutResorting(i);
    }
    reorderChildren();
  }

  void _adjustRoutesVisibility() {
    var render = true;
    for (var i = _currentRoutes.length - 1; i >= 0; i--) {
      _currentRoutes[i].isRendered = render;
      render &= _currentRoutes[i].transparent;
    }
  }

  @override
  void onMount() {
    super.onMount();
    final route = _resolveRoute(initialRoute);
    _currentRoutes.add(route);
    add(route);
    route.didPush(null);
  }
}

typedef _RouteFactory = Route Function(String parameter);
