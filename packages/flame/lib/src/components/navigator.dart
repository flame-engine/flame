import 'package:collection/collection.dart';
import 'package:flame/src/components/component.dart';
import 'package:flame/src/components/page.dart';

class Navigator extends Component {
  Navigator({
    required Map<String, Page> pages,
    required this.initialPage,
  }) : _pages = pages;

  final String initialPage;
  final Map<String, Page> _pages;
  final List<Page> _currentPages = [];

  void showPage(String name) {
    final page = _pages[name];
    assert(page != null, 'Page "$name" is not known to the Navigator');
    final activePage = _currentPages.lastOrNull;
    if (page! == activePage) {
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

  void _fixPageOrder() {
    for (var i = 0; i < _currentPages.length; i++) {
      _currentPages[i].changePriorityWithoutResorting(i);
    }
    reorderChildren();
  }

  @override
  void onMount() {
    super.onMount();
    showPage(initialPage);
  }
}
