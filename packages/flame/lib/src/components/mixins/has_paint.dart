import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/palette.dart';
import 'package:meta/meta.dart';

/// Adds a collection of paints and paint layers to a component
///
/// Component will always have a main Paint that can be accessed
/// by the [paint] attribute and other paints can be manipulated/accessed
/// using [getPaint], [setPaint] and [deletePaint] by a paintId of generic type
/// [T], that can be omitted if the component only has one paint.
/// [paintLayers] paints should be drawn in list order during the render. The
/// main Paint is the first element.
mixin HasPaint<T extends Object> on Component
    implements OpacityProvider, PaintProvider {
  late final Map<T, Paint> _paints = {};

  @override
  Paint paint = BasicPalette.white.paint();

  @internal
  List<Paint>? paintLayersInternal;

  /// Gets a paint from the collection.
  ///
  /// Returns the main paint if no [paintId] is provided.
  Paint getPaint([T? paintId]) {
    if (paintId == null) {
      return paint;
    }

    final _paint = _paints[paintId];

    if (_paint == null) {
      throw ArgumentError('No Paint found for $paintId');
    }

    return _paint;
  }

  /// Sets a paint on the collection.
  void setPaint(T paintId, Paint paint) {
    _paints[paintId] = paint;
  }

  /// Removes a paint from the collection.
  void deletePaint(T paintId) {
    _paints.remove(paintId);
  }

  /// List of paints to use (in order) during render.
  List<Paint> get paintLayers {
    if (!hasPaintLayers) {
      return paintLayersInternal = [];
    }
    return paintLayersInternal!;
  }

  set paintLayers(List<Paint> paintLayers) {
    paintLayersInternal = paintLayers;
  }

  /// Whether there are any paint layers defined for the component.
  bool get hasPaintLayers => paintLayersInternal?.isNotEmpty ?? false;

  /// Manipulate the paint to make it fully transparent.
  void makeTransparent({T? paintId}) {
    setOpacity(0, paintId: paintId);
  }

  /// Manipulate the paint to make it fully opaque.
  void makeOpaque({T? paintId}) {
    setOpacity(1, paintId: paintId);
  }

  /// Changes the opacity of the paint.
  void setOpacity(double opacity, {T? paintId}) {
    if (opacity < 0 || opacity > 1) {
      throw ArgumentError('Opacity needs to be between 0 and 1');
    }

    setColor(getPaint(paintId).color.withOpacity(opacity), paintId: paintId);
  }

  /// Returns the current opacity.
  double getOpacity({T? paintId}) {
    return getPaint(paintId).color.opacity;
  }

  /// Changes the opacity of the paint.
  void setAlpha(int alpha, {T? paintId}) {
    if (alpha < 0 || alpha > 255) {
      throw ArgumentError('Alpha needs to be between 0 and 255');
    }

    setColor(getPaint(paintId).color.withAlpha(alpha), paintId: paintId);
  }

  /// Returns the current opacity.
  int getAlpha({T? paintId}) {
    return getPaint(paintId).color.alpha;
  }

  /// Shortcut for changing the color of the paint.
  void setColor(Color color, {T? paintId}) {
    getPaint(paintId).color = color;
  }

  /// Applies a color filter to the paint which will make
  /// things rendered with the paint looking like it was
  /// tinted with the given color.
  void tint(Color color, {T? paintId}) {
    getPaint(paintId).colorFilter = ColorFilter.mode(color, BlendMode.srcATop);
  }

  @override
  double get opacity => paint.color.opacity;

  @override
  set opacity(double value) {
    paint.color = paint.color.withOpacity(value);
    for (final paint in _paints.values) {
      paint.color = paint.color.withOpacity(value);
    }
  }

  /// Creates an [OpacityProvider] for given [paintId] and can be used as
  /// `target` for [OpacityEffect].
  OpacityProvider opacityProviderOf(T paintId) {
    return _ProxyOpacityProvider(paintId, this);
  }

  /// Creates an [OpacityProvider] for given list of [paintIds] and can be
  /// used as `target` for [OpacityEffect].
  ///
  /// When opacities of all the given [paintIds] are not same, this provider
  /// directly effects opacity of the most opaque paint. Additionally, it
  /// modifies other paints such that their respective opacity ratio with most
  /// opaque paint is maintained.
  ///
  /// If [paintIds] is null or empty, all the paints are used for creating the
  /// [OpacityProvider].
  ///
  /// Note: Each call results in a new [OpacityProvider] and hence the cached
  /// opacity ratios are calculated using opacities when this method was called.
  OpacityProvider opacityProviderOfList({
    List<T?>? paintIds,
    bool includeLayers = true,
  }) {
    return _MultiPaintOpacityProvider(
      paintIds ?? (List<T?>.from(_paints.keys)..add(null)),
      includeLayers,
      this,
    );
  }
}

class _ProxyOpacityProvider<T extends Object> implements OpacityProvider {
  _ProxyOpacityProvider(this.paintId, this.target);

  final T paintId;
  final HasPaint<T> target;

  @override
  double get opacity => target.getOpacity(paintId: paintId);

  @override
  set opacity(double value) => target.setOpacity(value, paintId: paintId);
}

class _MultiPaintOpacityProvider<T extends Object> implements OpacityProvider {
  _MultiPaintOpacityProvider(this.paintIds, this.includeLayers, this.target) {
    final maxOpacity = opacity;

    _opacityRatios = [
      for (final paintId in paintIds)
        target.getOpacity(paintId: paintId) / maxOpacity,
    ];
    _layerOpacityRatios = target.paintLayersInternal
        ?.map(
          (paint) => paint.color.opacity / maxOpacity,
        )
        .toList(growable: false);
  }

  final List<T?> paintIds;
  final HasPaint<T> target;
  final bool includeLayers;
  late final List<double> _opacityRatios;
  late final List<double>? _layerOpacityRatios;

  @override
  double get opacity {
    var maxOpacity = 0.0;

    for (final paintId in paintIds) {
      maxOpacity = max(target.getOpacity(paintId: paintId), maxOpacity);
    }
    if (includeLayers) {
      target.paintLayersInternal?.forEach(
        (paint) => maxOpacity = max(paint.color.opacity, maxOpacity),
      );
    }

    return maxOpacity;
  }

  @override
  set opacity(double value) {
    for (var i = 0; i < paintIds.length; ++i) {
      target.setOpacity(
        value * _opacityRatios.elementAt(i),
        paintId: paintIds.elementAt(i),
      );
    }
    if (includeLayers) {
      final paintLayersInternal = target.paintLayersInternal;
      for (var i = 0; i < (paintLayersInternal?.length ?? 0); ++i) {
        paintLayersInternal![i].color = paintLayersInternal[i]
            .color
            .withOpacity(value * _layerOpacityRatios![i]);
      }
    }
  }
}
