import 'dart:ui' show Rect;

import 'package:flame/cache.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAssetBundle() extends Mock implements AssetBundle;

/// An SVG with a square of the given [side] at ([x], [y]).
String _squareSvg(double x, double y, [double side = 10]) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
    '<rect x="$x" y="$y" width="$side" height="$side" fill="#ff0000"/> </svg>';

SvgPathsAnimationFrame _frame(
  double start,
  double duration, {
  SvgPaths? svg,
}) {
  return SvgPathsAnimationFrame(
    svg ?? SvgPaths(_squareSvg(0, 0)),
    start: start,
    duration: duration,
  );
}

void main() {
  group('SvgPathsAnimation', () {
    test('lasts until the latest end of the frames by default', () {
      final animation = SvgPathsAnimation([_frame(0, 1), _frame(0.5, 2)]);
      expect(animation.duration, 2.5);
    });

    test('can last longer than its frames', () {
      final animation = SvgPathsAnimation([_frame(0, 1)], duration: 3);
      expect(animation.duration, 3);
    });

    test('asserts on invalid frames and durations', () {
      expect(() => SvgPathsAnimation([]), throwsAssertionError);
      expect(() => SvgPathsAnimation([_frame(-1, 1)]), throwsAssertionError);
      expect(() => SvgPathsAnimation([_frame(0, 0)]), throwsAssertionError);
      expect(
        () => SvgPathsAnimation([_frame(0, 2)], duration: 1),
        throwsAssertionError,
      );
    });

    test('has an area including the bounds of all frames', () {
      final animation = SvgPathsAnimation([
        _frame(0, 1, svg: SvgPaths(_squareSvg(10, 20))),
        _frame(1, 1, svg: SvgPaths(_squareSvg(50, 60))),
        _frame(
          2,
          1,
          svg: SvgPaths(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"/>',
          ),
        ),
      ]);
      expect(animation.area, const Rect.fromLTRB(10, 20, 60, 70));
    });

    group('indicesAt', () {
      // Frame 0 in [1, 2), 1 in [1.5, 3), 2 in [4, 5), 3 in [4, 5).
      final animation = SvgPathsAnimation([
        _frame(1, 1),
        _frame(1.5, 1.5),
        _frame(4, 1),
        _frame(4, 1),
      ], duration: 6);

      test('returns the active frames in order', () {
        expect(animation.indicesAt(1.2), [0]);
        expect(animation.indicesAt(1.5), [0, 1]);
        expect(animation.indicesAt(2), [1]);
        expect(animation.indicesAt(4.5), [2, 3]);
      });

      test('holds the frames ending last in a gap', () {
        expect(animation.indicesAt(3), [1]);
        expect(animation.indicesAt(3.9), [1]);
        expect(animation.indicesAt(5.5), [2, 3]);
      });

      test('shows the earliest frames before them in the first loop', () {
        expect(animation.indicesAt(0), [0]);
        expect(animation.indicesAt(0.5), [0]);
      });

      test('shows the latest frames before the earliest in later loops', () {
        expect(animation.indicesAt(0.5, firstLoop: false), [2, 3]);
      });

      test('does not overlap frames that follow each other', () {
        // 0.1 + 0.2 is a little more than 0.3.
        final following = SvgPathsAnimation([
          _frame(0, 0.1),
          _frame(0.1, 0.2),
          _frame(0.3, 0.1),
        ]);
        expect(following.indicesAt(0.3), [2]);
        expect(following.indicesAt(0.1), [1]);
      });

      test('returns lists that can not be modified', () {
        for (final time in [0.0, 1.2, 3.0]) {
          expect(
            () => animation.indicesAt(time).add(0),
            throwsUnsupportedError,
          );
        }
      });
    });

    test('loads each file once', () async {
      final bundle = _MockAssetBundle();
      when(
        () => bundle.loadString(any()),
      ).thenAnswer((_) async => _squareSvg(0, 0));
      final animation = await SvgPathsAnimation.load(
        [
          SvgPathsAnimationFrameData(fileName: 'a.svg', start: 0, duration: 1),
          SvgPathsAnimationFrameData(fileName: 'b.svg', start: 1, duration: 1),
          SvgPathsAnimationFrameData(fileName: 'a.svg', start: 2, duration: 1),
        ],
        cache: AssetsCache(bundle: bundle),
        loop: false,
      );
      verify(() => bundle.loadString('a.svg')).called(1);
      verify(() => bundle.loadString('b.svg')).called(1);
      expect(animation.frames.length, 3);
      expect(animation.frames[0].svg, same(animation.frames[2].svg));
      expect(animation.frames[1].start, 1);
      expect(animation.loop, isFalse);
    });
  });

  group('SvgPathsAnimationTicker', () {
    // Frame 0 in [0.5, 1.5), 1 in [1.5, 2), gap until 3.
    SvgPathsAnimation animationOf({bool loop = true}) => SvgPathsAnimation(
      [_frame(0.5, 1), _frame(1.5, 0.5)],
      duration: 3,
      loop: loop,
    );

    test('starts with the earliest frames', () {
      final ticker = animationOf().createTicker();
      expect(ticker.currentIndices, [0]);
      expect(ticker.currentFrames.single.start, 0.5);
      expect(ticker.totalDuration(), 3);
    });

    test('calls onFrame only when the frames shown change', () {
      final frames = <List<int>>[];
      var starts = 0;
      final ticker = animationOf().createTicker()
        ..onStart = (() => starts++)
        ..onFrame = frames.add;
      for (var i = 0; i < 10; i++) {
        ticker.update(0.25);
      }
      expect(starts, 1);
      expect(frames, [
        [0],
        [1],
      ]);
      expect(ticker.currentIndices, [1]);
    });

    test('loops back showing the latest frames before the earliest', () {
      final ticker = animationOf().createTicker()..update(3.25);
      expect(ticker.clock, closeTo(0.25, 1e-9));
      expect(ticker.elapsed, 3.25);
      expect(ticker.currentIndices, [1]);
      ticker.update(0.5);
      expect(ticker.currentIndices, [0]);
      expect(ticker.done(), isFalse);
    });

    test('completes when it does not loop', () async {
      var completions = 0;
      final ticker = animationOf(loop: false).createTicker()
        ..onComplete = (() => completions++);
      final completed = ticker.completed;
      ticker
        ..update(2)
        ..update(2);
      expect(ticker.done(), isTrue);
      expect(ticker.clock, 3);
      expect(ticker.currentIndices, [1]);
      expect(completions, 1);
      await expectLater(completed, completes);
      await expectLater(ticker.completed, completes);
    });

    test('does not update while paused', () {
      final ticker = animationOf().createTicker()
        ..paused = true
        ..update(1.6);
      expect(ticker.clock, 0);
      expect(ticker.currentIndices, [0]);
    });

    test('sets to last', () {
      final ticker = animationOf(loop: false).createTicker()..setToLast();
      expect(ticker.done(), isTrue);
      expect(ticker.currentIndices, [1]);
    });

    test('sets to last while paused', () {
      final ticker = animationOf(loop: false).createTicker()
        ..paused = true
        ..setToLast();
      expect(ticker.done(), isTrue);
      expect(ticker.clock, 3);
      expect(ticker.currentIndices, [1]);
    });

    test('completes again after a reset', () async {
      final ticker = animationOf(loop: false).createTicker();
      final first = ticker.completed;
      ticker
        ..update(4)
        ..reset();
      final second = ticker.completed;
      expect(second, isNot(same(first)));
      ticker.update(4);
      await expectLater(second, completes);
    });

    test('resets', () {
      final ticker = animationOf(loop: false).createTicker()
        ..update(4)
        ..reset();
      expect(ticker.done(), isFalse);
      expect(ticker.clock, 0);
      expect(ticker.elapsed, 0);
      expect(ticker.currentIndices, [0]);
    });
  });
}
