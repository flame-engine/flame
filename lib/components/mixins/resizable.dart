import 'package:meta/meta.dart';
import '../../extensions/vector2.dart';
import '../component.dart';

/// A [Component] mixin to make your component keep track of the size of the game viewport.
mixin Resizable on Component {
  /// This is the current updated screen size.
  Vector2 gameSize;

  /// Implementation provided by this mixin to the resize hook.
  /// This is a hook called by [BaseGame] to let this component know that the screen (or flame draw area) has been update.
  @override
  @mustCallSuper
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    this.gameSize = gameSize;
  }
}
