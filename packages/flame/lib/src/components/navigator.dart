import 'package:flame/src/components/component.dart';
import 'package:flame/src/components/route.dart';

/// [Navigator] is a component that handles transitions between multiple
/// [Route]s of your game.
///
class Navigator extends Component {
  Navigator({
    required Map<String, Route> routes,
    required this.initialRoute,
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
    final page = _resolveRoute(name);
    final currentActivePage = _currentRoutes.last;
    if (page == currentActivePage) {
      return;
    }
    if (_currentRoutes.contains(page)) {
      _currentRoutes.remove(page);
      _currentRoutes.add(page);
    } else {
      _currentRoutes.add(page);
      add(page);
    }
    _adjustPageOrder();
    page.didPush(currentActivePage);
    _execute(action: _adjustPageVisibility, delay: page.pushTransitionDuration);
  }

  void popRoute() {
    assert(
      _currentRoutes.length > 1,
      'Cannot pop the last page from the Navigator',
    );
    final page = _currentRoutes.removeLast();
    _adjustPageOrder();
    _adjustPageVisibility();
    page.didPop(_currentRoutes.last);
    _execute(action: page.removeFromParent, delay: page.popTransitionDuration);
  }

  Route _resolveRoute(String name) {
    final existingPage = _routes[name];
    if (existingPage != null) {
      return existingPage;
    }
    if (name.contains('/')) {
      final i = name.indexOf('/');
      final factoryName = name.substring(0, i);
      final factory = _routeFactories[factoryName];
      if (factory != null) {
        final argument = name.substring(i + 1);
        final generatedPage = factory(argument);
        _routes[name] = generatedPage;
        return generatedPage;
      }
    }
    if (onUnknownRoute != null) {
      return onUnknownRoute!(name);
    }
    throw ArgumentError('Page "$name" could not be resolved by the Navigator');
  }

  void _adjustPageOrder() {
    for (var i = 0; i < _currentRoutes.length; i++) {
      _currentRoutes[i].changePriorityWithoutResorting(i);
    }
    reorderChildren();
  }

  void _adjustPageVisibility() {
    var render = true;
    for (var i = _currentRoutes.length - 1; i >= 0; i--) {
      _currentRoutes[i].isRendered = render;
      render &= _currentRoutes[i].transparent;
    }
  }

  void _execute({required void Function() action, required double delay}) {
    if (delay > 0) {
      Future<void>.delayed(Duration(microseconds: (delay * 1e6).toInt()))
          .then((_) => action());
    } else {
      action();
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
