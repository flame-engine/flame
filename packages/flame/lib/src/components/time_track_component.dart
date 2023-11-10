import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

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
