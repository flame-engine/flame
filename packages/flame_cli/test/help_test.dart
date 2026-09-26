import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

void main() {
  test('groups the commands by category in workflow order', () {
    final usage = FlameCommandRunner(
      out: StringBuffer(),
      err: StringBuffer(),
    ).usage;

    final categories = [
      'Creating a game',
      'Launching the game',
      'Observing the game',
      'Pausing and changing the game',
      'Playing the game',
    ];
    final positions = categories.map(usage.indexOf).toList();
    expect(positions, everyElement(greaterThan(-1)));
    expect(positions, [...positions]..sort());

    int commandPosition(String name) => usage.indexOf('\n  $name ');
    expect(
      commandPosition('create'),
      inExclusiveRange(positions[0], positions[1]),
    );
    expect(
      commandPosition('run'),
      inExclusiveRange(positions[1], positions[2]),
    );
    expect(
      commandPosition('tree'),
      inExclusiveRange(positions[2], positions[3]),
    );
    expect(
      commandPosition('step'),
      inExclusiveRange(positions[3], positions[4]),
    );
    expect(commandPosition('input'), greaterThan(positions[4]));
  });
}
