import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAudioCache extends Mock implements AudioCache {}

class _MockAudioPlayer extends Mock implements AudioPlayer {}

class _MockBgmCache extends Mock implements Bgm {}

void main() {
  group('FlameAudio', () {
    test('starts the audioCache with the default prefix', () {
      expect(
        FlameAudio.audioCache.prefix,
        equals('assets/audio/'),
      );
    });

    group('updatePrefix', () {
      test('updates the prefix on both bgm and audioCache', () {
        final audioCache = _MockAudioCache();

        FlameAudio.audioCache = audioCache;

        final bgm = _MockBgmCache();
        final bgmAudioPlayer = _MockAudioPlayer();
        when(() => bgm.audioPlayer).thenReturn(bgmAudioPlayer);
        final bgmAudioCache = _MockAudioCache();
        when(() => bgmAudioPlayer.audioCache).thenReturn(bgmAudioCache);

        FlameAudio.bgmFactory = ({required AudioCache audioCache}) => bgm;

        const newPrefix = 'newPrefix/';
        FlameAudio.updatePrefix(newPrefix);

        verify(() => audioCache.prefix = newPrefix).called(1);
        verify(() => bgmAudioCache.prefix = newPrefix).called(1);
      });
    });
  });
}
