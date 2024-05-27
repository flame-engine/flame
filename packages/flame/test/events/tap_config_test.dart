import 'package:flame/src/events/tap_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TapConfig', () {
    test('default longTapDelay is 0.3', () {
      expect(TapConfig.longTapDelay, 0.3);
    });

    test('longTapDelay can be set new values', () {
      TapConfig.longTapDelay = 0.5;
      expect(TapConfig.longTapDelay, 0.5);
    });

    test('longTapDelay cannot be set to a value lower than 0.150', () {
      TapConfig.longTapDelay = 0.1;
      expect(TapConfig.longTapDelay, 0.150);
    });
  });
}
