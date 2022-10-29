import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('RiveComponents', () {
    late FutureOr<RiveFile> riveFile;

    setUpAll(() {
      riveFile = RiveFile.import(loadFile('assets/skills.riv'));
    });

    group('loadArtboard', () {
      test('Load mainArtboard by default', () async {
        final artboard = await loadArtboard(riveFile);
        final tempFile = await riveFile;
        expect(artboard.name, tempFile.mainArtboard.name);
      });

      test('Load the Specified Artboard', () async {
        const artboardName = 'New Artboard';
        final artboard = await loadArtboard(
          riveFile,
          artboardName: artboardName,
        );
        expect(artboard.name, artboardName);
      });

      test('Load an artboard that does not exist', () async {
        expect(
          () => loadArtboard(
            riveFile,
            artboardName: 'Empty',
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('RiveComponent', () {
      testWithFlameGame('Can Add to FlameGame', (game) async {
        final skillsArtboard = await loadArtboard(riveFile);
        final riveComponent = _RiveComponent(artboard: skillsArtboard);

        game.add(riveComponent);
        await game.ready();

        expect(riveComponent.parent, game);
      });

      testWithGame<_RiveComponentHasTappable>(
        'Can Add with Tappable',
        _RiveComponentHasTappable.new,
        (game) async {
          final child = _RiveComponentWthTappable(
            artboard: await loadArtboard(riveFile),
          );
          await game.ensureAdd(child);
          await game.ready();

          expect(child.parent, game);
        },
      );
    });

    group('RiveAnimation', () {
      testWithFlameGame('Does not Animate when no controller is attach',
          (game) async {
        final skillsArtboard = await loadArtboard(riveFile);
        final riveComponent = _RiveComponent(artboard: skillsArtboard);

        game.add(riveComponent);
        await game.ready();

        // Check if the current artboard has animation
        expect(riveComponent.artboard.hasAnimations, isTrue);
        // Check if this artboard is attach to any RiveAnimationController
        expect(riveComponent.artboard.animationControllers.isEmpty, isTrue);
      });

      testWithFlameGame('Animate when controller is attach', (game) async {
        final skillsArtboard = await loadArtboard(riveFile);
        final riveComponent = _RiveComponentWithAnimation(
          artboard: skillsArtboard,
        );

        game.add(riveComponent);
        await game.ready();

        // Check if this artboard has animation
        expect(riveComponent.artboard.hasAnimations, isTrue);
        // Check if this artboard is attach to any RiveAnimationController
        expect(riveComponent.artboard.animationControllers.isEmpty, isFalse);
        // Check if the attach RiveAnimationController is active
        expect(
          riveComponent.artboard.animationControllers.first.isActive,
          isTrue,
        );
      });
    });

    group('Antialiasing', () {
      test('Default value', () async {
        final skillsArtboard = await loadArtboard(riveFile);
        final riveComponent = RiveComponent(
          artboard: skillsArtboard,
        );

        expect(riveComponent.artboard.antialiasing, isTrue);
      });

      test('Can change to false', () async {
        final skillsArtboard = await loadArtboard(riveFile);
        final riveComponent = RiveComponent(
          artboard: skillsArtboard,
          antialiasing: false,
        );

        expect(riveComponent.artboard.antialiasing, isFalse);
      });
    });
  });
}

class _RiveComponent extends RiveComponent {
  _RiveComponent({required super.artboard});
}

class _RiveComponentWithAnimation extends RiveComponent {
  _RiveComponentWithAnimation({required super.artboard});

  @override
  Future<void>? onLoad() async {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "Designer's Test",
    );
    if (controller != null) {
      artboard.addController(controller);
    }
  }
}

class _RiveComponentHasTappable extends FlameGame with HasTappables {}

class _RiveComponentWthTappable extends RiveComponent with Tappable {
  _RiveComponentWthTappable({required super.artboard});
}
