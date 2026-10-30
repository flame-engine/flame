import 'package:flame_studio/repositories/component_repository/code_generation/dart_names.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dartClassName', () {
    test('converts names to PascalCase', () {
      expect(dartClassName('player'), equals('Player'));
      expect(dartClassName('player_ship'), equals('PlayerShip'));
      expect(dartClassName('playerShip'), equals('PlayerShip'));
      expect(dartClassName('PlayerShip'), equals('PlayerShip'));
      expect(dartClassName('_player__ship_'), equals('PlayerShip'));
      expect(dartClassName('_'), isEmpty);
    });
  });

  test('dartRootClassName adds the generated code prefix', () {
    expect(dartRootClassName('player_ship'), equals(r'$PlayerShip'));
  });

  test('dartChildClassName prefixes the child with the root class', () {
    expect(dartChildClassName('player_ship', 'head'), r'$PlayerShipHead');
    expect(dartChildClassName('player', 'ship_head'), r'$PlayerShipHead');
  });

  group('dartMemberName', () {
    test('converts names to camelCase', () {
      expect(dartMemberName('head'), equals('head'));
      expect(dartMemberName('Head'), equals('head'));
      expect(dartMemberName('left_arm'), equals('leftArm'));
      expect(dartMemberName('leftArm'), equals('leftArm'));
      expect(dartMemberName('__'), isEmpty);
    });
  });

  group('dartFileName', () {
    test('converts names to snake_case', () {
      expect(dartFileName('player'), equals('player'));
      expect(dartFileName('PlayerShip'), equals('player_ship'));
      expect(dartFileName('playerShip'), equals('player_ship'));
      expect(dartFileName('player_ship'), equals('player_ship'));
      expect(dartFileName('ship2Wing'), equals('ship2_wing'));
      expect(dartFileName('_Player'), equals('player'));
    });
  });

  test('isDartIdentifier', () {
    expect(isDartIdentifier('head'), isTrue);
    expect(isDartIdentifier('_head1'), isTrue);
    expect(isDartIdentifier('1head'), isFalse);
    expect(isDartIdentifier('my head'), isFalse);
    expect(isDartIdentifier(''), isFalse);
  });

  test('isDartKeyword', () {
    expect(isDartKeyword('class'), isTrue);
    expect(isDartKeyword('late'), isTrue);
    expect(isDartKeyword('head'), isFalse);
  });

  test('flameMemberNames lists inherited Flame members', () {
    expect(
      flameMemberNames(ComponentType.rectangle),
      containsAll(['size', 'position', 'paint', 'children', 'parent']),
    );
    expect(
      flameMemberNames(ComponentType.position),
      containsAll(['size', 'position', 'children', 'parent']),
    );
    expect(flameMemberNames(ComponentType.position), isNot(contains('paint')));
    expect(
      flameMemberNames(ComponentType.circle),
      containsAll(['radius', 'paint', 'isSolid']),
    );
    expect(
      flameMemberNames(ComponentType.circle),
      containsAll(flameMemberNames(ComponentType.position)),
    );
    expect(flameMemberNames(ComponentType.circle), isNot(contains('vertices')));
    expect(
      flameMemberNames(ComponentType.polygon),
      containsAll(['vertices', 'paint', 'refreshVertices', 'size']),
    );
    expect(flameMemberNames(ComponentType.polygon), isNot(contains('radius')));
    expect(
      flameMemberNames(ComponentType.rectangle),
      containsAll(flameMemberNames(ComponentType.position)),
    );
  });
}
