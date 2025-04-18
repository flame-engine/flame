import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/post_process.dart';
import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/components/core/component_render_context.dart';
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:meta/meta.dart';

/// A [PositionComponent] that applies a post-processing effect to its children.
/// This component is useful for applying effects such as bloom, blur, other
/// fragment shader effects to a group of components.
///
/// As opposed to [CameraComponent.postProcess], this only applies the post
/// process to the children of this component. This means that if you want to
/// apply a post process to the whole screen, you should use
/// [CameraComponent.postProcess] instead.
///
/// During the rendering process, children of this component can verify if they
/// are being rendered within a post process by using
/// [PostProcessingContextFinder.findPostProcessFromContext].
///
/// See also:
/// - [PostProcess] for the base class for post processes and more information
/// about how to create them.
/// - [PostProcessGroup] for a group of post processes that will be applied
/// in parallel
/// - [CameraComponent.postProcess] for a way to apply post processes to the
/// whole screen.
class PostProcessComponent<T extends PostProcess> extends PositionComponent {
  PostProcessComponent({
    required this.postProcess,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });

  @override
  PostProcessComponentRenderContext<T> get renderContext => _renderContext;

  final _renderContext =
      PostProcessComponentRenderContext<T>(postProcess: null);

  final T postProcess;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await postProcess.onLoad();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    postProcess.update(dt);
  }

  Rect get _boundingRectOfChildren {
    final rectChildren = children.query<PositionComponent>();

    if (rectChildren.isEmpty) {
      return Rect.zero;
    }

    return rectChildren
        .map((child) => child.toRect())
        .reduce((a, b) => a.expandToInclude(b));
  }

  @override
  NotifyingVector2 get size {
    final superSize = super.size;
    if (superSize.isZero() && hasChildren) {
      super.size.setFrom(_boundingRectOfChildren.size.toVector2());
    }
    return superSize;
  }

  @override
  @mustCallSuper
  void renderTree(Canvas canvas) {
    decorator.applyChain(
      (canvas) {
        postProcess.render(
          canvas,
          size,
          super.renderTreeWithoutDecorator,
          (context) {
            _renderContext.postProcess = postProcess;
          },
        );
      },
      canvas,
    );
  }
}

class PostProcessComponentRenderContext<T extends PostProcess>
    extends ComponentRenderContext {
  PostProcessComponentRenderContext({
    required this.postProcess,
  });

  T? postProcess;
}

extension PostProcessingContextFinder on Component {
  T? findPostProcessFromContext<T extends PostProcess>() {
    final closestContext =
        findRenderContext<PostProcessComponentRenderContext<T>>();
    if (closestContext != null) {
      return closestContext.postProcess;
    }
    final contextInCamera =
        findRenderContext<CameraRenderContext>()?.currentPostProcess;
    if (contextInCamera is T) {
      return contextInCamera;
    }

    return null;
  }
}
