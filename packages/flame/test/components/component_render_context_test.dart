import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Component Render Context', () {
    testWithFlameGame('simple parent and child', (game) async {
      final child = _ChildReadsContext();
      final parent = _ParentWithContext(
        startingValue: 42,
        children: [
          child,
        ],
      );
      game.add(parent);

      await game.ready();
      game.render(MockCanvas());

      expect(child.myContext, 42);
    });

    testWithFlameGame('complex parent and child', (game) async {
      final child1 = _ChildReadsContext();
      final child2 = _ChildReadsContext();
      final child3 = _ChildReadsContext();

      final parent = Component(
        children: [
          child1,
          _ParentWithContext(
            startingValue: 1,
            children: [
              child2,
              _ParentWithContext(
                startingValue: 2,
                children: [
                  child3,
                ],
              ),
            ],
          ),
        ],
      );
      game.add(parent);

      await game.ready();
      game.render(MockCanvas());

      expect(child1.myContext, null);
      expect(child2.myContext, 1);
      expect(child3.myContext, 2);
    });

    testWithFlameGame('mutating context', (game) async {
      final child = _ChildReadsContext();

      final parent = _ParentWithContext(
        startingValue: 10,
        children: [
          child,
        ],
      );
      game.add(parent);

      await game.ready();
      final canvas = MockCanvas();

      game.render(canvas);
      expect(child.myContext, 10);

      parent._myContext.value = 20;
      game.render(canvas);
      expect(child.myContext, 20);
    });
  });
}

class _IntContext extends ComponentRenderContext {
  int value;

  _IntContext(this.value);
}

class _ParentWithContext extends Component {
  final int startingValue;
  late final _IntContext _myContext = _IntContext(startingValue);

  _ParentWithContext({
    required this.startingValue,
    super.children,
  });

  @override
  _IntContext get renderContext => _myContext;
}

class _ChildReadsContext extends Component {
  int? myContext;

  @override
  void render(Canvas canvas) {
    final context = findRenderContext<_IntContext>();
    myContext = context?.value;

    super.render(canvas);
  }
}
