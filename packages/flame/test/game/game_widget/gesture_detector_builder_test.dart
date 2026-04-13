import 'package:flame/src/game/game_widget/gesture_detector_builder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GestureDetectorBuilder', () {
    test('register adds a recognizer factory', () {
      var onChange = 0;
      final builder = GestureDetectorBuilder(() => onChange++);

      builder.register<TapGestureRecognizer>(
        TapGestureRecognizer.new,
        (_) {},
      );

      expect(onChange, 1);
    });

    test('register throws on duplicate type', () {
      final builder = GestureDetectorBuilder(() {});

      builder.register<TapGestureRecognizer>(
        TapGestureRecognizer.new,
        (_) {},
      );

      expect(
        () => builder.register<TapGestureRecognizer>(
          TapGestureRecognizer.new,
          (_) {},
        ),
        throwsStateError,
      );
    });

    test('unregister removes the recognizer factory', () {
      var onChange = 0;
      final builder = GestureDetectorBuilder(() => onChange++);

      builder.register<TapGestureRecognizer>(
        TapGestureRecognizer.new,
        (_) {},
      );
      expect(onChange, 1);

      builder.unregister<TapGestureRecognizer>();
      expect(onChange, 2);
    });

    test('can re-register after unregister', () {
      var onChange = 0;
      final builder = GestureDetectorBuilder(() => onChange++);

      builder.register<LongPressGestureRecognizer>(
        LongPressGestureRecognizer.new,
        (_) {},
      );
      expect(onChange, 1);

      builder.unregister<LongPressGestureRecognizer>();
      expect(onChange, 2);

      builder.register<LongPressGestureRecognizer>(
        LongPressGestureRecognizer.new,
        (_) {},
      );
      expect(onChange, 3);
    });

    test('different recognizer types can coexist', () {
      var onChange = 0;
      final builder = GestureDetectorBuilder(() => onChange++);

      builder.register<TapGestureRecognizer>(
        TapGestureRecognizer.new,
        (_) {},
      );
      builder.register<LongPressGestureRecognizer>(
        LongPressGestureRecognizer.new,
        (_) {},
      );

      expect(onChange, 2);
    });
  });
}
