import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlameAudio', () {
    test('starts the audioCache with an empty prefix', () {
      expect(FlameAudio.audioCache.prefix, isEmpty);
    });
  });
}
