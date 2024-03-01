import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  final image = await generateImage();

  group('SpriteComponent', () {
    test('check sizing of SpriteComponent', () {
      expect(image.width, 1);
      expect(image.height, 1);

      final component1 = SpriteComponent.fromImage(image);
      expect(component1.size, Vector2(1, 1));

      final component2 = SpriteComponent.fromImage(image, size: Vector2(5, 10));
      expect(component2.size, Vector2(5, 10));

      final component3 = SpriteComponent.fromImage(
        image,
        srcSize: Vector2(4, 3),
      );
      expect(component3.size, Vector2(4, 3));

      final component4 = SpriteComponent.fromImage(
        image,
        size: Vector2(40, 30),
        srcSize: Vector2(4, 3),
      );
      expect(component4.size, Vector2(40, 30));

      final sprite = Sprite(image, srcSize: Vector2(2, 2));
      final component5 = SpriteComponent(sprite: sprite, size: Vector2(10, 10));
      expect(component5.size, Vector2(10, 10));

      final component6 = SpriteComponent(sprite: sprite);
      expect(component6.size, Vector2(2, 2));
    });
  });

  group('SpriteComponent.autoResize', () {
    test('mutual exclusive with size while construction', () {
      expect(
        () => SpriteComponent(autoResize: true, size: Vector2.all(2)),
        throwsAssertionError,
      );
      expect(
        () => SpriteComponent.fromImage(
          image,
          autoResize: true,
          size: Vector2.all(2),
        ),
        throwsAssertionError,
      );

      expect(() => SpriteComponent(autoResize: false), throwsAssertionError);
      expect(
        () => SpriteComponent.fromImage(image, autoResize: false),
        throwsAssertionError,
      );
    });

    test('default value set correctly when not provided explicitly', () {
      final component1 = SpriteComponent();
      final component2 = SpriteComponent(size: Vector2.all(2));

      expect(component1.autoResize, true);
      expect(component2.autoResize, false);
    });

    test('resizes on sprite change', () {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image, srcSize: Vector2.all(13));

      final component = SpriteComponent()..sprite = sprite1;
      expect(component.size, sprite1.srcSize);

      component.sprite = sprite2;
      expect(component.size, sprite2.srcSize);
    });

    test('resizes only when true', () {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image, srcSize: Vector2.all(13));
      final component = SpriteComponent(sprite: sprite1)..autoResize = false;

      component.sprite = sprite2;
      expect(component.size, sprite1.srcSize);

      component.autoResize = true;
      expect(component.size, sprite2.srcSize);
    });

    test('stop autoResizing on external size modifications', () {
      final testSize = Vector2(83, 100);
      final sprite = Sprite(image, srcSize: Vector2.all(13));
      final component = SpriteComponent();

      // NOTE: Sequence of modifications is important here. Changing the size
      // first disables the auto-resizing. So even if sprite is changed later,
      // the component should still maintain testSize.
      component
        ..size = testSize
        ..sprite = sprite;

      expectDouble(component.size.x, testSize.x);
      expectDouble(component.size.y, testSize.y);
    });

    test('modify size only if changed while auto-resizing', () {
      final sprite1 = Sprite(image, srcSize: Vector2.all(13));
      final sprite2 = Sprite(image, srcSize: Vector2.all(13));
      final sprite3 = Sprite(image, srcSize: Vector2(13, 14));
      final component = SpriteComponent();

      var sizeChangeCounter = 0;
      component.size.addListener(() => ++sizeChangeCounter);

      component.sprite = sprite1;
      expect(sizeChangeCounter, equals(1));

      component.sprite = sprite2;
      expect(sizeChangeCounter, equals(1));

      component.sprite = sprite3;
      expect(sizeChangeCounter, equals(2));
    });
  });
}
