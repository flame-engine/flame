import 'dart:convert';

import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

void main() {
  test('ComponentAttributes leaves out what the game did not report', () {
    final attributes = ComponentAttributes.fromJson({'priority': 3});
    expect(attributes.priority, 3);
    expect(attributes.position, isNull);
    expect(attributes.toJson(), {'priority': 3});
  });

  test('ComponentInfo reads and writes the JSON of the game', () {
    final json = {
      'id': 3,
      'name': 'Player',
      'toString': 'Player()',
      'parent': null,
      'childCount': 2,
      'debugMode': true,
      'attributes': {
        'priority': 0,
        'position': [1.5, 2.0],
      },
    };
    final info = ComponentInfo.fromJson(json);
    expect(info.parent, isNull);
    expect(info.childCount, 2);
    expect(info.debugMode, isTrue);
    expect(info.attributes.position, (x: 1.5, y: 2.0));
    expect(info.toJson(), json);
  });

  test('Overlays reads the registered and the active overlays', () {
    final overlays = Overlays.fromJson({
      'overlays': ['Menu', 'Hud'],
      'active': ['Hud'],
    });
    expect(overlays.registered, ['Menu', 'Hud']);
    expect(overlays.active, ['Hud']);
    expect(Overlays.fromJson({}).registered, isEmpty);
  });

  test('Snapshot decodes the image', () {
    final snapshot = Snapshot.fromJson({
      'snapshot': base64Encode([1, 2, 3]),
    });
    expect(snapshot.bytes, [1, 2, 3]);
    expect(Snapshot.fromJson({}).bytes, isEmpty);
  });

  test('RunResponse reads and writes the control port JSON', () {
    final json = {
      'ok': false,
      'message': 'Reload rejected',
      'output': ['Error: Expected ;'],
    };
    final response = RunResponse.fromJson(json);
    expect(response.ok, isFalse);
    expect(response.output, ['Error: Expected ;']);
    expect(response.toJson(), json);
  });
}
