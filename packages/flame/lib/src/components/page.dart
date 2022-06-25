
import 'package:flame/src/components/component.dart';
import 'package:flame/src/components/mixins/parent_is_a.dart';
import 'package:flame/src/components/navigator.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:meta/meta.dart';

class Page extends PositionComponent with ParentIsA<Navigator> {
  Page({
    required this.name,
    this.builder,
    this.transparent = false,
  });

  final String name;

  final Component Function()? builder;

  /// If true, then the page below this one will continue to be rendered when
  /// this page becomes active. If false, then this page is assumed to
  /// completely obscure any page that would be underneath, and therefore the
  /// page underneath doesn't need to be rendered.
  final bool transparent;

  @internal
  Component build() {
    assert(
      builder != null,
      'Either provide `builder` in the constructor, or override the build() '
      'method',
    );
    return builder!();
  }
}
