import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:test/test.dart';

Future<void> main() async {
  group('PlaceholderComponent', () {
    test('check color of PlaceholderComponent', () {
      final component1 = PlaceholderComponent(color: Colors.blue);
      expect(component1.color, Colors.blue);
    });
  });
}
