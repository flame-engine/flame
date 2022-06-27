import 'package:flame/src/components/component.dart';
import 'package:flame/src/components/page.dart';

/// [Navigator] is a component that handles transitions between multiple [Page]s
/// of your game.
///
class Navigator extends Component {
  Navigator({
    required Map<String, Page> pages,
    required this.initialPage,
    Map<String, _PageFactory>? pageFactories,
    this.onUnknownPage,
  })  : _pages = pages,
        _pageFactories = pageFactories ?? {};

  final String initialPage;
  final Map<String, Page> _pages;
  final Map<String, _PageFactory> _pageFactories;
  final List<Page> _currentPages = [];
  final _PageFactory? onUnknownPage;

  /// Puts the page [name] on top of the navigation stack.
  ///
  /// If the page is already in the stack, it will be simply moved on top;
  /// otherwise the page will be built, mounted, and added at the top. If the
  /// page is already on the top, this method will be a noop.
  ///
  ///
  void pushPage(String name) {
    final page = _resolvePage(name);
    final currentActivePage = _currentPages.last;
    if (page == currentActivePage) {
      return;
    }
    if (_currentPages.contains(page)) {
      _currentPages.remove(page);
      _currentPages.add(page);
    } else {
      _currentPages.add(page);
      add(page);
    }
    _adjustPageOrder();
    page.didPush(currentActivePage);
    _execute(action: _adjustPageVisibility, delay: page.pushTransitionDuration);
  }

  void popPage() {
    assert(
      _currentPages.length > 1,
      'Cannot pop the last page from the Navigator',
    );
    final page = _currentPages.removeLast();
    _adjustPageOrder();
    _adjustPageVisibility();
    page.didPop(_currentPages.last);
    _execute(action: page.removeFromParent, delay: page.popTransitionDuration);
  }

  Page _resolvePage(String name) {
    final existingPage = _pages[name];
    if (existingPage != null) {
      return existingPage;
    }
    if (name.contains('/')) {
      final i = name.indexOf('/');
      final factoryName = name.substring(0, i);
      final factory = _pageFactories[factoryName];
      if (factory != null) {
        final argument = name.substring(i + 1);
        final generatedPage = factory(argument);
        _pages[name] = generatedPage;
        return generatedPage;
      }
    }
    if (onUnknownPage != null) {
      return onUnknownPage!(name);
    }
    throw ArgumentError('Page "$name" could not be resolved by the Navigator');
  }

  void _adjustPageOrder() {
    for (var i = 0; i < _currentPages.length; i++) {
      _currentPages[i].changePriorityWithoutResorting(i);
    }
    reorderChildren();
  }

  void _adjustPageVisibility() {
    var render = true;
    for (var i = _currentPages.length - 1; i >= 0; i--) {
      _currentPages[i].isRendered = render;
      render &= _currentPages[i].transparent;
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
    final page = _resolvePage(initialPage);
    _currentPages.add(page);
    add(page);
    page.didPush(null);
  }
}

typedef _PageFactory = Page Function(String parameter);
