import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_gamepads/flame_callbacks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamepads/gamepads.dart';

import 'package:gamepads_platform_interface/gamepads_platform_interface.dart';
import 'package:gamepads_platform_interface/method_channel_gamepads_platform_interface.dart';

final platformInterface =
    GamepadsPlatformInterface.instance
        as MethodChannelGamepadsPlatformInterface;

class _TestComponent extends Component with GamepadCallbacks {
  void Function(NormalizedGamepadEvent event) onEvent;

  _TestComponent(this.onEvent);

  @override
  void onGamepadEvent(NormalizedGamepadEvent event) {
    onEvent(event);
  }
}

void main() {
  testWidgets('can get events', (WidgetTester tester) async {
    Gamepads.normalizer = GamepadNormalizer.forPlatform(
      GamepadPlatform.windows,
    );
    final streamController = StreamController<NormalizedGamepadEvent>();
    await tester.pumpWidget(
      GameWidget(
        game: FlameGame()
          ..add(
            _TestComponent(streamController.add),
          ),
      ),
    );
    final listener = streamController.stream.first;
    final millis = DateTime.now().millisecondsSinceEpoch;
    await platformInterface.platformCallHandler(
      MethodCall(
        'onGamepadEvent',
        <String, dynamic>{
          'gamepadId': '1',
          'time': millis,
          'type': 'button',
          'key': 'a',
          'value': 1.0,
        },
      ),
    );
    final event = await listener.timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        fail('Did not receive gamepad event');
      },
    );
    expect(event.gamepadId, '1');
    expect(event.timestamp, millis);
    expect(event.rawEvent.type, KeyType.button);
    expect(event.rawEvent.key, 'a');
    expect(event.value, 1.0);
    expect(event.button, GamepadButton.a);
    streamController.close();
  });
}
