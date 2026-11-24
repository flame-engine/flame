import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ProjectSettings, () {
    test('defaults the output path to lib/components', () {
      expect(const ProjectSettings().outputPath, 'lib/components');
    });

    test('supports value equality', () {
      expect(
        const ProjectSettings(outputPath: 'lib/a'),
        equals(const ProjectSettings(outputPath: 'lib/a')),
      );
    });

    test('copyWith replaces the given fields', () {
      expect(
        const ProjectSettings().copyWith(outputPath: 'lib/a'),
        const ProjectSettings(outputPath: 'lib/a'),
      );
      expect(const ProjectSettings().copyWith(), const ProjectSettings());
    });

    test('round-trips through JSON', () {
      const settings = ProjectSettings(outputPath: 'lib/a');

      expect(ProjectSettings.fromJson(settings.toJson()), settings);
    });

    test('fromJson falls back to defaults for missing values', () {
      expect(ProjectSettings.fromJson(const {}), const ProjectSettings());
      expect(
        ProjectSettings.fromJson(const {'outputPath': 1}),
        const ProjectSettings(),
      );
    });
  });
}
