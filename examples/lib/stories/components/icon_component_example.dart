import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' show IconData;

class IconComponentExample extends FlameGame {
  static const String description = '''
    In this example we showcase the `IconComponent`, which renders Flutter
    `IconData` as Flame components. The icons are rasterized to images on load,
    enabling paint-based effects like tinting, opacity, color effects, and
    glow effects.
  ''';

  static const _heartIcon = IconData(
    0xe87d,
    fontFamily: 'MaterialIcons',
  );
  static const _homeIcon = IconData(
    0xe318,
    fontFamily: 'MaterialIcons',
  );
  static const _settingsIcon = IconData(
    0xe8b8,
    fontFamily: 'MaterialIcons',
  );
  static const _checkCircleIcon = IconData(
    0xe86c,
    fontFamily: 'MaterialIcons',
  );
  static const _flashOnIcon = IconData(
    0xe3e7,
    fontFamily: 'MaterialIcons',
  );
  static const _starIcon = IconData(
    0xe838,
    fontFamily: 'MaterialIcons',
  );

  @override
  Future<void> onLoad() async {
    // A row of star icons with different colors
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF4444), // Red
      const Color(0xFF44AAFF), // Blue
      const Color(0xFF44FF44), // Green
      const Color(0xFFFF44FF), // Magenta
    ];
    final stars = colors.map((color) {
      return IconComponent(
        icon: _starIcon,
        anchor: Anchor.center,
      )..tint(color);
    }).toList();

    const spacing = 100.0;
    final startX = (size.x - (stars.length - 1) * spacing) / 2;
    for (var i = 0; i < stars.length; i++) {
      stars[i].position = Vector2(startX + i * spacing, size.y * 0.2);
      add(stars[i]);
    }

    // An icon with a pulsing opacity effect
    final pulsingHeart = IconComponent(
      icon: _heartIcon,
      iconSize: 80,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.45),
    )..tint(const Color(0xFFFF2222));
    pulsingHeart.add(
      OpacityEffect.to(
        0.2,
        EffectController(
          duration: 1,
          reverseDuration: 1,
          infinite: true,
        ),
      ),
    );
    add(pulsingHeart);

    // A row of various icons at the bottom
    final miscEntries = [
      (_heartIcon, const Color(0xFFFF6B6B)),
      (_homeIcon, const Color(0xFF4FC3F7)),
      (_settingsIcon, const Color(0xFFFFB74D)),
      (_checkCircleIcon, const Color(0xFF81C784)),
      (_flashOnIcon, const Color(0xFFCE93D8)),
    ];
    final miscIcons = miscEntries.map((entry) {
      return IconComponent(
        icon: entry.$1,
        iconSize: 48,
        anchor: Anchor.center,
      )..tint(entry.$2);
    }).toList();

    final bottomStartX = (size.x - (miscIcons.length - 1) * spacing) / 2;
    for (var i = 0; i < miscIcons.length; i++) {
      miscIcons[i].position = Vector2(
        bottomStartX + i * spacing,
        size.y * 0.75,
      );
      add(miscIcons[i]);
    }

    // Add a rotating icon
    final rotatingIcon = IconComponent(
      icon: _settingsIcon,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.6),
    )..tint(const Color(0xFFFFAB40));
    rotatingIcon.add(
      RotateEffect.by(
        2 * pi,
        EffectController(duration: 4, infinite: true),
      ),
    );
    add(rotatingIcon);
  }
}
