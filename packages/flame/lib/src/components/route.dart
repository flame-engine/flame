import 'dart:ui';

import 'package:flame/src/components/component.dart';
import 'package:flame/src/components/mixins/parent_is_a.dart';
import 'package:flame/src/components/navigator.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/page_render_effect.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

class Route extends PositionComponent with ParentIsA<Navigator> {
  Route({
    Component Function()? builder,
    this.transparent = false,
  }) : _builder = builder;

  /// If true, then the route below this one will continue to be rendered when
  /// this route becomes active. If false, then this route is assumed to
  /// completely obscure any route that would be underneath, and therefore the
  /// route underneath doesn't need to be rendered.
  final bool transparent;

  double pushTransitionDuration = 0;

  double popTransitionDuration = 0;

  final Component Function()? _builder;

  /// This method is invoked when the route is pushed on top of the
  /// [Navigator]'s stack.
  void onPush(Route? previousRoute) {}

  void onPop(Route previousRoute) {}

  Component build() {
    assert(
      _builder != null,
      'Either provide `builder` in the constructor, or override the build() '
      'method',
    );
    return _builder!();
  }

  double timeSpeed = 1.0;

  void stopTime() => timeSpeed = 0;

  void resumeTime() => timeSpeed = 1.0;

  void addRenderEffect(PageRenderEffect effect) => _renderEffect = effect;

  void removeRenderEffect() => _renderEffect = null;

  //#region Implementation methods

  @internal
  bool get isBuilt => _page != null;

  @internal
  bool isRendered = true;

  Component? _page;

  PageRenderEffect? _renderEffect;

  @internal
  void didPush(Route? previousRoute) {
    _page ??= build()..addToParent(this);
    onPush(previousRoute);
  }

  @internal
  void didPop(Route previousRoute) => onPop(previousRoute);

  @override
  void renderTree(Canvas canvas) {
    if (isRendered) {
      if (_renderEffect != null) {
        final useCanvas = _renderEffect!.preprocessCanvas(canvas);
        super.renderTree(useCanvas);
        _renderEffect!.postprocessCanvas(canvas);
      } else {
        super.renderTree(canvas);
      }
    }
  }

  @override
  void updateTree(double dt) {
    if (timeSpeed > 0) {
      super.updateTree(dt * timeSpeed);
    }
  }

  @override
  Iterable<Component> componentsAtPoint(
    Vector2 point, [
    List<Vector2>? nestedPoints,
  ]) {
    if (isRendered) {
      return super.componentsAtPoint(point, nestedPoints);
    } else {
      return const Iterable<Component>.empty();
    }
  }

  //#endregion
}
