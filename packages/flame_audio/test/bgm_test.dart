import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAudioPlayer() extends Mock implements AudioPlayer;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(AssetSource(''));
    registerFallbackValue(ReleaseMode.loop);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(name),
        (_) async => null,
      );
    }
  });

  group('Bgm', () {
    late _MockAudioPlayer player;
    late Bgm bgm;
    late List<Completer<void>> pendingSources;

    setUp(() {
      player = _MockAudioPlayer();
      pendingSources = [];
      when(() => player.release()).thenAnswer((_) async {});
      when(() => player.setReleaseMode(any())).thenAnswer((_) async {});
      when(() => player.setVolume(any())).thenAnswer((_) async {});
      when(() => player.setSource(any())).thenAnswer((_) {
        final completer = Completer<void>();
        pendingSources.add(completer);
        return completer.future;
      });
      when(() => player.resume()).thenAnswer((_) async {});
      when(() => player.stop()).thenAnswer((_) async {});
      bgm = Bgm()..audioPlayer = player;
    });

    Future<void> untilSourceIsLoading(int count) async {
      while (pendingSources.length < count) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('stop while play is still loading keeps the music stopped', () async {
      final playing = bgm.play('song.mp3');
      await untilSourceIsLoading(1);

      await bgm.stop();
      pendingSources.single.complete();
      await playing;

      verifyNever(() => player.resume());
      expect(bgm.isPlaying, isFalse);
    });

    test('play after stop starts the music', () async {
      await bgm.stop();
      final playing = bgm.play('song.mp3');
      await untilSourceIsLoading(1);
      pendingSources.single.complete();
      await playing;

      verify(() => player.resume()).called(1);
      expect(bgm.isPlaying, isTrue);
    });

    test('stop while the music is starting leaves isPlaying false', () async {
      final resuming = Completer<void>();
      when(() => player.resume()).thenAnswer((_) => resuming.future);
      final playing = bgm.play('song.mp3');
      await untilSourceIsLoading(1);
      pendingSources.single.complete();
      await Future<void>.delayed(Duration.zero);

      await bgm.stop();
      resuming.complete();
      await playing;

      verify(() => player.stop()).called(1);
      expect(bgm.isPlaying, isFalse);
    });

    test(
      'play while another play is loading starts only the last one',
      () async {
        final first = bgm.play('first.mp3');
        await untilSourceIsLoading(1);

        final second = bgm.play('second.mp3');
        await untilSourceIsLoading(2);
        pendingSources[1].complete();
        await second;
        pendingSources[0].complete();
        await first;

        verify(() => player.resume()).called(1);
        expect(bgm.isPlaying, isTrue);
      },
    );

    test('play whose resume fails leaves isPlaying false', () async {
      when(() => player.resume()).thenThrow(Exception('resume failed'));
      final playing = bgm.play('song.mp3');
      await untilSourceIsLoading(1);
      pendingSources.single.complete();

      await expectLater(playing, throwsException);
      expect(bgm.isPlaying, isFalse);
    });
  });
}
