import 'dart:ui' as ui;

import 'package:flame/components.dart' as flame;
import 'package:flame/game.dart';
import 'package:flame_studio/component_editor/widgets/preview/flame_mapping.dart';
import 'package:flame_studio/component_editor/widgets/preview/preview_hitboxes.dart';
import 'package:flame_studio/component_editor/widgets/preview/selection_highlight.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/painting.dart';

/// {@template component_preview_game}
/// A Flame game that renders a [Component] and its children, centered on
/// screen and scaled by [zoom], and highlights one of them. Hitboxes are
/// outlined while [areHitboxesVisible], and sprites draw their [spriteImages].
///
/// The game only renders: the component being edited is owned by the
/// `ComponentEditorBloc` and pushed here with [show].
/// {@endtemplate}
class ComponentPreviewGame({
  required var Component _component,
  var List<int>? _highlightedPath,
  var double _zoom = 1,
  var bool _areHitboxesVisible = true,
  var Map<String, ui.Image> _spriteImages = const {},
}) extends FlameGame {
  /// {@macro component_preview_game}
  this;

  late flame.PositionComponent _preview;

  /// The Flame component currently rendering the previewed root
  /// [Component]. Its children render the [Component] children.
  flame.PositionComponent get preview => _preview;

  /// Draws the border around the highlighted node.
  final highlight = SelectionHighlight();

  /// How much the preview is scaled, `1` being the actual size. It zooms
  /// around the center of the screen, where the root is.
  double get zoom => _zoom;
  set zoom(double value) {
    _zoom = value;
    if (isLoaded) {
      _applyZoom();
    }
  }

  /// Whether the hitboxes are outlined (see [PreviewHitbox]).
  bool get areHitboxesVisible => _areHitboxesVisible;
  set areHitboxesVisible(bool value) {
    _areHitboxesVisible = value;
    if (isLoaded) {
      _applyHitboxesVisibility();
    }
  }

  /// The images sprites draw, by asset path (see [ComponentSprite.image]).
  Map<String, ui.Image> get spriteImages => _spriteImages;
  set spriteImages(Map<String, ui.Image> value) {
    _spriteImages = value;
    if (isLoaded) {
      applyTree(_preview, _component, images: _spriteImages);
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF1E1E1E);

  @override
  void onLoad() {
    world.add(highlight);
    _applyZoom();
    _rebuild();
  }

  /// Renders [component] instead of the current one, highlighting the node
  /// at [highlightedPath] (see [ComponentTree]), if any.
  ///
  /// Only nodes with a size, a radius or vertices ([SizedComponent],
  /// [RadiusComponent], [VerticesComponent]) are highlighted.
  ///
  /// The existing Flame components are updated in place, unless components
  /// were added, removed or changed type, or polygons got new vertices (see
  /// [haveSameShape]).
  void show(Component component, {List<int>? highlightedPath}) {
    final previous = _component;
    _component = component;
    _highlightedPath = highlightedPath;
    if (!isLoaded) {
      return;
    }
    if (haveSameShape(previous, component)) {
      applyTree(_preview, component, images: _spriteImages);
      _updateHighlight();
    } else {
      _rebuild();
    }
  }

  void _applyZoom() {
    camera.viewfinder.zoom = _zoom;
    highlight.zoom = _zoom;
  }

  void _rebuild() {
    if (isLoaded) {
      _preview.removeFromParent();
    }
    _preview = buildFlameComponent(_component, images: _spriteImages);
    world.add(_preview);
    _applyHitboxesVisibility();
    _updateHighlight();
  }

  void _applyHitboxesVisibility() {
    for (final hitbox
        in _preview.descendants(includeSelf: true).whereType<PreviewHitbox>()) {
      hitbox.isVisible = _areHitboxesVisible;
    }
  }

  void _updateHighlight() {
    final path = _highlightedPath;
    highlight.target =
        path != null &&
            _component.hasNodeAt(path) &&
            _hasBounds(_component.nodeAt(path))
        ? flameNodeAt(_preview, path)
        : null;
  }

  static bool _hasBounds(Component node) {
    return node is SizedComponent ||
        node is RadiusComponent ||
        node is VerticesComponent;
  }
}
