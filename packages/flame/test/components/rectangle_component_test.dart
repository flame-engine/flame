import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RectangleComponent.size', () {
    group(
      'refreshes vertices',
      () {
        test(
          'default constructed',
          () {
            final component = RectangleComponent(
              position: Vector2.all(20),
              size: Vector2(20, 40),
            );

            final size1 = [
              Vector2(0, 0),
              Vector2(0, 20),
              Vector2(10, 20),
              Vector2(10, 0)
            ];
            final size2 = [
              Vector2(0, 0),
              Vector2(0, 40),
              Vector2(20, 40),
              Vector2(20, 0)
            ];

            component.size /= 2;
            expect(component.vertices, size1);

            component.size *= 2;
            expect(component.vertices, size2);
          },
        );

        test(
          'square',
          () {
            final component = RectangleComponent.square(
              position: Vector2(60, 20),
              size: 30,
            );
            final size1 = [
              Vector2(0, 0),
              Vector2(0, 15),
              Vector2(15, 15),
              Vector2(15, 0)
            ];
            final size2 = [
              Vector2(0, 0),
              Vector2(0, 30),
              Vector2(30, 30),
              Vector2(30, 0)
            ];

            component.size /= 2;
            expect(component.vertices, size1);

            component.size *= 2;
            expect(component.vertices, size2);
          },
        );

        test(
          'fromRect',
          () {
            final component = RectangleComponent.fromRect(
              const Rect.fromLTWH(110, 20, 50, 60),
            );
            final size1 = [
              Vector2(0, 0),
              Vector2(0, 30),
              Vector2(25, 30),
              Vector2(25, 0)
            ];
            final size2 = [
              Vector2(0, 0),
              Vector2(0, 60),
              Vector2(50, 60),
              Vector2(50, 0)
            ];

            component.size /= 2;
            expect(component.vertices, size1);
            component.size *= 2;
            expect(component.vertices, size2);
          },
        );

        test(
          'relative',
          () {
            final component = RectangleComponent.relative(
              Vector2.all(0.5),
              parentSize: Vector2(180, 60),
              position: Vector2(180, 100),
            );
            final size1 = [
              Vector2(0, 0),
              Vector2(0, 15),
              Vector2(45, 15),
              Vector2(45, 0)
            ];
            final size2 = [
              Vector2(0, 0),
              Vector2(0, 30),
              Vector2(90, 30),
              Vector2(90, 0)
            ];

            component.size /= 2;
            expect(component.vertices, size1);
            component.size *= 2;
            expect(component.vertices, size2);
          },
        );
      },
    );
  });
}
