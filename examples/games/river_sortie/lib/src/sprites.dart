/// The river's flat pictures, drawn here in code as its sounds are made by a
/// script: reeds on the banks, the flash of a blast, the word on a depot.
library;

import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart' show BillboardAtlas;
import 'package:flutter/painting.dart' show FontWeight, TextStyle;

/// Reeds and bushes to stand along the banks, and a blast's flash: Flame
/// sprites, drawn as pixel art at start-up rather than read from files.
///
/// **Pixel art, drawn by hand.** Each picture is a few dozen coloured
/// squares on a transparent sheet, sampled nearest in the scene, so it keeps
/// its squares however near the camera comes. No image files: the pictures
/// are the code below, and changing one is changing a colour here.
final class RiverSprites {
  RiverSprites._(this.banks, this._flashSheet, this.fuel);

  /// Draws every picture. Asynchronous only because an image is.
  static Future<RiverSprites> draw() async {
    final banks = await _drawBanks();
    final flash = await _drawFlash();
    final fuel = await BillboardAtlas.spriteOfText('FUEL', _lettering);
    return RiverSprites._(
      <Sprite>[
        for (var i = 0; i < _bankKinds; i++)
          Sprite(
            banks,
            srcPosition: Vector2(i * _bankWidth.toDouble(), 0.0),
            srcSize: Vector2(_bankWidth.toDouble(), _bankHeight.toDouble()),
          ),
      ],
      flash,
      fuel,
    );
  }

  /// What grows on a bank: tall reeds, reeds with a bulrush, a round bush.
  final List<Sprite> banks;

  /// The word a depot has always said, written by Flame's text paint: to
  /// be drawn smooth, as lettering is, not in squares.
  final Sprite fuel;

  /// Yellow, heavy, outlined in black so it reads over the depot's red and
  /// white stripes and over the water alike.
  static final TextPaint _lettering = TextPaint(
    style: TextStyle(
      fontSize: 48.0,
      fontWeight: FontWeight.w900,
      color: const ui.Color(0xFFFFD83A),
      letterSpacing: 4.0,
      shadows: <ui.Shadow>[
        for (final (dx, dy) in <(double, double)>[
          (-2.5, -2.5),
          (2.5, -2.5),
          (-2.5, 2.5),
          (2.5, 2.5),
        ])
          ui.Shadow(
            color: const ui.Color(0xFF101010),
            offset: ui.Offset(dx, dy),
          ),
      ],
    ),
  );

  final ui.Image _flashSheet;

  /// A blast's flash, played once: a white core swelling into an orange
  /// ball and breaking up into red.
  SpriteAnimation flash() => SpriteAnimation.fromFrameData(
    _flashSheet,
    SpriteAnimationData.sequenced(
      amount: _flashFrames,
      stepTime: 0.07,
      textureSize: Vector2.all(_flashSize.toDouble()),
      loop: false,
    ),
  );

  static const int _bankKinds = 3;
  static const int _bankWidth = 12;
  static const int _bankHeight = 16;
  static const int _flashFrames = 6;
  static const int _flashSize = 16;

  static const ui.Color _reed = ui.Color(0xFF4E7F3A);
  static const ui.Color _reedLight = ui.Color(0xFF7FAE4E);
  static const ui.Color _bulrush = ui.Color(0xFF6B4226);
  static const ui.Color _bush = ui.Color(0xFF3C6B34);
  static const ui.Color _bushLight = ui.Color(0xFF5E9444);

  static Future<ui.Image> _drawBanks() {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    void px(int x, int y, ui.Color colour) => canvas.drawRect(
      ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), 1.0, 1.0),
      ui.Paint()..color = colour,
    );
    // Reeds: blades of different heights, leaning a little.
    void blade(int at, int x, int tall, int lean, ui.Color colour) {
      for (var y = 0; y < tall; y++) {
        px(at + x + (y * lean ~/ 8), _bankHeight - 1 - y, colour);
      }
    }

    for (final (x, tall, lean) in <(int, int, int)>[
      (2, 12, -1),
      (4, 15, 0),
      (6, 11, 1),
      (8, 14, 1),
      (10, 9, 2),
    ]) {
      blade(0, x, tall, lean, x.isEven ? _reed : _reedLight);
    }
    // Reeds with a bulrush on the tallest.
    const at = _bankWidth;
    for (final (x, tall, lean) in <(int, int, int)>[
      (1, 10, 0),
      (3, 13, -1),
      (5, 15, 0),
      (8, 12, 1),
      (10, 10, 1),
    ]) {
      blade(at, x, tall, lean, x.isOdd ? _reed : _reedLight);
    }
    for (var y = 1; y < 5; y++) {
      px(at + 5, y, _bulrush);
      px(at + 6, y, _bulrush);
    }
    // A round bush, lighter on top.
    const bush = _bankWidth * 2;
    for (var y = 0; y < 9; y++) {
      for (var x = 0; x < _bankWidth; x++) {
        final dx = x - 5.5;
        final dy = y - 5.0;
        if (dx * dx + dy * dy * 1.6 <= 30.0) {
          px(bush + x, _bankHeight - 9 + y, y < 4 ? _bushLight : _bush);
        }
      }
    }
    return recorder.endRecording().toImage(
      _bankWidth * _bankKinds,
      _bankHeight,
    );
  }

  static Future<ui.Image> _drawFlash() {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const colours = <ui.Color>[
      ui.Color(0xFFFFFFF0),
      ui.Color(0xFFFFE27A),
      ui.Color(0xFFFFA23A),
      ui.Color(0xFFE8552A),
      ui.Color(0xFF9E2B1E),
    ];
    for (var frame = 0; frame < _flashFrames; frame++) {
      final left = frame * _flashSize;
      final reach = 3.5 + frame * 1.0;
      for (var y = 0; y < _flashSize; y++) {
        for (var x = 0; x < _flashSize; x++) {
          final dx = x - 7.5;
          final dy = y - 7.5;
          final r = dx * dx + dy * dy;
          if (r > reach * reach) {
            continue;
          }
          // Hollow as it breaks up: the late frames lose their middle and
          // every other square of their rim.
          if (frame >= 4 && r < (reach - 3.0) * (reach - 3.0)) {
            continue;
          }
          if (frame == 5 && (x + y).isOdd) {
            continue;
          }
          final band = ((r / (reach * reach)) * 3.0).floor() + frame ~/ 2;
          canvas.drawRect(
            ui.Rect.fromLTWH((left + x).toDouble(), y.toDouble(), 1.0, 1.0),
            ui.Paint()..color = colours[band.clamp(0, colours.length - 1)],
          );
        }
      }
    }
    return recorder.endRecording().toImage(
      _flashSize * _flashFrames,
      _flashSize,
    );
  }
}
