import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/src/components/component.dart';
import 'package:flame/src/components/mixins/coordinate_transform.dart';
import 'package:flame/src/components/page.dart';
import 'package:vector_math/vector_math_64.dart';

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

  void popPage() {
    if (_currentPages.isEmpty) {
      return;
    }
    final poppedPage = _currentPages.removeLast()..removeFromParent();
    _fixPageOrder();
    poppedPage.deactivate();
    _currentPages.lastOrNull?.activate();
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
