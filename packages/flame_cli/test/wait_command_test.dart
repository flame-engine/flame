import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

const _uri = 'http://127.0.0.1:1/abc=/';

typedef _Handler = FutureOr<Map<String, dynamic>> Function(
  String method,
  Map<String, String>? args,
);

/// A connection that answers the service extension calls with [handler], and
/// records the methods that were called.
class _FakeConnection(final _Handler handler) implements FlameConnection {
  final calls = <String>[];

  @override
  String get uri => _uri;

  @override
  Future<Map<String, dynamic>> call(
    String method, {
    Map<String, String>? args,
  }) async {
    calls.add(method);
    return await handler(method, args);
  }

  @override
  Future<void> dispose() async {}
}

/// A clock where time only passes when the command sleeps.
class _FakeClock() extends WaitClock {
  Duration elapsed = Duration.zero;
  final sleeps = <Duration>[];

  @override
  Duration Function() start() =>
      () => elapsed;

  @override
  Future<void> sleep(Duration duration) async {
    sleeps.add(duration);
    elapsed += duration;
  }
}

Map<String, dynamic> _node(
  int id,
  String name, {
  Map<String, dynamic> attributes = const {},
  List<Map<String, dynamic>> children = const [],
}) {
  return {
    'id': id,
    'name': name,
    'toString': '$name()',
    'isPositionComponent': attributes.containsKey('position'),
    'attributes': attributes,
    'children': children,
  };
}

Map<String, dynamic> _tree(List<Map<String, dynamic>> children) {
  return {
    'component_tree': _node(1, 'MyGame', children: children),
  };
}

