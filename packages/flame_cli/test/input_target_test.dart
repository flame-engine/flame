import 'package:args/command_runner.dart';
import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

class _Command() extends Command<int> {
  @override
  String get name => 'test';

  @override
  String get description => 'A command to parse targets with.';
}

void main() {
  final command = _Command();

  group('InputTarget', () {
    test('keeps a position as it is', () async {
      final target = InputTarget.parse(command, position: '1.5,-2');
      final calls = <String>[];

      final position = await target.resolve((method, {args}) async {
        calls.add(method);
        return {};
      });

      expect(position, (x: 1.5, y: -2.0));
      expect(calls, isEmpty);
      expect(target.describe(position), '1.5,-2');
    });

    test('asks the game where a component is', () async {
      final target = InputTarget.parse(
        command,
        component: '220731871',
        anchor: 'topLeft',
      );
      final methods = <String>[];
      final arguments = <Map<String, String>?>[];

      final position = await target.resolve((method, {args}) async {
        methods.add(method);
        arguments.add(args);
        return {'id': 220731871, 'x': 412.3456, 'y': 300};
      });

      expect(methods, ['getComponentCanvasPosition']);
      expect(arguments, [
        {'id': '220731871', 'anchor': 'topLeft'},
      ]);
      expect(position, (x: 412.3456, y: 300.0));
      expect(target.describe(position), 'component 220731871 at 412.35,300');
    });

    test('finds a component by its key', () {
      final target = InputTarget.parse(command, component: 'player');

      expect(target.componentArgs, {'key': 'player'});
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
