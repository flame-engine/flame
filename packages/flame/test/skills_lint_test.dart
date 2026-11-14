import 'package:skills_lint/skills_lint.dart';
import 'package:test/test.dart';

void main() {
  test('the package skills pass skills_lint', () async {
    final config = await ConfigParser.loadConfig();
    expect(
      config.parsingErrors,
      isEmpty,
      reason: 'Fix the skills_lint.yaml errors listed in this failure.',
    );
    expect(
      config.directoryConfigs,
      isNotEmpty,
      reason: 'skills_lint.yaml must list at least one skills directory.',
    );

    final passed = await validateSkills(config: config);

    expect(
      passed,
      isTrue,
      reason: 'skills_lint found errors, its findings are printed above.',
    );
  });
}
