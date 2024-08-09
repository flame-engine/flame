import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

enum _SpriteState {
  idle,
  running,
  flying,
}

Future<void> main() async {
  // Generate a image
  final image = await generateImage();

  group('SpriteGroupComponent', () {
    test('returns the correct sprite according to its state', () {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image);
      final component = SpriteGroupComponent<_SpriteState>(
        sprites: {
          _SpriteState.idle: sprite1,
          _SpriteState.running: sprite2,
        },
      );

      // No state was specified so nothing is playing
      expect(component.sprite, null);

      // Setting the idle state, we need to see the sprite1
      component.current = _SpriteState.idle;
      expect(component.sprite, sprite1);

      // Setting the running state, we need to see the sprite2
      component.current = _SpriteState.running;
      expect(component.sprite, sprite2);
    });

    test('Asserts that map contains key', () {
      expect(
        () {
          SpriteGroupComponent<String>(sprites: {}).current =
              'non-existent-key';
        },
        failsAssert('Sprite not found for key: non-existent-key'),
      );
    });
  });

  group('SpriteComponent.autoResize', () {
    test('mutual exclusive with size while construction', () {
      expect(
        () => SpriteGroupComponent<_SpriteState>(
          autoResize: true,
          size: Vector2.all(2),
        ),
        throwsAssertionError,
      );

      expect(
        () => SpriteGroupComponent<_SpriteState>(autoResize: false),
        throwsAssertionError,
      );
    });

    test('default value set correctly when not provided explicitly', () {
      final component1 = SpriteGroupComponent<_SpriteState>();
      final component2 = SpriteGroupComponent<_SpriteState>(
        size: Vector2.all(2),
      );

      expect(component1.autoResize, true);
      expect(component2.autoResize, false);
    });

    test('resizes on current state change', () {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image, srcSize: Vector2.all(15));

      final component = SpriteGroupComponent<_SpriteState>(
        sprites: {_SpriteState.idle: sprite1, _SpriteState.running: sprite2},
        current: _SpriteState.idle,
      );
      expect(component.size, sprite1.srcSize);

      component.current = _SpriteState.running;
      expect(component.size, sprite2.srcSize);
    });

    test('resizes only when true', () {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image, srcSize: Vector2.all(15));
      final component = SpriteGroupComponent<_SpriteState>(
        sprites: {_SpriteState.idle: sprite1, _SpriteState.running: sprite2},
        current: _SpriteState.idle,
      )..autoResize = false;

      component.current = _SpriteState.running;
      expect(component.size, sprite1.srcSize);

      component.autoResize = true;
      expect(component.size, sprite2.srcSize);
    });

    test('stop autoResizing on external size modifications', () {
      final testSize = Vector2(83, 100);
      final spritesMap = {
        _SpriteState.idle: Sprite(image),
        _SpriteState.running: Sprite(image, srcSize: Vector2.all(15)),
      };
      final component = SpriteGroupComponent<_SpriteState>();

      // NOTE: Sequence of modifications is important here. Changing the size
      // first disables the auto-resizing. So even if sprites map is changed
      // later, the component should still maintain testSize.
      component
        ..size = testSize
        ..sprites = spritesMap
        ..current = _SpriteState.running;

      expectDouble(component.size.x, testSize.x);
      expectDouble(component.size.y, testSize.y);
    });

    test('modify size only if changed while auto-resizing', () {
      final spritesMap = {
        _SpriteState.idle: Sprite(image, srcSize: Vector2.all(15)),
        _SpriteState.running: Sprite(image, srcSize: Vector2.all(15)),
        _SpriteState.flying: Sprite(image, srcSize: Vector2(15, 12)),
      };
      final component = SpriteGroupComponent<_SpriteState>(sprites: spritesMap);

      var sizeChangeCounter = 0;
      component.size.addListener(() => ++sizeChangeCounter);

      component.current = _SpriteState.running;
      expect(sizeChangeCounter, equals(1));

      component.current = _SpriteState.idle;
      expect(sizeChangeCounter, equals(1));

      component.current = _SpriteState.flying;
      expect(sizeChangeCounter, equals(2));
    });
  });

  group('SpriteGroupComponent.currentSpriteNotifier', () {
    test('notifies when the current sprite changes', () {
      final spritesMap = {
        _SpriteState.idle: Sprite(image, srcSize: Vector2.all(15)),
        _SpriteState.running: Sprite(image, srcSize: Vector2.all(15)),
        _SpriteState.flying: Sprite(image, srcSize: Vector2(15, 12)),
      };
      final component = SpriteGroupComponent<_SpriteState>(
        sprites: spritesMap,
      );
      var spriteChangeCounter = 0;
      component.currentSpriteNotifier.addListener(
        () => spriteChangeCounter++,
      );

      component.current = _SpriteState.running;
      expect(spriteChangeCounter, equals(1));

      component.current = _SpriteState.idle;
      expect(spriteChangeCounter, equals(2));

      component.update(1);
      expect(spriteChangeCounter, equals(2));

      component.current = _SpriteState.running;
      expect(spriteChangeCounter, equals(3));

      component.update(1);
      expect(spriteChangeCounter, equals(3));

      component.current = _SpriteState.running;
      component.update(1);
      expect(spriteChangeCounter, equals(3));
    });
  });
}
