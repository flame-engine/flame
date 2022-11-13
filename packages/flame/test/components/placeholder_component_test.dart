import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:test/test.dart';

Future<void> main() async {
  group('PlaceholderComponent', () {
    test('check default color of PlaceholderComponent', () {
      final component1 = PlaceholderComponent();
      expect(component1.color, Colors.red);
    });
    test('check constructor color of PlaceholderComponent', () {
      final component1 = PlaceholderComponent(color: Colors.blue);
      expect(component1.color, Colors.blue);
    });
  });
}
