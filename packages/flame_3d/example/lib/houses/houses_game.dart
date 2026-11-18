import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/houses/board_grid.dart';
import 'package:flame_3d_example/houses/house.dart';
import 'package:flame_3d_example/houses/stats_readout.dart';
import 'package:flutter/painting.dart' show Shadow, TextStyle;

/// An ordinary 2D game whose houses are real-time 3D.
///
/// The world is 2D: a grid drawn with the canvas, 2D labels, a 2D camera that
/// pans (drag) and zooms (pinch or scroll). The houses live in one
/// [Scene3DComponent] drawn between the grid and the labels; its projection
/// is the one of the 2D art, so the houses stand on their cells at every zoom
/// and pan. Tapping turns the tap into a 3D ray that picks a house.
class HousesGame()
    extends FlameGame
    with ScaleCallbacks, DragCallbacks, ScrollCallbacks, TapCallbacks {
  /// The board has [boardSize] by [boardSize] cells, one house on each.
  static const int boardSize = 12;

  static const double minZoom = 0.35;
  static const double maxZoom = 2.4;

  /// The scene is measured in cells, with z up. A cell is 88 by 44 pixels of
  /// 2D art and a unit of height 53.889 pixels: a dimetric view along
  /// (0.6124, 0.6124, 0.5). It mirrors the scene compared with a standard
  /// camera, which back-face culling takes care of.
  static final Scene3DProjection projection = Scene3DProjection.affine(
    origin: Vector2(0, -18),
    xAxis: Vector2(44, 22),
    yAxis: Vector2(-44, 22),
    zAxis: Vector2(0, -53.889),
    towardsViewer: Vector3(0.6124, 0.6124, 0.5),
    near: -20,
    far: 20,
  );

  static const _landmarks = {
    (2, 3): 'Town hall',
    (8, 2): 'Bakery',
    (5, 7): 'Library',
    (10, 9): 'Smithy',
    (3, 10): 'Inn',
  };

  /// The 3D layer of the houses.
  late final Scene3DComponent layer;

  /// The houses, by cell.
  final List<House> houses = [];

  final List<TextComponent> _labels = [];
  late final TextComponent _selectionLabel;
  House? _selected;
  late double _startZoom;

  @override
  Color backgroundColor() => const Color(0xFF17221A);

  @override
  Future<void> onLoad() async {
    layer = Scene3DComponent(
      projection: projection,
      msaa: Msaa.sample4,
      priority: 1,
    );
    world.addAll([
      BoardGrid(cells: boardSize, projection: projection),
      layer,
    ]);

    _buildTown();

    for (final MapEntry(key: (i, j), value: name) in _landmarks.entries) {
      _labels.add(_label(name, houseAt(i, j)));
    }
    _selectionLabel = _label('', null);
    layer.addAll([..._labels, _selectionLabel]);

    camera.viewfinder.position = layer.scenePointToLocal(
      Vector3(boardSize / 2, boardSize / 2, 0),
    );
    camera.viewport.add(StatsReadout(game: this));
  }

  /// The house on the cell ([i], [j]).
  House houseAt(int i, int j) => houses[i * boardSize + j];

  void _buildTown() {
    // Every house shares these two meshes and their materials, so the whole
    // town is drawn with one instanced draw call per mesh.
    final walls = CuboidMesh(
      size: Vector3(0.56, 1, 0.56),
      material: SpatialMaterial(metallic: 0, roughness: 0.9),
    );
    final roofs = ConeMesh(
      radius: 0.47,
      height: House.roofHeight,
      segments: 4,
      material: SpatialMaterial(metallic: 0, roughness: 0.7),
    );
    const wallColors = [
      Color(0xFFE8DCC4),
      Color(0xFFD9C3A0),
      Color(0xFFC9D6DF),
      Color(0xFFE4C9B6),
      Color(0xFFF2E9D8),
    ];
    const roofColors = [
      Color(0xFFB0412E),
      Color(0xFF8E3B2C),
      Color(0xFF4F6D7A),
      Color(0xFF6B4E3D),
    ];
    final random = math.Random(7);
    for (var i = 0; i < boardSize; i++) {
      for (var j = 0; j < boardSize; j++) {
        final landmark = _landmarks.containsKey((i, j));
        houses.add(
          House(
            cell: (i, j),
            walls: walls,
            roof: roofs,
            height: landmark ? 1.1 : 0.35 + random.nextDouble() * 0.45,
            wallColor: wallColors[random.nextInt(wallColors.length)],
            roofColor: roofColors[random.nextInt(roofColors.length)],
          ),
        );
      }
    }
    layer.world.addAll([
      LightComponent.ambient(intensity: 0.45),
      // Far away, so that it lights the whole town alike, from the right of
      // the viewer: the two visible walls of each house get distinct shades.
      LightComponent.point(position: Vector3(46, 14, 30), intensity: 5000),
      ...houses,
    ]);
  }

  TextComponent _label(String text, House? house) {
    return TextComponent(
      text: text,
      anchor: Anchor.bottomCenter,
      position: house == null ? Vector2.zero() : _labelPosition(house),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          shadows: [Shadow(blurRadius: 3)],
        ),
      ),
    );
  }

  /// Where a label above [house] goes, in the layer's coordinates.
  Vector2 _labelPosition(House house) {
    final (i, j) = house.cell;
    return layer.scenePointToLocal(Vector3(i + 0.5, j + 0.5, house.top + 0.1));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Keep the labels the same size on screen at every zoom.
    final labelScale = 1 / camera.viewfinder.zoom;
    for (final label in _labels) {
      label.scale.setAll(labelScale);
    }
    _selectionLabel.scale.setAll(labelScale);
  }

  void _zoomTo(double zoom) {
    camera.viewfinder.zoom = zoom.clamp(minZoom, maxZoom);
  }

  @override
  void onScroll(ScrollEvent event) {
    _zoomTo(
      camera.viewfinder.zoom *
          math.pow(1.0015, -event.scrollDelta.y.clamp(-200, 200)),
    );
  }

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    _startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    _zoomTo(_startZoom * event.scale);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    // A pinch also drags: do not pan while zooming.
    if (isScaling) {
      return;
    }
    camera.moveBy(-event.localDelta / camera.viewfinder.zoom);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Screen -> 2D world -> the layer's coordinates -> a ray into the scene.
    final local = layer.absoluteToLocal(
      camera.globalToLocal(event.canvasPosition),
    );
    final ray = layer.localPointToRay(local, output: _ray);
    House? nearest;
    var nearestDistance = double.infinity;
    for (final house in houses) {
      final distance = ray.intersectsWithAabb3(house.pickBox);
      if (distance != null && distance < nearestDistance) {
        nearest = house;
        nearestDistance = distance;
      }
    }
    _select(nearest);
  }

  final Ray _ray = Ray();

  void _select(House? house) {
    _selected?.highlighted = false;
    _selected = house;
    if (house == null) {
      _selectionLabel.text = '';
      return;
    }
    house.highlighted = true;
    final (i, j) = house.cell;
    // Landmarks have a label already.
    _selectionLabel
      ..text = _landmarks.containsKey(house.cell) ? '' : 'House $i, $j'
      ..position = _labelPosition(house);
  }
}
