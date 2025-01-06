import 'dart:ui';

final paintChoices = [
  'none',
  'transparent',
  'red tinted',
  'green tinted',
  'blue tinted',
];
final paintList = [
  null,
  Paint()..color = const Color(0x22FFFFFF),
  Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0x88FF0000),
      BlendMode.srcATop,
    ),
  Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0x8800FF00),
      BlendMode.srcATop,
    ),
  Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0x880000FF),
      BlendMode.srcATop,
    ),
];
