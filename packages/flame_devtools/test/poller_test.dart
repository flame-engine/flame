import 'dart:async';

import 'package:flame_devtools/poller.dart';
import 'package:flutter_test/flutter_test.dart';

const _interval = Duration(milliseconds: 100);

void main() {
  group('Poller', () {
    testWidgets('polls once per interval while it is active', (tester) async {
      var polls = 0;
      final poller = Poller(
        interval: _interval,
        isActive: () => true,
        poll: () async => polls++,
      )..start();

      await tester.pump(_interval * 3);
      expect(polls, 3);

      poller.stop();
    });

    testWidgets('does not poll while it is inactive', (tester) async {
      var polls = 0;
      var isActive = false;
      final poller = Poller(
        interval: _interval,
        isActive: () => isActive,
        poll: () async => polls++,
      )..start();

      await tester.pump(_interval * 3);
      expect(polls, 0);

      isActive = true;
      await tester.pump(_interval);
      expect(polls, 1);

      poller.stop();
    });

    testWidgets('does not start a poll while the previous one is running', (
      tester,
    ) async {
      var polls = 0;
      var completer = Completer<void>();
      final poller = Poller(
        interval: _interval,
        isActive: () => true,
        poll: () {
          polls++;
          return completer.future;
        },
      )..start();

      await tester.pump(_interval * 5);
      expect(polls, 1);
      expect(poller.isPolling, isTrue);

      completer.complete();
      completer = Completer<void>();
      await tester.pump();
      expect(poller.isPolling, isFalse);

      await tester.pump(_interval);
      expect(polls, 2);

      completer.complete();
      poller.stop();
    });

    testWidgets('keeps polling after a poll fails', (tester) async {
      var polls = 0;
      final poller = Poller(
        interval: _interval,
        isActive: () => true,
        poll: () async {
          polls++;
          throw StateError('The game was disconnected');
        },
      )..start();

      await tester.pump(_interval * 2);
      expect(polls, 2);
      expect(poller.isPolling, isFalse);

      poller.stop();
    });

    testWidgets('stops polling when it is stopped', (tester) async {
      var polls = 0;
      final poller = Poller(
        interval: _interval,
        isActive: () => true,
        poll: () async => polls++,
      )..start();

      await tester.pump(_interval);
      poller.stop();
      await tester.pump(_interval * 3);

      expect(polls, 1);
    });
  });
}
