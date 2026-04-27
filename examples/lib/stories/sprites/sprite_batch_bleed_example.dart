import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class SpriteBatchBleedExample extends FlameGame {
  static const String description = '''
    In this example we show how `bleed` can be used to prevent edge artifacts
    (seams) between tiles when rendering with `SpriteBatch`. 
    
    The top rows show tiles rendered without bleed, where slight gaps or
    color bleeding may appear at the edges.
    
    The bottom rows show the same tiles rendered with bleed, which expands
    the destination rectangle outward while keeping the source region the
    same, eliminating edge artifacts.
    
    The rotated tiles on the right demonstrate that bleed works correctly
    even with rotation, preserving the center point.
  ''';

  static const tileSize = 32.0;
  static const scale = 3.0;
  static const scaledTile = tileSize * scale;
  static const bleed = 1.0;

  @override
  Future<void> onLoad() async {
    final spriteBatch = await SpriteBatch.load('retro_tiles.png');

    const tile1 = Rect.fromLTWH(0, 0, tileSize, tileSize);
    const tile2 = Rect.fromLTWH(tileSize, 0, tileSize, tileSize);

    // --- Section 1: Without bleed (top) ---
    const startYNoBleed = 40.0;
    const startX = 40.0;
    const gap = 16.0;
    const startXRotated = startX + scaledTile * 6 + gap * 2;

    _addTileRow(
      spriteBatch,
      startX: startX,
      startY: startYNoBleed,
      tile1: tile1,
      tile2: tile2,
      bleed: 0,
    );

    _addTileRow(
      spriteBatch,
      startX: startX,
      startY: startYNoBleed + scaledTile + gap,
      tile1: tile2,
      tile2: tile1,
      bleed: 0,
    );

    // --- Section 2: With bleed (bottom) ---
    const startYBleed = startYNoBleed + (scaledTile + gap) * 2 + gap * 2;

    _addTileRow(
      spriteBatch,
      startX: startX,
      startY: startYBleed,
      tile1: tile1,
      tile2: tile2,
      bleed: bleed,
    );

    _addTileRow(
      spriteBatch,
      startX: startX,
      startY: startYBleed + scaledTile + gap,
      tile1: tile2,
      tile2: tile1,
      bleed: bleed,
    );

    // --- Section 3: Rotated tiles with bleed (right side) ---
    final centerY = size.y / 2;

    // Without bleed, rotated
    spriteBatch.add(
      source: tile1,
      offset: Vector2(startXRotated, centerY - scaledTile - gap),
      scale: scale,
      rotation: pi / 6,
      anchor: Vector2(tileSize / 2, tileSize / 2),
    );

    spriteBatch.add(
      source: tile2,
      offset: Vector2(
        startXRotated + scaledTile + gap,
        centerY - scaledTile - gap,
      ),
      scale: scale,
      rotation: pi / 6,
      anchor: Vector2(tileSize / 2, tileSize / 2),
    );

    // With bleed, rotated
    spriteBatch.add(
      source: tile1,
      offset: Vector2(startXRotated, centerY + gap),
      scale: scale,
      rotation: pi / 6,
      anchor: Vector2(tileSize / 2, tileSize / 2),
      bleed: bleed,
    );

    spriteBatch.add(
      source: tile2,
      offset: Vector2(
        startXRotated + scaledTile + gap,
        centerY + gap,
      ),
      scale: scale,
      rotation: pi / 6,
      anchor: Vector2(tileSize / 2, tileSize / 2),
      bleed: bleed,
    );

    add(
      SpriteBatchComponent(
        spriteBatch: spriteBatch,
        blendMode: BlendMode.srcOver,
      ),
    );

    // Add labels
    add(
      TextComponent(
        text: 'Without bleed',
        position: Vector2(startX, startYNoBleed - 20),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    add(
      TextComponent(
        text: 'With bleed (bleed=$bleed)',
        position: Vector2(startX, startYBleed - 20),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    add(
      TextComponent(
        text: 'Rotated',
        position: Vector2(startXRotated, 20),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _addTileRow(
    SpriteBatch batch, {
    required double startX,
    required double startY,
    required Rect tile1,
    required Rect tile2,
    required double bleed,
  }) {
    for (var i = 0; i < 6; i++) {
      batch.add(
        source: i.isEven ? tile1 : tile2,
        offset: Vector2(startX + i * scaledTile, startY),
        scale: scale,
        bleed: bleed,
      );
    }
  }
}
