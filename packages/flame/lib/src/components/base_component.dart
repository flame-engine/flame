import 'dart:ui';

import 'package:meta/meta.dart';

import '../../game.dart';
import '../../input.dart';
import '../extensions/vector2.dart';
import '../text.dart';
import 'component.dart';

/// This can be extended to represent a basic Component for your game.
///
/// The difference between this and [Component] is that the [BaseComponent]
/// implements the [update] and [render] methods, meanwhile you have to do that
/// yourself in [Component].
class BaseComponent extends Component {
  /// This is set by the BaseGame to tell this component to render additional
  /// debug information, like borders, coordinates, etc.
  /// This is very helpful while debugging. Set your BaseGame debugMode to true.
  /// You can also manually override this for certain components in order to
  /// identify issues.
  bool debugMode = false;

  /// How many decimal digits to print when displaying coordinates in the
  /// debug mode. Setting this to null will suppress all coordinates from
  /// the output.
  int? get debugCoordinatesPrecision => 0;

  Color debugColor = const Color(0xFFFF00FF);

  Paint get debugPaint => Paint()
    ..color = debugColor
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  TextPaint get debugTextPaint => TextPaint(
        config: TextPaintConfig(
          color: debugColor,
          fontSize: 12,
        ),
      );

  BaseComponent({int? priority}) : super(priority: priority);

  /// This method is called periodically by the game engine to request that your
  /// component updates itself.
  ///
  /// The time [dt] in seconds (with microseconds precision provided by Flutter)
  /// since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update
  /// your state considering this.
  /// All components on [BaseGame] are always updated by the same amount. The
  /// time each one takes to update adds up to the next update cycle.
  @mustCallSuper
  @override
  void update(double dt) {
    children.updateComponentList();
    children.forEach((c) => c.update(dt));
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    preRender(canvas);
  }

  @mustCallSuper
  @override
  void renderTree(Canvas canvas) {
    render(canvas);
    postRender(canvas);
    children.forEach((c) {
      canvas.save();
      c.renderTree(canvas);
      canvas.restore();
    });

    // Any debug rendering should be rendered on top of everything
    if (debugMode) {
      renderDebugMode(canvas);
    }
  }

  /// A render cycle callback that runs before the component and its children
  /// has been rendered.
  @protected
  void preRender(Canvas canvas) {}

  /// A render cycle callback that runs after the component has been
  /// rendered, but before any children has been rendered.
  void postRender(Canvas canvas) {}

  void renderDebugMode(Canvas canvas) {}

  @protected
  Vector2 eventPosition(PositionInfo info) {
    return isHud ? info.eventPosition.widget : info.eventPosition.game;
  }
}
