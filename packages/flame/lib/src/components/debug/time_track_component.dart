import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

/// A component that offers a simple way to track time spent in different parts
/// of your game.
///
/// This component is meant to be used for debugging purposes only and should
/// not be added in production builds.
///
/// To start tracking time, call [TimeTrackComponent.start] with an identifier
/// and [TimeTrackComponent.end] with that same identifier to finish tracking.
///
/// To see the recorded times, simply add this component to your game.
class TimeTrackComponent extends TextComponent {
  TimeTrackComponent({super.position});

  static final Map<String, int> _startTimes = {};
  static final Map<String, int> _endTimes = {};

  static void clear() {
    _startTimes.clear();
    _endTimes.clear();
  }

  static void start(String name) {
    _startTimes[name] = DateTime.now().microsecondsSinceEpoch;
  }

  static void end(String name) {
    _endTimes[name] = DateTime.now().microsecondsSinceEpoch;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    textRenderer = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 12,
      ),
    );

    add(
      TimerComponent(
        period: 1,
        repeat: true,
        onTick: () {
          final sb = StringBuffer();
          for (final entry in _startTimes.entries) {
            final name = entry.key;
            final startTime = entry.value;
            final endTime = _endTimes[name];
            final duration = endTime == null ? 0 : endTime - startTime;
            sb.writeln('$name: $duration');
          }
          text = sb.toString();
        },
      ),
    );
  }
}
