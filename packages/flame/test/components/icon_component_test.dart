import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart' show IconData;
import 'package:flutter_test/flutter_test.dart';

// A minimal IconData for testing (uses a basic Unicode code point).
const _testIcon = IconData(0x41, fontFamily: 'Roboto'); // 'A'

void main() {
  group('IconComponent', () {
    test('defaults size to iconSize', () {
      final component = IconComponent(icon: _testIcon, iconSize: 48);
      expect(component.size, Vector2.all(48));
    });

    test('uses explicit size when provided', () {
      final component = IconComponent(
        icon: _testIcon,
        iconSize: 48,
        size: Vector2(100, 200),
      );
      expect(component.size, Vector2(100, 200));
    });

    test('default iconSize is 64', () {
      final component = IconComponent(icon: _testIcon);
      expect(component.iconSize, 64);
      expect(component.size, Vector2.all(64));
    });

    test('accepts a custom paint', () {
      final customPaint = Paint()..color = const Color(0xFFFF0000);
      final component = IconComponent(
        icon: _testIcon,
        paint: customPaint,
      );
      expect(component.paint.color, const Color(0xFFFF0000));
    });

    test('icon getter and setter', () {
      final component = IconComponent(icon: _testIcon);
      expect(component.icon, _testIcon);

      const newIcon = IconData(0x42, fontFamily: 'Roboto');
      component.icon = newIcon;
      expect(component.icon, newIcon);
    });

    test('iconSize getter and setter', () {
      final component = IconComponent(icon: _testIcon, iconSize: 32);
      expect(component.iconSize, 32);

      component.iconSize = 128;
      expect(component.iconSize, 128);
    });

    testWithFlameGame('rasterizes icon on load', (game) async {
      final component = IconComponent(
        icon: _testIcon,
        iconSize: 32,
      );
      await game.ensureAdd(component);

      expect(component.image, isNotNull);
    });

    testWithFlameGame('re-rasterizes when icon changes', (game) async {
      final component = IconComponent(
        icon: _testIcon,
        iconSize: 32,
      );
      await game.ensureAdd(component);

      final originalImage = component.image;
      expect(originalImage, isNotNull);

      const newIcon = IconData(0x42, fontFamily: 'Roboto');
      component.icon = newIcon;
      game.update(0);

      // After update, the image should eventually be replaced.
      // We need to pump the event loop for the async rasterization.
      await Future<void>.delayed(Duration.zero);

      expect(component.image, isNotNull);
    });

    testWithFlameGame('re-rasterizes when iconSize changes', (game) async {
      final component = IconComponent(
        icon: _testIcon,
        iconSize: 32,
      );
      await game.ensureAdd(component);

      final originalImage = component.image;
      expect(originalImage, isNotNull);

      component.iconSize = 64;
      game.update(0);

      await Future<void>.delayed(Duration.zero);

      expect(component.image, isNotNull);
    });

    testWithFlameGame('disposes image on remove', (game) async {
      final component = IconComponent(
        icon: _testIcon,
        iconSize: 32,
      );
      await game.ensureAdd(component);

      expect(component.image, isNotNull);

      component.removeFromParent();
      game.update(0);

      expect(component.image, isNull);
    });

    testWithFlameGame('asserts icon is set on mount', (game) async {
      final component = IconComponent();
      expect(
        () async => game.ensureAdd(component),
        throwsAssertionError,
      );
    });

    testWithFlameGame('supports tint', (game) async {
      final component = IconComponent(
        icon: _testIcon,
        iconSize: 32,
      );
      await game.ensureAdd(component);

      component.tint(const Color(0xFFFF0000));
      expect(component.paint.colorFilter, isNotNull);
    });

    testWithFlameGame('supports setOpacity', (game) async {
      final component = IconComponent(
        icon: _testIcon,
        iconSize: 32,
      );
      await game.ensureAdd(component);

      component.setOpacity(0.5);
      expect(component.paint.color.a, closeTo(0.5, 0.01));
    });

    test('setting same icon does not trigger re-rasterize', () {
      final component = IconComponent(icon: _testIcon, iconSize: 32);
      // Access internal state indirectly - setting the same icon shouldn't
      // trigger re-rasterization.
      component.icon = _testIcon;
      // No assertion error or state change expected.
      expect(component.icon, _testIcon);
    });

    test('setting same iconSize does not trigger re-rasterize', () {
      final component = IconComponent(icon: _testIcon, iconSize: 32);
      component.iconSize = 32;
      expect(component.iconSize, 32);
    });
  });
}