void main() {
  late StringBuffer out;
  late StringBuffer err;
  late _FakeClock clock;
  late _FakeConnection connection;

  setUp(() {
    out = StringBuffer();
    err = StringBuffer();
    clock = _FakeClock();
  });

  Future<int> run(List<String> arguments, _Handler handler) {
    connection = _FakeConnection(handler);
    final runner = FlameCommandRunner(
      out: out,
      err: err,
      connect: (_) async => connection,
      waitClock: clock,
    );
    return runner.run(['wait', ...arguments, '--uri', _uri]);
  }

  /// Answers the calls to [method] with the [responses] in order, and with
  /// the last one when they run out.
  _Handler sequence(String method, List<Map<String, dynamic>> responses) {
    var index = 0;
    return (calledMethod, _) {
      expect(calledMethod, method);
      return responses[index < responses.length ? index++ : index - 1];
    };
  }

  group('component', () {
    test('succeeds right away when a component matches', () async {
      final exitCode = await run(
        ['component', 'enemy'],
        sequence('getComponentTree', [
          _tree([
            _node(2, 'Player'),
            _node(
              3,
              'Enemy',
              attributes: {
                'position': [10.0, 20.0],
              },
            ),
          ]),
        ]),
      );

      expect(exitCode, ExitCode.success.code);
      expect(
        out.toString(),
        'Found 1 component with a type matching enemy:\n'
        'Enemy (id: 3) position 10,20\n',
      );
      expect(clock.sleeps, isEmpty);
    });

    test('polls until a component matches', () async {
      final exitCode = await run(
        ['component', 'GameOver', '--interval', '0.5'],
        sequence('getComponentTree', [
          _tree([_node(2, 'Player')]),
          _tree([_node(2, 'Player')]),
          _tree([_node(2, 'Player'), _node(4, 'GameOverText')]),
        ]),
      );

      expect(exitCode, ExitCode.success.code);
      expect(connection.calls, hasLength(3));
      expect(clock.sleeps, [
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 500),
      ]);
      expect(out.toString(), contains('GameOverText (id: 4)'));
    });

    test('times out with a distinct exit code', () async {
      final exitCode = await run(
        ['component', 'enemy', '--timeout', '1', '--interval', '0.3'],
        sequence('getComponentTree', [
          _tree([_node(2, 'Player')]),
        ]),
      );

      expect(exitCode, ExitCode.tempFail.code);
      expect(exitCode, 75);
      expect(
        err.toString(),
        'Timed out after 1 second waiting for a component with a type '
        'matching enemy, found 0.\n',
      );
      expect(clock.sleeps, [
        const Duration(milliseconds: 300),
        const Duration(milliseconds: 300),
        const Duration(milliseconds: 300),
        const Duration(milliseconds: 100),
      ]);
      expect(connection.calls, hasLength(5));
      expect(out.toString(), isEmpty);
    });

    test('checks once with a timeout of 0', () async {
      final exitCode = await run(
        ['component', 'enemy', '--timeout', '0'],
        sequence('getComponentTree', [
          _tree([_node(2, 'Player')]),
        ]),
      );

      expect(exitCode, ExitCode.tempFail.code);
      expect(err.toString(), contains('Timed out after 0 seconds'));
      expect(connection.calls, hasLength(1));
      expect(clock.sleeps, isEmpty);
    });

    test('waits for an exact count', () async {
      final exitCode = await run(
        ['component', 'enemy', '--count', '2'],
        sequence('getComponentTree', [
          _tree([_node(2, 'Enemy')]),
          _tree([_node(2, 'Enemy'), _node(3, 'Enemy'), _node(4, 'Enemy')]),
          _tree([
            _node(2, 'Enemy', children: [_node(3, 'EnemyBullet')]),
          ]),
        ]),
      );

      expect(exitCode, ExitCode.success.code);
      expect(connection.calls, hasLength(3));
      expect(
        out.toString(),
        'Found 2 components with a type matching enemy:\n'
        'Enemy (id: 2)\n'
        'EnemyBullet (id: 3)\n',
      );
    });

    test('waits for at least a number of components', () async {
      final exitCode = await run(
        ['component', r'^enemy$', '--at-least', '2', '--timeout', '0'],
        sequence('getComponentTree', [
          _tree([_node(2, 'Enemy'), _node(3, 'EnemyBullet')]),
        ]),
      );

      expect(exitCode, ExitCode.tempFail.code);
      expect(
        err.toString(),
        contains(
          'waiting for at least 2 components with a type matching '
          r'^enemy$, found 1.',
        ),
      );
    });

    test('waits until a component is removed', () async {
      final exitCode = await run(
        ['component', '--id', '3', '--gone'],
        sequence('getComponentTree', [
          _tree([_node(2, 'Player'), _node(3, 'Enemy')]),
          _tree([_node(2, 'Player')]),
        ]),
      );

      expect(exitCode, ExitCode.success.code);
      expect(out.toString(), 'Found no components with the id 3.\n');
      expect(connection.calls, hasLength(2));
    });

    test('reports the components that are not gone on a timeout', () async {
      final exitCode = await run(
        ['component', 'enemy', '--gone', '--timeout', '0.5'],
        sequence('getComponentTree', [
          _tree([_node(2, 'Enemy')]),
        ]),
      );

      expect(exitCode, ExitCode.tempFail.code);
      expect(
        err.toString(),
        'Timed out after 0.5 seconds waiting for no components with a type '
        'matching enemy, found 1.\n',
      );
    });

    test('compares attributes with --where', () async {
      Map<String, dynamic> player(double x) => _tree([
        _node(
          2,
          'World',
          children: [
            _node(
              3,
              'Player',
              attributes: {
                'position': [x, 0.0],
                'angle': 0.0,
                'priority': 1,
              },
            ),
          ],
        ),
      ]);
      final exitCode = await run(
        [
          'component',
          'player',
          '--where',
          'position.x > 100',
          '-w',
          'priority==1',
        ],
        sequence('getComponentTree', [player(50), player(100), player(101)]),
      );

      expect(exitCode, ExitCode.success.code);
      expect(connection.calls, hasLength(3));
      expect(
        out.toString(),
        startsWith(
          'Found 1 component with a type matching player and '
          'position.x > 100 and priority == 1:\n',
        ),
      );
    });

    test('compares vector attributes with float32 precision', () async {
      final x = Float32List.fromList([100.1]).first;
      final exitCode = await run(
        [
          'component',
          'player',
          '-w',
          'position.x == 100.1',
          '-w',
          'position.y >= 0.3',
          '-t',
          '0',
        ],
        sequence('getComponentTree', [
          _tree([
            _node(
              2,
              'Player',
              attributes: {
                'position': [
                  x,
                  Float32List.fromList([0.3]).first,
                ],
              },
            ),
          ]),
        ]),
      );

      expect(exitCode, ExitCode.success.code);
    });

    test('does not match components without the attribute', () async {
      final exitCode = await run(
        ['component', '--id', '2', '--where', 'size.y < 5', '-t', '0'],
        sequence('getComponentTree', [
          _tree([_node(2, 'Component')]),
        ]),
      );

      expect(exitCode, ExitCode.tempFail.code);
    });

    test('prints the matching components as json', () async {
      final exitCode = await run(
        ['component', 'enemy', '--json'],
        sequence('getComponentTree', [
          _tree([
            _node(2, 'Enemy', children: [_node(3, 'Child')]),
          ]),
        ]),
      );

      expect(exitCode, ExitCode.success.code);
      expect(jsonDecode(out.toString()), {
        'components': [
          {
            'id': 2,
            'name': 'Enemy',
            'toString': 'Enemy()',
            'isPositionComponent': false,
            'attributes': <String, dynamic>{},
          },
        ],
      });
    });

    test('times out when the game does not answer', () async {
      final exitCode = await run(
        ['component', 'enemy', '--timeout', '0.05'],
        (_, _) => Completer<Map<String, dynamic>>().future,
      );

      expect(exitCode, ExitCode.tempFail.code);
      expect(
        err.toString(),
        'Timed out after 0.05 seconds waiting for a component with a type '
        'matching enemy, the game did not answer.\n',
      );
    });

    test('fails when the game stops while waiting', () async {
      var calls = 0;
      final exitCode = await run(['component', 'enemy'], (_, _) {
        if (calls++ == 0) {
          return _tree([]);
        }
        throw const FlameCliException(
          'The game is no longer running.',
          exitCode: ExitCode.unavailable,
        );
      });

      expect(exitCode, ExitCode.unavailable.code);
      expect(err.toString(), contains('The game is no longer running.'));
    });
  });

  group('overlay', () {
    Map<String, dynamic> overlays(List<String> active) => {
      'overlays': ['PauseMenu', 'GameOver'],
      'active': active,
    };

    test('waits until an overlay is shown', () async {
      final exitCode = await run(
        ['overlay', 'GameOver'],
        sequence('getOverlays', [
          overlays([]),
          overlays(['PauseMenu']),
          overlays(['GameOver']),
        ]),
      );

      expect(exitCode, ExitCode.success.code);
      expect(out.toString(), 'The overlay GameOver is shown.\n');
      expect(clock.sleeps, hasLength(2));
    });

    test('waits until an overlay is hidden', () async {
      final exitCode = await run(
        ['overlay', 'PauseMenu', '--hidden', '--json'],
        sequence('getOverlays', [
          overlays(['PauseMenu']),
          overlays(['GameOver']),
        ]),
      );

      expect(exitCode, ExitCode.success.code);
      expect(jsonDecode(out.toString()), {
        'overlays': ['PauseMenu', 'GameOver'],
        'active': ['GameOver'],
      });
    });

    test('says which overlays are shown on a timeout', () async {
      final exitCode = await run(
        ['overlay', 'GameOver', '--timeout', '2'],
        sequence('getOverlays', [
          overlays(['PauseMenu']),
        ]),
      );

      expect(exitCode, ExitCode.tempFail.code);
      expect(
        err.toString(),
        'Timed out after 2 seconds waiting for the overlay GameOver to be '
        'shown, the shown overlays are PauseMenu.\n',
      );
    });

    test('fails right away for an unknown overlay', () async {
      final exitCode = await run(
        ['overlay', 'Settings'],
        sequence('getOverlays', [overlays([])]),
      );

      expect(exitCode, ExitCode.data.code);
      expect(err.toString(), contains('Unknown overlay: Settings'));
      expect(clock.sleeps, isEmpty);
    });
  });

  group('paused and resumed', () {
    test('waits until the game is paused', () async {
      final exitCode = await run(
        ['paused'],
        sequence('getPaused', [
          {'paused': false},
          {'paused': true},
        ]),
      );

      expect(exitCode, ExitCode.success.code);
      expect(out.toString(), 'The game is paused.\n');
    });

    test('waits until the game is running', () async {
      final exitCode = await run(
        ['resumed', '--timeout', '0'],
        sequence('getPaused', [
          {'paused': true},
        ]),
      );

      expect(exitCode, ExitCode.tempFail.code);
      expect(
        err.toString(),
        'Timed out after 0 seconds waiting for the game to be running, it is '
        'paused.\n',
      );
    });
  });
}
