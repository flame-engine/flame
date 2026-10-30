import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(Project, () {
    test('supports value equality', () {
      expect(const Project(path: '/a'), equals(const Project(path: '/a')));
      expect(const Project(path: '/a'), isNot(const Project(path: '/b')));
    });

    group('name', () {
      test('is the last path segment', () {
        expect(const Project(path: '/a/my_game').name, equals('my_game'));
      });

      test('ignores trailing separators', () {
        expect(const Project(path: '/a/my_game/').name, equals('my_game'));
      });

      test('supports Windows paths', () {
        expect(const Project(path: r'C:\a\my_game').name, equals('my_game'));
      });

      test('falls back to the path when there are no segments', () {
        expect(const Project(path: '/').name, equals('/'));
      });
    });

    test('round trips through JSON', () {
      const project = Project(path: '/a/my_game');

      expect(Project.fromJson(project.toJson()), equals(project));
    });
  });
}
