import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _RemoveComponent extends Component {
  int removeCounter = 0;

  @override
  void onRemove() {
    super.onRemove();
    removeCounter++;
  }
}

class _PrepareGame extends FlameGame {
  late final _ParentOnPrepareComponent prepareParent;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await add(prepareParent = _ParentOnPrepareComponent());
  }

  @override
  void prepareComponent(Component c) {
    super.prepareComponent(c);
    (c as _OnPrepareComponent).prepareRuns++;
  }
}

class _OnPrepareComponent extends Component {
  int prepareRuns = 0;
}

class _ParentOnPrepareComponent extends _OnPrepareComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    await add(_OnPrepareComponent());
  }
}

void main() {
  final prepareGame = FlameTester(() => _PrepareGame());

  group('Component', () {
    test('get/set x/y or position', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(2.2, 3.4);
      expect(c.x, 2.2);
      expect(c.y, 3.4);

      c.position.setValues(1.0, 0.0);
      expect(c.x, 1.0);
      expect(c.y, 0.0);
    });

    test('get/set width/height or size', () {
      final PositionComponent c = SpriteComponent();
      c.size.setValues(2.2, 3.4);
      expect(c.size.x, 2.2);
      expect(c.size.y, 3.4);

      c.size.setValues(1.0, 0.0);
      expect(c.width, 1.0);
      expect(c.height, 0.0);
    });

    test('get/set rect', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(0.0, 1.0);
      c.size.setValues(2.0, 2.0);
      final rect = c.toRect();
      expect(rect.left, 0.0);
      expect(rect.top, 1.0);
      expect(rect.width, 2.0);
      expect(rect.height, 2.0);

      c.setByRect(const Rect.fromLTWH(10.0, 10.0, 1.0, 1.0));
      expect(c.x, 10.0);
      expect(c.y, 10.0);
      expect(c.width, 1.0);
      expect(c.height, 1.0);
    });

    test('get/set rect with anchor', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(0.0, 1.0);
      c.size.setValues(2.0, 2.0);
      c.anchor = Anchor.center;
      final rect = c.toRect();
      expect(rect.left, -1.0);
      expect(rect.top, 0.0);
      expect(rect.width, 2.0);
      expect(rect.height, 2.0);

      c.setByRect(const Rect.fromLTWH(10.0, 10.0, 1.0, 1.0));
      expect(c.x, 10.5);
      expect(c.y, 10.5);
      expect(c.width, 1.0);
      expect(c.height, 1.0);
    });

    test('get/set anchorPosition', () {
      final PositionComponent c = SpriteComponent();
      c.position.setValues(0.0, 1.0);
      c.size.setValues(2.0, 2.0);
      c.anchor = Anchor.center;
      final anchorPosition = c.topLeftPosition;
      expect(anchorPosition.x, -1.0);
      expect(anchorPosition.y, 0.0);
    });

    test('remove and shouldRemove', () {
      final c1 = SpriteComponent();
      expect(c1.shouldRemove, equals(false));
      c1.removeFromParent();
      expect(c1.shouldRemove, equals(true));

      final c2 = SpriteAnimationComponent();
      expect(c2.shouldRemove, equals(false));
      c2.removeFromParent();
      expect(c2.shouldRemove, equals(true));

      c2.shouldRemove = false;
      expect(c2.shouldRemove, equals(false));
    });

    flameGame.test(
      'remove and re-add should not double trigger onRemove',
      (game) async {
        final component = _RemoveComponent();

        await game.ensureAdd(component);
        component.removeFromParent();
        game.update(0);
        expect(component.removeCounter, 1);
        component.shouldRemove = false;
        component.removeCounter = 0;
        await game.ensureAdd(component);
        expect(component.removeCounter, 0);
        expect(game.children.length, 1);
      },
    );

    prepareGame.test(
      'adding children to a parent that is not yet added to a game should not '
      'run double onPrepare',
      (game) async {
        final parent = game.prepareParent;
        expect(parent.prepareRuns, 1);
        expect((parent.children.first as _OnPrepareComponent).prepareRuns, 1);
      },
    );

    test('childrenFactory', () {
      Component.childrenFactory = (Component owner) {
        return ComponentSet.createDefault(owner, strictMode: false);
      };

      final component1 = Component();
      final component2 = Component();
      component1.add(component2);
      component2.add(Component());
      expect(component1.children.strictMode, false);
      expect(component2.children.strictMode, false);
    });
  });
}
