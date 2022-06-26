import 'package:collection/collection.dart';
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
  }) : _pages = pages,
       _pageFactories = pageFactories ?? {};

  final String initialPage;
  final Map<String, Page> _pages;
  final Map<String, _PageFactory> _pageFactories;
  final List<Page> _currentPages = [];
  final _PageFactory? onUnknownPage;

  void showPage(String name) {
    final page = _resolvePage(name);
    final activePage = _currentPages.lastOrNull;
    if (page == activePage) {
      return;
    }
    if (!page.isMounted) {
      add(page);
    }
    _currentPages.remove(page);
    _currentPages.add(page);
    _fixPageOrder();
    activePage?.deactivate();
    page.activate();
  }

  void popPage() {
    if (_currentPages.isEmpty) {
      return;
    }
    final poppedPage = _currentPages.removeLast()..removeFromParent();
    _fixPageOrder();
    poppedPage.deactivate();
    _currentPages.lastOrNull?.activate();
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

  void _fixPageOrder() {
    var render = true;
    for (var i = _currentPages.length - 1; i >= 0; i--) {
      _currentPages[i].changePriorityWithoutResorting(i);
      _currentPages[i].isRendered = render;
      render &= _currentPages[i].transparent;
    }
    reorderChildren();
  }

  @override
  void onMount() {
    super.onMount();
    showPage(initialPage);
  }
}

typedef _PageFactory = Page Function(String parameter);
