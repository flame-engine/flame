import 'package:flame/src/anchor.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:vector_math/vector_math_64.dart';

class AlignComponent extends PositionComponent {
  AlignComponent({
    required this.child,
    required this.alignment,
    this.widthFactor,
    this.heightFactor,
    bool keepChildAnchor = false,
  }) {
    add(child);
    if (!keepChildAnchor) {
      child.anchor = alignment;
    }
  }

  final PositionComponent child;
  final Anchor alignment;
  final double? widthFactor;
  final double? heightFactor;

  @override
  set size(Vector2 value) {
    throw UnsupportedError('The size of AlignComponent cannot be set directly');
  }

  @override
  void onMount() {
    assert(
      parent is SizeProvider,
      "An AlignComponent's parent must have a size",
    );
  }

  @override
  void onParentResize(Vector2 maxSize) {
    super.size = Vector2(
      widthFactor == null? maxSize.x : child.size.x * widthFactor!,
      heightFactor == null? maxSize.y : child.size.y * heightFactor!,
    );
    child.position = Vector2(size.x * alignment.x, size.y * alignment.y);
  }
}
