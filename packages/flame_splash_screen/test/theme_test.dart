import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('white', () {
    final theme = FlameSplashTheme.white;
    expect(
      theme.constraints,
      const BoxConstraints.expand(),
    );
    expect(
      theme.backgroundDecoration,
      const BoxDecoration(color: Color(0xFFFFFFFF)),
    );
  });

  test('dark', () {
    final theme = FlameSplashTheme.dark;
    expect(theme.constraints, const BoxConstraints.expand());
    expect(
      theme.backgroundDecoration,
      const BoxDecoration(color: Color(0xFF000000)),
    );
  });
}
