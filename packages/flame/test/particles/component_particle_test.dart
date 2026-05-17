import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComponentParticle', () {
    test(
      'CircleComponent renders without error when used outside of the '
      'component lifecycle',
      () {
        final particle = ComponentParticle(
          component: CircleComponent(radius: 2),
          lifespan: 1,
        );

        expect(
          () => particle.render(Canvas(PictureRecorder())),
          returnsNormally,
        );
      },
    );
  });
}
