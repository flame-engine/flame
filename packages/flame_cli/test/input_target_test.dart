import 'package:args/command_runner.dart';
import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

class _Command() extends Command<int> {
  @override
  String get name => 'test';

  @override
  String get description => 'A command to parse targets with.';
}

/// A connection that records the service extension calls and answers them
/// with [_response].
class _FakeConnection(final Map<String, dynamic> _response)
    implements FlameConnection {
  final calls = <(String, Map<String, String>?)>[];

  @override
  String get uri => 'ws://127.0.0.1:1/ws';

  @override
  Future<Map<String, dynamic>> call(
    String method, {
    Map<String, String>? args,
  }) async {
    calls.add((method, args));
    return _response;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  final command = _Command();

  group('InputTarget', () {
    test('keeps a position as it is', () async {
      final target = InputTarget.parse(command, position: '1.5,-2');
      final connection = _FakeConnection({});

      final position = await target.resolve(connection);

      expect(position, (x: 1.5, y: -2.0));
      expect(connection.calls, isEmpty);
      expect(target.describe(position), '1.5,-2');
    });

    test('asks the game where a component is', () async {
      final target = InputTarget.parse(
        command,
        component: '220731871',
        anchor: 'topLeft',
      );
      final connection = _FakeConnection({
        'id': 220731871,
        'x': 412.3456,
        'y': 300,
      });

      final position = await target.resolve(connection);

      final (method, args) = connection.calls.single;
      expect(method, 'getComponentCanvasPosition');
      expect(args, {'id': '220731871', 'anchor': 'topLeft'});
      expect(position, (x: 412.3456, y: 300.0));
      expect(target.describe(position), 'component 220731871 at 412.35,300');
    });

    test('finds a component by its key', () async {
      final target = InputTarget.parse(command, component: 'player');
      final connection = _FakeConnection({'x': 1, 'y': 2});

      await target.resolve(connection);

      expect(target.component, isA<ComponentKeyName>());
      expect(connection.calls.single.$2, {'key': 'player'});
    });
  });

  group('formatCoordinate', () {
    test('uses at most two decimals', () {
      expect(formatCoordinate(400), '400');
      expect(formatCoordinate(100.5), '100.5');
      expect(formatCoordinate(0.126), '0.13');
      expect(formatCoordinate(1000.004), '1000');
    });
  });
}
